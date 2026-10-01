import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class AssistantEditorActions extends StatelessWidget {
  const AssistantEditorActions({
    super.key,
    required this.onCancel,
    required this.onSave,
    this.busy = false,
  });

  final VoidCallback onCancel;
  final VoidCallback onSave;
  final bool busy;

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: AppColors.snow,
      border: Border(top: BorderSide(color: AppColors.fog)),
    ),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: busy ? null : onCancel,
                child: const Text('Huỷ'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                onPressed: busy ? null : onSave,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.obsidian,
                ),
                icon: busy
                    ? const SizedBox.square(
                        dimension: 17,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.snow,
                        ),
                      )
                    : const Icon(Icons.check_rounded, size: 17),
                label: Text(busy ? 'Đang lưu...' : 'Lưu thay đổi'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
