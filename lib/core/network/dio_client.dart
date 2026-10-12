import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_config.dart';
import 'auth_session_store.dart';
import 'session_interceptor.dart';

final dioProvider = Provider<Dio>((ref) {
  final baseUrl = ref.watch(apiConfigProvider).requireBaseUrl();
  final sessionStore = ref.watch(authSessionStoreProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: const {'Accept': 'application/json'},
    ),
  );
  dio.interceptors.add(
    SessionInterceptor(dio: dio, baseUrl: baseUrl, sessionStore: sessionStore),
  );

  return dio;
});
