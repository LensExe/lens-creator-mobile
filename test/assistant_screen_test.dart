import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lens_creator_mobile/features/photographer/assistant/assistant_screen.dart';

void main() {
  testWidgets('assistant screen explains Backend capability is unavailable', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 700);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: AssistantScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Trợ lý AI chưa được hỗ trợ'), findsOneWidget);
    expect(find.textContaining('Backend hiện chưa có API'), findsOneWidget);
    expect(find.text('Lưu thay đổi'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
