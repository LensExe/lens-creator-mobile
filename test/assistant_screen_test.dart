import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lens_creator_mobile/data/mock_database.dart';
import 'package:lens_creator_mobile/features/photographer/assistant/assistant_screen.dart';

void main() {
  setUp(() {
    MockDatabase.currentUser = MockDatabase.photographerUser;
  });

  tearDown(() {
    MockDatabase.currentUser = null;
  });

  testWidgets('assistant editor fits a compact mobile viewport', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 700);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: AssistantScreen())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Thiết lập cách trợ lý phản hồi'), findsOneWidget);
    expect(find.text('Kích hoạt trợ lý'), findsOneWidget);
    expect(find.text('Thông tin trả lời'), findsOneWidget);
    expect(find.text('Lưu thay đổi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
