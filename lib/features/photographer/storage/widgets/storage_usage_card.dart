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
  });

  final StoragePlan plan;
  final int usedBytes;
  final int capacityBytes;
  final int galleryCount;

  @override
  Widget build(BuildContext context) {
    final ratio = capacityBytes == 0 ? 0.0 : usedBytes / capacityBytes;
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
    final retention = plan.retentionDays == null
        ? 'Lưu dài hạn khi duy trì gói'
        : 'Lưu ${plan.retentionDays} ngày';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        border: Border.all(color: AppColors.fog),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0E8),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.cloud_outlined,
                  color: AppColors.ember,
                  size: 19,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Gói hiện tại · ${plan.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.obsidian,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: statusBackground,
                  borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                ),
                child: Text(
                  overLimit
                      ? 'Vượt hạn mức'
                      : nearLimit
                      ? 'Sắp đầy'
                      : 'Đang sử dụng',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: Text(
                        formatStorageBytes(usedBytes),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.obsidian,
                          fontSize: 25,
                          height: 1,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.7,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '/ ${formatStorageBytes(capacityBytes)}',
                      style: const TextStyle(
                        color: AppColors.ash,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$percentage% đã dùng',
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTokens.radiusPill),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: ratio.clamp(0.0, 1.0),
              color: statusColor,
              backgroundColor: AppColors.mist,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppColors.fog),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 7,
            children: [
              _UsageDetail(
                icon: Icons.photo_library_outlined,
                label: '$galleryCount buổi đã giao ảnh',
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
