import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lens_creator_mobile/features/photographer/achievements/achievement_provider.dart';
import 'package:lens_creator_mobile/features/photographer/achievements/achievements_screen.dart';
import 'package:lens_creator_mobile/features/photographer/achievements/models/photographer_achievements.dart';

const _demoAchievements = PhotographerAchievements(
  photographerId: 'me',
  completedSessions: 27,
  fiveStarPct: 92,
  returningClients: 8,
  cancelRate: 4,
  badges: ['fast-reply', 'punctual', 'loyal'],
);

Widget _screen(Future<PhotographerAchievements> Function(Ref ref) load) =>
    ProviderScope(
      overrides: [photographerAchievementsProvider.overrideWith(load)],
      child: const MaterialApp(home: AchievementsScreen()),
    );

void main() {
  testWidgets(
    'renders real achievement data and fee explanation on narrow mobile',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 740);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_screen((ref) async => _demoAchievements));
      await tester.pumpAndSettle();

      expect(find.text('Thành Tựu & Cấp Bậc'), findsOneWidget);
      expect(find.text('Thợ Đồng'), findsWidgets);
      expect(find.text('27 / 30 buổi'), findsOneWidget);
      expect(find.text('Còn 3 buổi'), findsOneWidget);
      expect(find.text('Phí 9% → 8%'), findsOneWidget);
      expect(find.text('4.9'), findsNothing);
      expect(find.text('42%'), findsNothing);
      expect(tester.takeException(), isNull);

      await tester.scrollUntilVisible(
        find.text('Thành tích nổi bật'),
        260,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('92%'), findsOneWidget);
      expect(find.text('8'), findsWidgets);
      expect(tester.takeException(), isNull);

      await tester.scrollUntilVisible(
        find.text('Huy hiệu chuyên môn'),
        260,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('3/6 đã mở khóa'), findsOneWidget);

      await tester.tap(find.text('Giải thích'));
      await tester.pumpAndSettle();

      expect(find.text('Giải thích cấp bậc & phí sàn'), findsOneWidget);
      expect(find.text('Thợ Bạc (30 buổi)'), findsOneWidget);
      expect(find.text('Đã hiểu'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Đã hiểu'));
      await tester.pumpAndSettle();
      expect(find.text('Giải thích cấp bậc & phí sàn'), findsNothing);
    },
  );

  testWidgets('uses a centered fee dialog on a wide layout', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1000, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_screen((ref) async => _demoAchievements));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Giải thích'));
    await tester.pumpAndSettle();

    expect(
      find.text('Mức phí sàn giảm theo các mốc số buổi chụp đã hoàn thành.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('handles a new creator and long metrics at the highest rank', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 740);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const newCreator = PhotographerAchievements(
      photographerId: 'new-creator',
      completedSessions: 0,
      fiveStarPct: 0,
      returningClients: 0,
      cancelRate: 0,
      badges: [],
    );
    await tester.pumpWidget(_screen((ref) async => newCreator));
    await tester.pumpAndSettle();
    expect(find.text('Tân binh'), findsWidgets);
    expect(find.text('Còn 10 buổi'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Huy hiệu chuyên môn'),
      260,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('0/6 đã mở khóa'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    const topRank = PhotographerAchievements(
      photographerId: 'top-creator',
      completedSessions: 999999999,
      fiveStarPct: 99,
      returningClients: 999999999,
      cancelRate: 18,
      badges: [
        'yearbook',
        'wedding',
        'fast-reply',
        'punctual',
        'top-rated',
        'loyal',
      ],
    );
    await tester.pumpWidget(_screen((ref) async => topRank));
    await tester.pumpAndSettle();
    expect(find.text('Thợ Kim Cương'), findsWidgets);
    expect(
      find.text('Bạn đang ở cấp bậc cao nhất của lộ trình.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(
      find.text('Tỷ lệ huỷ lịch'),
      260,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.text('Tỷ lệ huỷ đang cao. Cần cải thiện để bảo vệ thứ hạng.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('preserves the loading state and retry action', (tester) async {
    final pending = Completer<PhotographerAchievements>();
    var requests = 0;
    await tester.pumpWidget(
      _screen((ref) {
        requests++;
        if (requests == 1) return pending.future;
        return Future.value(_demoAchievements);
      }),
    );

    expect(find.text('Đang tải thành tựu…'), findsOneWidget);
    pending.completeError(StateError('offline'));
    await tester.pumpAndSettle();
    expect(find.text('Không thể tải thành tựu'), findsOneWidget);

    await tester.tap(find.text('Thử lại'));
    await tester.pumpAndSettle();
    expect(find.text('Hành trình sáng tạo'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps the existing portfolio destination', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = GoRouter(
      initialLocation: '/achievements',
      routes: [
        GoRoute(
          path: '/achievements',
          builder: (context, state) => const AchievementsScreen(),
        ),
        GoRoute(
          path: '/photographer_home/portfolio',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Hồ sơ năng lực đích'))),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          photographerAchievementsProvider.overrideWith(
            (ref) async => _demoAchievements,
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Cập nhật hồ sơ năng lực'),
      280,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Cập nhật hồ sơ năng lực'));
    await tester.pumpAndSettle();

    expect(find.text('Hồ sơ năng lực đích'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
