import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class AchievementStatsSection extends StatelessWidget {
  const AchievementStatsSection({
    super.key,
    required this.completedSessions,
    required this.fiveStarPct,
    required this.returningClients,
    required this.cancelRate,
  });

  final int completedSessions;
  final int fiveStarPct;
  final int returningClients;
  final int cancelRate;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const Icon(Icons.verified_outlined, color: AppColors.slate, size: 21),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              'Thành tích nổi bật',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.obsidian,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Text(
            'Tổng quan hoạt động',
            style: TextStyle(color: AppColors.steel, fontSize: 10),
          ),
        ],
      ),
      const SizedBox(height: 11),
      LayoutBuilder(
        builder: (context, constraints) {
          const spacing = 9.0;
          final cardWidth = (constraints.maxWidth - spacing * 2) / 3;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: cardWidth,
                child: _MetricCard(
                  value: '$completedSessions',
                  label: 'Buổi chụp',
                  detail: 'Hoàn thành',
                ),
              ),
              const SizedBox(width: spacing),
              SizedBox(
                width: cardWidth,
                child: _MetricCard(
                  value: '$fiveStarPct%',
                  label: 'Đánh giá 5 sao',
                  detail: 'Tỷ lệ',
                ),
              ),
              const SizedBox(width: spacing),
              SizedBox(
                width: cardWidth,
                child: _MetricCard(
                  value: '$returningClients',
                  label: 'Khách quay lại',
                  detail: 'Khách hàng',
                ),
              ),
            ],
          );
        },
      ),
      const SizedBox(height: 9),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.snow,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.fog.withValues(alpha: 0.8)),
        ),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'Tỷ lệ huỷ lịch',
                style: TextStyle(color: AppColors.graphite, fontSize: 12),
              ),
            ),
            Text(
              '$cancelRate%',
              style: TextStyle(
                color: cancelRate > 5
                    ? AppColors.destructive
                    : AppColors.obsidian,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
      if (cancelRate > 5) ...[
        const SizedBox(height: 9),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.warningSoft,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.warning,
                size: 18,
              ),
              SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Tỷ lệ huỷ đang cao. Cần cải thiện để bảo vệ thứ hạng.',
                  style: TextStyle(
                    color: AppColors.warning,
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ],
  );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.value,
    required this.label,
    required this.detail,
  });

  final String value;
  final String label;
  final String detail;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 106),
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 11),
    decoration: BoxDecoration(
      color: AppColors.snow,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.fog.withValues(alpha: 0.8)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0809090B),
          blurRadius: 10,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            maxLines: 1,
            style: const TextStyle(
              color: AppColors.obsidian,
              fontSize: 22,
              height: 1.15,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.slate,
            fontSize: 10,
            height: 1.25,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          detail,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.ember,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
