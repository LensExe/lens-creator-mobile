import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class PortfolioEditorActions extends StatelessWidget {
  const PortfolioEditorActions({
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
      boxShadow: [
        BoxShadow(
          color: Color(0x0A000000),
          blurRadius: 12,
          offset: Offset(0, -3),
        ),
      ],
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
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.graphite,
                  side: const BorderSide(color: AppColors.pebble),
                  minimumSize: const Size(0, 46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                child: const Text('Huỷ'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                onPressed: busy ? null : onSave,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.obsidian,
                  foregroundColor: AppColors.snow,
                  minimumSize: const Size(0, 46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                icon: const Icon(Icons.check_rounded, size: 17),
                label: Text(
                  busy ? 'Đang lưu...' : 'Lưu hồ sơ',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
