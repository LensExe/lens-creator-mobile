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
    children: [
      _StatRow(label: 'Buổi chụp hoàn thành', value: '$completedSessions'),
      _StatRow(label: 'Đánh giá 5 sao', value: '$fiveStarPct%'),
      _StatRow(label: 'Khách hàng quay lại', value: '$returningClients'),
      _StatRow(
        label: 'Tỷ lệ huỷ lịch',
        value: '$cancelRate%',
        warning: cancelRate > 5,
        last: true,
      ),
      if (cancelRate > 5) ...[
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF2E2),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Text(
            'Tỷ lệ huỷ đang cao. Cần cải thiện để bảo vệ thứ hạng.',
            style: TextStyle(
              color: AppColors.warning,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ],
  );
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    this.warning = false,
    this.last = false,
  });

  final String label;
  final String value;
  final bool warning;
  final bool last;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14),
    decoration: BoxDecoration(
      border: last
          ? null
          : const Border(bottom: BorderSide(color: AppColors.fog)),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppColors.graphite, fontSize: 13),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: warning ? AppColors.destructive : AppColors.obsidian,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}
