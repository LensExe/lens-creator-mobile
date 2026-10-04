import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../conversation_provider.dart';
import 'conversation_avatar.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    required this.senderName,
  });

  final StudioMessage message;
  final bool isMine;
  final String senderName;

  @override
  Widget build(BuildContext context) {
    final fromStudio = isMine || message.isAi;
    final bubbleColor = fromStudio ? const Color(0xFF2F3132) : AppColors.snow;
    final textColor = fromStudio ? AppColors.snow : AppColors.ink;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Align(
        alignment: fromStudio ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.88,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!fromStudio) ...[
                ConversationAvatar(name: senderName, size: 27),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Column(
                  crossAxisAlignment: fromStudio
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    if (message.isAi) ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: 5),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8E8E9),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.bolt_rounded,
                              color: AppColors.ember,
                              size: 13,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Trợ lý AI trả lời tự động',
                              style: TextStyle(
                                color: AppColors.graphite,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: bubbleColor,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(20),
                          topRight: const Radius.circular(20),
                          bottomLeft: Radius.circular(fromStudio ? 20 : 5),
                          bottomRight: Radius.circular(fromStudio ? 5 : 20),
                        ),
                        border: fromStudio
                            ? null
                            : Border.all(color: const Color(0xFFE8E8E9)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x07000000),
                            blurRadius: 9,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        message.text,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          height: 1.45,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                      child: Text(
                        DateFormat('HH:mm').format(message.sentAt),
                        style: const TextStyle(
                          color: AppColors.steel,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
