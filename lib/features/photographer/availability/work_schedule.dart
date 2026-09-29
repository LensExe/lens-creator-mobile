import '../../../domain/models/models.dart';

/// Half-hour cells are the mobile editor's local representation of web ranges.
/// The repository can serialize contiguous cells as TimeRange values for the API.
class WorkSchedule {
  WorkSchedule({required this.weekly, required this.busy});

  final List<Set<String>> weekly; // Sunday = 0.
  final Map<String, Set<String>> busy;

  static final List<String> slots = [
    for (var hour = 7; hour < 24; hour++)
      for (final minute in [0, 30])
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
  ];

  factory WorkSchedule.open({bool demoSeed = false}) {
    final today = DateTime.now();
    return WorkSchedule(
      weekly: [for (var day = 0; day < 7; day++) {...slots}],
      busy: demoSeed ? {
        iso(today.add(const Duration(days: 5))): {...slots},
        iso(today.add(const Duration(days: 9))): {
          '14:00', '14:30', '15:00', '15:30',
        },
      } : {},
    );
  }

  WorkSchedule copy() => WorkSchedule(
    weekly: [
      for (final day in weekly) {...day},
    ],
    busy: {
      for (final entry in busy.entries) entry.key: {...entry.value},
    },
  );

  static String iso(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  bool isBooked(Booking booking, String date, String slot) {
    if (booking.date != date ||
        booking.timeSlot == null ||
        booking.status == BookingStatus.cancelled ||
        booking.status == BookingStatus.released) {
      return false;
    }
    final start = slots.indexOf(booking.timeSlot!);
    final current = slots.indexOf(slot);
    final length = ((booking.durationHours ?? 2) * 2).ceil();
    return start >= 0 && current >= start && current < start + length;
  }

  bool isBusy(DateTime date, String slot) {
    final dateKey = iso(date);
    return !weekly[date.weekday % 7].contains(slot) ||
        (busy[dateKey]?.contains(slot) ?? false);
  }
}
