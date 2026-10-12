import 'package:dio/dio.dart';

import '../../core/network/api_exception.dart';
import '../../core/network/auth_session_store.dart';
import '../../domain/models/models.dart';
import '../../domain/repositories/auth_repository.dart';

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._dio, this._sessionStore);

  final Dio _dio;
  final AuthSessionStore _sessionStore;

  @override
  Future<User> register(
    String name,
    String email,
    String password, {
    required String location,
    required List<String> styles,
  }) async {
    if (location.trim().isEmpty || styles.isEmpty) {
      throw const ApiException(
        'Hồ sơ cần có khu vực hoạt động và ít nhất một phong cách chụp.',
      );
    }
    final user = await _authenticate('auth/register', {
      'role': 'photographer',
      'fullname': name.trim(),
      'email': email.trim(),
      'password': password,
    }, fallbackRole: 'photographer');
    try {
      final response = await _dio.post<dynamic>(
        'photographers/profile',
        data: {'location': location.trim(), 'styles': styles},
      );
      final profile = _asMap(response.data);
      if (profile['verification_status'] != 'pending') {
        throw const ApiException(
          'Backend chưa xác nhận hồ sơ nhiếp ảnh gia đang chờ xét duyệt.',
        );
      }
    } on DioException catch (error) {
      await _discardSession();
      throw ApiException.fromDio(error);
    } on Object {
      await _discardSession();
      rethrow;
    }
    await _discardSession();
    return user;
  }

  @override
  Future<User> login(String email, String password) async {
    // AUTH-009's published response omits user.role. The following
    // photographers/me request still verifies role and approval status.
    final user = await _authenticate('auth/login', {
      'email': email.trim(),
      'password': password,
    }, fallbackRole: 'photographer');
    late final String status;
    try {
      final response = await _dio.get<dynamic>('photographers/me');
      final profile = _asMap(_unwrap(response.data));
      status = profile['verification_status']?.toString() ?? '';
    } on DioException catch (error) {
      await _discardSession();
      throw ApiException.fromDio(error);
    } on Object {
      await _discardSession();
      rethrow;
    }
    if (status == 'verified') {
      try {
        final saved = await _readCurrentProfile(user);
        await _sessionStore.updateUser(saved);
        return saved;
      } on DioException catch (error) {
        await _discardSession();
        throw ApiException.fromDio(error);
      } on Object {
        await _discardSession();
        rethrow;
      }
    }

    final message = switch (status) {
      'pending' => 'Hồ sơ nhiếp ảnh gia đang chờ xét duyệt.',
      'rejected' => 'Hồ sơ bị từ chối. Ứng dụng chưa hỗ trợ cập nhật và gửi lại; vui lòng liên hệ LENS.',
      'unverified' => 'Hồ sơ chưa được gửi xét duyệt. Ứng dụng chưa hỗ trợ hoàn tất hồ sơ này; vui lòng liên hệ LENS.',
      _ => 'Backend chưa trả về trạng thái xác minh hợp lệ cho hồ sơ.',
    };
    await _discardSession();
    throw ApiException(message);
  }

  @override
  Future<User> updateProfile(User user) async {
    final current = _sessionStore.session?.user;
    if (current == null) throw const ApiException('Vui lòng đăng nhập.');
    final normalized = user.copyWith(
      name: user.name.trim(),
      phone: user.phone.trim(),
      birthday: user.birthday.trim(),
      gender: user.gender.trim(),
      city: user.city.trim(),
      addressDetail: user.addressDetail.trim(),
    );
    if (normalized.id != current.id) {
      throw const ApiException('Không thể cập nhật hồ sơ của tài khoản khác.');
    }
    if (normalized.addressDetail != current.addressDetail.trim()) {
      throw const ApiException(
        'Backend chưa có trường địa chỉ chi tiết cho hồ sơ photographer.',
      );
    }

    final body = <String, String>{};
    if (normalized.name != current.name) {
      if (normalized.name.isEmpty) {
        throw const ApiException('Họ tên không được để trống.');
      }
      body['fullname'] = normalized.name;
    }
    if (normalized.phone != current.phone) {
      if (normalized.phone.isEmpty) {
        throw const ApiException(
          'Backend hiện không hỗ trợ xóa số điện thoại đã xác minh.',
        );
      }
      body['phone_number'] = normalized.phone;
    }
    if (normalized.gender != current.gender) {
      if (normalized.gender.isEmpty) {
        throw const ApiException('Backend hiện không hỗ trợ xóa giới tính.');
      }
      body['gender'] = normalized.gender;
    }
    if (normalized.birthday != current.birthday) {
      if (normalized.birthday.isEmpty) {
        throw const ApiException('Backend hiện không hỗ trợ xóa ngày sinh.');
      }
      body['dob'] = normalized.birthday;
    }

    final cityChanged = normalized.city != current.city;
    if (cityChanged && normalized.city.isEmpty) {
      throw const ApiException('Khu vực phục vụ không được để trống.');
    }

    try {
      if (body.isNotEmpty) {
        await _dio.patch<dynamic>('users/me', data: body);
      }
      if (cityChanged) {
        await _dio.patch<dynamic>(
          'photographers/me/location',
          data: {'location': normalized.city},
        );
      }
      final saved = await _readCurrentProfile(normalized);
      await _sessionStore.updateUser(saved);
      return saved;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  @override
  Future<User> readCurrentProfile() async {
    final current = _sessionStore.session?.user;
    if (current == null) throw const ApiException('Vui lòng đăng nhập.');
    try {
      final saved = await _readCurrentProfile(current);
      await _sessionStore.updateUser(saved);
      return saved;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<User> _readCurrentProfile(User fallback) async {
    final responses = await Future.wait([
      _dio.get<dynamic>('users/me'),
      _dio.get<dynamic>('photographers/me'),
    ]);
    final userJson = _asMap(_unwrap(responses[0].data));
    final photographerJson = _asMap(_unwrap(responses[1].data));
    final id = userJson['id']?.toString() ?? fallback.id;
    if (id != fallback.id) {
      throw const ApiException('Backend trả về hồ sơ của tài khoản khác.');
    }
    return fallback.copyWith(
      name: userJson['fullname']?.toString() ?? fallback.name,
      phone: userJson['phone_number']?.toString() ?? '',
      birthday: userJson['dob']?.toString() ?? '',
      gender: userJson['gender']?.toString() ?? '',
      city: photographerJson['location']?.toString() ?? '',
    );
  }

  @override
  Future<void> logout() async {
    final refreshToken = _sessionStore.refreshToken;
    try {
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _dio
            .post<dynamic>(
              'auth/logout',
              data: {'refresh_token': refreshToken},
              options: Options(
                sendTimeout: const Duration(seconds: 3),
                receiveTimeout: const Duration(seconds: 3),
              ),
            )
            .timeout(const Duration(seconds: 3));
      }
    } catch (_) {
      // Best-effort remote revocation. Local logout always clears device storage.
    } finally {
      await _sessionStore.clear();
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dio.post<dynamic>(
        'auth/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'confirm_password': newPassword,
        },
      );
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<User> _authenticate(
    String path,
    Map<String, Object?> body, {
    String? fallbackRole,
  }) async {
    try {
      final response = await _dio.post<dynamic>(path, data: body);
      final data = _asMap(_unwrap(response.data));
      final session = AuthSessionData.fromApiJson(
        data,
        fallbackRole: fallbackRole,
      );
      if (session.user.role != 'photographer') {
        throw const ApiException(
          'Ứng dụng Creator chỉ hỗ trợ tài khoản nhiếp ảnh gia.',
        );
      }
      await _sessionStore.save(session);
      return session.user;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> _discardSession() async {
    final refreshToken = _sessionStore.refreshToken;
    try {
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _dio.post<dynamic>(
          'auth/logout',
          data: {'refresh_token': refreshToken},
        );
      }
    } on DioException {
      // Best-effort revocation. Local secure storage is always cleared below.
    } finally {
      try {
        await _sessionStore.clear();
      } on Object {
        // The store clears its in-memory session before secure deletion.
      }
    }
  }
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.map((key, value) => MapEntry('$key', value));
  throw const ApiException('Backend trả về dữ liệu không đúng cấu trúc.');
}

Object? _unwrap(Object? value) {
  var result = value;
  while (result is Map && result.containsKey('data')) {
    result = result['data'];
  }
  return result;
}
