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
  final _plansSectionKey = GlobalKey();
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

  Future<void> _viewPlans() async {
    final target = _plansSectionKey.currentContext;
    if (target == null) return;
    await Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
      alignment: 0.08,
    );
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
      backgroundColor: const Color(0xFFF9F9FA),
      appBar: AppBar(
        title: const Text('Lưu trữ'),
        backgroundColor: const Color(0xFFF9F9FA),
        surfaceTintColor: Colors.transparent,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppTokens.contentMaxWidth,
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 14),
                child: Text(
                  'Quản lý dung lượng và các bộ ảnh đã bàn giao.',
                  style: TextStyle(
                    color: AppColors.steel,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
              StorageUsageCard(
                plan: plan,
                usedBytes: usedBytes,
                capacityBytes: capacityBytes,
                galleryCount: galleries.length,
                onViewPlans: _viewPlans,
              ),
              const SizedBox(height: 23),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Expanded(
                    child: Text(
                      'Bộ sưu tập đã giao',
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.25,
                      ),
                    ),
                  ),
                  Text(
                    '${galleries.length} bộ ảnh',
                    style: const TextStyle(
                      color: AppColors.steel,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
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
                    attention: true,
                  ),
                ],
              ),
              const SizedBox(height: 7),
              if (visible.isEmpty)
                const StorageEmptyState()
              else
                for (final gallery in visible)
                  StorageGalleryCard(gallery: gallery),
              const SizedBox(height: 20),
              Container(
                key: _plansSectionKey,
                child: const _StoragePlansHeading(),
              ),
              const SizedBox(height: 10),
              for (var index = 0; index < storagePlans.length; index++) ...[
                StoragePlanCard(
                  plan: storagePlans[index],
                  selected: storagePlans[index].tier == tier,
                  onChoose: () => _choosePlan(storagePlans[index].tier),
                  busy: changingPlan == storagePlans[index].tier,
                ),
                if (index < storagePlans.length - 1) const SizedBox(height: 9),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StoragePlansHeading extends StatelessWidget {
  const _StoragePlansHeading();

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Gói lưu trữ đề xuất',
        style: TextStyle(
          color: AppColors.ink,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.25,
        ),
      ),
      SizedBox(height: 3),
      Text(
        'Mở rộng dung lượng và thời hạn lưu trữ theo nhu cầu của bạn.',
        style: TextStyle(color: AppColors.steel, fontSize: 12, height: 1.4),
      ),
    ],
  );
}
