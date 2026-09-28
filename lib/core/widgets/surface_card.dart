import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class SurfaceCard extends StatelessWidget {
  final Widget child;
  final bool isMuted;
  final EdgeInsetsGeometry padding;

  const SurfaceCard({
    super.key,
    required this.child,
    this.isMuted = false,
    this.padding = const EdgeInsets.all(28),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: isMuted ? AppColors.fog : AppColors.snow,
        borderRadius: BorderRadius.circular(24),
        border: !isMuted
            ? Border.all(color: AppColors.pebble, width: 1.0)
            : null,
      ),
      child: child,
    );
  }
}
