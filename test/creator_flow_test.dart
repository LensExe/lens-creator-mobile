import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_creator_mobile/data/mock_api_service.dart';
import 'package:lens_creator_mobile/data/mock_database.dart';
import 'package:lens_creator_mobile/domain/booking_rules.dart';
import 'package:lens_creator_mobile/domain/models/models.dart';
import 'package:lens_creator_mobile/features/photographer/availability/work_schedule.dart';
import 'package:lens_creator_mobile/features/photographer/assistant/assistant_rules.dart';
import 'package:lens_creator_mobile/features/photographer/bookings/widgets/studio_booking_card.dart';
import 'package:lens_creator_mobile/features/photographer/messages/conversation_provider.dart';
import 'package:lens_creator_mobile/features/photographer/storage/storage_provider.dart';
import 'package:lens_creator_mobile/features/photographer/portfolio/portfolio_screen.dart';
import 'package:lens_creator_mobile/main.dart';
import 'package:lens_creator_mobile/providers/data_providers.dart';

void main() {
  test('only deposited pending bookings can be approved or declined', () {
    expect(
      BookingRules.canTransition(
        BookingStatus.pending,
        BookingStatus.confirmed,
      ),
      isTrue,
    );
    expect(
      BookingRules.canTransition(
        BookingStatus.pending,
        BookingStatus.cancelled,
      ),
      isTrue,
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

  test('upgrading storage unlocks the over-quota demo gallery', () async {
    MockDatabase.currentUser = MockDatabase.photographerUser;
    final container = ProviderContainer();
    addTearDown(() {
      container.dispose();
      MockDatabase.currentUser = null;
    });
    await container.read(asyncBookingsProvider.future);
    StorageGallery gallery() => container
        .read(storageGalleriesProvider)
        .firstWhere((item) => item.booking.id == 'in-6');
    expect(gallery().locked, isTrue);
    expect(gallery().needsAttention, isTrue);
    container.read(storageTierProvider.notifier).choose(StorageTier.pro);
    expect(gallery().locked, isFalse);
    expect(gallery().daysLeft, greaterThan(300));
  });

  test('client complaint gets AI handoff and disables thread assistant', () {
    MockDatabase.currentUser = MockDatabase.photographerUser;
    final container = ProviderContainer();
    addTearDown(() {
      container.dispose();
      MockDatabase.currentUser = null;
    });
    final notifier = container.read(conversationsProvider.notifier);
    notifier.receiveFromClient('c5', 'Cho tôi hỏi giá gói cơ bản?');
    var conversation = container
        .read(conversationsProvider)
        .firstWhere((item) => item.id == 'c5');
    expect(conversation.messages.last.isAi, isTrue);
    expect(conversation.aiEnabled, isTrue);
    notifier.receiveFromClient('c5', 'Tôi muốn khiếu nại và hoàn tiền');
    conversation = container
        .read(conversationsProvider)
        .firstWhere((item) => item.id == 'c5');
    expect(conversation.messages.last.text, AssistantRules.handoffMessage);
    expect(conversation.aiEnabled, isFalse);
    final count = conversation.messages.length;
    notifier.receiveFromClient('c5', 'Cần hỗ trợ thêm');
    expect(
      container
          .read(conversationsProvider)
          .firstWhere((item) => item.id == 'c5')
          .messages
          .length,
      count + 1,
    );
  });

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
      expect(find.text('Đã cọc 135.000 ₫'), findsOneWidget);
      await tester.tap(find.text('Xác nhận'));
      expect(decision, BookingStatus.confirmed);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('demo login reaches connected dashboard and package tab', (
    tester,
  ) async {
    MockDatabase.currentUser = null;
    addTearDown(() => MockDatabase.currentUser = null);
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Điền tài khoản mẫu'), findsOneWidget);
    await tester.tap(find.text('Điền tài khoản mẫu'));
    await tester.tap(find.text('Đăng nhập'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(seconds: 2));
    expect(find.textContaining('Chào, Lý Gia Hân'), findsOneWidget);
    expect(find.text('Lời mời liên kết'), findsOneWidget);
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
    expect(find.text('Xem hồ sơ công khai'), findsWidgets);
    expect(find.text('Giới thiệu'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
