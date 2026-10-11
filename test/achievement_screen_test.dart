import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lens_creator_mobile/features/photographer/achievements/achievement_provider.dart';
import 'package:lens_creator_mobile/features/photographer/achievements/achievements_screen.dart';
import 'package:lens_creator_mobile/features/photographer/achievements/models/photographer_achievements.dart';
import 'package:lens_creator_mobile/features/photographer/achievements/models/photographer_rank.dart';

const _backendShapedAchievements = PhotographerAchievements(
  photographerId: 'photographer-uuid',
  currentRankCode: 'starter',
  currentRankName: 'Người mới',
  averageRating: 4.7,
  totalFeedbacks: 12,
  totalBookings: 18,
  returnCustomers: 3,
  ranks: [
    PhotographerRank(
      id: 'rank-uuid',
      code: 'starter',
      name: 'Người mới',
      minimumSessions: 10,
      commissionPercent: 10,
    ),
  ],
  badges: [
    PhotographerBadge(
      id: 'badge-uuid',
      code: 'high-rating',
      name: 'Đánh giá tốt',
      description: 'Duy trì điểm đánh giá',
      metric: 'average_rating',
      minimumValue: 4.5,
      minimumReviews: 5,
      isActive: true,
    ),
  ],
  earnedBadgeCodes: {'high-rating'},
);

Widget _screen(Future<PhotographerAchievements> Function(Ref ref) load) =>
    ProviderScope(
      overrides: [photographerAchievementsProvider.overrideWith(load)],
      child: const MaterialApp(home: AchievementsScreen()),
    );

void main() {
  testWidgets('renders only rank and metrics supplied by the repository', (
    tester,
  ) async {
    await tester.pumpWidget(_screen((ref) async => _backendShapedAchievements));
    await tester.pumpAndSettle();

    expect(find.text('Người mới'), findsWidgets);
    expect(find.text('18'), findsOneWidget);
    expect(find.text('4.7'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('Đánh giá tốt'), findsOneWidget);
    expect(find.text('92%'), findsNothing);
    expect(find.text('Tỷ lệ huỷ lịch'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders empty catalogs without inventing ranks or badges', (
    tester,
  ) async {
    const empty = PhotographerAchievements(
      photographerId: 'new-photographer',
      currentRankCode: '',
      currentRankName: '',
      averageRating: 0,
      totalFeedbacks: 0,
      totalBookings: 0,
      returnCustomers: 0,
      ranks: [],
      badges: [],
      earnedBadgeCodes: {},
    );
    await tester.pumpWidget(_screen((ref) async => empty));
    await tester.pumpAndSettle();

    expect(find.text('Chưa có cấp bậc'), findsOneWidget);
    expect(find.text('Backend chưa có danh mục cấp bậc.'), findsOneWidget);
    expect(find.text('Backend chưa có huy hiệu khả dụng.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('preserves loading, error, and retry states', (tester) async {
    final pending = Completer<PhotographerAchievements>();
    var requests = 0;
    await tester.pumpWidget(
      _screen((ref) {
        requests++;
        if (requests == 1) return pending.future;
        return Future.value(_backendShapedAchievements);
      }),
    );

    expect(find.text('Đang tải thành tựu…'), findsOneWidget);
    pending.completeError(StateError('offline'));
    await tester.pumpAndSettle();
    expect(find.text('Không thể tải thành tựu'), findsOneWidget);

    await tester.tap(find.text('Thử lại'));
    await tester.pumpAndSettle();
    expect(find.text('Tổng booking'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
