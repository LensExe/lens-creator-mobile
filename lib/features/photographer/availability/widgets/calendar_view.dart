import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:lens_creator_mobile/core/theme/app_colors.dart';
import 'package:lens_creator_mobile/core/widgets/surface_card.dart';

class CalendarView extends StatelessWidget {
  final DateTime selectedDay;
  final DateTime firstDay;
  final DateTime lastDay;
  final List<DateTime> bookedDays;
  final Function(DateTime) onDaySelected;

  const CalendarView({
    super.key,
    required this.selectedDay,
    required this.firstDay,
    required this.lastDay,
    required this.bookedDays,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: TableCalendar(
        firstDay: firstDay,
        lastDay: lastDay,
        focusedDay: selectedDay,
        selectedDayPredicate: (day) {
          return isSameDay(selectedDay, day);
        },
        onDaySelected: (selected, focused) {
          onDaySelected(selected);
        },
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.obsidian,
          ),
          leftChevronIcon: Icon(Icons.chevron_left, color: AppColors.obsidian),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: AppColors.obsidian,
          ),
        ),
        calendarStyle: CalendarStyle(
          todayDecoration: const BoxDecoration(
            color: AppColors.pebble,
            shape: BoxShape.circle,
          ),
          selectedDecoration: const BoxDecoration(
            color: AppColors.obsidian,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(color: AppColors.snow),
          defaultTextStyle: const TextStyle(
            color: AppColors.obsidian,
            fontWeight: FontWeight.w500,
          ),
          weekendTextStyle: const TextStyle(
            color: AppColors.ember,
            fontWeight: FontWeight.w500,
          ),
          outsideDaysVisible: false,
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (bookedDays.any((bookedDay) => isSameDay(bookedDay, date))) {
              return Positioned(
                bottom: 6,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }
            return null;
          },
        ),
      ),
    );
  }
}
