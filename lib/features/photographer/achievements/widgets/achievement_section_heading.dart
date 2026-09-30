import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class AchievementSectionHeading extends StatelessWidget {
  const AchievementSectionHeading({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final String? trailing;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.obsidian,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.25,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.steel,
                fontSize: 11,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
      if (trailing != null) ...[
        const SizedBox(width: 10),
        Text(
          trailing!,
          style: const TextStyle(
            color: AppColors.ash,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ],
  );
}
