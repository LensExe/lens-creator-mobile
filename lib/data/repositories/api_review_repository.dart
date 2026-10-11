import 'package:dio/dio.dart';

import '../../core/network/api_exception.dart';
import '../../domain/models/review.dart';
import '../../features/photographer/reviews/review_repository.dart';

class ApiReviewRepository implements ReviewRepository {
  const ApiReviewRepository(this._dio);
  final Dio _dio;

  @override
  Future<List<Review>> getPhotographerReviews(String photographerId) async {
    try {
      const pageSize = 100;
      var offset = 0;
      var total = 0;
      final reviews = <Review>[];
      do {
        final response = await _dio.get<dynamic>(
          'photographers/$photographerId/reviews',
          queryParameters: {'limit': pageSize, 'offset': offset},
        );
        final json = _asMap(_unwrap(response.data));
        final items = json['items'];
        if (items is! List) {
          throw const ApiException('Danh sách review từ Backend không hợp lệ.');
        }
        reviews.addAll(
          items.map((item) => _review(_asMap(item), photographerId)),
        );
        total = _int(json['total'], fallback: offset + items.length);
        offset += items.length;
        if (items.isEmpty) break;
      } while (offset < total);
      return reviews;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  @override
  Future<ReviewSummary> getSummary({
    required String photographerId,
    required double average,
    required int total,
    required int fiveStarPercent,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        'photographers/$photographerId/rating-summary',
      );
      final json = _asMap(_unwrap(response.data));
      final raw = _asMap(json['distribution']);
      final breakdown = {
        for (var score = 1; score <= 5; score++) score: _int(raw['$score']),
      };
      return ReviewSummary(
        average: _number(json['average_rating']),
        total: _int(json['total_feedbacks']),
        breakdown: breakdown,
      );
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  @override
  Future<void> reply(String feedbackId, String reply) async {
    final normalized = reply.trim();
    if (normalized.isEmpty || normalized.length > 10000) {
      throw const ApiException('Phản hồi phải có từ 1 đến 10.000 ký tự.');
    }
    try {
      await _dio.put<dynamic>(
        'reviews/$feedbackId/reply',
        data: {'reply': normalized},
      );
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Review _review(Map<String, dynamic> json, String photographerId) {
    final customer = json['customer'] is Map
        ? _asMap(json['customer'])
        : const <String, dynamic>{};
    return Review(
      id: _required(json['id'], 'id'),
      photographerId: photographerId,
      authorName: customer['name']?.toString() ?? 'Khách hàng',
      authorAvatar: customer['avatar_url']?.toString() ?? '',
      rating: _number(json['rating']),
      comment: json['comment']?.toString() ?? '',
      date: _required(json['created_at'], 'created_at'),
      photographerReply: json['photographer_reply']?.toString(),
      punctualityRating: _numberOrNull(json['punctuality_rating']),
      attitudeRating: _numberOrNull(json['attitude_rating']),
    );
  }
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
  throw const ApiException('Backend trả về đối tượng không hợp lệ.');
}

String _required(Object? value, String field) {
  if (value is String && value.trim().isNotEmpty) return value.trim();
  throw ApiException('Backend thiếu trường $field.');
}

int _int(Object? value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? fallback;
}

double _number(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? 0;
}

double? _numberOrNull(Object? value) => value == null ? null : _number(value);
