import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class AssistantEditorActions extends StatelessWidget {
  const AssistantEditorActions({
    super.key,
    required this.onSave,
    this.onCancel,
    this.busy = false,
    this.isDirty = false,
  });

  final VoidCallback onSave;
  final VoidCallback? onCancel;
  final bool busy;
  final bool isDirty;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: const Color(0xFFF9F9FA).withValues(alpha: 0.95),
      border: const Border(top: BorderSide(color: Color(0xFFE8E8E9))),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 16,
          offset: const Offset(0, -4),
        ),
      ],
    ),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          children: [
            // Status Indicator (Dirty vs Synced)
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDirty
                          ? AppColors.ember
                          : const Color(0xFF2E6B27),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      isDirty ? 'Có thay đổi chưa lưu' : 'Đã đồng bộ',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: isDirty
                            ? AppColors.ember
                            : const Color(0xFF5F5E60),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Save Action Button
            ElevatedButton.icon(
              onPressed: busy ? null : onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.ember,
                foregroundColor: Colors.white,
                elevation: 1,
                shadowColor: AppColors.ember.withValues(alpha: 0.25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 9,
                ),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              icon: busy
                  ? const SizedBox.square(
                      dimension: 15,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_rounded, size: 16),
              label: Text(busy ? 'Đang lưu...' : 'Lưu cấu hình'),
            ),
          ],
        ),
      ),
    ),
  );
}
