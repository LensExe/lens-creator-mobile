import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../conversation_provider.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isMine,
  });

  final StudioMessage message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final bubbleColor = message.isAi
        ? const Color(0xFFFFF0E8)
        : isMine
        ? AppColors.obsidian
        : AppColors.snow;
    final textColor = isMine && !message.isAi
        ? AppColors.snow
        : AppColors.obsidian;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 11),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isMine ? 18 : 5),
              bottomRight: Radius.circular(isMine ? 5 : 18),
            ),
            border: message.isAi || isMine
                ? null
                : Border.all(color: AppColors.fog),
            boxShadow: [
              if (!isMine)
                const BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.isAi) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.ember,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Trợ lý AI',
                      style: TextStyle(
                        color: AppColors.ember,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
              Text(
                message.text,
                style: TextStyle(color: textColor, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  DateFormat('HH:mm').format(message.sentAt),
                  style: TextStyle(
                    color: isMine && !message.isAi
                        ? AppColors.pebble
                        : AppColors.ash,
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
