import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';

class ProfessionalBadgeCard extends StatelessWidget {
  const ProfessionalBadgeCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool isUnlocked;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
    decoration: BoxDecoration(
      color: AppColors.snow,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.fog.withValues(alpha: 0.65)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0809090B),
          blurRadius: 12,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: isUnlocked ? AppColors.emberSoft : AppColors.mist,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isUnlocked ? icon : Icons.lock_outline_rounded,
            color: isUnlocked ? AppColors.ember : AppColors.ash,
            size: 23,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isUnlocked ? AppColors.obsidian : AppColors.slate,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.steel,
                  fontSize: 11,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 7),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.mist,
            borderRadius: BorderRadius.circular(AppTokens.radiusPill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isUnlocked ? Icons.check_circle_rounded : Icons.lock_rounded,
                color: AppColors.ember,
                size: 13,
              ),
              const SizedBox(width: 4),
              Text(
                isUnlocked ? 'Đã đạt' : 'Chưa đạt',
                style: const TextStyle(
                  color: AppColors.graphite,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
