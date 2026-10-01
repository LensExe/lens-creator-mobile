import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/creator_booking_tile.dart';
import '../../../../domain/models/models.dart';

String formatDong(int amount) =>
    '${NumberFormat.decimalPattern('vi').format(amount)} ₫';

class StudioBookingCard extends StatelessWidget {
  const StudioBookingCard({
    super.key,
    required this.booking,
    this.onDecide,
    this.onMessage,
    this.busy = false,
    this.openDetail = true,
  });

  final Booking booking;
  final Future<void> Function(BookingStatus)? onDecide;
  final VoidCallback? onMessage;
  final bool busy;
  final bool openDetail;

  @override
  Widget build(BuildContext context) => CreatorBookingTile(
    booking: booking,
    busy: busy,
    onTap: openDetail
        ? () => context.push('/photographer_home/booking/${booking.id}')
        : null,
    onDecide: onDecide,
    onMessage: onMessage,
    onGallery:
        booking.status == BookingStatus.held ||
            booking.status == BookingStatus.released
        ? () => context.push('/photographer_home/booking/${booking.id}/gallery')
        : null,
  );
}
