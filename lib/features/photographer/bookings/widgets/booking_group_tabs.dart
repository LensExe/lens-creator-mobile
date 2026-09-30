import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class BookingGroupTab {
  const BookingGroupTab(this.label, this.count);
  final String label;
  final int count;
}

class BookingGroupTabs extends StatelessWidget {
  const BookingGroupTabs({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<BookingGroupTab> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        for (var index = 0; index < items.length; index++) ...[
          _Tab(
            item: items[index],
            selected: index == selectedIndex,
            onTap: () => onSelected(index),
          ),
          if (index < items.length - 1) const SizedBox(width: 8),
        ],
      ],
    ),
  );
}

class _Tab extends StatelessWidget {
  const _Tab({required this.item, required this.selected, required this.onTap});
  final BookingGroupTab item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? AppColors.obsidian : AppColors.snow,
    borderRadius: BorderRadius.circular(13),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: selected ? AppColors.obsidian : AppColors.fog,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.done_rounded, color: AppColors.snow, size: 14),
              const SizedBox(width: 5),
            ],
            Text(
              '${item.label} (${item.count})',
              style: TextStyle(
                color: selected ? AppColors.snow : AppColors.graphite,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
