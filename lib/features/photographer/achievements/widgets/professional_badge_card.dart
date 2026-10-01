import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

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
    padding: const EdgeInsets.symmetric(vertical: 15),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: AppColors.fog)),
    ),
    child: Row(
      children: [
        Container(
          width: 41,
          height: 41,
          decoration: BoxDecoration(
            color: isUnlocked ? const Color(0xFFFFF0E8) : AppColors.mist,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            isUnlocked ? icon : Icons.lock_outline_rounded,
            color: isUnlocked ? AppColors.ember : AppColors.ash,
            size: 21,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isUnlocked ? AppColors.obsidian : AppColors.steel,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: const TextStyle(
                  color: AppColors.steel,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
