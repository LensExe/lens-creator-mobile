import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

class SurfaceCard extends StatelessWidget {
  final Widget child;
  final bool isMuted;
  final EdgeInsetsGeometry padding;

  const SurfaceCard({
    super.key,
    required this.child,
    this.isMuted = false,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: isMuted ? AppColors.fog : AppColors.snow,
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        border: !isMuted
            ? Border.all(color: AppColors.pebble, width: 1.0)
            : null,
      ),
      child: child,
    );
  }
}
