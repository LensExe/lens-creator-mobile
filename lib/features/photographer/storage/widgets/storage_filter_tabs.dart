import 'package:flutter/material.dart';

import '../../../../core/widgets/creator_filter_tabs.dart';

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
  Widget build(BuildContext context) => CreatorFilterTabs(
    options: [
      for (final option in options)
        CreatorFilterOption(option.label, count: option.count),
    ],
    selectedIndex: selectedIndex,
    onSelected: onSelected,
  );
}
