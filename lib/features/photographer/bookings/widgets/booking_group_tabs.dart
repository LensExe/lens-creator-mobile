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
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: Color(0xFFEAE9EE))),
    ),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            for (var index = 0; index < items.length; index++) ...[
              _StatusTab(
                item: items[index],
                selected: index == selectedIndex,
                onTap: () => onSelected(index),
              ),
              if (index < items.length - 1) const SizedBox(width: 4),
            ],
          ],
        ),
      ),
    ),
  );
}

class _StatusTab extends StatelessWidget {
  const _StatusTab({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final BookingGroupTab item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? AppColors.ink : Colors.transparent,
    borderRadius: BorderRadius.circular(999),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 36),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.label,
                style: TextStyle(
                  color: selected ? AppColors.snow : AppColors.graphite,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 17,
                height: 17,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? AppColors.ember : const Color(0xFFE8E8EC),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${item.count}',
                  style: TextStyle(
                    color: selected ? AppColors.snow : AppColors.graphite,
                    fontSize: 10,
                    height: 1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
