import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/booking_rules.dart';
import '../../domain/models/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
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

  String _timeRange() {
    final start = booking.timeSlot;
    if (start == null || booking.durationHours == null) return start ?? '';
    final parts = start.split(':');
    if (parts.length != 2) return start;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return start;
    final total = (hour * 60 + minute + booking.durationHours! * 60)
        .round()
        .clamp(0, 24 * 60);
    final end =
        '${(total ~/ 60).toString().padLeft(2, '0')}:${(total % 60).toString().padLeft(2, '0')}';
    return '$start – $end';
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(booking.date);
    final dateLabel = date == null
        ? booking.date
        : DateFormat('dd/MM/yyyy').format(date);
    final time = _timeRange();
    final isPending = booking.status == BookingStatus.pending;
    final isDelivered =
        booking.status == BookingStatus.held ||
        booking.status == BookingStatus.released;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        border: Border.all(color: AppColors.fog),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTokens.radiusCard),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CreatorAvatar(name: booking.clientName, size: 44),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 1),
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
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              booking.packageName == null
                                  ? booking.style
                                  : '${booking.style} · ${booking.packageName}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.steel,
                                fontSize: 12,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CreatorStatusBadge(status: booking.status),
                  ],
                ),
                const SizedBox(height: 15),
                _BookingMeta(
                  icon: Icons.calendar_today_outlined,
                  text: time.isEmpty ? dateLabel : '$dateLabel · $time',
                ),
                const SizedBox(height: 8),
                _BookingMeta(
                  icon: Icons.location_on_outlined,
                  text: booking.location,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 13),
                  child: Divider(height: 1),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'GIÁ TRỊ BUỔI CHỤP',
                            style: TextStyle(
                              color: AppColors.steel,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.7,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _money(booking.price),
                            style: const TextStyle(
                              color: AppColors.obsidian,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onTap != null)
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.ash,
                        size: 18,
                      ),
                  ],
                ),
                if (isPending) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Đã cọc ${_money(booking.depositAmount)}',
                    style: const TextStyle(
                      color: AppColors.steel,
                      fontSize: 12,
                    ),
                  ),
                ] else if (isDelivered) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Thực nhận ${_money(BookingRules.payoutFor(booking, booking.photographerId))}'
                    '${booking.status == BookingStatus.held ? ' · Đã giao ${booking.deliveredPhotos}/${booking.promisedPhotos ?? 1} ảnh' : ''}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.steel,
                      fontSize: 12,
                    ),
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
                  if (!isPending) const SizedBox(height: 7),
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
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 1),
        child: Icon(icon, size: 15, color: AppColors.ash),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.graphite,
            fontSize: 12,
            height: 1.4,
          ),
        ),
      ),
    ],
  );
}
