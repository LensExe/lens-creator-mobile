import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../storage_provider.dart';

class StorageUsageCard extends StatelessWidget {
  const StorageUsageCard({
    super.key,
    required this.plan,
    required this.usedBytes,
    required this.capacityBytes,
    required this.galleryCount,
    required this.onViewPlans,
  });

  final StoragePlan plan;
  final int usedBytes;
  final int capacityBytes;
  final int galleryCount;
  final VoidCallback onViewPlans;

  @override
  Widget build(BuildContext context) {
    final ratio = capacityBytes <= 0 ? 0.0 : usedBytes / capacityBytes;
    final percentage = (ratio * 100).round();
    final overLimit = ratio > 1;
    final nearLimit = ratio >= 0.8;
    final statusColor = overLimit
        ? AppColors.destructive
        : nearLimit
        ? AppColors.warning
        : AppColors.success;
    final statusBackground = overLimit
        ? const Color(0xFFFFECEA)
        : nearLimit
        ? const Color(0xFFFFF5E7)
        : const Color(0xFFE8F6EF);
    final statusLabel = overLimit
        ? '+${((ratio - 1) * 100).round()}% vượt hạn mức'
        : nearLimit
        ? 'Sắp đầy'
        : 'Đang sử dụng';
    final retention = plan.retentionDays == null
        ? 'Lưu dài hạn khi duy trì gói'
        : 'Lưu ${plan.retentionDays} ngày';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE7DE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_off_outlined,
                  color: AppColors.destructive,
                  size: 18,
                ),
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: Text(
                  'Dung lượng lưu trữ',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEEEF),
                  borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                ),
                child: Text(
                  'Gói ${plan.name}',
                  style: const TextStyle(
                    color: AppColors.graphite,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Text(
                formatStorageBytes(usedBytes),
                style: TextStyle(
                  color: overLimit ? AppColors.destructive : AppColors.ink,
                  fontSize: 29,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                ),
              ),
              Text(
                '/ ${formatStorageBytes(capacityBytes)}',
                style: const TextStyle(
                  color: AppColors.steel,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: overLimit ? statusColor : statusBackground,
                  borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: overLimit ? AppColors.snow : statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final safeRatio = ratio.clamp(0.0, 1.0);
              if (!overLimit) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                  child: SizedBox(
                    height: 10,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        const ColoredBox(color: Color(0xFFE8E8E9)),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: safeRatio,
                            child: const ColoredBox(color: AppColors.ember),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final overFraction = (ratio - 1) / ratio;
              final overFlex = (overFraction * 1000).round().clamp(1, 999);
              final baseFlex = 1000 - overFlex;
              final markerPosition = baseFlex / 1000;
              return ClipRRect(
                borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                child: SizedBox(
                  height: 10,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: baseFlex,
                            child: const ColoredBox(color: AppColors.ember),
                          ),
                          Expanded(
                            flex: overFlex,
                            child: const ColoredBox(
                              color: AppColors.destructive,
                            ),
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment(markerPosition * 2 - 1, 0),
                        child: Container(
                          width: 2,
                          height: 10,
                          color: AppColors.ink.withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 6),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 8,
            runSpacing: 2,
            children: [
              Text(
                'Đã dùng $percentage%',
                style: const TextStyle(
                  color: AppColors.steel,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Giới hạn: ${formatStorageBytes(capacityBytes)}',
                style: const TextStyle(
                  color: AppColors.steel,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (overLimit) ...[
            const SizedBox(height: 11),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFECEA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.destructive,
                    size: 18,
                  ),
                  SizedBox(width: 7),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Đã vượt dung lượng lưu trữ',
                          style: TextStyle(
                            color: AppColors.destructive,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Khách hàng có thể gặp gián đoạn khi xem hoặc tải ảnh độ phân giải cao.',
                          style: TextStyle(
                            color: Color(0xFF7F1D1D),
                            fontSize: 11,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.center,
            child: TextButton.icon(
              onPressed: onViewPlans,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.ember,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                visualDensity: VisualDensity.compact,
              ),
              iconAlignment: IconAlignment.end,
              icon: const Icon(Icons.arrow_downward_rounded, size: 16),
              label: const Text(
                'Xem các gói mở rộng dung lượng',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const Divider(height: 10, color: AppColors.fog),
          Wrap(
            spacing: 12,
            runSpacing: 7,
            children: [
              _UsageDetail(
                icon: Icons.photo_library_outlined,
                label: '$galleryCount bộ ảnh',
              ),
              _UsageDetail(
                icon: Icons.data_usage_outlined,
                label: '${plan.quotaGb} GB mỗi buổi',
              ),
              _UsageDetail(icon: Icons.schedule_rounded, label: retention),
            ],
          ),
        ],
      ),
    );
  }
}

class _UsageDetail extends StatelessWidget {
  const _UsageDetail({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 13, color: AppColors.ash),
      const SizedBox(width: 5),
      Text(
        label,
        style: const TextStyle(
          color: AppColors.steel,
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );
}
