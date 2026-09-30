import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import 'storage_provider.dart';
import 'widgets/storage_empty_state.dart';
import 'widgets/storage_filter_tabs.dart';
import 'widgets/storage_gallery_card.dart';
import 'widgets/storage_plan_card.dart';
import 'widgets/storage_usage_card.dart';

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
    final visible = switch (filter) {
      _GalleryFilter.all => galleries,
      _GalleryFilter.open => galleries.where((item) => !item.locked).toList(),
      _GalleryFilter.attention =>
        galleries.where((item) => item.needsAttention).toList(),
    };
    final openCount = galleries.where((item) => !item.locked).length;
    final attentionCount = galleries
        .where((item) => item.needsAttention)
        .length;

    return Scaffold(
      backgroundColor: AppColors.mist,
      appBar: AppBar(
        title: const Text('Lưu trữ ảnh'),
        backgroundColor: AppColors.mist,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
            children: [
              const Text(
                'Quản lý dung lượng, bộ sưu tập đã giao và thời hạn lưu ảnh.',
                style: TextStyle(
                  color: AppColors.steel,
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 15),
              StorageUsageCard(
                plan: plan,
                usedBytes: usedBytes,
                capacityBytes: capacityBytes,
                galleryCount: galleries.length,
              ),
              const SizedBox(height: 22),
              const _StorageSectionHeading(
                title: 'Gói lưu trữ',
                subtitle: 'Dung lượng và thời hạn theo từng gói.',
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 220,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: storagePlans.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final candidate = storagePlans[index];
                    return StoragePlanCard(
                      plan: candidate,
                      selected: candidate.tier == tier,
                      onChoose: () {
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
                    );
                  },
                ),
              ),
              const SizedBox(height: 23),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Expanded(
                    child: _StorageSectionHeading(
                      title: 'Bộ sưu tập đã giao',
                      subtitle: 'Ảnh đã bàn giao cho khách hàng.',
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.snow,
                      borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                      border: Border.all(color: AppColors.fog),
                    ),
                    child: Text(
                      '${visible.length}/${galleries.length}',
                      style: const TextStyle(
                        color: AppColors.graphite,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 11),
              StorageFilterTabs(
                selectedIndex: _GalleryFilter.values.indexOf(filter),
                onSelected: (index) =>
                    setState(() => filter = _GalleryFilter.values[index]),
                options: [
                  StorageFilterOption(label: 'Tất cả', count: galleries.length),
                  StorageFilterOption(label: 'Đang mở', count: openCount),
                  StorageFilterOption(
                    label: 'Cần chú ý',
                    count: attentionCount,
                  ),
                ],
              ),
              const SizedBox(height: 11),
              if (visible.isEmpty)
                const StorageEmptyState()
              else
                for (final gallery in visible) ...[
                  StorageGalleryCard(gallery: gallery),
                  const SizedBox(height: 9),
                ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StorageSectionHeading extends StatelessWidget {
  const _StorageSectionHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: AppColors.obsidian,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        subtitle,
        style: const TextStyle(color: AppColors.steel, fontSize: 10),
      ),
    ],
  );
}
