import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../../providers/data_providers.dart';

class PortfolioAsset {
  const PortfolioAsset({
    required this.portfolioId,
    required this.portfolioItemId,
    required this.mediaId,
    required this.position,
    required this.url,
  });

  final String portfolioId;
  final String portfolioItemId;
  final String mediaId;
  final int position;
  final String url;
}

class PortfolioAlbum {
  const PortfolioAlbum({
    required this.id,
    required this.name,
    required this.itemIds,
  });

  final String id;
  final String name;
  final List<String> itemIds;
}

class PortfolioWorkspace {
  const PortfolioWorkspace({required this.albums, required this.assets});

  final List<PortfolioAlbum> albums;
  final List<PortfolioAsset> assets;
}

class UploadedMedia {
  const UploadedMedia({
    required this.id,
    required this.previewUrl,
    required this.downloadUrl,
  });

  final String id;
  final String? previewUrl;
  final String? downloadUrl;
}

class ApiPortfolioRepository {
  const ApiPortfolioRepository(this._dio);

  final Dio _dio;

  Future<PortfolioWorkspace> getMine() async {
    final albums = await _listMine();
    final assets = <PortfolioAsset>[];
    for (final album in albums) {
      for (var index = 0; index < album.itemIds.length; index++) {
        final mediaId = album.itemIds[index];
        final media = await _getMedia(mediaId);
        if (media.status != 'ready') continue;
        final url = media.previewUrl ?? media.downloadUrl;
        if (url == null || url.isEmpty) continue;
        assets.add(
          PortfolioAsset(
            portfolioId: album.id,
            portfolioItemId: mediaId,
            mediaId: mediaId,
            position: index,
            url: url,
          ),
        );
      }
    }
    return PortfolioWorkspace(albums: albums, assets: assets);
  }

  Future<PortfolioAsset> uploadAndAdd(
    XFile file, {
    String? portfolioId,
    String? newAlbumName,
    void Function(double progress)? onProgress,
  }) async {
    final media = await uploadReadyMedia(file, onProgress: onProgress);
    final url = media.previewUrl ?? media.downloadUrl;
    if (url == null || url.isEmpty) {
      await cleanupUnreferencedMedia(media.id);
      throw const ApiException(
        'Ảnh đã sẵn sàng nhưng Backend chưa trả URL hiển thị.',
      );
    }
    try {
      final albums = await _listMine();
      final album = albums.isEmpty
          ? await _createAlbum(newAlbumName?.trim() ?? '')
          : portfolioId == null
          ? albums.first
          : albums.firstWhere(
              (item) => item.id == portfolioId,
              orElse: () => throw const ApiException(
                'Bộ sưu tập đã thay đổi. Hãy tải lại rồi thử lại.',
              ),
            );
      await _addItem(album.id, media.id);
      return PortfolioAsset(
        portfolioId: album.id,
        portfolioItemId: media.id,
        mediaId: media.id,
        position: album.itemIds.length,
        url: url,
      );
    } catch (_) {
      await cleanupUnreferencedMedia(media.id);
      rethrow;
    }
  }

  Future<UploadedMedia> uploadReadyMedia(
    XFile file, {
    void Function(double progress)? onProgress,
  }) async {
    final contentType = _contentType(file.name);
    final fileSize = await file.length();
    if (fileSize <= 0 || fileSize > 104857600) {
      throw const ApiException('Ảnh phải có dung lượng từ 1 byte đến 100 MB.');
    }

    String? mediaId;
    try {
      final upload = await _requestUploadUrl(
        contentType: contentType,
        fileSize: fileSize,
      );
      mediaId = upload.mediaId;
      final bytes = await file.readAsBytes();
      await _putToSignedUrl(upload.url, bytes, contentType, onProgress);
      await _completeUpload(mediaId);
      onProgress?.call(1);

      final media = await _waitUntilReady(mediaId);
      return UploadedMedia(
        id: mediaId,
        previewUrl: media.previewUrl,
        downloadUrl: media.downloadUrl,
      );
    } catch (error) {
      if (mediaId != null) await cleanupUnreferencedMedia(mediaId);
      rethrow;
    }
  }

  Future<void> cleanupUnreferencedMedia(String mediaId) async {
    try {
      await _dio.delete<dynamic>('media/$mediaId');
    } on DioException {
      // Backend refuses cleanup when a failed request already referenced it.
    }
  }

