import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
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
  });

  final StudioConversation conversation;
  final VoidCallback onTap;
  final Booking? booking;

  @override
  Widget build(BuildContext context) {
    final lastMessage = conversation.messages.lastOrNull;
    final hasUnread = conversation.unreadCount > 0;

    return Material(
      color: AppColors.snow,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              ConversationAvatar(
                name: conversation.participantName,
                unread: hasUnread,
                size: 49,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.participantName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.obsidian,
                              fontSize: 15,
                              fontWeight: hasUnread
                                  ? FontWeight.w800
                                  : FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          lastMessage == null
                              ? ''
                              : DateFormat('HH:mm').format(lastMessage.sentAt),
                          style: TextStyle(
                            color: hasUnread ? AppColors.ember : AppColors.ash,
                            fontSize: 11,
                            fontWeight: hasUnread
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    if (booking != null) ...[
                      Text(
                        '${booking!.style} · ${BookingRules.statusLabel(booking!.status)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.ember,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                    ],
                    Text(
                      lastMessage?.text ?? 'Chưa có tin nhắn',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: hasUnread ? AppColors.graphite : AppColors.steel,
                        fontSize: 12,
                        fontWeight: hasUnread
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasUnread) ...[
                const SizedBox(width: 9),
                Container(
                  constraints: const BoxConstraints(
                    minWidth: 21,
                    minHeight: 21,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
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
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
