import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/creator_decision_actions.dart';
import '../../../../domain/models/models.dart';
import 'studio_booking_card.dart' show formatDong;

class CollaborationInviteCard extends StatelessWidget {
  const CollaborationInviteCard({
    super.key,
    required this.booking,
    required this.collaborator,
    required this.amount,
    required this.busy,
    required this.onAccept,
    required this.onDecline,
    this.subdued = false,
  });

  final Booking booking;
  final BookingCollaborator collaborator;
  final int amount;
  final bool busy;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final bool subdued;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: subdued ? AppColors.snow : AppColors.emberSoft,
      borderRadius: BorderRadius.circular(AppTokens.radiusCard),
      border: subdued ? Border.all(color: AppColors.fog) : null,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                '${booking.photographerName} mời bạn cùng chụp',
                style: const TextStyle(
                  color: AppColors.obsidian,
                  fontSize: 13,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.circle, size: 8, color: AppColors.ember),
          ],
        ),
        const SizedBox(height: 9),
        _Info(
          icon: Icons.event_outlined,
          text: '${booking.style} · ${booking.date}',
        ),
        const SizedBox(height: 5),
        _Info(icon: Icons.location_on_outlined, text: booking.location),
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 3,
          children: [
            Text(
              'Tỷ lệ ${collaborator.sharePct}%',
              style: const TextStyle(
                color: AppColors.graphite,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text.rich(
              TextSpan(
                text: 'Nhận ',
                style: const TextStyle(color: AppColors.steel, fontSize: 11),
                children: [
                  TextSpan(
                    text: formatDong(amount),
                    style: const TextStyle(
                      color: AppColors.ember,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 11),
        CreatorDecisionActions(
          busy: busy,
          onDecline: onDecline,
          onAccept: onAccept,
          acceptLabel: 'Đồng ý',
        ),
      ],
    ),
  );
}

class _Info extends StatelessWidget {
  const _Info({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: AppColors.ash, size: 14),
      const SizedBox(width: 6),
      Expanded(
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.steel, fontSize: 11),
        ),
      ),
    ],
  );
}
