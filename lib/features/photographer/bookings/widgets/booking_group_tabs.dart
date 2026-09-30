import 'package:flutter/material.dart';

import '../../../../core/widgets/creator_filter_tabs.dart';

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
  Widget build(BuildContext context) => CreatorFilterTabs(
    options: [
      for (final item in items)
        CreatorFilterOption(item.label, count: item.count),
    ],
    selectedIndex: selectedIndex,
    onSelected: onSelected,
  );
}
