import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/creator_avatar.dart';
import '../../../../core/widgets/creator_decision_actions.dart';
import '../../../../core/widgets/creator_status_badge.dart';
import '../../../../domain/booking_rules.dart';
import '../../../../domain/models/models.dart';

class HomeBookingCard extends StatelessWidget {
  const HomeBookingCard({
    super.key,
    required this.booking,
    this.onDecide,
    this.onMessage,
  });

  final Booking booking;
  final Future<void> Function(BookingStatus)? onDecide;
  final VoidCallback? onMessage;

  String get _money =>
      '${NumberFormat.decimalPattern('vi').format(booking.price)} ₫';

  String get _deposit =>
      '${NumberFormat.decimalPattern('vi').format(booking.depositAmount)} ₫';

  String get _dateAndTime {
    final date = DateTime.tryParse(booking.date);
    final dateLabel = date == null
        ? booking.date
        : DateFormat('dd/MM/yyyy').format(date);
    final start = booking.timeSlot;
    if (start == null || start.isEmpty) return dateLabel;

    final duration = booking.durationHours;
    if (duration == null) return '$dateLabel · $start';
    final parts = start.split(':');
    if (parts.length != 2) return '$dateLabel · $start';
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return '$dateLabel · $start';
    final totalMinutes = (hour * 60 + minute + duration * 60).round().clamp(
      0,
      24 * 60,
    );
    final end =
        '${(totalMinutes ~/ 60).toString().padLeft(2, '0')}:${(totalMinutes % 60).toString().padLeft(2, '0')}';
    return '$dateLabel · $start – $end';
  }

  @override
  Widget build(BuildContext context) {
    final isPending = booking.status == BookingStatus.pending;
    final isDelivered =
        booking.status == BookingStatus.held ||
        booking.status == BookingStatus.released;
    final hasDeposit = booking.depositAmount > 0;
    final package = booking.packageName?.trim();
    final service = package == null || package.isEmpty
        ? booking.style
        : '${booking.style} · $package';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        border: Border.all(color: AppColors.fog),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        child: InkWell(
          onTap: () => context.push('/photographer_home/booking/${booking.id}'),
          borderRadius: BorderRadius.circular(AppTokens.radiusCard),
          child: Padding(
            padding: const EdgeInsets.all(AppTokens.space4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CreatorAvatar(name: booking.clientName, size: 40),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Text(
                          booking.clientName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.ink,
                            fontSize: 14,
                            height: 1.25,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CreatorStatusBadge(status: booking.status),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: AppColors.mist,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.fog),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _BookingInfoRow(
                        icon: Icons.photo_camera_outlined,
                        text: service,
                        emphasized: true,
                      ),
                      const SizedBox(height: 7),
                      _BookingInfoRow(
                        icon: Icons.event_outlined,
                        text: _dateAndTime,
                      ),
                      const SizedBox(height: 7),
                      _BookingInfoRow(
                        icon: Icons.location_on_outlined,
                        text: booking.location,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 9),
                        child: Divider(height: 1),
                      ),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          Text.rich(
                            TextSpan(
                              text: 'Tổng: ',
                              style: const TextStyle(
                                color: AppColors.steel,
                                fontSize: 11,
                              ),
                              children: [
                                TextSpan(
                                  text: _money,
                                  style: const TextStyle(
                                    color: AppColors.ink,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (hasDeposit) _DepositBadge(amount: _deposit),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isPending && onDecide != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (onMessage != null) ...[
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: OutlinedButton(
                            onPressed: onMessage,
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              foregroundColor: AppColors.graphite,
                              side: const BorderSide(color: AppColors.fog),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Icon(
                              Icons.chat_bubble_outline,
                              size: 17,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: CreatorDecisionActions(
                          onDecline: () => onDecide!(BookingStatus.cancelled),
                          onAccept: () => onDecide!(BookingStatus.confirmed),
                          declineLabel: 'Từ chối',
                          acceptLabel: 'Xác nhận',
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  if (isDelivered) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Thực nhận ${NumberFormat.decimalPattern('vi').format(BookingRules.payoutFor(booking, booking.photographerId))} ₫'
                      '${booking.status == BookingStatus.held ? ' · Đã giao ${booking.deliveredPhotos}/${booking.promisedPhotos ?? 1} ảnh' : ''}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.steel,
                        fontSize: 11,
                        height: 1.35,
                      ),
                    ),
                  ],
                  if (onMessage != null || isDelivered) ...[
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 4,
                      children: [
                        if (onMessage != null &&
                            booking.status != BookingStatus.cancelled)
                          TextButton.icon(
                            onPressed: onMessage,
                            icon: const Icon(
                              Icons.chat_bubble_outline,
                              size: 16,
                            ),
                            label: const Text('Nhắn tin'),
                          ),
                        if (isDelivered)
                          TextButton.icon(
                            onPressed: () => context.push(
                              '/photographer_home/booking/${booking.id}/gallery',
                            ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BookingInfoRow extends StatelessWidget {
  const _BookingInfoRow({
    required this.icon,
    required this.text,
    this.emphasized = false,
  });

  final IconData icon;
  final String text;
  final bool emphasized;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 1),
        child: Icon(
          icon,
          size: 15,
          color: emphasized ? AppColors.ember : AppColors.steel,
        ),
      ),
      const SizedBox(width: 7),
      Expanded(
        child: Text(
          text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: emphasized ? AppColors.ink : AppColors.graphite,
            fontSize: emphasized ? 12 : 11.5,
            height: 1.35,
            fontWeight: emphasized ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    ],
  );
}

class _DepositBadge extends StatelessWidget {
  const _DepositBadge({required this.amount});

  final String amount;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(maxWidth: 176),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.successSoft,
      borderRadius: BorderRadius.circular(7),
      border: Border.all(color: const Color(0x332E9B62)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.verified_outlined, size: 13, color: Color(0xFF087443)),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            'Đã cọc $amount',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF087443),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}
