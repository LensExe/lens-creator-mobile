import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../domain/models/models.dart';
import '../work_schedule.dart';
import 'availability_booking_card.dart';

class DayScheduleCard extends StatelessWidget {
  const DayScheduleCard({
    super.key,
    required this.date,
    required this.bookings,
    required this.workingSlots,
    required this.busySlots,
    required this.bookedSlots,
    required this.availableCount,
    required this.busyAllDay,
    required this.onPickDate,
    required this.onBusyAllDayChanged,
    required this.onBusySlotTap,
  });

  final DateTime date;
  final List<Booking> bookings;
  final Set<String> workingSlots;
  final Set<String> busySlots;
  final Set<String> bookedSlots;
  final int availableCount;
  final bool busyAllDay;
  final VoidCallback onPickDate;
  final ValueChanged<bool> onBusyAllDayChanged;
  final ValueChanged<String> onBusySlotTap;

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(date);
    return Container(
      padding: const EdgeInsets.all(14),
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
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ngoại lệ theo ngày',
                      style: TextStyle(
                        color: AppColors.obsidian,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Điều chỉnh lịch riêng cho ngày được chọn.',
                      style: const TextStyle(
                        color: AppColors.steel,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Chọn ngày',
                visualDensity: VisualDensity.compact,
                onPressed: onPickDate,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.mist,
                  foregroundColor: AppColors.graphite,
                ),
                icon: const Icon(Icons.calendar_month_outlined, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            dateLabel,
            style: const TextStyle(
              color: AppColors.obsidian,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              _SummaryPill(
                icon: Icons.lock_outline_rounded,
                label: '${bookings.length} buổi đã đặt',
                color: AppColors.ember,
                background: const Color(0xFFFFF0E8),
              ),
              _SummaryPill(
                icon: Icons.event_busy_outlined,
                label:
                    '${busySlots.intersection(workingSlots).length} khung bận',
                color: AppColors.graphite,
                background: AppColors.mist,
              ),
              _SummaryPill(
                icon: Icons.check_circle_outline_rounded,
                label: '$availableCount khung trống',
                color: const Color(0xFF16865A),
                background: const Color(0xFFE8F6EF),
              ),
            ],
          ),
          if (bookings.isNotEmpty) ...[
            const SizedBox(height: 13),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Buổi chụp đã đặt',
                    style: TextStyle(
                      color: AppColors.graphite,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '${bookings.length}',
                  style: const TextStyle(
                    color: AppColors.ash,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final booking in bookings) ...[
              AvailabilityBookingCard(booking: booking),
              const SizedBox(height: 8),
            ],
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppColors.fog),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.mist,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              children: [
                Container(
                  width: 31,
                  height: 31,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0E8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.event_busy_outlined,
                    color: AppColors.ember,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 9),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bận cả ngày',
                        style: TextStyle(
                          color: AppColors.graphite,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Đóng toàn bộ khung định kỳ trong ngày này',
                        style: TextStyle(color: AppColors.steel, fontSize: 9),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: busyAllDay,
                  activeTrackColor: AppColors.ember,
                  onChanged: workingSlots.isEmpty ? null : onBusyAllDayChanged,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Khung giờ trong ngày',
                  style: TextStyle(
                    color: AppColors.graphite,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(
                Icons.timelapse_rounded,
                color: AppColors.ash,
                size: 14,
              ),
              const SizedBox(width: 4),
              const Text(
                'Mỗi khung 30 phút',
                style: TextStyle(color: AppColors.ash, fontSize: 9),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (workingSlots.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.mist,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Ngày này đang nghỉ theo lịch định kỳ.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.steel, fontSize: 10),
              ),
            )
          else
            Wrap(
              spacing: 6,
              runSpacing: 7,
              children: [
                for (final slot in WorkSchedule.slots)
                  if (workingSlots.contains(slot))
                    _AvailabilityTimeChip(
                      label: slot,
                      booked: bookedSlots.contains(slot),
                      busy: busySlots.contains(slot),
                      onTap: () => onBusySlotTap(slot),
                    ),
              ],
            ),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 12,
            runSpacing: 7,
            children: [
              _Legend(
                icon: Icons.circle,
                color: AppColors.ember,
                label: 'Có khách',
              ),
              _Legend(
                icon: Icons.circle,
                color: AppColors.graphite,
                label: 'Bận cá nhân',
              ),
              _Legend(
                icon: Icons.circle,
                color: AppColors.success,
                label: 'Trống nhận khách',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(AppTokens.radiusPill),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _AvailabilityTimeChip extends StatelessWidget {
  const _AvailabilityTimeChip({
    required this.label,
    required this.booked,
    required this.busy,
    required this.onTap,
  });

  final String label;
  final bool booked;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background = booked
        ? const Color(0xFFFFF0E8)
        : busy
        ? AppColors.graphite
        : const Color(0xFFE8F6EF);
    final foreground = booked
        ? AppColors.ember
        : busy
        ? AppColors.snow
        : const Color(0xFF16865A);
    final border = booked
        ? const Color(0xFFFFD8C3)
        : busy
        ? AppColors.graphite
        : const Color(0xFFD5EFE0);
    return Semantics(
      button: !booked,
      label:
          '$label, ${booked
              ? 'đã có khách'
              : busy
              ? 'bận cá nhân'
              : 'còn trống'}',
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          onTap: booked ? null : onTap,
          borderRadius: BorderRadius.circular(9),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (booked) ...[
                  Icon(Icons.lock_rounded, size: 10, color: foreground),
                  const SizedBox(width: 4),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 9,
                    fontWeight: booked || busy
                        ? FontWeight.w700
                        : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.icon, required this.color, required this.label});

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 8, color: color),
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
