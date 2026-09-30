import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/creator_section_header.dart';
import '../../../../core/widgets/creator_summary_strip.dart';

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
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const CreatorSectionHeader(title: 'Tổng quan lịch'),
      const SizedBox(height: 12),
      CreatorSummaryStrip(
        items: [
          CreatorSummaryItem('Giờ mở mỗi tuần', '$weeklyHours giờ'),
          CreatorSummaryItem('Lịch khách 7 ngày tới', '$upcomingBookings buổi'),
          CreatorSummaryItem('Khung bận cá nhân', '$busySlots khung'),
          CreatorSummaryItem('Ngày nhận lịch', '$openDays/7'),
        ],
      ),
      const SizedBox(height: 15),
      Text(
        openDays > 0
            ? 'Lịch định kỳ đã thiết lập · $openDays/7 ngày'
            : 'Chưa có ngày nhận lịch',
        style: const TextStyle(
          color: AppColors.graphite,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 5),
      const Text(
        'Khách có thể đặt từ 07:00 đến trước 24:00. Các khung đã có khách sẽ được khóa.',
        style: TextStyle(color: AppColors.steel, fontSize: 11, height: 1.4),
      ),
    ],
  );
}
