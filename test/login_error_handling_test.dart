import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lens_creator_mobile/core/network/api_exception.dart';
import 'package:lens_creator_mobile/domain/models/models.dart';
import 'package:lens_creator_mobile/domain/repositories/auth_repository.dart';
import 'package:lens_creator_mobile/features/auth/login_screen.dart';
import 'package:lens_creator_mobile/providers/data_providers.dart';

class _FailingAuthRepository implements AuthRepository {
  _FailingAuthRepository(this.errorToThrow);

  final Object errorToThrow;

  @override
  Future<User> login(String email, String password) async {
    throw errorToThrow;
  }

  @override
  Future<User> register(
    String name,
    String email,
    String password, {
    required String location,
    required List<String> styles,
  }) async {
    throw errorToThrow;
  }

  @override
  Future<User> updateProfile(User user) async => user;

  @override
  Future<User> readCurrentProfile() async {
    throw errorToThrow;
  }

  @override
  Future<void> logout() async {}

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {}
}

Widget _createTestApp(AuthRepository repository) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LoginScreen(),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(repository),
    ],
    child: MaterialApp.router(
      routerConfig: router,
    ),
  );
}

void main() {
  testWidgets(
    'shows friendly SnackBar and no raw inline error when login fails with 401',
    (tester) async {
      await tester.pumpWidget(
        _createTestApp(
          _FailingAuthRepository(
            const ApiException(
              'Email hoặc mật khẩu không chính xác. Vui lòng kiểm tra lại.',
              statusCode: 401,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'wrong@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'wrongpass');
      await tester.tap(find.text('Đăng nhập'));
      await tester.pump();

      // Verify SnackBar is shown with the friendly message
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text('Email hoặc mật khẩu không chính xác. Vui lòng kiểm tra lại.'),
        findsOneWidget,
      );

      // Verify no raw provider or stack trace strings exist in widget tree
      expect(find.textContaining('ProviderException'), findsNothing);
      expect(find.textContaining('stack trace'), findsNothing);
    },
  );

  testWidgets(
    'masks unexpected internal exceptions into friendly user message without crashing UI',
    (tester) async {
      await tester.pumpWidget(
        _createTestApp(
          _FailingAuthRepository(
            Exception(
              'ProviderException: Tried to use a provider that is in error state.\n#0 stack trace',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'test@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'secret123');
      await tester.tap(find.text('Đăng nhập'));
      await tester.pump();

      // Verify friendly SnackBar is shown instead of raw stack trace
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text('Không thể kết nối đến hệ thống máy chủ. Vui lòng thử lại sau.'),
        findsOneWidget,
      );
      expect(find.textContaining('stack trace'), findsNothing);
    },
  );
}
