import 'package:dio/dio.dart';

import '../../core/network/api_exception.dart';
import '../../domain/models/models.dart';

class ApiPhotographerProfileRepository {
  const ApiPhotographerProfileRepository(this._dio);
  final Dio _dio;

  Future<Photographer> getMine() async {
    try {
      final response = await _dio.get<dynamic>('photographers/me');
      return _map(_asMap(_unwrap(response.data)));
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<Photographer> update(
    Photographer profile,
    Photographer current,
  ) async {
    if (profile.id != current.id) {
      throw const ApiException('Không thể cập nhật hồ sơ photographer khác.');
    }
    try {
      if (profile.city != current.city) {
        if (profile.city.trim().isEmpty) {
          throw const ApiException('Khu vực hoạt động không được để trống.');
        }
        await _dio.patch<dynamic>(
          'photographers/me/location',
          data: {'location': profile.city.trim()},
        );
      }
      final body = <String, Object?>{};
      if (profile.bio != current.bio) {
        if (profile.bio.trim().isEmpty) {
          throw const ApiException('Phần giới thiệu không được để trống.');
        }
        body['description'] = profile.bio.trim();
      }
      if (!_same(profile.styles, current.styles)) {
        body['styles'] = profile.styles;
      }
      if (profile.experienceYears != current.experienceYears) {
        body['started_career_at'] =
            DateTime.now().year - profile.experienceYears;
      }
      if (body.isNotEmpty) {
        await _dio.patch<dynamic>('photographers/me', data: body);
      }
      return await getMine();
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Photographer _map(Map<String, dynamic> json) {
    final rating = _mapOrEmpty(json['rating']);
    final rank = _mapOrEmpty(json['rank']);
    final startedYear = _integer(json['started_career_at']);
    final nowYear = DateTime.now().year;
    return Photographer(
      id: _required(json['id'], 'id'),
      name: _required(json['fullname'], 'fullname'),
      avatar: json['avatar_url']?.toString() ?? '',
      cover: '',
      city: json['location']?.toString() ?? '',
      styles: json['styles'] is List
          ? (json['styles'] as List).map((value) => '$value').toList()
          : const [],
      pricePerSession: 0,
      rating: _number(rating['average_rating']),
      reviewCount: _integer(rating['total_feedbacks']),
      bio: json['description']?.toString() ?? '',
      experienceYears: startedYear == 0
          ? 0
          : (nowYear - startedYear).clamp(0, 200).toInt(),
      portfolio: const [],
      packages: const [],
      rank: rank['name']?.toString() ?? '',
    );
  }
}

bool _same(List<String> a, List<String> b) =>
    a.length == b.length &&
    List.generate(
      a.length,
      (index) => a[index] == b[index],
    ).every((same) => same);

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
  throw const ApiException('Backend trả về hồ sơ photographer không hợp lệ.');
}

Map<String, dynamic> _mapOrEmpty(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.map((key, value) => MapEntry('$key', value));
  return const {};
}

String _required(Object? value, String field) {
  if (value is String && value.trim().isNotEmpty) return value.trim();
  throw ApiException('Backend không trả về trường $field của hồ sơ.');
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
