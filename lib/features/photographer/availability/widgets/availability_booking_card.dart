import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../domain/models/models.dart';
import '../../bookings/widgets/studio_booking_card.dart' show formatDong;

class AvailabilityBookingCard extends StatelessWidget {
  const AvailabilityBookingCard({super.key, required this.booking});

  final Booking booking;

  String get _initials {
    final name = booking.clientName.trim();
    if (name.isEmpty) return '?';
    final words = name.split(RegExp(r'\s+'));
    if (words.length == 1) return words.first.characters.first.toUpperCase();
    return '${words.first.characters.first}${words.last.characters.first}'
        .toUpperCase();
  }

  String get _timeRange {
    final start = booking.timeSlot;
    if (start == null) return 'Chưa có giờ';
    final parts = start.split(':');
    if (parts.length != 2) return start;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return start;
    final startMinutes = hour * 60 + minute;
    final duration = ((booking.durationHours ?? 2) * 60).round();
    final endMinutes = (startMinutes + duration).clamp(0, 24 * 60);
    final end =
        '${(endMinutes ~/ 60).toString().padLeft(2, '0')}:${(endMinutes % 60).toString().padLeft(2, '0')}';
    return '$start – $end';
  }

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.snow,
    borderRadius: BorderRadius.circular(15),
    child: InkWell(
      onTap: () => context.push('/photographer_home/booking/${booking.id}'),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFFFE0CF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.ember,
                  child: Text(
                    _initials,
                    style: const TextStyle(
                      color: AppColors.snow,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.clientName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.obsidian,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        booking.style,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.steel,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: const BoxDecoration(
                    color: AppColors.mist,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    color: AppColors.graphite,
                    size: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 14,
                  color: AppColors.ember,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    _timeRange,
                    style: const TextStyle(
                      color: AppColors.graphite,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  formatDong(booking.price),
                  style: const TextStyle(
                    color: AppColors.obsidian,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(height: 1, color: AppColors.fog),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 14,
                  color: AppColors.success,
                ),
                const SizedBox(width: 5),
                const Expanded(
                  child: Text(
                    'Đã khóa lịch nhận khách',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Text(
                  'Chi tiết',
                  style: TextStyle(
                    color: AppColors.ember,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.ember,
                  size: 13,
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
