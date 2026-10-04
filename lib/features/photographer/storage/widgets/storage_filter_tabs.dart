import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';

class StorageFilterOption {
  const StorageFilterOption({
    required this.label,
    required this.count,
    this.attention = false,
  });

  final String label;
  final int count;
  final bool attention;
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
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: AppColors.snow,
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: AppColors.fog),
    ),
    child: Row(
      children: [
        for (var index = 0; index < options.length; index++) ...[
          if (index > 0) const SizedBox(width: 3),
          Expanded(
            child: _FilterTab(
              option: options[index],
              selected: index == selectedIndex,
              onTap: () => onSelected(index),
            ),
          ),
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
    color: selected ? AppColors.ember : Colors.transparent,
    borderRadius: BorderRadius.circular(10),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: 38,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (option.attention && !selected) ...[
              const Icon(Icons.circle, color: AppColors.destructive, size: 6),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                option.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? AppColors.snow : AppColors.graphite,
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              constraints: const BoxConstraints(minWidth: 17),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0x40FFFFFF)
                    : option.attention
                    ? const Color(0xFFFFECEA)
                    : const Color(0xFFF0F0F1),
                borderRadius: BorderRadius.circular(AppTokens.radiusPill),
              ),
              child: Text(
                '${option.count}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected
                      ? AppColors.snow
                      : option.attention
                      ? AppColors.destructive
                      : AppColors.steel,
                  fontSize: 9,
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
