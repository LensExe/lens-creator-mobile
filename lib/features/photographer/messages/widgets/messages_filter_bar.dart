import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';

class MessagesFilterBar extends StatelessWidget {
  const MessagesFilterBar({
    super.key,
    required this.unreadOnly,
    required this.totalCount,
    required this.unreadCount,
    required this.onChanged,
  });

  final bool unreadOnly;
  final int totalCount;
  final int unreadCount;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        _MessageFilterChip(
          label: 'Tất cả',
          count: totalCount,
          selected: !unreadOnly,
          onTap: () => onChanged(false),
        ),
        const SizedBox(width: 7),
        _MessageFilterChip(
          label: 'Chưa đọc',
          count: unreadCount,
          selected: unreadOnly,
          onTap: () => onChanged(true),
        ),
      ],
    ),
  );
}

class _MessageFilterChip extends StatelessWidget {
  const _MessageFilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int? count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? AppColors.ember : const Color(0xFFEEEEEF),
    borderRadius: BorderRadius.circular(AppTokens.radiusPill),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTokens.radiusPill),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.snow : AppColors.graphite,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 7),
              Container(
                constraints: const BoxConstraints(minWidth: 18),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: selected ? const Color(0x40FFFFFF) : AppColors.ember,
                  borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                ),
                child: Text(
                  '$count',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.snow,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
