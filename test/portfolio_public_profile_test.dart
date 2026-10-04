import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lens_creator_mobile/domain/models/models.dart';
import 'package:lens_creator_mobile/domain/models/review.dart';
import 'package:lens_creator_mobile/features/photographer/portfolio/portfolio_screen.dart';
import 'package:lens_creator_mobile/features/photographer/portfolio/public_profile_screen.dart';
import 'package:lens_creator_mobile/features/photographer/reviews/review_provider.dart';
import 'package:lens_creator_mobile/providers/data_providers.dart';

void main() {
  final profile = Photographer(
    id: 'me',
    name: 'Nguyễn Lan Chi',
    avatar: '',
    cover: '',
    city: 'Đà Nẵng',
    styles: const ['Chân dung', 'Gia đình'],
    pricePerSession: 245000,
    rating: 4.8,
    reviewCount: 7,
    bio: 'Chân dung tự nhiên và những khoảnh khắc gia đình.',
    experienceYears: 5,
    portfolio: const [],
    packages: [
      PhotographerPackage(
        id: 'portrait',
        name: 'Gói Chân Dung',
        duration: 'Buổi chụp cá nhân',
        price: 245000,
        description: 'Dành cho ảnh chân dung cá nhân.',
        photoCount: 18,
        durationHours: 1.5,
        deliveryDays: 6,
      ),
    ],
  );

  final reviews = [
    const Review(
      id: 'review-1',
      photographerId: 'me',
      authorName: 'Khách hàng A',
      authorAvatar: '',
      rating: 5,
      comment: 'Buổi chụp thoải mái, ảnh rất tự nhiên.',
      date: '2026-09-24',
    ),
  ];

  void setViewport(WidgetTester tester, Size size) {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('portfolio stays usable on narrow and large phone layouts', (
    tester,
  ) async {
    for (final size in [const Size(320, 640), const Size(430, 932)]) {
      setViewport(tester, size);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [myPhotographerProvider.overrideWith((ref) => profile)],
          child: const MaterialApp(home: PortfolioScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('HỒ SƠ NĂNG LỰC'), findsNWidgets(2));
      expect(find.text(profile.name), findsOneWidget);
      expect(find.text(profile.bio), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.scrollUntilVisible(
        find.text('Chỉnh sửa'),
        180,
        scrollable: find
            .descendant(
              of: find.byType(PortfolioScreen),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.tap(find.text('Chỉnh sửa').last);
      await tester.pumpAndSettle();
      expect(find.text('Chỉnh sửa hồ sơ'), findsOneWidget);
      expect(find.text('Lưu hồ sơ'), findsOneWidget);
      final layoutError = tester.takeException();
      expect(layoutError, isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('portfolio add action uses the existing HTTPS URL editor', (
    tester,
  ) async {
    setViewport(tester, const Size(430, 932));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [myPhotographerProvider.overrideWith((ref) => profile)],
        child: const MaterialApp(home: PortfolioScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Thêm ảnh'));
    await tester.pumpAndSettle();
    expect(find.text('Đường dẫn ảnh HTTPS'), findsOneWidget);
    await tester.enterText(
      find.byType(TextField).last,
      'https://example.com/portrait.jpg',
    );
    await tester.tap(find.text('Thêm ảnh').last);
    await tester.pumpAndSettle();
    expect(find.text('Chỉnh sửa hồ sơ'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('public profile tabs show existing package and review data', (
    tester,
  ) async {
    for (final size in [const Size(320, 640), const Size(430, 932)]) {
      setViewport(tester, size);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            myPhotographerProvider.overrideWith((ref) => profile),
            photographerReviewsProvider.overrideWith((ref) async => reviews),
          ],
          child: const MaterialApp(home: PublicProfileScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(profile.name), findsOneWidget);
      expect(find.textContaining('7 đánh giá'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.ensureVisible(find.text('Giới thiệu').last);
      await tester.tap(find.text('Giới thiệu').last);
      await tester.pumpAndSettle();
      expect(find.text('Gói dịch vụ nhiếp ảnh'), findsOneWidget);
      expect(find.text('Gói Chân Dung'), findsOneWidget);
      expect(find.text('Dành cho ảnh chân dung cá nhân.'), findsOneWidget);

      await tester.ensureVisible(find.text('Đánh giá').last);
      await tester.tap(find.text('Đánh giá').last);
      await tester.pumpAndSettle();
      expect(
        find.text('Buổi chụp thoải mái, ảnh rất tự nhiên.'),
        findsOneWidget,
      );
      expect(find.text('Xem tất cả đánh giá'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });
}
