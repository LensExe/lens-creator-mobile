import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ConversationAvatar extends StatelessWidget {
  const ConversationAvatar({
    super.key,
    required this.name,
    this.size = 48,
    this.unread = false,
    this.imageUrl,
  });

  final String name;
  final double size;
  final bool unread;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final normalizedName = name.trim();
    final initial = normalizedName.isEmpty
        ? '?'
        : normalizedName.characters.first.toUpperCase();

    final imageUrl = this.imageUrl?.trim();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: unread ? const Color(0xFFFFE9DC) : AppColors.mist,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl == null || imageUrl.isEmpty
          ? Center(
              child: Text(
                initial,
                style: TextStyle(
                  color: unread ? AppColors.ember : AppColors.graphite,
                  fontSize: size * 0.38,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : Image.network(
              imageUrl,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Center(
                child: Text(
                  initial,
                  style: TextStyle(
                    color: unread ? AppColors.ember : AppColors.graphite,
                    fontSize: size * 0.38,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
    );
  }
}
