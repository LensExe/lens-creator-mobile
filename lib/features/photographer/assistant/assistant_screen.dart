import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';

class AssistantScreen extends StatelessWidget {
  const AssistantScreen({super.key});

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
              context.go('/photographer_home');
            }
          },
          icon: const Icon(LucideIcons.arrowLeft),
        ),
        title: const Text('Trợ lý AI'),
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
                Icon(LucideIcons.bot, size: 32, color: AppColors.steel),
                SizedBox(height: 16),
                Text(
                  'Trợ lý AI chưa được hỗ trợ',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8),
                Text(
                  'Backend hiện chưa có API lưu cấu hình hoặc xử lý hội thoại AI. '
                  'Các câu trả lời mô phỏng và tùy chọn chưa được lưu đã được tắt.',
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
