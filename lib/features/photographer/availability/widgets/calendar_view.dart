import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:lens_creator_mobile/core/theme/app_colors.dart';
import 'package:lens_creator_mobile/core/widgets/surface_card.dart';

class CalendarView extends StatelessWidget {
  final DateTime selectedDay;
  final Function(DateTime) onDaySelected;

  const CalendarView({
    super.key,
    required this.selectedDay,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 10, 16),
        lastDay: DateTime.utc(2030, 3, 14),
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
        // Mocking some busy days (rendering markers for UI demonstration)
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            // Hardcode some busy days for UI demonstration
            if (date.day % 4 == 0 && !isSameDay(date, selectedDay)) {
              return Positioned(
                bottom: 6,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.ember,
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
