import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Single-row availability summary strip matching the approved HTML design.
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
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. Days open
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.event_available_rounded,
                  size: 15,
                  color: AppColors.ember,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: RichText(
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF0F172A),
                      ),
                      children: [
                        TextSpan(
                          text: '$openDays/7 ',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const TextSpan(
                          text: 'ngày nhận',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              '·',
              style: TextStyle(
                color: Color(0xFFCBD5E1),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // 2. Weekly hours
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 15,
                  color: Color(0xFF94A3B8),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: RichText(
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF0F172A),
                      ),
                      children: [
                        TextSpan(
                          text: '$weeklyHours ',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const TextSpan(
                          text: 'giờ/tuần',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              '·',
              style: TextStyle(
                color: Color(0xFFCBD5E1),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // 3. Upcoming Bookings
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.photo_camera_rounded,
                  size: 15,
                  color: Color(0xFF059669),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: RichText(
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF047857),
                      ),
                      children: [
                        TextSpan(
                          text: '$upcomingBookings ',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const TextSpan(
                          text: 'ca chốt',
                          style: TextStyle(
                            color: Color(0xFF059669),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
