import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';

class MessagesFilterBar extends StatelessWidget {
  const MessagesFilterBar({
    super.key,
    required this.unreadOnly,
    required this.unreadCount,
    required this.onChanged,
  });

  final bool unreadOnly;
  final int unreadCount;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        _FilterChip(
          label: 'Tất cả',
          selected: !unreadOnly,
          onTap: () => onChanged(false),
        ),
        const SizedBox(width: 8),
        _FilterChip(
          label: 'Chưa đọc',
          count: unreadCount,
          selected: unreadOnly,
          onTap: () => onChanged(true),
        ),
      ],
    ),
  );
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.count,
  });

  final String label;
  final bool selected;
  final int? count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? AppColors.ember : AppColors.snow,
    borderRadius: BorderRadius.circular(AppTokens.radiusPill),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTokens.radiusPill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTokens.radiusPill),
          border: Border.all(color: selected ? AppColors.ember : AppColors.fog),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.check_rounded, size: 13, color: AppColors.snow),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.snow : AppColors.graphite,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.snow.withValues(alpha: 0.2)
                      : AppColors.mist,
                  borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: selected ? AppColors.snow : AppColors.steel,
                    fontSize: 9,
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
