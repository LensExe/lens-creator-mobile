import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../domain/booking_rules.dart';
import '../../../../domain/models/models.dart';
import 'studio_booking_card.dart' show formatDong;

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

  (Color, Color, Color) get _statusStyle => switch (booking.status) {
    BookingStatus.pending => (
      const Color(0xFFFFF4E5),
      const Color(0xFF8A4B08),
      const Color(0xFFE9A23B),
    ),
    BookingStatus.confirmed => (
      const Color(0xFFEAF2FF),
      const Color(0xFF2458A6),
      const Color(0xFF4285E8),
    ),
    BookingStatus.held => (
      const Color(0xFFF0ECFF),
      const Color(0xFF6941C6),
      const Color(0xFF8059D6),
    ),
    BookingStatus.released => (
      const Color(0xFFE5F7EF),
      const Color(0xFF087443),
      const Color(0xFF1A9B61),
    ),
    BookingStatus.cancelled => (AppColors.mist, AppColors.steel, AppColors.ash),
    BookingStatus.awaitingDeposit => (
      const Color(0xFFFFEDE3),
      AppColors.ember,
      AppColors.ember,
    ),
  };

  String get _initials {
    final words = booking.clientName.trim().split(RegExp(r'\s+'));
    if (words.length == 1) return words.first.characters.first.toUpperCase();
    return '${words.first.characters.first}${words.last.characters.first}'
        .toUpperCase();
  }

  String get _dateTime {
    final parsed = DateTime.tryParse(booking.date);
    final date = parsed == null
        ? booking.date
        : DateFormat('dd/MM/yyyy').format(parsed);
    return [date, if (booking.timeSlot != null) booking.timeSlot!].join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final (background, foreground, dot) = _statusStyle;
    return Card(
      margin: EdgeInsets.zero,
      color: AppColors.snow,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        side: const BorderSide(color: AppColors.fog),
      ),
      child: InkWell(
        onTap: () => context.push('/photographer_home/booking/${booking.id}'),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.ember.withValues(alpha: 0.85),
                    child: Text(
                      _initials,
                      style: const TextStyle(
                        color: AppColors.snow,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
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
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${booking.style}${booking.packageName == null ? '' : ' · ${booking.packageName}'}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.steel,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: background,
                        borderRadius: BorderRadius.circular(
                          AppTokens.radiusPill,
                        ),
                        border: Border.all(color: dot.withValues(alpha: 0.18)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: dot,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              BookingRules.statusLabel(booking.status),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: foreground,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.mist,
                  borderRadius: BorderRadius.circular(AppTokens.radiusInput),
                  border: Border.all(
                    color: AppColors.fog.withValues(alpha: 0.8),
                  ),
                ),
                child: Column(
                  children: [
                    _DetailLine(
                      icon: Icons.schedule_rounded,
                      text: _dateTime,
                      emphasize: true,
                    ),
                    const SizedBox(height: 6),
                    _DetailLine(
                      icon: Icons.location_on_outlined,
                      text: booking.location,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 11),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  _PriceAndDeposit(booking: booking),
                  if (booking.status == BookingStatus.pending)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF8F1),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: const Color(0xFFD3EFDF)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified_user_outlined,
                            size: 14,
                            color: Color(0xFF13804D),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Đã cọc ${formatDong(booking.depositAmount)}',
                            style: const TextStyle(
                              color: Color(0xFF13804D),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (booking.status == BookingStatus.held)
                    Text(
                      '${booking.deliveredPhotos}/${booking.promisedPhotos ?? 1} ảnh đã giao',
                      style: const TextStyle(
                        color: AppColors.steel,
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
              if (booking.status == BookingStatus.pending &&
                  onDecide != null) ...[
                const SizedBox(height: 11),
                const Divider(height: 1, color: AppColors.fog),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: busy
                            ? null
                            : () => onDecide!(BookingStatus.cancelled),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.graphite,
                          side: const BorderSide(color: AppColors.pebble),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(0, 42),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: const Text(
                          'Từ chối',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: busy
                            ? null
                            : () => onDecide!(BookingStatus.confirmed),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.obsidian,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(0, 42),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        icon: busy
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.snow,
                                ),
                              )
                            : const Icon(Icons.check_circle_outline, size: 16),
                        label: const Text(
                          'Xác nhận',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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

class _DetailLine extends StatelessWidget {
  const _DetailLine({
    required this.icon,
    required this.text,
    this.emphasize = false,
  });
  final IconData icon;
  final String text;
  final bool emphasize;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 15, color: AppColors.ash),
      const SizedBox(width: 7),
      Expanded(
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: emphasize ? AppColors.graphite : AppColors.steel,
            fontSize: 11,
            fontWeight: emphasize ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    ],
  );
}

class _PriceAndDeposit extends StatelessWidget {
  const _PriceAndDeposit({required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Tổng giá',
        style: TextStyle(color: AppColors.ash, fontSize: 10),
      ),
      const SizedBox(height: 2),
      Text(
        formatDong(booking.price),
        style: const TextStyle(
          color: AppColors.obsidian,
          fontSize: 16,
          height: 1.1,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      ),
    ],
  );
}
