import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lens_creator_mobile/core/network/api_exception.dart';
import 'package:lens_creator_mobile/data/repositories/api_booking_repository.dart';
import 'package:lens_creator_mobile/domain/models/models.dart';

void main() {
  const bookingId = '61ce08cf-2d44-4f59-bc54-4033a8eec025';
  const baseUrl = 'https://api.example.test/v1/';

  test(
    'lists real booking pages and maps Backend statuses and fields',
    () async {
      final requests = <RequestOptions>[];
      final pages = <int, List<Map<String, Object?>>>{
        0: [_bookingJson(status: 'accepted')],
        1: [_bookingJson(status: 'in_progress')],
      };
      final dio = Dio(BaseOptions(baseUrl: baseUrl));
      dio.httpClientAdapter = _Adapter((request) async {
        requests.add(request);
        final offset = int.parse(request.queryParameters['offset'].toString());
        return _response(200, {
          'data': {
            'items': pages[offset],
            'total': 2,
            'offset': offset,
            'limit': 100,
          },
        });
      });

      final bookings = await ApiBookingRepository(dio)
          .getBookings('ignored-user-id', 'photographer');

      expect(requests.map((request) => request.uri.path), [
        '/v1/bookings',
        '/v1/bookings',
      ]);
      expect(requests.map((request) => request.queryParameters['offset']), [
        0,
        1,
      ]);
      expect(requests.first.queryParameters.containsKey('user_id'), isFalse);
      expect(bookings.map((booking) => booking.status), [
        BookingStatus.accepted,
        BookingStatus.inProgress,
      ]);
      expect(bookings.first.id, bookingId);
      expect(bookings.first.clientName, 'Khách hàng');
      expect(bookings.first.style, 'Buổi chụp');
      expect(bookings.first.location, 'Hà Nội');
      expect(bookings.first.price, 1200000);
      expect(bookings.first.depositAmount, 360000);
      expect(bookings.first.timeSlot, '09:30');
      expect(bookings.first.durationHours, 1.5);
    },
  );

  test('loads a booking detail and Backend status history', () async {
    final dio = Dio(BaseOptions(baseUrl: baseUrl));
    dio.httpClientAdapter = _Adapter((request) async {
      if (request.uri.path == '/v1/bookings/$bookingId') {
        return _response(200, {'data': _bookingJson(status: 'shot')});
      }
      if (request.uri.path == '/v1/bookings/$bookingId/timeline') {
        return _response(200, {
          'data': {
            'items': [
              {
                'from_status': 'pending',
                'to_status': 'rejected',
                'actor_role': 'photographer',
                'reason': 'Không còn lịch trống',
                'created_at': '2026-10-10T03:00:00.000Z',
              },
            ],
          },
        });
      }
      throw StateError('Unexpected request ${request.uri}');
    });

    final repository = ApiBookingRepository(dio);
    final booking = await repository.getBooking(bookingId);
    final timeline = await repository.getTimeline(bookingId);

    expect(booking.status, BookingStatus.shot);
    expect(booking.id, bookingId);
    expect(timeline, hasLength(1));
    expect(timeline.single.fromStatus, 'pending');
    expect(timeline.single.toStatus, 'rejected');
    expect(timeline.single.actorRole, 'photographer');
    expect(timeline.single.reason, 'Không còn lịch trống');
    expect(timeline.single.createdAt, isNotNull);
  });

  test(
    'uses exact Backend booking action routes and rejection reason body',
    () async {
      final requests = <RequestOptions>[];
      final dio = Dio(BaseOptions(baseUrl: baseUrl));
      dio.httpClientAdapter = _Adapter((request) async {
        requests.add(request);
        return _response(200, {'success': true});
      });
      final repository = ApiBookingRepository(dio);

      await repository.updateBookingStatus(bookingId, BookingStatus.accepted);
      await repository.updateBookingStatus(
        bookingId,
        BookingStatus.rejected,
        reason: 'Không còn lịch trống',
      );
      await repository.updateBookingStatus(bookingId, BookingStatus.inProgress);
      await repository.updateBookingStatus(bookingId, BookingStatus.shot);

      expect(requests.map((request) => request.method), [
        'POST',
        'POST',
        'POST',
        'POST',
      ]);
      expect(requests.map((request) => request.uri.path), [
        '/v1/bookings/$bookingId/accept',
        '/v1/bookings/$bookingId/reject',
        '/v1/bookings/$bookingId/start',
        '/v1/bookings/$bookingId/complete-shoot',
      ]);
      expect(requests.first.data, isNull);
      expect(requests[1].data, {'reason': 'Không còn lịch trống'});
      expect(requests[2].data, isNull);
      expect(requests[3].data, isNull);
    },
  );

  test('does not send rejection or cancellation without a reason', () async {
    var requestCount = 0;
    final dio = Dio(BaseOptions(baseUrl: baseUrl));
    dio.httpClientAdapter = _Adapter((request) async {
      requestCount++;
      return _response(200, {'success': true});
    });
    final repository = ApiBookingRepository(dio);

    await expectLater(
      repository.updateBookingStatus(bookingId, BookingStatus.rejected),
      throwsA(isA<ApiException>()),
    );
    await expectLater(
      repository.updateBookingStatus(bookingId, BookingStatus.cancelled),
      throwsA(isA<ApiException>()),
    );
    expect(requestCount, 0);
  });
}

Map<String, Object?> _bookingJson({required String status}) => {
  'id': '61ce08cf-2d44-4f59-bc54-4033a8eec025',
  'customer_id': 'customer-uuid',
  'photographer_id': 'photographer-uuid',
  'booking_plan_id': 'plan-uuid',
  'location': 'Hà Nội',
  'from': '2026-10-10T09:30:00+07:00',
  'to': '2026-10-10T11:00:00+07:00',
  'total_amount': 1200000,
  'deposit_amount': 360000,
  'status': status,
};

ResponseBody _response(int statusCode, Object payload) =>
    ResponseBody.fromString(
      jsonEncode(payload),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

class _Adapter implements HttpClientAdapter {
  _Adapter(this.respond);

  final Future<ResponseBody> Function(RequestOptions request) respond;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) => respond(options);

  @override
  void close({bool force = false}) {}
}
