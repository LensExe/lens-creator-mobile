import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/creator_page_header.dart';
import '../../../core/widgets/creator_section_header.dart';
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
  StorageTier? changingPlan;

  Future<void> _choosePlan(StorageTier tier) async {
    if (changingPlan != null) return;
    setState(() => changingPlan = tier);
    try {
      await ref.read(storageTierProvider.notifier).choose(tier);
      if (mounted) {
        final plan = storagePlans.firstWhere((item) => item.tier == tier);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã chuyển sang gói ${plan.name}')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể đổi gói lưu trữ: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => changingPlan = null);
    }
  }

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
      backgroundColor: AppColors.snow,
      appBar: AppBar(title: const Text('Lưu trữ ảnh')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppTokens.contentMaxWidth,
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
            children: [
              const CreatorPageHeader(
                title: 'Thư viện đã giao',
                subtitle: 'Dung lượng và thời hạn lưu ảnh của từng bộ sưu tập.',
              ),
              const SizedBox(height: 20),
              StorageUsageCard(
                plan: plan,
                usedBytes: usedBytes,
                capacityBytes: capacityBytes,
                galleryCount: galleries.length,
              ),
              const SizedBox(height: 22),
              const CreatorSectionHeader(
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
                      onChoose: () => _choosePlan(candidate.tier),
                      busy: changingPlan == candidate.tier,
                    );
                  },
                ),
              ),
              const SizedBox(height: 23),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Expanded(
                    child: CreatorSectionHeader(
                      title: 'Bộ sưu tập đã giao',
                      subtitle: 'Ảnh đã bàn giao cho khách hàng.',
                    ),
                  ),
                  Text(
                    '${visible.length}/${galleries.length}',
                    style: const TextStyle(
                      color: AppColors.graphite,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
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
                  const Divider(height: 1),
                ],
            ],
          ),
        ),
      ),
    );
  }
}
