import 'package:flutter/material.dart';

import '../../../../core/widgets/creator_filter_tabs.dart';

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
  Widget build(BuildContext context) => CreatorFilterTabs(
    options: [
      const CreatorFilterOption('Tất cả'),
      CreatorFilterOption('Chưa đọc', count: unreadCount),
    ],
    selectedIndex: unreadOnly ? 1 : 0,
    onSelected: (index) => onChanged(index == 1),
  );
}
