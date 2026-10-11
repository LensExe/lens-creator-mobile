import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lens_creator_mobile/core/network/auth_session_store.dart';
import 'package:lens_creator_mobile/data/mock_database.dart';
import 'package:lens_creator_mobile/features/auth/data/mock_auth_repository.dart';
import 'package:lens_creator_mobile/features/photographer/settings/settings_screen.dart';
import 'package:lens_creator_mobile/providers/data_providers.dart';

void main() {
  setUp(() {
    MockDatabase.currentUser = MockDatabase.photographerUser;
  });

  tearDown(() {
    MockDatabase.currentUser = null;
  });

  testWidgets('settings tabs present profile, account and notification UI', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 800);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initialAuthUserProvider.overrideWithValue(
            MockDatabase.photographerUser,
          ),
          authRepositoryProvider.overrideWithValue(MockAuthRepository()),
          myPhotographerProvider.overrideWithValue(
            MockDatabase.photographers.singleWhere((item) => item.id == 'me'),
          ),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hồ sơ công khai'), findsOneWidget);
    expect(find.byTooltip('Đổi ảnh đại diện'), findsNothing);
    expect(find.text('Thông tin cá nhân'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Tài khoản'));
    await tester.pumpAndSettle();
    expect(find.text('Thông tin tài khoản'), findsOneWidget);
    expect(find.text('Bảo mật'), findsOneWidget);
    expect(find.text('Phiên đăng nhập'), findsOneWidget);
    expect(find.text('Đổi mật khẩu'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Thông báo').last);
    await tester.pumpAndSettle();
    expect(
      find.textContaining(
        'Backend hiện chưa có API đọc hoặc cập nhật tùy chọn thông báo',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
