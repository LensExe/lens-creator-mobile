import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lens_creator_mobile/data/mock_database.dart';
import 'package:lens_creator_mobile/features/photographer/settings/settings_screen.dart';

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
      const ProviderScope(child: MaterialApp(home: SettingsScreen())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hồ sơ cá nhân'), findsOneWidget);
    expect(find.text('Đổi ảnh đại diện'), findsOneWidget);
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
    expect(find.text('Hoạt động'), findsOneWidget);
    expect(find.text('Ưu đãi & tổng hợp'), findsOneWidget);
    expect(find.text('Cập nhật lịch đặt'), findsOneWidget);
    expect(find.text('Email tổng hợp hằng tuần'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
