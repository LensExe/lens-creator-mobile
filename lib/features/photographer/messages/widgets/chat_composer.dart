import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';

class ChatComposer extends StatelessWidget {
  const ChatComposer({
    super.key,
    required this.controller,
    required this.onSend,
    this.busy = false,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool busy;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
    decoration: BoxDecoration(
      color: AppColors.snow,
      border: const Border(top: BorderSide(color: Color(0xFFE8E8E9))),
      boxShadow: const [
        BoxShadow(
          color: Color(0x08000000),
          blurRadius: 12,
          offset: Offset(0, -3),
        ),
      ],
    ),
    child: SafeArea(
      top: false,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: !busy,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Nhập tin nhắn tư vấn...',
                filled: true,
                fillColor: AppColors.snow,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 11,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                  borderSide: const BorderSide(color: AppColors.ember),
                ),
              ),
            ),
          ),
          const SizedBox(width: 9),
          SizedBox(
            width: 43,
            height: 43,
            child: IconButton.filled(
              onPressed: busy ? null : onSend,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.ember,
                foregroundColor: AppColors.snow,
                shape: const CircleBorder(),
              ),
              icon: busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.snow,
                      ),
                    )
                  : const Icon(Icons.arrow_upward_rounded, size: 20),
              tooltip: 'Gửi tin nhắn',
            ),
          ),
        ],
      ),
    ),
  );
}
