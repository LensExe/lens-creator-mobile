import 'package:flutter/material.dart';

import '../../domain/booking_rules.dart';
import '../../domain/models/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

class CreatorStatusBadge extends StatelessWidget {
  const CreatorStatusBadge({super.key, required this.status});

  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final (foreground, background) = switch (status) {
      BookingStatus.pending => (AppColors.ember, AppColors.emberSoft),
      BookingStatus.accepted ||
      BookingStatus.confirmed ||
      BookingStatus.inProgress ||
      BookingStatus.held ||
      BookingStatus.shot => (AppColors.ink, AppColors.mist),
      BookingStatus.completed || BookingStatus.released => (
        const Color(0xFF087443),
        AppColors.successSoft,
      ),
      BookingStatus.rejected ||
      BookingStatus.expired ||
      BookingStatus.awaitingDeposit ||
      BookingStatus.cancelled => (AppColors.slate, AppColors.mist),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppTokens.radiusPill),
      ),
      child: Text(
        BookingRules.statusLabel(status),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: foreground,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
