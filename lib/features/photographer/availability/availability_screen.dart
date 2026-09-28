import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lens_creator_mobile/core/theme/app_colors.dart';
import 'package:lens_creator_mobile/core/widgets/surface_card.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lens_creator_mobile/features/photographer/achievements/widgets/dashed_rect_painter.dart';

class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  // Mock data of ISO date strings (yyyy-MM-dd)
  List<String> upcomingDates = [];

  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Add some mock dates based on today
    final today = DateTime.now();
    upcomingDates = [
      DateFormat('yyyy-MM-dd').format(today.add(const Duration(days: 1))),
      DateFormat('yyyy-MM-dd').format(today.add(const Duration(days: 3))),
      DateFormat('yyyy-MM-dd').format(today.add(const Duration(days: 15))),
    ];
  }

  void _toggleAvailability(DateTime date) {
    // Only allow future or today dates (ignoring time)
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final selectedDate = DateTime(date.year, date.month, date.day);

    if (selectedDate.isBefore(todayDate)) return;

    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    setState(() {
      if (upcomingDates.contains(dateStr)) {
        upcomingDates.remove(dateStr);
      } else {
        upcomingDates.add(dateStr);
      }
      upcomingDates.sort(); // Keep them ordered chronologically
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mist,
      appBar: AppBar(
        backgroundColor: AppColors.mist,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.obsidian),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Lịch trống',
              style: TextStyle(
                color: AppColors.obsidian,
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Chọn những ngày bạn sẵn sàng nhận lịch chụp. Khách hàng sẽ chỉ đặt được vào các ngày này.',
              style: TextStyle(color: AppColors.steel, fontSize: 15),
            ),
            const SizedBox(height: 32),

            // Calendar View
            SurfaceCard(
              child: TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(
                  const Duration(days: 730),
                ), // 2 years
                focusedDay: _focusedDay,
                currentDay: DateTime.now(),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.obsidian,
                  ),
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    color: AppColors.obsidian,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    color: AppColors.obsidian,
                  ),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    color: AppColors.steel,
                    fontWeight: FontWeight.bold,
                  ),
                  weekendStyle: TextStyle(
                    color: AppColors.steel,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: AppColors.pebble,
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: TextStyle(
                    color: AppColors.obsidian,
                    fontWeight: FontWeight.bold,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: AppColors.obsidian,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: TextStyle(
                    color: AppColors.snow,
                    fontWeight: FontWeight.bold,
                  ),
                  disabledTextStyle: TextStyle(color: AppColors.fog),
                  defaultTextStyle: TextStyle(
                    color: AppColors.obsidian,
                    fontWeight: FontWeight.w500,
                  ),
                  weekendTextStyle: TextStyle(
                    color: AppColors.obsidian,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                selectedDayPredicate: (day) {
                  final dateStr = DateFormat('yyyy-MM-dd').format(day);
                  return upcomingDates.contains(dateStr);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                  });
                  _toggleAvailability(selectedDay);
                },
              ),
            ).animate().fade().slideY(begin: 0.1),

            const SizedBox(height: 32),

            // Upcoming Free Days
            Row(
              children: [
                const Icon(Icons.edit_calendar, color: AppColors.obsidian),
                const SizedBox(width: 8),
                Text(
                  'Ngày rảnh sắp tới (${upcomingDates.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.obsidian,
                  ),
                ),
              ],
            ).animate().fade(delay: 200.ms),
            const SizedBox(height: 16),

            if (upcomingDates.isEmpty)
              _buildEmptyState().animate().fade(delay: 300.ms)
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: upcomingDates.map((dateStr) {
                  final date = DateTime.parse(dateStr);
                  final displayDate = DateFormat('dd/MM/yyyy').format(date);
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.snow,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.pebble),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          displayDate,
                          style: const TextStyle(
                            color: AppColors.obsidian,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _toggleAvailability(date),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.mist,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: AppColors.steel,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ).animate().fade(delay: 300.ms),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return CustomPaint(
      painter: DashedRectPainter(
        color: AppColors.steel,
        strokeWidth: 1.5,
        gap: 5,
        radius: 20,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: const [
            Icon(Icons.event_busy, color: AppColors.steel, size: 48),
            SizedBox(height: 16),
            Text(
              'Bạn chưa chọn ngày trống nào.\nHãy chọn trên lịch.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.steel,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
