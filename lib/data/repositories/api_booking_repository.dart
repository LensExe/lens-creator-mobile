import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../core/network/api_exception.dart';
import '../../domain/models/models.dart';
import '../../domain/repositories/booking_repository.dart';

class ApiBookingRepository implements BookingRepository {
  const ApiBookingRepository(this._dio);

  final Dio _dio;

  Future<Booking> getBooking(String id) async {
    try {
      final response = await _dio.get<dynamic>('bookings/$id');
      return _booking(_asMap(_unwrap(response.data)));
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<List<BookingTimelineEntry>> getTimeline(String id) async {
    try {
      final response = await _dio.get<dynamic>('bookings/$id/timeline');
      final payload = _asMap(_unwrap(response.data));
      final rawItems = payload['items'];
      if (rawItems is! List) {
        throw const ApiException(
          'Backend trả về lịch sử booking không hợp lệ.',
        );
      }
      return rawItems
          .map((item) {
            final json = _asMap(item);
            return BookingTimelineEntry(
              fromStatus: _string(json['from_status']),
              toStatus: _requiredString(json['to_status'], 'to_status'),
              actorRole: _string(json['actor_role']),
              reason: _string(json['reason']),
              createdAt: DateTime.tryParse(_string(json['created_at']))
                  ?.toLocal(),
            );
          })
          .toList(growable: false);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  @override
  Future<List<Booking>> getBookings(String userId, String role) async {
    if (role != 'photographer') return const [];
    try {
      const limit = 100;
      var offset = 0;
      var total = 0;
      final bookings = <Booking>[];
      do {
        final response = await _dio.get<dynamic>(
          'bookings',
          queryParameters: {'limit': limit, 'offset': offset},
        );
        final page = _asMap(_unwrap(response.data));
        final rawItems = page['items'];
        if (rawItems is! List) {
          throw const ApiException(
            'Backend trả về danh sách booking không hợp lệ.',
          );
        }
        final items = rawItems.map((item) => _booking(_asMap(item))).toList();
        bookings.addAll(items);
        total = _integer(page['total']);
        offset += items.length;
        if (items.isEmpty) break;
      } while (offset < total);
      return bookings;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  @override
  Future<Booking> createBooking(Booking booking) => Future.error(
    const ApiException('Creator không tạo booking; booking do khách tạo.'),
  );

  @override
  Future<void> updateBookingStatus(
    String id,
    BookingStatus status, {
    String? reason,
  }) async {
    try {
      switch (status) {
        case BookingStatus.accepted:
        case BookingStatus.confirmed:
          await _dio.post<dynamic>('bookings/$id/accept');
          return;
        case BookingStatus.rejected:
          await _dio.post<dynamic>(
            'bookings/$id/reject',
            data: {'reason': _requiredReason(reason)},
          );
          return;
        case BookingStatus.cancelled:
          await _dio.post<dynamic>(
            'bookings/$id/cancel',
            data: {'reason': _requiredReason(reason)},
          );
          return;
        case BookingStatus.inProgress:
          await _dio.post<dynamic>('bookings/$id/start');
          return;
        case BookingStatus.shot:
          await _dio.post<dynamic>('bookings/$id/complete-shoot');
          return;
        case BookingStatus.awaitingDeposit:
        case BookingStatus.pending:
        case BookingStatus.held:
        case BookingStatus.released:
        case BookingStatus.expired:
        case BookingStatus.completed:
          throw const ApiException(
            'Backend không hỗ trợ chuyển booking sang trạng thái này từ Creator.',
          );
      }
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  @override
  Future<Booking> addDeliveryPhotos(String id, List<String> urls) =>
      Future.error(
        const ApiException(
          'Ảnh cần tải qua media upload và gắn bằng media UUID trong gallery booking.',
        ),
      );

  @override
  Future<Booking> inviteCollaborator(
    String id,
    Photographer photographer,
    int sharePct,
  ) => Future.error(
    const ApiException('Backend chưa có API mời cộng tác viên.'),
  );

  @override
  Future<Booking> respondToCollaboration(
    String id,
    CollaborationStatus status,
  ) => Future.error(
    const ApiException('Backend chưa có API phản hồi lời mời cộng tác.'),
  );
}

class BookingTimelineEntry {
  const BookingTimelineEntry({
    required this.fromStatus,
    required this.toStatus,
    required this.actorRole,
    required this.reason,
    required this.createdAt,
  });

  final String fromStatus;
  final String toStatus;
  final String actorRole;
  final String reason;
  final DateTime? createdAt;
}

Booking _booking(Map<String, dynamic> json) {
  final from = DateTime.parse(_requiredString(json['from'], 'from')).toLocal();
  final to = DateTime.parse(_requiredString(json['to'], 'to')).toLocal();
  final status = switch (_requiredString(json['status'], 'status')) {
    'pending' => BookingStatus.pending,
    'accepted' => BookingStatus.accepted,
    'rejected' => BookingStatus.rejected,
    'cancelled' => BookingStatus.cancelled,
    'expired' => BookingStatus.expired,
    'in_progress' => BookingStatus.inProgress,
    'shot' => BookingStatus.shot,
    'completed' => BookingStatus.completed,
    final value => throw ApiException(
      'Backend trả trạng thái booking lạ: $value',
    ),
  };
  final durationMinutes = to.difference(from).inMinutes;
  return Booking(
    id: _requiredString(json['id'], 'id'),
    clientId: _string(json['customer_id']),
    clientName: 'Khách hàng',
    photographerId: _requiredString(json['photographer_id'], 'photographer_id'),
    photographerName: 'Nhiếp ảnh gia',
    style: 'Buổi chụp',
    date: DateFormat('yyyy-MM-dd').format(from),
    location: _string(json['location']),
    price: _integer(json['total_amount']),
    packageId: _string(json['booking_plan_id']),
    durationHours: durationMinutes > 0 ? durationMinutes / 60 : null,
    timeSlot: DateFormat('HH:mm').format(from),
    depositAmount: _integer(json['deposit_amount']),
    status: status,
  );
}

String _requiredReason(String? reason) {
  final value = reason?.trim() ?? '';
  if (value.isEmpty) {
    throw const ApiException('Nhập lý do để Backend ghi nhận thao tác này.');
  }
  return value;
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
  throw const ApiException('Backend trả về booking không đúng cấu trúc.');
}

String _string(Object? value) => value is String ? value : '';

String _requiredString(Object? value, String field) {
  if (value is String && value.trim().isNotEmpty) return value.trim();
  throw ApiException('Backend không trả về trường $field hợp lệ.');
}

int _integer(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? 0;
  }
  return 0;
}
