/// Canonical clock and calendar helpers for Lens bookings (+07:00).
///
/// [now], [today], and [fromInstant] return UTC DateTimes whose fields
/// represent Vietnam wall-clock values. Treat them as calendar values and do
/// not convert them to the device's local timezone.
abstract final class VietnamTime {
  static const Duration offset = Duration(hours: 7);

  static DateTime now() {
    final vietnam = DateTime.now().toUtc().add(offset);
    return DateTime.utc(
      vietnam.year,
      vietnam.month,
      vietnam.day,
      vietnam.hour,
      vietnam.minute,
      vietnam.second,
      vietnam.millisecond,
      vietnam.microsecond,
    );
  }

  static DateTime today() {
    final current = now();
    return DateTime.utc(current.year, current.month, current.day);
  }

  static DateTime fromInstant(DateTime value) {
    final vietnam = value.toUtc().add(offset);
    return DateTime.utc(
      vietnam.year,
      vietnam.month,
      vietnam.day,
      vietnam.hour,
      vietnam.minute,
      vietnam.second,
      vietnam.millisecond,
      vietnam.microsecond,
    );
  }

  static String toApiIso(DateTime value) {
    String two(int part) => part.toString().padLeft(2, '0');
    final date =
        '${value.year.toString().padLeft(4, '0')}-${two(value.month)}-${two(value.day)}';
    final time = '${two(value.hour)}:${two(value.minute)}:${two(value.second)}';
    return '${date}T$time+07:00';
  }
}
