import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import 'storage_provider.dart';

enum _GalleryFilter { all, open, attention }

class StorageScreen extends ConsumerStatefulWidget {
  const StorageScreen({super.key});

  @override
  ConsumerState<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends ConsumerState<StorageScreen> {
  _GalleryFilter filter = _GalleryFilter.all;

  @override
  Widget build(BuildContext context) {
    final tier = ref.watch(storageTierProvider);
    final plan = storagePlans.firstWhere((item) => item.tier == tier);
    final galleries = ref.watch(storageGalleriesProvider);
    final usedBytes = galleries.fold<int>(
      0,
      (sum, item) => sum + item.sizeBytes,
    );
    final capacityBytes =
        plan.quotaGb *
        1024 *
        storageMb *
        (galleries.isEmpty ? 1 : galleries.length);
    final fraction = (usedBytes / capacityBytes).clamp(0.0, 1.0);
    final visible = switch (filter) {
      _GalleryFilter.all => galleries,
      _GalleryFilter.open => galleries.where((item) => !item.locked).toList(),
      _GalleryFilter.attention =>
        galleries.where((item) => item.needsAttention).toList(),
    };
    return Scaffold(
      appBar: AppBar(title: const Text('Lưu trữ ảnh')),
      body: ListView(
        padding: AppTokens.pagePadding,
        children: [
          Text(
            'Quản lý dung lượng, bộ sưu tập đã giao và thời hạn lưu ảnh.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gói hiện tại · ${plan.name}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${formatStorageBytes(usedBytes)} / ${formatStorageBytes(capacityBytes)}',
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: fraction,
                    color: AppColors.ember,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${galleries.length} buổi đã giao ảnh · ${plan.quotaGb}GB mỗi buổi',
                    style: const TextStyle(color: AppColors.steel),
                  ),
                  Text(
                    plan.retentionDays == null
                        ? 'Lưu dài hạn khi còn duy trì gói'
                        : 'Lưu ${plan.retentionDays} ngày',
                    style: const TextStyle(color: AppColors.steel),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Gói lưu trữ', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          for (final candidate in storagePlans)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            candidate.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        if (candidate.tier == tier)
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.ember,
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(candidate.price),
                    Text(
                      '${candidate.quotaGb}GB mỗi buổi · ${candidate.retentionDays == null ? 'Lưu dài hạn khi duy trì gói' : 'Lưu ${candidate.retentionDays} ngày'}',
                      style: const TextStyle(color: AppColors.steel),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: candidate.tier == tier
                          ? null
                          : () {
                              ref
                                  .read(storageTierProvider.notifier)
                                  .choose(candidate.tier);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Đã chuyển sang gói ${candidate.name}',
                                  ),
                                ),
                              );
                            },
                      child: Text(
                        candidate.tier == tier
                            ? 'Gói đang sử dụng'
                            : 'Chọn gói này',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 20),
          Text(
            'Bộ sưu tập đã giao',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final item in _GalleryFilter.values)
                ChoiceChip(
                  label: Text(switch (item) {
                    _GalleryFilter.all => 'Tất cả',
                    _GalleryFilter.open => 'Đang mở',
                    _GalleryFilter.attention => 'Cần chú ý',
                  }),
                  selected: filter == item,
                  onSelected: (_) => setState(() => filter = item),
                ),
            ],
          ),
          if (visible.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(28),
                child: Center(child: Text('Chưa có bộ sưu tập trong mục này')),
              ),
            ),
          for (final gallery in visible)
            Card(
              child: ListTile(
                isThreeLine: true,
                leading: Icon(
                  gallery.locked
                      ? Icons.lock_outline
                      : Icons.photo_library_outlined,
                ),
                title: Text(
                  '${gallery.booking.style} · ${gallery.booking.clientName}',
                ),
                subtitle: Text(
                  '${gallery.locked ? 'Đã khóa · ' : ''}${gallery.booking.deliveredPhotos} ảnh · ${formatStorageBytes(gallery.sizeBytes)}\n'
                  'Giao ${DateFormat('dd/MM/yyyy').format(gallery.deliveredAt)} · '
                  '${gallery.daysLeft == null
                      ? 'Dài hạn theo gói'
                      : gallery.daysLeft! <= 0
                      ? 'Đã hết hạn'
                      : 'Còn ${gallery.daysLeft} ngày'}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(
                  '/photographer_home/booking/${gallery.booking.id}/gallery',
                ),
              ),
            ),
        ],
      ),
    );
  }
}
