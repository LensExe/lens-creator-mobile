import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/theme/app_colors.dart';
import '../work_schedule.dart';

class CalendarView extends StatefulWidget {
  final DateTime selectedDay;
  final DateTime firstDay;
  final DateTime lastDay;
  final List<DateTime> bookedDays;
  final WorkSchedule? schedule;
  final ValueChanged<DateTime> onDaySelected;

  const CalendarView({
    super.key,
    required this.selectedDay,
    required this.firstDay,
    required this.lastDay,
    required this.bookedDays,
    this.schedule,
    required this.onDaySelected,
  });

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.selectedDay;
  }

  @override
  void didUpdateWidget(covariant CalendarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!isSameDay(oldWidget.selectedDay, widget.selectedDay)) {
      _focusedDay = widget.selectedDay;
    }
  }

  int _getWeekNumber(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays + 1;
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }

  void _previousMonth() {
    setState(() {
      final prev = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
      _focusedDay = prev.isBefore(widget.firstDay) ? widget.firstDay : prev;
    });
  }

  void _nextMonth() {
    setState(() {
      final next = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
      _focusedDay = next.isAfter(widget.lastDay) ? widget.lastDay : next;
    });
  }

  void _jumpToToday() {
    final today = DateUtils.dateOnly(DateTime.now());
    final target = today.isBefore(widget.firstDay) ? widget.firstDay : today;
    setState(() => _focusedDay = target);
    widget.onDaySelected(target);
  }

  bool _isDayOff(DateTime day) {
    final schedule = widget.schedule;
    if (schedule == null) return false;
    final weeklySlots = schedule.weekly[day.weekday % 7];
    if (weeklySlots.isEmpty) return true;
    final key = WorkSchedule.iso(day);
    final busy = schedule.busy[key];
    if (busy != null && busy.containsAll(weeklySlots)) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel = 'Tháng ${_focusedDay.month}, ${_focusedDay.year}';
    final weekNumber = _getWeekNumber(_focusedDay);

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
        children: [
          // 1. Month Header & Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  children: [
                    Text(
                      monthLabel,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      '(Tuần $weekNumber)',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: _previousMonth,
                      borderRadius: BorderRadius.circular(7),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.chevron_left_rounded,
                          size: 18,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    InkWell(
                      onTap: _jumpToToday,
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: const [
                            BoxShadow(color: Color(0x08000000), blurRadius: 2),
                          ],
                        ),
                        child: const Text(
                          'Hôm nay',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    InkWell(
                      onTap: _nextMonth,
                      borderRadius: BorderRadius.circular(7),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // 2. Calendar Grid
          TableCalendar(
            firstDay: widget.firstDay,
            lastDay: widget.lastDay,
            focusedDay: _focusedDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerVisible: false,
            daysOfWeekHeight: 26,
            rowHeight: 46,
            selectedDayPredicate: (day) => isSameDay(widget.selectedDay, day),
            onDaySelected: (selected, focused) {
              setState(() => _focusedDay = focused);
              widget.onDaySelected(selected);
            },
            calendarBuilders: CalendarBuilders(
              dowBuilder: (context, day) {
                final isSunday = day.weekday == DateTime.sunday;
                final text = switch (day.weekday) {
                  DateTime.monday => 'T2',
                  DateTime.tuesday => 'T3',
                  DateTime.wednesday => 'T4',
                  DateTime.thursday => 'T5',
                  DateTime.friday => 'T6',
                  DateTime.saturday => 'T7',
                  DateTime.sunday => 'CN',
                  _ => '',
                };
                return Center(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSunday
                          ? const Color(0xFFFB7185)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                );
              },
              selectedBuilder: (context, date, events) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.ember,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x4DFF5A00),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          date.day.toString().padLeft(2, '0'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: AppColors.ember,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                );
              },
              todayBuilder: (context, date, events) {
                if (isSameDay(widget.selectedDay, date)) return null;
                final hasBooking = widget.bookedDays.any(
                  (b) => isSameDay(b, date),
                );
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: hasBooking
                              ? const Color(0xFFECFDF5)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: hasBooking
                                ? const Color(0xFFA7F3D0)
                                : AppColors.ember.withValues(alpha: 0.5),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          date.day.toString().padLeft(2, '0'),
                          style: TextStyle(
                            color: hasBooking
                                ? const Color(0xFF064E3B)
                                : AppColors.ember,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: hasBooking
                              ? const Color(0xFF10B981)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                );
              },
              defaultBuilder: (context, date, events) {
                final hasBooking = widget.bookedDays.any(
                  (b) => isSameDay(b, date),
                );
                final isOff = _isDayOff(date);

                if (hasBooking) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            date.day.toString().padLeft(2, '0'),
                            style: const TextStyle(
                              color: Color(0xFF064E3B),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (isOff) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          child: Text(
                            date.day.toString().padLeft(2, '0'),
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const SizedBox(width: 4, height: 4),
                      ],
                    ),
                  );
                }

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        child: Text(
                          date.day.toString().padLeft(2, '0'),
                          style: const TextStyle(
                            color: Color(0xFF334155),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const SizedBox(width: 4, height: 4),
                    ],
                  ),
                );
              },
              outsideBuilder: (context, date, events) {
                return Center(
                  child: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    child: Text(
                      date.day.toString(),
                      style: const TextStyle(
                        color: Color(0xFFCBD5E1),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // 3. Ultra-concise minimal legend
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
                  _LegendItem(
                    dotColor: Color(0xFF10B981),
                    label: 'Có lịch chụp',
                  ),
                  _LegendItem(dotColor: AppColors.ember, label: 'Đang chọn'),
                  _LegendItem(label: 'Nghỉ/Khóa', isLineThrough: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    this.dotColor,
    required this.label,
    this.isLineThrough = false,
  });

  final Color? dotColor;
  final String label;
  final bool isLineThrough;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLineThrough) ...[
          const Text(
            '11',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          const SizedBox(width: 5),
        ] else if (dotColor != null) ...[
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
        ],
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
