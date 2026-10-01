import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import 'assistant_info_field.dart';

class AssistantFaqEditor extends StatelessWidget {
  const AssistantFaqEditor({
    super.key,
    required this.index,
    required this.question,
    required this.answer,
    required this.enabled,
    required this.onRemove,
  });

  final int index;
  final TextEditingController question;
  final TextEditingController answer;
  final bool enabled;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.snow,
      border: Border.all(color: AppColors.fog),
      borderRadius: BorderRadius.circular(AppTokens.radiusCard),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Câu hỏi $index',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontSize: 14),
              ),
            ),
            IconButton(
              onPressed: enabled ? onRemove : null,
              tooltip: 'Xoá câu hỏi',
              visualDensity: VisualDensity.compact,
              style: IconButton.styleFrom(
                foregroundColor: AppColors.destructive,
              ),
              icon: const Icon(Icons.delete_outline_rounded, size: 20),
            ),
          ],
        ),
        AssistantInfoField(
          label: 'Câu hỏi',
          controller: question,
          maxLines: 1,
          enabled: enabled,
        ),
        const SizedBox(height: 10),
        AssistantInfoField(
          label: 'Câu trả lời',
          controller: answer,
          maxLines: 3,
          enabled: enabled,
        ),
      ],
    ),
  );
}
