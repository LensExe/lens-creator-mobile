import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../domain/booking_rules.dart';
import '../../../../domain/models/models.dart';
import '../../bookings/widgets/studio_booking_card.dart';

class HomeBookingCard extends StatelessWidget {
  const HomeBookingCard({super.key, required this.booking, this.onDecide});

  final Booking booking;
  final Future<void> Function(BookingStatus)? onDecide;

  (Color, Color) get _statusColors => switch (booking.status) {
    BookingStatus.pending => (const Color(0xFFFFF4D6), const Color(0xFF8A4B08)),
    BookingStatus.confirmed => (
      const Color(0xFFE8F1FF),
      const Color(0xFF2458A6),
    ),
    BookingStatus.held => (const Color(0xFFF0ECFF), const Color(0xFF6941C6)),
    BookingStatus.released => (
      const Color(0xFFE5F7EF),
      const Color(0xFF087443),
    ),
    BookingStatus.cancelled => (AppColors.mist, AppColors.steel),
    BookingStatus.awaitingDeposit => (const Color(0xFFFFEDE3), AppColors.ember),
  };

  String get _initials {
    final parts = booking.clientName.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return '${parts.first.characters.first}${parts.last.characters.first}'
        .toUpperCase();
  }

  String get _dateLabel {
    final date = DateTime.tryParse(booking.date);
    return date == null ? booking.date : DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = _statusColors;
    final dateTime = [
      _dateLabel,
      if (booking.timeSlot != null) booking.timeSlot!,
    ].join(' · ');

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
          padding: const EdgeInsets.all(AppTokens.space4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 21,
                    backgroundColor: AppColors.ember.withValues(alpha: 0.1),
                    child: Text(
                      _initials,
                      style: const TextStyle(
                        color: AppColors.ember,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTokens.space3),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.clientName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${booking.style}${booking.packageName == null ? '' : ' · ${booking.packageName}'}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.steel,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: background,
                        borderRadius: BorderRadius.circular(
                          AppTokens.radiusPill,
                        ),
                      ),
                      child: Text(
                        BookingRules.statusLabel(booking.status),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: foreground,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTokens.space3),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.mist,
                  borderRadius: BorderRadius.circular(AppTokens.radiusInput),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoLine(
                      icon: Icons.schedule_rounded,
                      text: dateTime,
                      strong: true,
                    ),
                    const SizedBox(height: 6),
                    _InfoLine(
                      icon: Icons.location_on_outlined,
                      text: booking.location,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTokens.space3),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: AppTokens.space3,
                spacing: AppTokens.space3,
                children: [
                  _PriceSummary(booking: booking),
                  if (booking.status == BookingStatus.pending &&
                      onDecide != null)
                    Wrap(
                      spacing: AppTokens.space2,
                      runSpacing: AppTokens.space2,
                      children: [
                        OutlinedButton(
                          onPressed: () => onDecide!(BookingStatus.cancelled),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.ink,
                            minimumSize: const Size(0, 38),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            side: const BorderSide(color: AppColors.fog),
                          ),
                          child: const Text(
                            'Từ chối',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        FilledButton(
                          onPressed: () => onDecide!(BookingStatus.confirmed),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.obsidian,
                            minimumSize: const Size(0, 38),
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                          ),
                          child: const Text(
                            'Xác nhận',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.icon,
    required this.text,
    this.strong = false,
  });
  final IconData icon;
  final String text;
  final bool strong;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 16, color: AppColors.steel),
      const SizedBox(width: 7),
      Expanded(
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            fontWeight: strong ? FontWeight.w600 : FontWeight.w400,
            color: strong ? AppColors.ink : AppColors.steel,
          ),
        ),
      ),
    ],
  );
}

class _PriceSummary extends StatelessWidget {
  const _PriceSummary({required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        formatDong(booking.price),
        style: const TextStyle(
          color: AppColors.ink,
          fontSize: 17,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      ),
      if (booking.status == BookingStatus.pending)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_rounded,
              size: 13,
              color: AppColors.success,
            ),
            const SizedBox(width: 4),
            Text(
              'Đã cọc ${formatDong(booking.depositAmount)}',
              style: const TextStyle(
                color: Color(0xFF087443),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        )
      else if (booking.status == BookingStatus.held ||
          booking.status == BookingStatus.released)
        Text(
          'Thực nhận ${formatDong(BookingRules.payoutFor(booking, booking.photographerId))}',
          style: const TextStyle(color: AppColors.steel, fontSize: 11),
        ),
    ],
  );
}
