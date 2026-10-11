import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../../domain/models/models.dart';
import '../../../providers/data_providers.dart';

class ApiBookingPlanRepository {
  const ApiBookingPlanRepository(this._dio);

  final Dio _dio;

  Future<List<PhotographerPackage>> listMine() async {
    try {
      final response = await _dio.get<dynamic>(
        'photographers/me/booking-plans',
      );
      final data = _unwrap(response.data);
      final items = data is List
          ? data
          : data is Map
          ? (data['items'] ?? data['results'] ?? const [])
          : const [];
      if (items is! List) {
        throw const ApiException('Danh sách gói chụp từ Backend không hợp lệ.');
      }
      return items.map((item) => _plan(_asMap(item))).toList();
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> create(PhotographerPackage package) async {
    try {
      await _dio.post<dynamic>(
        'photographers/me/booking-plans',
        data: _body(package),
      );
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> updatePlan(PhotographerPackage package) async {
    try {
      await _dio.patch<dynamic>(
        'booking-plans/${package.id}',
        data: {..._body(package), 'is_active': package.isActive},
      );
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> delete(String id) async {
    try {
      await _dio.delete<dynamic>('booking-plans/$id');
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Map<String, Object?> _body(PhotographerPackage package) => {
    'name': package.name,
    if (package.description.trim().isNotEmpty)
      'description': package.description.trim(),
    'price': package.price,
    'duration_minutes': package.durationMinutes,
    'photo_count': package.photoCount,
    'retouched_photo_count': package.retouchedPhotoCount,
    'features': package.features,
  };

  PhotographerPackage _plan(Map<String, dynamic> json) {
    final duration = _int(json['duration_minutes']);
    return PhotographerPackage(
      id: _requiredString(json['id'], 'id'),
      name: _requiredString(json['name'], 'name'),
      duration: '$duration phút',
      description: json['description']?.toString() ?? '',
      price: _int(json['price']),
      photoCount: _int(json['photo_count']),
      retouchedPhotoCount: _int(json['retouched_photo_count']),
      durationHours: duration / 60,
      features: json['features'] is List
          ? (json['features'] as List).map((value) => '$value').toList()
          : const [],
      isActive: json['is_active'] != false,
    );
  }
}

final apiBookingPlanRepositoryProvider = Provider<ApiBookingPlanRepository>(
  (ref) => ApiBookingPlanRepository(ref.watch(dioProvider)),
);

class BookingPlansNotifier extends AsyncNotifier<List<PhotographerPackage>> {
  @override
  Future<List<PhotographerPackage>> build() async {
    if (ref.watch(authUserProvider)?.role != 'photographer') return const [];
    return ref.read(apiBookingPlanRepositoryProvider).listMine();
  }

  Future<void> create(PhotographerPackage package) async {
    await ref.read(apiBookingPlanRepositoryProvider).create(package);
    state = AsyncData(
      await ref.read(apiBookingPlanRepositoryProvider).listMine(),
    );
  }

  Future<void> updatePlan(PhotographerPackage package) async {
    await ref.read(apiBookingPlanRepositoryProvider).updatePlan(package);
    state = AsyncData(
      await ref.read(apiBookingPlanRepositoryProvider).listMine(),
    );
  }

  Future<void> delete(String id) async {
    await ref.read(apiBookingPlanRepositoryProvider).delete(id);
    state = AsyncData(
      await ref.read(apiBookingPlanRepositoryProvider).listMine(),
    );
  }
}

final bookingPlansProvider =
    AsyncNotifierProvider<BookingPlansNotifier, List<PhotographerPackage>>(
      BookingPlansNotifier.new,
    );

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
  throw const ApiException('Backend trả về gói chụp không hợp lệ.');
}

String _requiredString(Object? value, String field) {
  if (value is String && value.trim().isNotEmpty) return value.trim();
  throw ApiException('Backend không trả về trường $field của gói chụp.');
}

int _int(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}
