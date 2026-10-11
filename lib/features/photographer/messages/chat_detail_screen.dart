import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';

class ChatDetailScreen extends StatelessWidget {
  const ChatDetailScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9FA),
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/photographer_home/messages');
            }
          },
          icon: const Icon(LucideIcons.arrowLeft),
        ),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  LucideIcons.messageSquareText,
                  size: 32,
                  color: AppColors.steel,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Không thể mở cuộc trò chuyện',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Backend hiện chưa cung cấp API tải hoặc gửi tin nhắn. '
                  'Cuộc trò chuyện $id chưa được tải và không có nội dung mẫu được lưu.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.steel, height: 1.45),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
