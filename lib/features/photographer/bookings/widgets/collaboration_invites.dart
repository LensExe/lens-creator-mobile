import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../domain/booking_rules.dart';
import '../../../../domain/models/models.dart';
import '../../../../providers/data_providers.dart';
import 'collaboration_invite_card.dart';

class CollaborationInvites extends ConsumerStatefulWidget {
  const CollaborationInvites({
    super.key,
    this.subdued = false,
    this.compact = false,
  });

  final bool subdued;
  final bool compact;

  @override
  ConsumerState<CollaborationInvites> createState() =>
      _CollaborationInvitesState();
}

class _CollaborationInvitesState extends ConsumerState<CollaborationInvites> {
  String? responding;

  Future<void> _respond(Booking booking, CollaborationStatus status) async {
    setState(() => responding = booking.id);
    try {
      await ref
          .read(asyncBookingsProvider.notifier)
          .respondToCollaboration(booking.id, status);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == CollaborationStatus.accepted
                  ? 'Đã đồng ý tham gia buổi chụp'
                  : 'Đã từ chối lời mời',
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể phản hồi: $error')));
      }
    } finally {
      if (mounted) setState(() => responding = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authUserProvider);
    final photographers = ref.watch(photographersProvider);
    final invites = ref
        .watch(myCollaborationsProvider)
        .where(
          (booking) => booking.collaborators.any(
            (item) =>
                item.photographerId == user?.id &&
                item.status == CollaborationStatus.invited,
          ),
        )
        .toList();
    if (invites.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(top: widget.subdued ? 8 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.compact) ...[
            Row(
              children: [
                const Icon(
                  Icons.handshake_outlined,
                  size: 19,
                  color: AppColors.ember,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'Lời mời liên kết',
                    style: TextStyle(
                      color: AppColors.obsidian,
                      fontSize: widget.subdued ? 14 : 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: widget.subdued
                        ? AppColors.mist
                        : const Color(0xFFFFEEE5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${invites.length} mới',
                    style: TextStyle(
                      color: widget.subdued ? AppColors.steel : AppColors.ember,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          for (final booking in invites) ...[
            Builder(
              builder: (context) {
                final entry = booking.collaborators.firstWhere(
                  (item) => item.photographerId == user!.id,
                );
                final amount =
                    (BookingRules.payout(booking.price) * entry.sharePct / 100)
                        .round();
                final inviter = photographers
                    .where(
                      (photographer) =>
                          photographer.id == booking.photographerId,
                    )
                    .firstOrNull;
                return CollaborationInviteCard(
                  booking: booking,
                  collaborator: entry,
                  amount: amount,
                  busy: responding == booking.id,
                  subdued: widget.subdued,
                  compact: widget.compact,
                  inviterAvatar: inviter?.avatar,
                  onAccept: () =>
                      _respond(booking, CollaborationStatus.accepted),
                  onDecline: () =>
                      _respond(booking, CollaborationStatus.declined),
                );
              },
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
