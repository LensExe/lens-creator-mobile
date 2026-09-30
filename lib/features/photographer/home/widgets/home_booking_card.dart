import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/creator_booking_tile.dart';
import '../../../../domain/models/models.dart';

class HomeBookingCard extends StatelessWidget {
  const HomeBookingCard({super.key, required this.booking, this.onDecide});

  final Booking booking;
  final Future<void> Function(BookingStatus)? onDecide;

  @override
  Widget build(BuildContext context) => CreatorBookingTile(
    booking: booking,
    onTap: () => context.push('/photographer_home/booking/${booking.id}'),
    onDecide: onDecide,
  );
}
