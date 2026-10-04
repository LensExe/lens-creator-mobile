import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class PackageEditorActions extends StatelessWidget {
  const PackageEditorActions({
    super.key,
    required this.onCancel,
    required this.onSave,
    required this.saveLabel,
    this.busy = false,
  });

  final VoidCallback onCancel;
  final VoidCallback onSave;
  final String saveLabel;
  final bool busy;

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: Color(0xFFF9F9FA),
      border: Border(top: BorderSide(color: AppColors.fog)),
      boxShadow: [
        BoxShadow(
          color: Color(0x0A000000),
          blurRadius: 16,
          offset: Offset(0, -4),
        ),
      ],
    ),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: busy ? null : onCancel,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFE5E1E4),
                        foregroundColor: AppColors.ink,
                        side: BorderSide.none,
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('Huỷ'),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: busy ? null : onSave,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.ember,
                        foregroundColor: AppColors.snow,
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      icon: busy
                          ? const SizedBox.square(
                              dimension: 17,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.snow,
                              ),
                            )
                          : const Icon(Icons.save_outlined, size: 18),
                      label: Text(busy ? 'Đang lưu...' : saveLabel),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            const Text(
              'Số lượng ảnh và thời hạn giao là cam kết của buổi chụp. Lịch đã đặt giữ nguyên điều khoản.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.steel,
                fontSize: 10,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
