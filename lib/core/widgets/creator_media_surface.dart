import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

class CreatorMediaSurface extends StatelessWidget {
  const CreatorMediaSurface({
    super.key,
    required this.imageUrl,
    this.height,
    this.radius = AppTokens.radiusCard,
    this.placeholderIcon = Icons.photo_outlined,
  });

  final String imageUrl;
  final double? height;
  final double radius;
  final IconData placeholderIcon;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: SizedBox(
      width: double.infinity,
      height: height,
      child: imageUrl.isEmpty
          ? _placeholder()
          : Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _placeholder(),
              loadingBuilder: (context, child, progress) => progress == null
                  ? child
                  : const ColoredBox(
                      color: AppColors.mist,
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
            ),
    ),
  );

  Widget _placeholder() => ColoredBox(
    color: AppColors.fog,
    child: Center(child: Icon(placeholderIcon, color: AppColors.steel)),
  );
}
