import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../domain/booking_rules.dart';
import '../../../../domain/models/models.dart';
import '../conversation_provider.dart';
import 'conversation_avatar.dart';

class ConversationPreviewTile extends StatelessWidget {
  const ConversationPreviewTile({
    super.key,
    required this.conversation,
    required this.onTap,
    this.booking,
    this.assistantEnabled = false,
  });

  final StudioConversation conversation;
  final VoidCallback onTap;
  final Booking? booking;
  final bool assistantEnabled;

  String _timeLabel(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    if (DateUtils.isSameDay(date, now)) return DateFormat('HH:mm').format(date);
    if (DateUtils.isSameDay(date, now.subtract(const Duration(days: 1)))) {
      return 'Hôm qua';
    }
    return DateFormat('dd/MM').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final lastMessage = conversation.messages.lastOrNull;
    final hasUnread = conversation.unreadCount > 0;
    final aiActive =
        !conversation.participantIsPhotographer &&
        conversation.aiEnabled &&
        assistantEnabled;

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E8E9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConversationAvatar(
                  name: conversation.participantName,
                  unread: hasUnread,
                  size: 48,
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (hasUnread) ...[
                            Container(
                              width: 7,
                              height: 7,
                              margin: const EdgeInsets.only(right: 6),
                              decoration: const BoxDecoration(
                                color: AppColors.ember,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                          Expanded(
                            child: Text(
                              conversation.participantName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.ink,
                                fontSize: 15,
                                fontWeight: hasUnread
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 7),
                          Text(
                            _timeLabel(lastMessage?.sentAt),
                            style: TextStyle(
                              color: hasUnread
                                  ? AppColors.ember
                                  : AppColors.steel,
                              fontSize: 10,
                              fontWeight: hasUnread
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        lastMessage?.text ?? 'Chưa có tin nhắn',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: hasUnread ? AppColors.ink : AppColors.graphite,
                          fontSize: 13,
                          height: 1.35,
                          fontWeight: hasUnread
                              ? FontWeight.w500
                              : FontWeight.w400,
                        ),
                      ),
                      if (booking != null ||
                          conversation.participantIsPhotographer ||
                          aiActive) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 5,
                          children: [
                            if (booking != null)
                              _PreviewTag(
                                icon: Icons.photo_camera_outlined,
                                label:
                                    '${booking!.style} · ${BookingRules.statusLabel(booking!.status)}',
                              ),
                            if (conversation.participantIsPhotographer)
                              const _PreviewTag(
                                icon: Icons.groups_outlined,
                                label: 'Cộng tác viên',
                                emphasized: false,
                              ),
                            if (aiActive)
                              const _PreviewTag(
                                icon: Icons.smart_toy_outlined,
                                label: 'AI Auto-reply',
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                if (hasUnread) ...[
                  const SizedBox(width: 8),
                  Container(
                    constraints: const BoxConstraints(
                      minWidth: 19,
                      minHeight: 19,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.ember,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${conversation.unreadCount}',
                      style: const TextStyle(
                        color: AppColors.snow,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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

class _PreviewTag extends StatelessWidget {
  const _PreviewTag({
    required this.icon,
    required this.label,
    this.emphasized = true,
  });

  final IconData icon;
  final String label;
  final bool emphasized;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(maxWidth: 230),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: emphasized ? const Color(0xFFF3F3F4) : const Color(0xFFE5E1E4),
      borderRadius: BorderRadius.circular(AppTokens.radiusPill),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 13,
          color: emphasized ? AppColors.ember : AppColors.graphite,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.graphite,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}
