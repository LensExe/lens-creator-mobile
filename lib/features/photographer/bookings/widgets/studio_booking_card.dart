import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../domain/booking_rules.dart';
import '../../../../domain/models/models.dart';

String formatDong(int amount) =>
    '${NumberFormat.decimalPattern('vi').format(amount)} ₫';

class StudioBookingCard extends StatelessWidget {
  const StudioBookingCard({
    super.key,
    required this.booking,
    this.onDecide,
    this.busy = false,
    this.openDetail = true,
  });

  final Booking booking;
  final Future<void> Function(BookingStatus)? onDecide;
  final bool busy;
  final bool openDetail;

  @override
  Widget build(BuildContext context) {
    final status = booking.status;
    final date = DateTime.tryParse(booking.date);
    final dateLabel = date == null
        ? booking.date
        : DateFormat('dd/MM/yyyy').format(date);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: openDetail
            ? () => context.push('/photographer_home/booking/${booking.id}')
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      booking.clientName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  _StatusPill(status: status),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '${booking.style}${booking.packageName == null ? '' : ' · ${booking.packageName}'}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 6),
              Text(
                '$dateLabel${booking.timeSlot == null ? '' : ' · ${booking.timeSlot}'}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Text(
                booking.location,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Divider(height: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatDong(booking.price),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  if (status == BookingStatus.pending)
                    Text(
                      'Đã cọc ${formatDong(booking.depositAmount)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.success,
                      ),
                    ),
                  if (status == BookingStatus.held ||
                      status == BookingStatus.released)
                    Text(
                      'Thực nhận ${formatDong(BookingRules.payoutFor(booking, booking.photographerId))}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.steel,
                      ),
                    ),
                ],
              ),
              if (status == BookingStatus.pending && onDecide != null) ...[
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton(
                      onPressed: busy
                          ? null
                          : () => onDecide!(BookingStatus.cancelled),
                      child: const Text('Từ chối'),
                    ),
                    FilledButton(
                      onPressed: busy
                          ? null
                          : () => onDecide!(BookingStatus.confirmed),
                      child: const Text('Xác nhận'),
                    ),
                  ],
                ),
              ],
              if (status == BookingStatus.held) ...[
                const SizedBox(height: 8),
                Text(
                  'Đã giao ${booking.deliveredPhotos}/${booking.promisedPhotos ?? 1} ảnh · Mở chi tiết để giao ảnh',
                  style: const TextStyle(color: AppColors.steel, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (status) {
      BookingStatus.pending => (
        const Color(0xFFFEF3C7),
        const Color(0xFF92400E),
      ),
      BookingStatus.confirmed => (
        const Color(0xFFDBEAFE),
        const Color(0xFF1D4ED8),
      ),
      BookingStatus.held => (const Color(0xFFEDE9FE), const Color(0xFF6D28D9)),
      BookingStatus.released => (
        const Color(0xFFD1FAE5),
        const Color(0xFF047857),
      ),
      BookingStatus.cancelled => (AppColors.mist, AppColors.steel),
      BookingStatus.awaitingDeposit => (
        const Color(0xFFFFEDD5),
        const Color(0xFF9A3412),
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        BookingRules.statusLabel(status),
        style: TextStyle(
          color: foreground,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
