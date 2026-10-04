import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
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

  String get _formattedDate {
    const weekdays = [
      'Thứ hai',
      'Thứ ba',
      'Thứ tư',
      'Thứ năm',
      'Thứ sáu',
      'Thứ bảy',
      'Chủ nhật',
    ];
    final weekday = weekdays[date.weekday - 1];
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$weekday, $d/$m/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isToday = DateUtils.isSameDay(date, DateTime.now());
    final activeSlots = WorkSchedule.slots
        .where((s) => workingSlots.contains(s))
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Date Header & Day Lock Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _formattedDate,
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isToday) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEDD5),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'Hôm nay',
                              style: TextStyle(
                                color: AppColors.ember,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$availableCount khung giờ khả dụng cho khách đặt',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Bận cả ngày',
                      style: TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    SizedBox(
                      height: 22,
                      width: 34,
                      child: Switch.adaptive(
                        value: busyAllDay,
                        activeThumbColor: Colors.white,
                        activeTrackColor: const Color(0xFFF43F5E),
                        onChanged: workingSlots.isEmpty
                            ? null
                            : onBusyAllDayChanged,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 2. Contextual Booking Callout Card(s)
          if (bookings.isNotEmpty) ...[
            const SizedBox(height: 14),
            for (final booking in bookings) ...[
              AvailabilityBookingCard(booking: booking),
              const SizedBox(height: 8),
            ],
          ],

          const SizedBox(height: 16),

          // 3. 30-Minute Time Slots Matrix Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Flexible(
                child: Text(
                  'KHUNG GIỜ CHI TIẾT (MỖI 30 PHÚT)',
                  style: TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Chạm để khóa / mở',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // 4. Slots Grid or Empty Off State
          if (workingSlots.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Text(
                'Ngày này đang nghỉ theo lịch định kỳ.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activeSlots.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
                mainAxisExtent: 46,
              ),
              itemBuilder: (context, index) {
                final slot = activeSlots[index];
                final isBooked = bookedSlots.contains(slot);
                final isBusy = busySlots.contains(slot);
                return _SlotItem(
                  slot: slot,
                  isBooked: isBooked,
                  isBusy: isBusy,
                  onTap: isBooked ? null : () => onBusySlotTap(slot),
                );
              },
            ),

          const SizedBox(height: 14),

          // 5. Legend for Slots
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
            ),
            child: const Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 6,
                children: [
                  _SlotLegendItem(
                    borderColor: Color(0xFF6EE7B7),
                    bgColor: Colors.white,
                    label: 'Sẵn sàng',
                  ),
                  _SlotLegendItem(
                    borderColor: Color(0xFFFED7AA),
                    bgColor: Color(0xFFFFF7ED),
                    label: 'Khách đã đặt',
                  ),
                  _SlotLegendItem(
                    borderColor: Color(0xFFE2E8F0),
                    bgColor: Color(0xFFF1F5F9),
                    label: 'Tự khóa',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SlotItem extends StatelessWidget {
  const _SlotItem({
    required this.slot,
    required this.isBooked,
    required this.isBusy,
    this.onTap,
  });

  final String slot;
  final bool isBooked;
  final bool isBusy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color borderColor;
    final Color timeColor;
    final Color statusColor;
    final String statusText;
    final bool lineThrough;

    if (isBooked) {
      bgColor = const Color(0xFFFFF7ED); // orange-50
      borderColor = const Color(0xFFFED7AA); // orange-200
      timeColor = AppColors.ember;
      statusColor = const Color(0xFFC2410C); // orange-700
      statusText = 'Đã đặt';
      lineThrough = false;
    } else if (isBusy) {
      bgColor = const Color(0xFFF1F5F9); // slate-100
      borderColor = const Color(0xFFE2E8F0); // slate-200
      timeColor = const Color(0xFF94A3B8); // slate-400
      statusColor = const Color(0xFF64748B); // slate-500
      statusText = 'Tự khóa';
      lineThrough = true;
    } else {
      bgColor = Colors.white;
      borderColor = const Color(0xFF6EE7B7); // emerald-300
      timeColor = const Color(0xFF1E293B); // slate-800
      statusColor = const Color(0xFF059669); // emerald-600
      statusText = 'Sẵn sàng';
      lineThrough = false;
    }

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  slot,
                  style: TextStyle(
                    color: timeColor,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    decoration: lineThrough ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
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

class _SlotLegendItem extends StatelessWidget {
  const _SlotLegendItem({
    required this.borderColor,
    required this.bgColor,
    required this.label,
  });

  final Color borderColor;
  final Color bgColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: borderColor),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
