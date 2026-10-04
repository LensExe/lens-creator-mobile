import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lens_creator_mobile/data/mock_database.dart';
import 'package:lens_creator_mobile/features/photographer/messages/chat_detail_screen.dart';
import 'package:lens_creator_mobile/features/photographer/messages/conversation_provider.dart';
import 'package:lens_creator_mobile/features/photographer/messages/messages_list_screen.dart';

void main() {
  testWidgets(
    'message search, unread filter, send, AI and booking details work',
    (tester) async {
      final previousUser = MockDatabase.currentUser;
      MockDatabase.currentUser = MockDatabase.photographerUser;
      addTearDown(() => MockDatabase.currentUser = previousUser);

      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final router = GoRouter(
        initialLocation: '/photographer_home/messages',
        routes: [
          GoRoute(
            path: '/photographer_home/messages',
            builder: (context, state) => const MessagesListScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) =>
                    ChatDetailScreen(id: state.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: '/photographer_home/booking/:id',
            builder: (context, state) => Scaffold(
              body: Center(
                child: Text('Booking ${state.pathParameters['id']}'),
              ),
            ),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(child: MaterialApp.router(routerConfig: router)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(find.text('LENS Studio'), findsOneWidget);
      expect(find.text('Nguyễn Thuý An'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'Phạm Mai Chi');
      await tester.pumpAndSettle();
      expect(find.text('Phạm Mai Chi'), findsNWidgets(2));
      expect(find.text('Nguyễn Thuý An'), findsNothing);

      await tester.tap(find.byTooltip('Xóa tìm kiếm'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Chưa đọc'));
      await tester.pumpAndSettle();
      expect(find.text('Nguyễn Thuý An'), findsOneWidget);
      expect(find.text('Phạm Mai Chi'), findsNothing);

      await tester.tap(find.text('Tất cả'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Nguyễn Thuý An'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(find.byType(ChatDetailScreen), findsOneWidget);
      final providerScope = ProviderScope.containerOf(
        tester.element(find.byType(ChatDetailScreen)),
      );
      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);
      expect(tester.widget<Switch>(switchFinder).value, isTrue);
      await tester.tap(switchFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      expect(tester.widget<Switch>(switchFinder).value, isFalse);

      final composer = find.byType(TextField).last;
      await tester.enterText(composer, 'Tin nhắn kiểm tra giao diện');
      await tester.tap(find.byTooltip('Gửi tin nhắn'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      expect(find.text('Tin nhắn kiểm tra giao diện'), findsOneWidget);

      await tester.tap(find.byTooltip('Thông tin hội thoại'));
      await tester.pumpAndSettle();
      expect(find.text('Lịch chụp liên quan'), findsOneWidget);
      await tester.tap(find.byTooltip('Đóng'));
      await tester.pumpAndSettle();

      final detailsButton = find.text('Chi tiết');
      expect(detailsButton, findsOneWidget);
      await tester.tap(detailsButton);
      await tester.pumpAndSettle();
      expect(find.textContaining('Booking '), findsOneWidget);
      expect(tester.takeException(), isNull);

      final conversation = providerScope
          .read(conversationsProvider)
          .singleWhere((item) => item.id == 'c1');
      expect(conversation.aiEnabled, isFalse);
      expect(conversation.messages.last.text, 'Tin nhắn kiểm tra giao diện');
    },
  );
}
