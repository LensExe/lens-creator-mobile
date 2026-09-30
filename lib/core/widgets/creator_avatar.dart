import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class CreatorAvatar extends StatelessWidget {
  const CreatorAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 44,
  });

  final String name;
  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final words = name.trim().split(RegExp(r'\s+'));
    final initial = name.trim().isEmpty
        ? '?'
        : words.length == 1
        ? words.first.characters.first.toUpperCase()
        : '${words.first.characters.first}${words.last.characters.first}'
              .toUpperCase();
    final url = imageUrl?.trim() ?? '';
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: AppColors.emberSoft,
      foregroundImage: url.isEmpty ? null : NetworkImage(url),
      onForegroundImageError: url.isEmpty ? null : (_, _) {},
      child: Text(
        initial,
        style: TextStyle(
          color: AppColors.ember,
          fontSize: size * 0.28,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
