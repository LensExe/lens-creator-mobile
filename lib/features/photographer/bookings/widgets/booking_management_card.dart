import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/creator_booking_tile.dart';
import '../../../../domain/models/models.dart';

class BookingManagementCard extends StatelessWidget {
  const BookingManagementCard({
    super.key,
    required this.booking,
    this.busy = false,
    this.onDecide,
  });

  final Booking booking;
  final bool busy;
  final Future<void> Function(BookingStatus)? onDecide;

  @override
  Widget build(BuildContext context) => CreatorBookingTile(
    booking: booking,
    busy: busy,
    onTap: () => context.push('/photographer_home/booking/${booking.id}'),
    onDecide: onDecide,
  );
}
