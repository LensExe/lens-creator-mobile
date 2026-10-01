import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/booking_rules.dart';
import '../../domain/models/models.dart';
import '../theme/app_colors.dart';
import 'creator_avatar.dart';
import 'creator_decision_actions.dart';
import 'creator_status_badge.dart';

class CreatorBookingTile extends StatelessWidget {
  const CreatorBookingTile({
    super.key,
    required this.booking,
    this.onTap,
    this.onDecide,
    this.onMessage,
    this.onGallery,
    this.busy = false,
  });

  final Booking booking;
  final VoidCallback? onTap;
  final Future<void> Function(BookingStatus)? onDecide;
  final VoidCallback? onMessage;
  final VoidCallback? onGallery;
  final bool busy;

  String _money(int value) =>
      '${NumberFormat.decimalPattern('vi').format(value)} ₫';

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(booking.date);
    final dateLabel = date == null
        ? booking.date
        : DateFormat('dd/MM/yyyy').format(date);
    final when = [
      dateLabel,
      if (booking.timeSlot != null) booking.timeSlot!,
    ].join(' · ');
    final isPending = booking.status == BookingStatus.pending;
    final isDelivered =
        booking.status == BookingStatus.held ||
        booking.status == BookingStatus.released;

    return Material(
      color: AppColors.snow,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.fog)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CreatorAvatar(name: booking.clientName, size: 44),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.clientName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.obsidian,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${booking.style}${booking.packageName == null ? '' : ' · ${booking.packageName}'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.steel,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onTap != null) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.ash,
                      size: 20,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 13),
              _BookingMeta(icon: Icons.calendar_today_outlined, text: when),
              const SizedBox(height: 7),
              _BookingMeta(
                icon: Icons.location_on_outlined,
                text: booking.location,
              ),
              const SizedBox(height: 13),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _money(booking.price),
                      style: const TextStyle(
                        color: AppColors.obsidian,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CreatorStatusBadge(status: booking.status),
                ],
              ),
              if (isPending) ...[
                const SizedBox(height: 5),
                Text(
                  'Đã cọc ${_money(booking.depositAmount)}',
                  style: const TextStyle(color: AppColors.steel, fontSize: 12),
                ),
              ] else if (isDelivered) ...[
                const SizedBox(height: 5),
                Text(
                  'Thực nhận ${_money(BookingRules.payoutFor(booking, booking.photographerId))}'
                  '${booking.status == BookingStatus.held ? ' · Đã giao ${booking.deliveredPhotos}/${booking.promisedPhotos ?? 1} ảnh' : ''}',
                  style: const TextStyle(color: AppColors.steel, fontSize: 12),
                ),
              ],
              if (isPending && onDecide != null) ...[
                const SizedBox(height: 15),
                CreatorDecisionActions(
                  busy: busy,
                  onDecline: () => onDecide!(BookingStatus.cancelled),
                  onAccept: () => onDecide!(BookingStatus.confirmed),
                ),
              ],
              if (onMessage != null || onGallery != null) ...[
                const SizedBox(height: 5),
                Wrap(
                  spacing: 4,
                  children: [
                    if (onMessage != null &&
                        booking.status != BookingStatus.cancelled)
                      TextButton.icon(
                        onPressed: onMessage,
                        icon: const Icon(Icons.chat_bubble_outline, size: 16),
                        label: const Text('Nhắn tin'),
                      ),
                    if (onGallery != null && isDelivered)
                      TextButton.icon(
                        onPressed: onGallery,
                        icon: const Icon(
                          Icons.photo_library_outlined,
                          size: 16,
                        ),
                        label: Text(
                          booking.status == BookingStatus.held
                              ? 'Giao ảnh'
                              : 'Xem ảnh',
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingMeta extends StatelessWidget {
  const _BookingMeta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 15, color: AppColors.ash),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.graphite, fontSize: 12),
        ),
      ),
    ],
  );
}
