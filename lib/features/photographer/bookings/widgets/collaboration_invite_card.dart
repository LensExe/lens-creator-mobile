import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/creator_avatar.dart';
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
    this.compact = false,
    this.inviterAvatar,
  });

  final Booking booking;
  final BookingCollaborator collaborator;
  final int amount;
  final bool busy;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final bool subdued;
  final bool compact;
  final String? inviterAvatar;

  @override
  Widget build(BuildContext context) =>
      compact ? _buildCompact(context) : _buildDetailed();

  Widget _buildCompact(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final narrow = constraints.maxWidth < 350;
      final avatar = Stack(
        clipBehavior: Clip.none,
        children: [
          CreatorAvatar(
            name: booking.photographerName,
            imageUrl: inviterAvatar,
            size: 32,
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.ember,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.snow, width: 1.5),
              ),
              child: const Icon(
                Icons.group_add_rounded,
                size: 8,
                color: AppColors.snow,
              ),
            ),
          ),
        ],
      );

      final summary = _CompactInviteSummary(
        booking: booking,
        collaborator: collaborator,
        amount: amount,
      );
      final actions = _CompactInviteActions(
        busy: busy,
        onAccept: onAccept,
        onDecline: onDecline,
      );

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.snow,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: const Color(0xFFEAE9EE)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x05000000),
              blurRadius: 5,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: narrow
            ? Column(
                children: [
                  Row(
                    children: [
                      avatar,
                      const SizedBox(width: 9),
                      Expanded(child: summary),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(alignment: Alignment.centerRight, child: actions),
                ],
              )
            : Row(
                children: [
                  avatar,
                  const SizedBox(width: 9),
                  Expanded(child: summary),
                  const SizedBox(width: 8),
                  actions,
                ],
              ),
      );
    },
  );

  Widget _buildDetailed() => Container(
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

class _CompactInviteSummary extends StatelessWidget {
  const _CompactInviteSummary({
    required this.booking,
    required this.collaborator,
    required this.amount,
  });

  final Booking booking;
  final BookingCollaborator collaborator;
  final int amount;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(booking.date);
    final dateLabel = date == null
        ? booking.date
        : DateFormat('dd/MM').format(date);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: '${booking.photographerName} ',
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
            children: [
              const TextSpan(
                text: 'mời cộng tác · ',
                style: TextStyle(
                  color: AppColors.graphite,
                  fontWeight: FontWeight.w400,
                ),
              ),
              TextSpan(
                text: '${booking.style} $dateLabel · ${booking.location}',
                style: const TextStyle(
                  color: AppColors.steel,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 3),
        Text.rich(
          TextSpan(
            text: 'Tỷ lệ ${collaborator.sharePct}%  ·  ',
            style: const TextStyle(
              color: AppColors.steel,
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
            ),
            children: [
              TextSpan(
                text: '+${formatDong(amount)}',
                style: const TextStyle(
                  color: AppColors.ember,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _CompactInviteActions extends StatelessWidget {
  const _CompactInviteActions({
    required this.busy,
    required this.onAccept,
    required this.onDecline,
  });

  final bool busy;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      OutlinedButton(
        onPressed: busy ? null : onDecline,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 30),
          padding: const EdgeInsets.symmetric(horizontal: 9),
          backgroundColor: const Color(0xFFF4F4F6),
          foregroundColor: AppColors.graphite,
          side: BorderSide.none,
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),
        child: const Text('Từ chối'),
      ),
      const SizedBox(width: 5),
      FilledButton(
        onPressed: busy ? null : onAccept,
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 30),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          backgroundColor: AppColors.ink,
          foregroundColor: AppColors.snow,
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
        child: busy
            ? const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: AppColors.snow,
                ),
              )
            : const Text('Đồng ý'),
      ),
    ],
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
