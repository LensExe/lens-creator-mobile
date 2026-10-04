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
    margin: const EdgeInsets.fromLTRB(12, 5, 12, 4),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.snow,
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: const Color(0xFFE8E8E9)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x06000000),
          blurRadius: 9,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 37,
          height: 37,
          decoration: BoxDecoration(
            color: const Color(0xFFE8E8E9),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.smart_toy_rounded,
            color: AppColors.ember,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                runSpacing: 3,
                children: [
                  const Text(
                    'Trợ lý AI tự động phản hồi',
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x1AFF5A00),
                      borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                    ),
                    child: const Text(
                      'LENS AI',
                      style: TextStyle(
                        color: AppColors.ember,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
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
                  fontSize: 10,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Switch.adaptive(
          value: isEnabled,
          onChanged: canToggle ? onChanged : null,
          activeTrackColor: AppColors.ember,
        ),
      ],
    ),
  );
}
