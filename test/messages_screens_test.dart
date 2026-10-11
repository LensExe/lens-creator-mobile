import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lens_creator_mobile/features/photographer/messages/chat_detail_screen.dart';
import 'package:lens_creator_mobile/features/photographer/messages/messages_list_screen.dart';

void main() {
  testWidgets('message list explains that Backend messaging is unavailable', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: MessagesListScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Tin nhắn chưa được hỗ trợ'), findsOneWidget);
    expect(
      find.textContaining('Backend hiện chưa cung cấp API'),
      findsOneWidget,
    );
    expect(find.text('Nguyễn Thuý An'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('chat detail never shows mock conversation content', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: ChatDetailScreen(id: 'sample-thread')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Không thể mở cuộc trò chuyện'), findsOneWidget);
    expect(
      find.textContaining('Backend hiện chưa cung cấp API'),
      findsOneWidget,
    );
    expect(find.text('Tin nhắn kiểm tra giao diện'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
