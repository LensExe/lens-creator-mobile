import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lens_creator_mobile/core/widgets/creator_booking_tile.dart';
import 'package:lens_creator_mobile/data/mock_database.dart';
import 'package:lens_creator_mobile/domain/models/models.dart';
import 'package:lens_creator_mobile/features/photographer/availability/availability_screen.dart';
import 'package:lens_creator_mobile/features/photographer/booking_request_detail_screen.dart';
import 'package:lens_creator_mobile/features/photographer/packages/packages_screen.dart';
import 'package:lens_creator_mobile/features/photographer/photographer_bookings_screen.dart';
import 'package:lens_creator_mobile/features/photographer/photographer_home_screen.dart';
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
    final pending = bookings.firstWhere(
      (booking) => booking.status == BookingStatus.pending,
    );

    addTearDown(() {
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
      ]) {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              myPhotographerProvider.overrideWithValue(profile),
              incomingBookingsProvider.overrideWithValue(AsyncData(bookings)),
              myBookingsProvider.overrideWithValue(bookings),
            ],
            child: MaterialApp(home: screen.$2),
          ),
        );
        await tester.pumpAndSettle();
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
