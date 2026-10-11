import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lens_creator_mobile/core/network/auth_session_store.dart';
import 'package:lens_creator_mobile/features/photographer/availability/calendar_api_repository.dart';
import 'package:lens_creator_mobile/features/photographer/packages/booking_plan_repository.dart';
import 'package:lens_creator_mobile/features/photographer/portfolio/api_portfolio_repository.dart';
import 'package:lens_creator_mobile/features/photographer/storage/subscription_repository.dart';
import 'package:lens_creator_mobile/features/photographer/wallet/wallet_entry.dart';
import 'package:lens_creator_mobile/features/photographer/wallet/wallet_provider.dart';
import 'package:lens_creator_mobile/core/widgets/creator_booking_tile.dart';
import 'package:lens_creator_mobile/data/mock_database.dart';
import 'package:lens_creator_mobile/domain/models/models.dart';
import 'package:lens_creator_mobile/features/photographer/availability/availability_screen.dart';
import 'package:lens_creator_mobile/features/photographer/booking_request_detail_screen.dart';
import 'package:lens_creator_mobile/features/photographer/packages/packages_screen.dart';
import 'package:lens_creator_mobile/features/photographer/photographer_bookings_screen.dart';
import 'package:lens_creator_mobile/features/photographer/photographer_home_screen.dart';
import 'package:lens_creator_mobile/features/photographer/messages/chat_detail_screen.dart';
import 'package:lens_creator_mobile/features/photographer/messages/messages_list_screen.dart';
import 'package:lens_creator_mobile/features/photographer/storage/storage_screen.dart';
import 'package:lens_creator_mobile/providers/data_providers.dart';

void main() {
  testWidgets('workspace screens fit compact and large phone widths', (
    tester,
  ) async {
    final profile = MockDatabase.photographers.singleWhere(
      (item) => item.id == 'me',
    );
    final bookings = MockDatabase.bookings
        .where((booking) => booking.photographerId == 'me')
        .toList();
    final previousUser = MockDatabase.currentUser;
    MockDatabase.currentUser = MockDatabase.photographerUser;
    final pending = bookings.firstWhere(
      (booking) => booking.status == BookingStatus.pending,
    );

    addTearDown(() {
      MockDatabase.currentUser = previousUser;
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    for (final size in const [Size(320, 640), Size(430, 932)]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;

      for (final screen in <(String, Widget)>[
        ('home', const PhotographerHomeScreen()),
        ('requests', const PhotographerBookingsScreen()),
        ('booking detail', BookingRequestDetailScreen(bookingId: pending.id)),
        ('availability', const AvailabilityScreen()),
        ('packages', const PackagesScreen()),
        ('messages', const MessagesListScreen()),
        ('message detail', const ChatDetailScreen(id: 'c1')),
        ('storage', const StorageScreen()),
      ]) {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              initialAuthUserProvider.overrideWithValue(
                MockDatabase.photographerUser,
              ),
              myPhotographerProvider.overrideWithValue(profile),
              incomingBookingsProvider.overrideWithValue(AsyncData(bookings)),
              myBookingsProvider.overrideWithValue(bookings),
              creatorCalendarProvider.overrideWith(
                (ref) async =>
                    const CalendarSnapshot(bookings: [], blocked: []),
              ),
              creatorBookingDetailProvider(pending.id)
                  .overrideWith((ref) async => pending),
              creatorBookingTimelineProvider(pending.id)
                  .overrideWith((ref) async => const []),
              bookingPlansProvider.overrideWith(_EmptyBookingPlansNotifier.new),
              photographerPortfolioProvider.overrideWith(
                (ref) async => const PortfolioWorkspace(albums: [], assets: []),
              ),
              subscriptionWorkspaceProvider.overrideWith(
                (ref) async => _emptySubscriptionWorkspace,
              ),
              walletProvider.overrideWith(_EmptyWalletNotifier.new),
            ],
            child: MaterialApp(home: screen.$2),
          ),
        );
        await tester.pumpAndSettle();
        if (screen.$1 == 'messages' || screen.$1 == 'message detail') {
          await tester.pump(const Duration(milliseconds: 300));
          await tester.pumpAndSettle();
        }
        final error = tester.takeException();
        expect(
          error,
          isNull,
          reason:
              '${screen.$1} should fit ${size.width} × ${size.height}: ${error is FlutterError ? error.toStringDeep() : error}',
        );
      }
    }
  });

  testWidgets('booking request card wraps its actions on a compact phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final booking = MockDatabase.bookings.firstWhere(
      (item) => item.status == BookingStatus.pending,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(children: [CreatorBookingTile(booking: booking)]),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(booking.clientName), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
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

class _EmptyBookingPlansNotifier extends BookingPlansNotifier {
  @override
  Future<List<PhotographerPackage>> build() async => const [];
}

class _EmptyWalletNotifier extends WalletNotifier {
  @override
  Future<WalletSnapshot> build() async =>
      const WalletSnapshot(balance: 0, frozenBalance: 0, entries: []);
}
