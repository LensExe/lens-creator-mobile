import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class AvailabilitySaveBar extends StatelessWidget {
  const AvailabilitySaveBar({
    super.key,
    required this.onDiscard,
    required this.onSave,
  });

  final VoidCallback onDiscard;
  final VoidCallback onSave;

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
        padding: const EdgeInsets.fromLTRB(16, 11, 16, 11),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onDiscard,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.graphite,
                  side: const BorderSide(color: AppColors.pebble),
                  minimumSize: const Size(0, 46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                child: const Text('Bỏ thay đổi'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                onPressed: onSave,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.obsidian,
                  foregroundColor: AppColors.snow,
                  minimumSize: const Size(0, 46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                icon: const Icon(Icons.save_outlined, size: 17),
                label: const Text(
                  'Lưu lịch',
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
