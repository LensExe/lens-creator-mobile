import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';

class AvailabilityOverview extends StatelessWidget {
  const AvailabilityOverview({
    super.key,
    required this.weeklyHours,
    required this.upcomingBookings,
    required this.busySlots,
    required this.openDays,
  });

  final String weeklyHours;
  final int upcomingBookings;
  final int busySlots;
  final int openDays;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.snow,
          borderRadius: BorderRadius.circular(AppTokens.radiusCard),
          border: Border.all(color: AppColors.fog),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
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
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: openDays > 0 ? AppColors.success : AppColors.ash,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    openDays > 0
                        ? 'Lịch định kỳ đã thiết lập'
                        : 'Chưa có ngày nhận lịch',
                    style: const TextStyle(
                      color: AppColors.obsidian,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '$openDays/7 ngày',
                  style: TextStyle(
                    color: openDays > 0 ? AppColors.success : AppColors.steel,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 11),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.mist,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: AppColors.ember,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Khách có thể đặt từ 07:00 đến trước 24:00. Các khung đã có khách sẽ được khóa.',
                      style: TextStyle(
                        color: AppColors.slate,
                        fontSize: 10.5,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 11),
      LayoutBuilder(
        builder: (context, constraints) {
          final tileWidth = (constraints.maxWidth - 10) / 2;
          return GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: tileWidth / 112,
            children: [
              _MetricCard(
                icon: Icons.schedule_rounded,
                value: weeklyHours,
                unit: 'giờ',
                label: 'Giờ mở mỗi tuần',
                caption: 'Theo lịch định kỳ',
                accent: AppColors.ember,
                tint: const Color(0xFFFFF0E8),
              ),
              _MetricCard(
                icon: Icons.event_available_outlined,
                value: '$upcomingBookings',
                unit: 'buổi',
                label: 'Lịch khách 7 ngày tới',
                caption: 'Các khung đã được giữ',
                accent: const Color(0xFF426D9C),
                tint: const Color(0xFFEAF2FA),
              ),
              _MetricCard(
                icon: Icons.block_outlined,
                value: '$busySlots',
                unit: 'khung',
                label: 'Khung bận cá nhân',
                caption: 'Theo ngoại lệ đã cài',
                accent: const Color(0xFF6B7280),
                tint: const Color(0xFFF0F1F3),
              ),
              _MetricCard(
                icon: Icons.calendar_view_week_outlined,
                value: '$openDays/7',
                unit: 'ngày',
                label: 'Ngày nhận lịch',
                caption: 'Trong tuần định kỳ',
                accent: const Color(0xFF16865A),
                tint: const Color(0xFFE8F6EF),
              ),
            ],
          );
        },
      ),
    ],
  );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.value,
    required this.unit,
    required this.label,
    required this.caption,
    required this.accent,
    required this.tint,
  });

  final IconData icon;
  final String value;
  final String unit;
  final String label;
  final String caption;
  final Color accent;
  final Color tint;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.snow,
      borderRadius: BorderRadius.circular(AppTokens.radiusCard),
      border: Border.all(color: AppColors.fog),
      boxShadow: const [
        BoxShadow(
          color: Color(0x05000000),
          blurRadius: 10,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 29,
          height: 29,
          decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
          child: Icon(icon, color: accent, size: 16),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.obsidian,
                      fontSize: 21,
                      height: 1,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: const TextStyle(
                    color: AppColors.steel,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.graphite,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.ash, fontSize: 9),
            ),
          ],
        ),
      ],
    ),
  );
}
