import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_creator_mobile/core/network/auth_session_store.dart';
import 'package:lens_creator_mobile/data/mock_api_service.dart';
import 'package:lens_creator_mobile/data/mock_database.dart';
import 'package:lens_creator_mobile/data/datasources/mock/mock_achievement_data_source.dart';
import 'package:lens_creator_mobile/data/datasources/mock/mock_review_data_source.dart';
import 'package:lens_creator_mobile/data/datasources/mock/mock_settings_data_source.dart';
import 'package:lens_creator_mobile/domain/booking_rules.dart';
import 'package:lens_creator_mobile/domain/models/models.dart';
import 'package:lens_creator_mobile/features/auth/data/mock_auth_repository.dart';
import 'package:lens_creator_mobile/features/photographer/availability/work_schedule.dart';
import 'package:lens_creator_mobile/features/photographer/availability/mock_availability_repository.dart';
import 'package:lens_creator_mobile/features/photographer/packages/booking_plan_repository.dart';
import 'package:lens_creator_mobile/features/photographer/bookings/widgets/studio_booking_card.dart';
import 'package:lens_creator_mobile/features/photographer/messages/conversation_provider.dart';
import 'package:lens_creator_mobile/features/photographer/wallet/mock_wallet_repository.dart';
import 'package:lens_creator_mobile/features/photographer/portfolio/portfolio_screen.dart';
import 'package:lens_creator_mobile/features/photographer/portfolio/api_portfolio_repository.dart';
import 'package:lens_creator_mobile/features/photographer/packages/edit_package_screen.dart';
import 'package:lens_creator_mobile/features/photographer/packages/widgets/package_editor_actions.dart';
import 'package:lens_creator_mobile/features/photographer/reviews/review_provider.dart';
import 'package:lens_creator_mobile/features/photographer/storage/storage_screen.dart';
import 'package:lens_creator_mobile/features/photographer/storage/subscription_repository.dart';
import 'package:lens_creator_mobile/features/photographer/wallet/wallet_entry.dart';
import 'package:lens_creator_mobile/features/photographer/wallet/wallet_provider.dart';
import 'package:lens_creator_mobile/main.dart';
import 'package:lens_creator_mobile/providers/data_providers.dart';

