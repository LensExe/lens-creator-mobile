import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../../providers/data_providers.dart';
import '../portfolio/api_portfolio_repository.dart';

class BookingGalleryItem {
  const BookingGalleryItem({required this.mediaId, required this.thumbnailUrl});

  final String mediaId;
  final String thumbnailUrl;
}

class BookingGallerySnapshot {
  const BookingGallerySnapshot({
    required this.status,
    required this.from,
    required this.to,
    required this.location,
    required this.publishedAt,
    required this.items,
    required this.galleryExists,
  });

  final String status;
  final String from;
  final String to;
  final String location;
  final DateTime? publishedAt;
  final List<BookingGalleryItem> items;
  final bool galleryExists;

  bool get canPublish => status == 'shot' || status == 'completed';
}

class ApiBookingGalleryRepository {
  const ApiBookingGalleryRepository(this._dio, this._media);

  final Dio _dio;
  final ApiPortfolioRepository _media;

  Future<BookingGallerySnapshot> get(String bookingId) async {
    try {
      final bookingResponse = await _dio.get<dynamic>('bookings/$bookingId');
      final booking = _asMap(_unwrap(bookingResponse.data));
      final gallery = await _getGallery(bookingId);
      final rawItems = gallery?['items'];
      final items = <BookingGalleryItem>[];
      if (rawItems is List) {
        for (final rawItem in rawItems) {
          final item = _asMap(rawItem);
          final url = item['thumbnail_url']?.toString();
          final mediaId =
              item['media_id']?.toString() ?? item['id']?.toString();
          if (url == null ||
              url.isEmpty ||
              mediaId == null ||
              mediaId.isEmpty) {
            continue;
          }
          items.add(BookingGalleryItem(mediaId: mediaId, thumbnailUrl: url));
        }
      }
      final publishedAt = DateTime.tryParse(
        gallery?['published_at']?.toString() ??
            booking['gallery_published_at']?.toString() ??
            '',
      );
      return BookingGallerySnapshot(
        status: booking['status']?.toString() ?? 'unknown',
        from: booking['from']?.toString() ?? '',
        to: booking['to']?.toString() ?? '',
        location: booking['location']?.toString() ?? '',
        publishedAt: publishedAt,
        items: items,
        galleryExists: gallery != null,
      );
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<BookingGallerySnapshot> uploadAndAdd(
    String bookingId,
    XFile file, {
    void Function(double progress)? onProgress,
  }) async {
    final existing = await _getGallery(bookingId);
    if (existing == null) {
      try {
        await _dio.post<dynamic>('bookings/$bookingId/gallery');
      } on DioException catch (error) {
        throw ApiException.fromDio(error);
      }
    }
    final media = await _media.uploadReadyMedia(file, onProgress: onProgress);
    try {
      await _dio.post<dynamic>(
        'bookings/$bookingId/gallery/items',
        data: {'media_id': media.id},
      );
    } on DioException catch (error) {
      await _media.cleanupUnreferencedMedia(media.id);
      throw ApiException.fromDio(error);
    } catch (_) {
      await _media.cleanupUnreferencedMedia(media.id);
      rethrow;
    }
    return get(bookingId);
  }

  Future<BookingGallerySnapshot> publish(String bookingId) async {
    try {
      await _dio.post<dynamic>('bookings/$bookingId/gallery/publish');
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
    final snapshot = await get(bookingId);
    if (snapshot.publishedAt == null) {
      throw const ApiException(
        'Backend trả thành công nhưng chưa xác nhận thời điểm công bố gallery.',
      );
    }
    return snapshot;
  }

  Future<Map<String, dynamic>?> _getGallery(String bookingId) async {
    try {
      final response = await _dio.get<dynamic>('bookings/$bookingId/gallery');
      return _asMap(_unwrap(response.data));
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) return null;
      throw ApiException.fromDio(error);
    }
  }
}

final apiBookingGalleryRepositoryProvider =
    Provider<ApiBookingGalleryRepository>(
      (ref) => ApiBookingGalleryRepository(
        ref.watch(dioProvider),
        ref.watch(apiPortfolioRepositoryProvider),
      ),
    );

final bookingGalleryProvider =
    FutureProvider.family<BookingGallerySnapshot, String>((ref, bookingId) {
      final user = ref.watch(authUserProvider);
      if (user == null || user.role != 'photographer') {
        throw StateError('Vui lòng đăng nhập tài khoản nhiếp ảnh gia');
      }
      return ref.read(apiBookingGalleryRepositoryProvider).get(bookingId);
    });

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
  throw const ApiException(
    'Backend trả về dữ liệu booking gallery không hợp lệ.',
  );
}
