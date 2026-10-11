import 'package:dio/dio.dart';

import '../../core/network/api_exception.dart';
import '../../features/photographer/achievements/achievement_repository.dart';
import '../../features/photographer/achievements/models/photographer_achievements.dart';
import '../../features/photographer/achievements/models/photographer_rank.dart';

class ApiAchievementRepository implements AchievementRepository {
  const ApiAchievementRepository(this._dio);
  final Dio _dio;

  @override
  Future<PhotographerAchievements> getAchievements(
    String photographerId,
  ) async {
    try {
      final responses = await Future.wait([
        _dio.get<dynamic>('photographers/me'),
        _dio.get<dynamic>('ranks'),
        _dio.get<dynamic>('badges'),
      ]);
      final profile = _asMap(_unwrap(responses[0].data));
      if (profile['id']?.toString() != photographerId) {
        throw const ApiException(
          'Hồ sơ Backend không khớp photographer đang đăng nhập.',
        );
      }
      final rankJson = _items(_unwrap(responses[1].data));
      final badgeJson = _items(_unwrap(responses[2].data));
      final rating = _mapOrEmpty(profile['rating']);
      final currentRank = _mapOrEmpty(profile['rank']);
      final earned = profile['badges'] is List
          ? (profile['badges'] as List)
                .map(_asMap)
                .map((item) => item['code']?.toString() ?? '')
                .where((code) => code.isNotEmpty)
                .toSet()
          : <String>{};
      return PhotographerAchievements(
        photographerId: photographerId,
        currentRankCode: currentRank['code']?.toString() ?? '',
        currentRankName: currentRank['name']?.toString() ?? '',
        averageRating: _number(rating['average_rating']),
        totalFeedbacks: _integer(rating['total_feedbacks']),
        totalBookings: _integer(rating['total_bookings']),
        returnCustomers: _integer(rating['return_customers']),
        ranks: rankJson.map(_rank).toList(),
        badges: badgeJson.map(_badge).toList(),
        earnedBadgeCodes: earned,
      );
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}

PhotographerRank _rank(Map<String, dynamic> json) => PhotographerRank(
  id: _required(json['id'], 'rank.id'),
  code: _required(json['code'], 'rank.code'),
  name: _required(json['name'], 'rank.name'),
  minimumSessions: _integer(json['min_completed']),
  commissionPercent: _integer(json['commission_percent']),
);

PhotographerBadge _badge(Map<String, dynamic> json) => PhotographerBadge(
  id: _required(json['id'], 'badge.id'),
  code: _required(json['code'], 'badge.code'),
  name: _required(json['name'], 'badge.name'),
  description: json['description']?.toString() ?? '',
  metric: json['metric']?.toString() ?? '',
  minimumValue: _number(json['min_value']),
  minimumReviews: _integer(json['min_reviews']),
  isActive: json['is_active'] == true,
);

List<Map<String, dynamic>> _items(Object? value) {
  if (value is List) return value.map(_asMap).toList();
  if (value is Map && value['items'] is List) {
    return (value['items'] as List).map(_asMap).toList();
  }
  throw const ApiException('Danh mục rank/badge từ Backend không hợp lệ.');
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

Map<String, dynamic> _mapOrEmpty(Object? value) => value is Map
    ? value.map((key, value) => MapEntry('$key', value))
    : const {};

String _required(Object? value, String field) {
  if (value is String && value.trim().isNotEmpty) return value.trim();
  throw ApiException('Backend không trả về $field.');
}

int _integer(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}

double _number(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? 0;
}