void main() {
  test('only pending bookings can be accepted or rejected', () {
    expect(
      BookingRules.canTransition(BookingStatus.pending, BookingStatus.accepted),
      isTrue,
    );
    expect(
      BookingRules.canTransition(BookingStatus.pending, BookingStatus.rejected),
      isTrue,
    );
    expect(
      BookingRules.canTransition(
        BookingStatus.pending,
        BookingStatus.confirmed,
      ),
      isFalse,
    );
    expect(
      BookingRules.canTransition(
        BookingStatus.pending,
        BookingStatus.cancelled,
      ),
      isFalse,
    );
    expect(
      BookingRules.canTransition(BookingStatus.confirmed, BookingStatus.held),
      isFalse,
    );
    expect(
      BookingRules.canTransition(BookingStatus.held, BookingStatus.released),
      isFalse,
    );
  });

  test('deposit and payout use the portal rounding rules', () {
    expect(BookingRules.deposit(1234567), 370000);
    expect(BookingRules.commission(1234567), 123000);
    expect(BookingRules.payout(1234567), 1111567);
  });

  test(
    'accepted collaborator payout is rounded and lead gets the remainder',
    () {
      final booking = Booking(
        id: 'split',
        clientId: 'c',
        clientName: 'Khách',
        photographerId: 'me',
        photographerName: 'Lý Gia Hân',
        style: 'Gia đình',
        date: '2026-10-01',
        location: 'Hà Nội',
        price: 400000,
        collaborators: const [
          BookingCollaborator(
            photographerId: 'p3',
            photographerName: 'Hương',
            sharePct: 30,
            status: CollaborationStatus.accepted,
          ),
          BookingCollaborator(
            photographerId: 'p9',
            photographerName: 'Trân',
            sharePct: 20,
          ),
        ],
      );
      expect(BookingRules.payoutFor(booking, 'p3'), 108000);
      expect(BookingRules.payoutFor(booking, 'p9'), 0);
      expect(BookingRules.payoutFor(booking, 'me'), 252000);
    },
  );

  test('photographer cannot see a request before deposit', () {
    final request = Booking(
      id: 'b',
      clientId: 'c',
      clientName: 'Khách',
      photographerId: 'me',
      photographerName: 'Studio',
      style: 'Chân dung',
      date: '2026-10-01',
      location: 'Hà Nội',
      price: 450000,
      status: BookingStatus.awaitingDeposit,
    );
    expect(BookingRules.visibleToPhotographer(request), isFalse);
    expect(
      BookingRules.visibleToPhotographer(
        request.copyWith(status: BookingStatus.pending),
      ),
      isTrue,
    );
  });

  test('demo creator only receives her deposited bookings', () async {
    final bookings = await MockApiService().getMyBookings('me', 'photographer');
    expect(bookings, isNotEmpty);
    expect(bookings.every((booking) => booking.photographerId == 'me'), isTrue);
    expect(
      bookings.any(
        (booking) => booking.status == BookingStatus.awaitingDeposit,
      ),
      isFalse,
    );
    expect(
      bookings.any(
        (booking) => booking.id == 'in-4' && booking.collaborators.length == 2,
      ),
      isTrue,
    );
    expect(
      MockDatabase.bookings.any(
        (booking) =>
            booking.id == 'collab-1' &&
            booking.collaborators.any((item) => item.photographerId == 'me'),
      ),
      isTrue,
    );
  });

  test('photo delivery cannot exceed the booking promise', () async {
    final booking = Booking(
      id: 'gallery-limit-test',
      clientId: 'client-test',
      clientName: 'Khách thử',
      photographerId: 'me',
      photographerName: 'Lý Gia Hân',
      style: 'Chân dung',
      date: MockDatabase.dateFromNow(2),
      location: 'Hà Nội',
      price: 220000,
      promisedPhotos: 2,
      deliveredPhotos: 1,
      status: BookingStatus.held,
    );
    MockDatabase.bookings.add(booking);
    MockDatabase.currentUser = MockDatabase.photographerUser;
    addTearDown(() {
      MockDatabase.bookings.removeWhere((item) => item.id == booking.id);
      MockDatabase.currentUser = null;
    });

    await expectLater(
      MockApiService().addDeliveryPhotos(booking.id, ['photo-1', 'photo-2']),
      throwsStateError,
    );
    expect(
      MockDatabase.bookings
          .singleWhere((item) => item.id == booking.id)
          .deliveredPhotos,
      1,
    );
    final updated = await MockApiService().addDeliveryPhotos(booking.id, [
      'photo-1',
    ]);
    expect(updated.deliveredPhotos, 2);
  });

  test('schedule keeps booked cells locked for the package duration', () {
    final schedule = WorkSchedule.open();
    final booking = Booking(
      id: 'b',
      clientId: 'c',
      clientName: 'Khách',
      photographerId: 'me',
      photographerName: 'Studio',
      style: 'Chân dung',
      date: '2026-10-01',
      location: 'Hà Nội',
      price: 450000,
      timeSlot: '09:00',
      durationHours: 1.5,
      status: BookingStatus.held,
    );
    expect(schedule.isBooked(booking, '2026-10-01', '09:00'), isTrue);
    expect(schedule.isBooked(booking, '2026-10-01', '10:00'), isTrue);
    expect(schedule.isBooked(booking, '2026-10-01', '10:30'), isFalse);
  });

  test('availability repository returns the saved schedule snapshot', () async {
    final repository = MockAvailabilityRepository();
    final draft = WorkSchedule.open();
    draft.weekly[0].clear();

    await repository.saveSchedule('schedule-test', draft);
    final reloaded = await repository.getSchedule('schedule-test');

    expect(reloaded.weekly[0], isEmpty);
    expect(reloaded.weekly[1], isNotEmpty);
  });

  test(
    'wallet repository rejects withdrawals above the available balance',
    () async {
      final repository = MockWalletRepository();
      final transactions = await repository.getTransactions('me');
      expect(
        transactions.fold<int>(0, (sum, entry) => sum + entry.amount),
        400000,
      );
      await expectLater(
        repository.requestWithdraw('me', 400001),
        throwsStateError,
      );
    },
  );

  test(
    'creator auth repository validates and registers creator accounts',
    () async {
      final auth = MockAuthRepository();
      final user = await auth.login(' NHIEPANHGIA@LENS.VN ', 'demo1234');
      expect(user.id, 'me');
      expect(user.role, 'photographer');

      final registered = await auth.register(
        'Người chụp mới',
        'new-creator@lens.vn',
        'secure123',
        location: 'Hà Nội',
        styles: const ['portrait'],
      );
      expect(registered.role, 'photographer');
      expect(registered.name, 'Người chụp mới');
      await expectLater(
        auth.register(
          'Khác',
          'new-creator@lens.vn',
          'secure123',
          location: 'Hà Nội',
          styles: const ['portrait'],
        ),
        throwsStateError,
      );
    },
  );

  test(
    'isolated achievement mock does not fabricate performance history',
    () async {
      final source = MockAchievementDataSource();
      final seeded = await source.getAchievements('me');
      expect(seeded.totalBookings, 0);
      expect(seeded.ranks, isEmpty);
      expect(seeded.badges, isEmpty);
      expect(seeded.earnedBadgeCodes, isEmpty);

      final newCreator = await source.getAchievements('new-creator-test');
      expect(newCreator.totalBookings, 0);
      expect(newCreator.averageRating, 0);
      expect(newCreator.badges, isEmpty);
    },
  );

  test(
    'settings repository mock persists each photographer preference',
    () async {
      final source = MockSettingsDataSource();
      final changed = await source.updateNotification(
        'settings-test',
        'messages',
        false,
      );
      expect(changed['messages'], isFalse);
      expect(source.cachedNotifications('settings-test')?['messages'], isFalse);
      expect(await source.setTwoFactor('settings-test', false), isFalse);
      expect(source.cachedTwoFactor('settings-test'), isFalse);
      await expectLater(
        source.changePassword(
          userId: 'settings-test',
          currentPassword: 'old',
          newPassword: 'short',
        ),
        throwsStateError,
      );
    },
  );

  test(
    'review mock only returns source-backed reviews for the demo creator',
    () async {
      final source = MockReviewDataSource();
      final reviews = await source.getPhotographerReviews('me');
      expect(reviews, hasLength(3));
      expect(reviews.every((review) => review.photographerId == 'me'), isTrue);
      expect(await source.getPhotographerReviews('new-creator-test'), isEmpty);
    },
  );

  test(
    'collaboration invitation validates share and recipient response',
    () async {
      final booking = Booking(
        id: 'collab-test',
        clientId: 'c',
        clientName: 'Khách',
        photographerId: 'me',
        photographerName: 'Lý Gia Hân',
        style: 'Cưới',
        date: '2026-10-20',
        location: 'Hà Nội',
        price: 1000000,
        status: BookingStatus.confirmed,
      );
      MockDatabase.bookings.add(booking);
      MockDatabase.currentUser = MockDatabase.photographerUser;
      addTearDown(() {
        MockDatabase.bookings.removeWhere((item) => item.id == booking.id);
        MockDatabase.currentUser = null;
      });
      final api = MockApiService();
      final invited = await api.inviteCollaborator(
        'collab-test',
        MockDatabase.photographers.first,
        30,
      );
      expect(invited.collaborators.single.status, CollaborationStatus.invited);
      await expectLater(
        api.inviteCollaborator(
          'collab-test',
          MockDatabase.photographers.first,
          80,
        ),
        throwsStateError,
      );
      MockDatabase.currentUser = User(
        id: MockDatabase.photographers.first.id,
        name: 'Alex',
        email: 'alex@lens.vn',
        role: 'photographer',
      );
      final accepted = await api.respondToCollaboration(
        'collab-test',
        CollaborationStatus.accepted,
      );
      expect(
        accepted.collaborators.single.status,
        CollaborationStatus.accepted,
      );
    },
  );

  test(
    'messaging operations fail clearly when Backend has no chat API',
    () async {
      MockDatabase.currentUser = MockDatabase.photographerUser;
      final container = ProviderContainer(
        overrides: [
          initialAuthUserProvider.overrideWithValue(
            MockDatabase.photographerUser,
          ),
        ],
      );
      addTearDown(() {
        container.dispose();
        MockDatabase.currentUser = null;
      });
      final notifier = container.read(conversationsProvider.notifier);
      expect(container.read(conversationsProvider), isEmpty);
      await expectLater(notifier.refresh(), throwsStateError);
      await expectLater(notifier.markRead('c5'), throwsStateError);
      await expectLater(
        notifier.openOrCreateForClient(
          participantId: 'client',
          participantName: 'Khách',
        ),
        throwsStateError,
      );
      await expectLater(notifier.toggleAi('c5', true), throwsStateError);
      await expectLater(notifier.send('c5', 'test'), throwsStateError);
      expect(
        () => notifier.receiveFromClient('c5', 'sample'),
        throwsStateError,
      );
    },
  );

  testWidgets(
    'pending request exposes the photographer decision on a narrow phone',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      final booking = Booking(
        id: 'b',
        clientId: 'c',
        clientName: 'Khách Hàng',
        photographerId: 'me',
        photographerName: 'Studio',
        style: 'Chân dung',
        date: '2026-10-01',
        location: 'Hà Nội',
        price: 450000,
        depositAmount: 135000,
        status: BookingStatus.pending,
      );
      BookingStatus? decision;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: StudioBookingCard(
                booking: booking,
                openDetail: false,
                onDecide: (status) async {
                  decision = status;
                },
              ),
            ),
          ),
        ),
      );
      expect(find.text('Chờ xác nhận'), findsOneWidget);
      expect(find.text('Mức cọc yêu cầu 135.000 ₫'), findsOneWidget);
      await tester.tap(find.text('Xác nhận'));
      expect(decision, BookingStatus.accepted);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('demo login reaches connected dashboard and package tab', (
    tester,
  ) async {
    MockDatabase.currentUser = null;
    addTearDown(() => MockDatabase.currentUser = null);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initialAuthUserProvider.overrideWithValue(null),
          authRepositoryProvider.overrideWithValue(MockAuthRepository()),
          myPhotographerProvider.overrideWithValue(
            MockDatabase.photographers.singleWhere((item) => item.id == 'me'),
          ),
          incomingBookingsProvider.overrideWithValue(
            AsyncData(
              MockDatabase.bookings
                  .where((booking) => booking.photographerId == 'me')
                  .toList(),
            ),
          ),
          myBookingsProvider.overrideWith(
            (ref) => MockDatabase.bookings
                .where((booking) => booking.photographerId == 'me')
                .toList(),
          ),
          bookingPlansProvider.overrideWith(_DemoBookingPlansNotifier.new),
          photographerPortfolioProvider.overrideWith(
            (ref) async => const PortfolioWorkspace(albums: [], assets: []),
          ),
          photographerReviewsProvider.overrideWith((ref) async => []),
          walletProvider.overrideWith(_EmptyWalletNotifier.new),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'nhiepanhgia@lens.vn',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'demo1234');
    await tester.tap(find.text('Đăng nhập'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(seconds: 2));
    expect(find.textContaining('Chào, Lý Gia Hân'), findsOneWidget);
    expect(find.text('Yêu cầu đặt lịch'), findsOneWidget);
    await tester.tap(find.text('Gói chụp'));
    await tester.pumpAndSettle();
    expect(find.text('Gói cơ bản'), findsWidgets);
    await tester.tap(find.text('Khác'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hồ sơ năng lực').last);
    await tester.pumpAndSettle();
    expect(find.byType(PortfolioScreen), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Xem hồ sơ công khai'),
      250,
      scrollable: find
          .descendant(
            of: find.byType(PortfolioScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.ensureVisible(find.text('Xem hồ sơ công khai'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xem hồ sơ công khai'));
    await tester.pumpAndSettle();
    expect(find.text('Hồ sơ nhiếp ảnh'), findsOneWidget);
    expect(find.text('Giới thiệu'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'creator signup collects application fields and waits for review',
    (tester) async {
      MockDatabase.currentUser = null;
      addTearDown(() => MockDatabase.currentUser = null);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(MockAuthRepository()),
          ],
          child: const MyApp(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 600));
      await tester.tap(find.text('Chưa có tài khoản? Đăng ký'));
      await tester.pump();

      await tester.enterText(find.byType(TextFormField).at(0), 'Nguyễn An');
      await tester.enterText(find.byType(TextFormField).at(1), 'Hà Nội');
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'an@example.test',
      );
      await tester.enterText(find.byType(TextFormField).at(3), 'secure123');
      await tester.ensureVisible(find.widgetWithText(FilterChip, 'Chân dung'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilterChip, 'Chân dung'));
      await tester.ensureVisible(find.text('Tạo tài khoản'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tạo tài khoản'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.textContaining('đang chờ LENS xét duyệt'), findsOneWidget);
      expect(find.text('Chào, Lý Gia Hân'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('creator can log out and sign in again without provider cycles', (
    tester,
  ) async {
    MockDatabase.currentUser = null;
    addTearDown(() => MockDatabase.currentUser = null);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initialAuthUserProvider.overrideWithValue(null),
          authRepositoryProvider.overrideWithValue(MockAuthRepository()),
          myPhotographerProvider.overrideWithValue(
            MockDatabase.photographers.singleWhere((item) => item.id == 'me'),
          ),
          incomingBookingsProvider.overrideWithValue(
            AsyncData(
              MockDatabase.bookings
                  .where((booking) => booking.photographerId == 'me')
                  .toList(),
            ),
          ),
          myBookingsProvider.overrideWith(
            (ref) => MockDatabase.bookings
                .where((booking) => booking.photographerId == 'me')
                .toList(),
          ),
          bookingPlansProvider.overrideWith(_DemoBookingPlansNotifier.new),
          photographerPortfolioProvider.overrideWith(
            (ref) async => const PortfolioWorkspace(albums: [], assets: []),
          ),
          photographerReviewsProvider.overrideWith((ref) async => []),
          walletProvider.overrideWith(_EmptyWalletNotifier.new),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));

    Future<void> signIn() async {
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'nhiepanhgia@lens.vn',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'demo1234');
      await tester.tap(find.text('Đăng nhập'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(seconds: 2));
    }

    await signIn();
    expect(find.textContaining('Chào, Lý Gia Hân'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Khác'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Đăng xuất'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đăng xuất'));
    await tester.pumpAndSettle();
    expect(find.text('Chào mừng trở lại'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await signIn();
    expect(find.textContaining('Chào, Lý Gia Hân'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('add and edit package forms fit a narrow mobile viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    final profile = MockDatabase.photographers.singleWhere(
      (item) => item.id == 'me',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initialAuthUserProvider.overrideWithValue(
            MockDatabase.photographerUser,
          ),
          myPhotographerProvider.overrideWithValue(profile),
          bookingPlansProvider.overrideWith(_DemoBookingPlansNotifier.new),
        ],
        child: const MaterialApp(home: EditPackageScreen(id: 'new')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Tạo gói chụp'), findsWidgets);
    expect(find.byType(Form), findsOneWidget);
    expect(find.byType(PackageEditorActions), findsOneWidget);
    expect(find.text('Tên gói'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initialAuthUserProvider.overrideWithValue(
            MockDatabase.photographerUser,
          ),
          myPhotographerProvider.overrideWithValue(profile),
          bookingPlansProvider.overrideWith(_DemoBookingPlansNotifier.new),
        ],
        child: const MaterialApp(home: EditPackageScreen(id: 'basic')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Cập nhật gói chụp'), findsWidgets);
    expect(find.byType(Form), findsOneWidget);
    expect(find.byType(PackageEditorActions), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('subscription screen does not show demo storage galleries', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initialAuthUserProvider.overrideWithValue(
            MockDatabase.photographerUser,
          ),
          subscriptionWorkspaceProvider.overrideWith(
            (ref) async => _emptySubscriptionWorkspace,
          ),
        ],
        child: const MaterialApp(home: StorageScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dung lượng & gói đăng ký'), findsOneWidget);
    expect(find.text('Backend chưa có gói đang hoạt động'), findsOneWidget);
    expect(find.text('Bộ sưu tập đã giao'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

class _DemoBookingPlansNotifier extends BookingPlansNotifier {
  @override
  Future<List<PhotographerPackage>> build() async => MockDatabase.photographers
      .singleWhere((item) => item.id == 'me')
      .packages;
}

class _EmptyWalletNotifier extends WalletNotifier {
  @override
  Future<WalletSnapshot> build() async =>
      const WalletSnapshot(balance: 0, frozenBalance: 0, entries: []);
}

const _emptySubscriptionWorkspace = SubscriptionWorkspace(
  plans: [],
  current: null,
  features: [],
  usage: SubscriptionUsage(
    storageBytes: 0,
    reservedStorageBytes: 0,
    storageLimitBytes: null,
    storageRemainingBytes: null,
    storageOverLimit: false,
    portfolioCount: 0,
    portfolioLimit: null,
    portfolioRemainingCount: null,
    portfolioOverLimit: false,
  ),
  history: [],
);
