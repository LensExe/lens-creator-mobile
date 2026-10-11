import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';

class MessagesListScreen extends StatelessWidget {
  const MessagesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9FA),
        title: const Text('Tin nhắn'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.pageHorizontal),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.snow,
              borderRadius: BorderRadius.circular(AppTokens.cardRadius),
              border: Border.all(color: AppColors.pebble),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.messageSquareText,
                  size: 32,
                  color: AppColors.steel,
                ),
                SizedBox(height: 16),
                Text(
                  'Tin nhắn chưa được hỗ trợ',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8),
                Text(
                  'Backend hiện chưa cung cấp API cuộc trò chuyện, lịch sử tin nhắn hoặc gửi tin. '
                  'Không có hội thoại mẫu nào được hiển thị.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.steel, height: 1.45),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
