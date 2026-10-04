import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/creator_avatar.dart';
import '../../../../core/widgets/creator_status_badge.dart';
import '../../../../domain/booking_rules.dart';
import '../../../../domain/models/models.dart';

class BookingManagementCard extends StatelessWidget {
  const BookingManagementCard({
    super.key,
    required this.booking,
    this.busy = false,
    this.onDecide,
    this.onMessage,
  });

  final Booking booking;
  final bool busy;
  final Future<void> Function(BookingStatus)? onDecide;
  final VoidCallback? onMessage;

  String _money(int amount) =>
      '${NumberFormat.decimalPattern('vi').format(amount)} ₫';

  String get _service {
    final style = booking.style.trim();
    final package = booking.packageName?.trim() ?? '';
    if (package.isEmpty || package == style) {
      return style.isEmpty ? package : style;
    }
    if (style.isEmpty) {
      return package;
    }
    return '$style · $package';
  }

  String get _dateAndTime {
    final date = DateTime.tryParse(booking.date);
    final dateLabel = date == null
        ? booking.date
        : DateFormat('dd/MM/yyyy').format(date);
    final start = booking.timeSlot;
    if (start == null || start.isEmpty) return dateLabel;
    final duration = booking.durationHours;
    if (duration == null) return '$start · $dateLabel';
    final parts = start.split(':');
    if (parts.length != 2) return '$start · $dateLabel';
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return '$start · $dateLabel';
    final totalMinutes = (hour * 60 + minute + duration * 60).round().clamp(
      0,
      24 * 60,
    );
    final end =
        '${(totalMinutes ~/ 60).toString().padLeft(2, '0')}:${(totalMinutes % 60).toString().padLeft(2, '0')}';
    return '$start – $end · $dateLabel';
  }

  @override
  Widget build(BuildContext context) {
    final isPending = booking.status == BookingStatus.pending;
    final isDelivered =
        booking.status == BookingStatus.held ||
        booking.status == BookingStatus.released;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE8E8ED)),
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
        borderRadius: BorderRadius.circular(17),
        child: InkWell(
          onTap: () => context.push('/photographer_home/booking/${booking.id}'),
          borderRadius: BorderRadius.circular(17),
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
                            height: 1.2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CreatorStatusBadge(status: booking.status),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Divider(height: 1, color: Color(0xFFF1F1F4)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _BookingInfoRow(
                        icon: Icons.photo_camera_outlined,
                        text: _service,
                        emphasized: true,
                      ),
                      const SizedBox(height: 8),
                      _BookingInfoRow(
                        icon: Icons.schedule_rounded,
                        text: _dateAndTime,
                      ),
                      const SizedBox(height: 7),
                      _BookingInfoRow(
                        icon: Icons.location_on_outlined,
                        text: booking.location,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFF1F1F4)),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      if (booking.depositAmount > 0 || isPending)
                        _DepositBadge(amount: _money(booking.depositAmount)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'TỔNG CỘNG',
                            style: TextStyle(
                              color: AppColors.ash,
                              fontSize: 9,
                              letterSpacing: 0.8,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _money(booking.price),
                            style: const TextStyle(
                              color: AppColors.ink,
                              fontSize: 16,
                              height: 1.2,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isDelivered) ...[
                  Text(
                    'Thực nhận ${_money(BookingRules.payoutFor(booking, booking.photographerId))}'
                    '${booking.status == BookingStatus.held ? ' · Đã giao ${booking.deliveredPhotos}/${booking.promisedPhotos ?? 1} ảnh' : ''}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.steel,
                      fontSize: 11,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                if (isPending && onDecide != null)
                  _PendingActions(
                    busy: busy,
                    onMessage: onMessage,
                    onReject: () => onDecide!(BookingStatus.cancelled),
                    onConfirm: () => onDecide!(BookingStatus.confirmed),
                  )
                else if (onMessage != null || isDelivered)
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
          color: emphasized ? AppColors.ember : AppColors.ash,
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
            fontSize: emphasized ? 12.5 : 11.5,
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
    constraints: const BoxConstraints(maxWidth: 190),
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.successSoft,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: const Color(0x332E9B62)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.verified_user_outlined,
          size: 13,
          color: Color(0xFF087443),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            'Đã cọc $amount',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF087443),
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

class _PendingActions extends StatelessWidget {
  const _PendingActions({
    required this.busy,
    required this.onMessage,
    required this.onReject,
    required this.onConfirm,
  });

  final bool busy;
  final VoidCallback? onMessage;
  final VoidCallback onReject;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) => Row(
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
              side: const BorderSide(color: Color(0xFFE8E8ED)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
            child: const Icon(Icons.chat_bubble_outline, size: 17),
          ),
        ),
        const SizedBox(width: 8),
      ],
      Expanded(
        child: OutlinedButton(
          onPressed: busy ? null : onReject,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 40),
            foregroundColor: AppColors.ink,
            side: const BorderSide(color: Color(0xFFE8E8ED)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11),
            ),
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: const Text('Từ chối'),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: FilledButton(
          onPressed: busy ? null : onConfirm,
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 40),
            backgroundColor: AppColors.ink,
            foregroundColor: AppColors.snow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11),
            ),
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: busy
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.snow,
                  ),
                )
              : const Text('Xác nhận'),
        ),
      ),
    ],
  );
}
