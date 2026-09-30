import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ConversationAvatar extends StatelessWidget {
  const ConversationAvatar({
    super.key,
    required this.name,
    this.size = 48,
    this.unread = false,
  });

  final String name;
  final double size;
  final bool unread;

  @override
  Widget build(BuildContext context) {
    final normalizedName = name.trim();
    final initial = normalizedName.isEmpty
        ? '?'
        : normalizedName.characters.first.toUpperCase();

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: unread ? const Color(0xFFFFE9DC) : AppColors.mist,
        shape: BoxShape.circle,
      ),
      child: Text(
        initial,
        style: TextStyle(
          color: unread ? AppColors.ember : AppColors.graphite,
          fontSize: size * 0.38,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
