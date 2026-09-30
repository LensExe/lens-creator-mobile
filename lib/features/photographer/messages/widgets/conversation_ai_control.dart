import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';

class ConversationAiControl extends StatelessWidget {
  const ConversationAiControl({
    super.key,
    required this.isEnabled,
    required this.canToggle,
    required this.onChanged,
  });

  final bool isEnabled;
  final bool canToggle;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
    decoration: BoxDecoration(
      color: AppColors.snow,
      borderRadius: BorderRadius.circular(AppTokens.radiusCard),
      border: Border.all(color: AppColors.fog),
    ),
    child: Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isEnabled ? const Color(0xFFFFF0E8) : AppColors.mist,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.auto_awesome_rounded,
            color: isEnabled ? AppColors.ember : AppColors.steel,
            size: 19,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Trợ lý AI',
                    style: TextStyle(
                      color: AppColors.obsidian,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isEnabled
                          ? const Color(0xFFE8F6EF)
                          : AppColors.mist,
                      borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                    ),
                    child: Text(
                      isEnabled ? 'ĐANG BẬT' : 'ĐANG TẮT',
                      style: TextStyle(
                        color: isEnabled
                            ? const Color(0xFF16865A)
                            : AppColors.steel,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                canToggle
                    ? isEnabled
                          ? 'Trợ lý đang trả lời trong hội thoại này.'
                          : 'Bạn đang trực tiếp trả lời khách.'
                    : 'Bật Trợ lý AI trong cài đặt để sử dụng.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.steel,
                  fontSize: 9,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Switch.adaptive(
          value: isEnabled,
          onChanged: canToggle ? onChanged : null,
          activeTrackColor: AppColors.ember,
        ),
      ],
    ),
  );
}
