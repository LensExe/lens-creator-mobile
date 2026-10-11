import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';

class CalendarEntry {
  const CalendarEntry({
    required this.id,
    required this.kind,
    required this.from,
    required this.to,
    this.status,
    this.location,
    this.reason,
  });

  final String id;
  final String kind;
  final DateTime from;
  final DateTime to;
  final String? status;
  final String? location;
  final String? reason;
}

class CalendarSnapshot {
  const CalendarSnapshot({required this.bookings, required this.blocked});
  final List<CalendarEntry> bookings;
  final List<CalendarEntry> blocked;
}

class CalendarApiRepository {
  const CalendarApiRepository(this._dio);
  final Dio _dio;

  Future<CalendarSnapshot> getRange(DateTime from, DateTime to) async {
    try {
      final response = await _dio.get<dynamic>(
        'calendar/me',
        queryParameters: {
          'from': calendarIsoWithOffset(from),
          'to': calendarIsoWithOffset(to),
        },
      );
      final json = _asMap(_unwrap(response.data));
      return CalendarSnapshot(
        bookings: _entries(json['bookings'], 'booking'),
        blocked: _entries(json['blocked'], 'blocked'),
      );
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<List<CalendarEntry>> previewBlock(Map<String, Object?> body) async {
    try {
      final response = await _dio.get<dynamic>(
        'calendar/blocked-times/affected',
        queryParameters: body,
      );
      final json = _unwrap(response.data);
      final items = json is List
          ? json
          : json is Map
          ? json['items']
          : null;
      if (items is! List) {
        throw const ApiException(
          'Backend trả về danh sách booking bị ảnh hưởng không hợp lệ.',
        );
      }
      return items.map((item) => _entry(_asMap(item), 'booking')).toList();
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> block(Map<String, Object?> body) async {
    try {
      await _dio.post<dynamic>('calendar/blocked-times', data: body);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> unblock(String id) async {
    try {
      await _dio.delete<dynamic>('calendar/blocked-times/$id');
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  List<CalendarEntry> _entries(Object? value, String kind) {
    if (value is! List) return const [];
    return value.map((item) => _entry(_asMap(item), kind)).toList();
  }

  CalendarEntry _entry(Map<String, dynamic> json, String kind) {
    final from = DateTime.tryParse('${json['from']}');
    final to = DateTime.tryParse('${json['to']}');
    if (from == null || to == null) {
      throw const ApiException('Backend trả về khoảng lịch không hợp lệ.');
    }
    return CalendarEntry(
      id: '${json['id'] ?? ''}',
      kind: kind,
      from: from,
      to: to,
      status: json['status']?.toString(),
      location: json['location']?.toString(),
      reason: json['reason']?.toString(),
    );
  }
}

final calendarApiRepositoryProvider = Provider<CalendarApiRepository>(
  (ref) => CalendarApiRepository(ref.watch(dioProvider)),
);

final creatorCalendarProvider = FutureProvider.autoDispose<CalendarSnapshot>((
  ref,
) {
  final now = DateTime.now();
  return ref
      .read(calendarApiRepositoryProvider)
      .getRange(
        DateTime(now.year, now.month, now.day),
        DateTime(now.year, now.month, now.day).add(const Duration(days: 91)),
      );
});

String calendarIsoWithOffset(DateTime value) {
  final local = value.toLocal();
  final offset = local.timeZoneOffset;
  final sign = offset.isNegative ? '-' : '+';
  final hours = offset.inHours.abs().toString().padLeft(2, '0');
  final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
  final date =
      '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
  final time =
      '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}:00';
  return '${date}T$time$sign$hours:$minutes';
}

Object? _unwrap(Object? value) {
  var result = value;
  while (result is Map && result.containsKey('data')) {
    result = result['data'];
  }
  return result;
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.map((key, value) => MapEntry('$key', value));
  throw const ApiException('Backend trả về dữ liệu lịch không hợp lệ.');
}
