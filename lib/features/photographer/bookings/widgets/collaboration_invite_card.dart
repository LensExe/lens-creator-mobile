import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
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
  });

  final Booking booking;
  final BookingCollaborator collaborator;
  final int amount;
  final bool busy;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.snow, Color(0xFFFFF8F3)],
      ),
      borderRadius: BorderRadius.circular(AppTokens.radiusCard),
      border: Border.all(color: const Color(0xFFFFD9C5)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x07000000),
          blurRadius: 10,
          offset: Offset(0, 3),
        ),
      ],
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
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
          decoration: BoxDecoration(
            color: AppColors.mist,
            border: Border.all(color: AppColors.fog),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Wrap(
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
        ),
        const SizedBox(height: 11),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: busy ? null : onDecline,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.graphite,
                  side: const BorderSide(color: AppColors.pebble),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                  minimumSize: const Size(0, 40),
                ),
                child: const Text('Từ chối', style: TextStyle(fontSize: 12)),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: FilledButton.icon(
                onPressed: busy ? null : onAccept,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.obsidian,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                  minimumSize: const Size(0, 40),
                ),
                icon: busy
                    ? const SizedBox(
                        width: 13,
                        height: 13,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.snow,
                        ),
                      )
                    : const Icon(Icons.check_rounded, size: 15),
                label: const Text('Đồng ý', style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
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
