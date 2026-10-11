import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  factory ApiException.fromDio(DioException error) {
    final statusCode = error.response?.statusCode;
    final body = error.response?.data;
    final backendMessage = body is Map ? body['message'] : null;

    if (statusCode == 401) {
      if (backendMessage is String &&
          backendMessage.trim().isNotEmpty &&
          backendMessage.trim().toLowerCase() != 'unauthorized') {
        return ApiException(backendMessage.trim(), statusCode: statusCode);
      }
      return const ApiException(
        'Email hoặc mật khẩu không chính xác. Vui lòng kiểm tra lại.',
        statusCode: 401,
      );
    }

    if (backendMessage is String && backendMessage.trim().isNotEmpty) {
      final msg = backendMessage.trim();
      if (msg.contains('Keycloak request failed with status 400') ||
          msg.contains('Keycloak rejected the registration details')) {
        return ApiException(
          'Thông tin đăng ký không hợp lệ hoặc đã tồn tại. Vui lòng kiểm tra lại Họ tên và Email.',
          statusCode: statusCode,
        );
      }
      if (msg.contains('Keycloak user already exists') ||
          msg.contains('User exists with same email')) {
        return ApiException(
          'Email này đã được đăng ký trong hệ thống. Vui lòng dùng email khác hoặc đăng nhập.',
          statusCode: statusCode,
        );
      }
      return ApiException(msg, statusCode: statusCode);
    }
    if (backendMessage is List && backendMessage.isNotEmpty) {
      return ApiException(
        backendMessage.map((item) => item.toString()).join('\n'),
        statusCode: statusCode,
      );
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return ApiException(
        'Kết nối đến máy chủ quá thời gian. Vui lòng thử lại.',
        statusCode: statusCode,
      );
    }
    if (error.type == DioExceptionType.connectionError) {
      return ApiException(
        'Không thể kết nối đến máy chủ. Vui lòng kiểm tra mạng hoặc đảm bảo backend đang hoạt động.',
        statusCode: statusCode,
      );
    }
    if (statusCode != null) {
      if (statusCode == 403) {
        return ApiException(
          'Bạn không có quyền thực hiện thao tác này.',
          statusCode: statusCode,
        );
      }
      if (statusCode == 404) {
        return ApiException(
          'Không tìm thấy dịch vụ yêu cầu (HTTP 404).',
          statusCode: statusCode,
        );
      }
      if (statusCode >= 500) {
        return ApiException(
          'Máy chủ gặp sự cố (HTTP $statusCode). Vui lòng thử lại sau.',
          statusCode: statusCode,
        );
      }
      return ApiException(
        'Yêu cầu thất bại (HTTP $statusCode).',
        statusCode: statusCode,
      );
    }
    return const ApiException(
      'Không thể kết nối đến máy chủ. Vui lòng kiểm tra mạng.',
    );
  }

  @override
  String toString() => message;
}