  Future<void> removeItem(PortfolioAsset item) async {
    try {
      await _dio.delete<dynamic>(
        'portfolios/${item.portfolioId}/items/${item.portfolioItemId}',
      );
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> reorderAlbum(String portfolioId, List<String> mediaIds) async {
    try {
      await _dio.patch<dynamic>(
        'portfolios/$portfolioId/items/reorder',
        data: {'portfolio_item_ids': mediaIds},
      );
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<List<PortfolioAlbum>> _listMine() async {
    const limit = 100;
    var offset = 0;
    var total = 1;
    final albums = <PortfolioAlbum>[];
    try {
      while (offset < total) {
        final response = await _dio.get<dynamic>(
          'photographers/me/portfolios',
          queryParameters: {'limit': limit, 'offset': offset},
        );
        final body = _asMap(_unwrap(response.data));
        final rows = body['items'];
        if (rows is! List) {
          throw const ApiException(
            'Backend trả về danh sách portfolio không hợp lệ.',
          );
        }
        for (final row in rows) {
          final json = _asMap(row);
          final rawIds = json['items'];
          albums.add(
            PortfolioAlbum(
              id: _requiredString(json['id'], 'portfolio.id'),
              name: json['name']?.toString() ?? '',
              itemIds: rawIds is List
                  ? rawIds.map((id) => '$id').toList()
                  : const [],
            ),
          );
        }
        total = _asInt(body['total'], albums.length);
        if (rows.isEmpty) break;
        offset += rows.length;
        if (rows.length < limit) break;
      }
      return albums;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<PortfolioAlbum> _createAlbum(String name) async {
    if (name.isEmpty) {
      throw const ApiException('Nhập tên bộ sưu tập trước khi tải ảnh lên.');
    }
    try {
      final response = await _dio.post<dynamic>(
        'photographers/me/portfolios',
        data: {'name': name},
      );
      final body = _asMap(_unwrap(response.data));
      return PortfolioAlbum(
        id: _requiredString(body['id'], 'portfolio.id'),
        name: body['name']?.toString() ?? name,
        itemIds: const [],
      );
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<_MediaUpload> _requestUploadUrl({
    required String contentType,
    required int fileSize,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        'media/upload-url',
        data: {
          'content_type': contentType,
          'file_size': fileSize,
          'visibility': 'private',
        },
      );
      final body = _asMap(_unwrap(response.data));
      final media = _asMap(body['media']);
      return _MediaUpload(
        mediaId: _requiredString(media['id'], 'media.id'),
        url: _requiredString(body['upload_url'], 'upload_url'),
      );
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> _putToSignedUrl(
    String url,
    Uint8List bytes,
    String contentType,
    void Function(double progress)? onProgress,
  ) async {
    try {
      final response =
          await Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 20),
              sendTimeout: const Duration(minutes: 2),
              receiveTimeout: const Duration(seconds: 30),
              headers: const {'Accept': '*/*'},
            ),
          ).put<dynamic>(
            url,
            data: Stream<List<int>>.value(bytes),
            options: Options(
              headers: {
                'Content-Type': contentType,
                'Content-Length': bytes.length,
              },
              contentType: contentType,
              responseType: ResponseType.plain,
            ),
            onSendProgress: (sent, total) {
              if (total > 0) onProgress?.call(sent / total);
            },
          );
      if (response.statusCode == null ||
          response.statusCode! < 200 ||
          response.statusCode! >= 300) {
        throw ApiException(
          'Kho lưu trữ từ chối upload (HTTP ${response.statusCode ?? 'không rõ'}).',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (error) {
      throw ApiException(
        'Upload ảnh lên kho lưu trữ thất bại${error.response?.statusCode == null ? '' : ' (HTTP ${error.response!.statusCode})'}.',
        statusCode: error.response?.statusCode,
      );
    }
  }

  Future<void> _completeUpload(String mediaId) async {
    try {
      await _dio.post<dynamic>(
        'media/complete-upload',
        data: {'media_id': mediaId},
      );
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<_MediaDetails> _waitUntilReady(String mediaId) async {
    for (var attempt = 0; attempt < 40; attempt++) {
      final media = await _getMedia(mediaId);
      if (media.status == 'ready') return media;
      if (media.status == 'failed' || media.status == 'deleted') {
        throw ApiException('Backend xử lý ảnh thất bại (${media.status}).');
      }
      await Future<void>.delayed(const Duration(seconds: 2));
    }
    throw const ApiException(
      'Ảnh vẫn đang được Backend xử lý. Hãy thử tải lại portfolio sau ít phút.',
    );
  }

  Future<_MediaDetails> _getMedia(String mediaId) async {
    try {
      final response = await _dio.get<dynamic>('media/$mediaId');
      final body = _asMap(_unwrap(response.data));
      return _MediaDetails(
        status: body['status']?.toString() ?? 'unknown',
        previewUrl: body['preview_url']?.toString(),
        downloadUrl: body['download_url']?.toString(),
      );
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> _addItem(String portfolioId, String mediaId) async {
    try {
      await _dio.post<dynamic>(
        'portfolios/$portfolioId/items',
        data: {'media_id': mediaId},
      );
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  String _contentType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    return switch (extension) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => throw const ApiException(
        'Backend chỉ nhận ảnh JPEG, PNG hoặc WEBP. Hãy chọn lại file.',
      ),
    };
  }
}

class _MediaUpload {
  const _MediaUpload({required this.mediaId, required this.url});
  final String mediaId;
  final String url;
}

class _MediaDetails {
  const _MediaDetails({
    required this.status,
    required this.previewUrl,
    required this.downloadUrl,
  });
  final String status;
  final String? previewUrl;
  final String? downloadUrl;
}

final apiPortfolioRepositoryProvider = Provider<ApiPortfolioRepository>(
  (ref) => ApiPortfolioRepository(ref.watch(dioProvider)),
);

final photographerPortfolioProvider = FutureProvider<PortfolioWorkspace>((ref) {
  final user = ref.watch(authUserProvider);
  if (user == null || user.role != 'photographer') {
    throw StateError('Vui lòng đăng nhập tài khoản nhiếp ảnh gia');
  }
  return ref.read(apiPortfolioRepositoryProvider).getMine();
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
  throw const ApiException('Backend trả về dữ liệu portfolio không hợp lệ.');
}

String _requiredString(Object? value, String field) {
  if (value is String && value.trim().isNotEmpty) return value.trim();
  throw ApiException('Backend không trả về trường $field.');
}

int _asInt(Object? value, int fallback) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? fallback;
}
