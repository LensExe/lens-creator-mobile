import 'package:flutter/material.dart';
import 'package:lens_creator_mobile/core/theme/app_colors.dart';

class BadgeItem extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isUnlocked;

  const BadgeItem({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUnlocked ? color.withValues(alpha: 0.4) : AppColors.fog,
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isUnlocked
                  ? color.withValues(alpha: 0.15)
                  : AppColors.mist,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isUnlocked ? icon : Icons.lock_outline,
              color: isUnlocked ? color : AppColors.steel,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: isUnlocked ? AppColors.obsidian : AppColors.slate,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              description,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.steel,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
