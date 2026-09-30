import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';

class StorageFilterOption {
  const StorageFilterOption({required this.label, required this.count});

  final String label;
  final int count;
}

class StorageFilterTabs extends StatelessWidget {
  const StorageFilterTabs({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<StorageFilterOption> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        for (var index = 0; index < options.length; index++) ...[
          _FilterTab(
            option: options[index],
            selected: selectedIndex == index,
            onTap: () => onSelected(index),
          ),
          if (index < options.length - 1) const SizedBox(width: 7),
        ],
      ],
    ),
  );
}

class _FilterTab extends StatelessWidget {
  const _FilterTab({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final StorageFilterOption option;
  final bool selected;
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
              const Icon(Icons.check_rounded, color: AppColors.snow, size: 13),
              const SizedBox(width: 4),
            ],
            Text(
              option.label,
              style: TextStyle(
                color: selected ? AppColors.snow : AppColors.graphite,
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.snow.withValues(alpha: 0.2)
                    : AppColors.mist,
                borderRadius: BorderRadius.circular(AppTokens.radiusPill),
              ),
              child: Text(
                '${option.count}',
                style: TextStyle(
                  color: selected ? AppColors.snow : AppColors.steel,
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
