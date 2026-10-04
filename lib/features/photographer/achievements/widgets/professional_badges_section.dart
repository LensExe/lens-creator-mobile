import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'professional_badge_card.dart';

class ProfessionalBadge {
  const ProfessionalBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final bool isUnlocked;
}

class ProfessionalBadgesSection extends StatelessWidget {
  const ProfessionalBadgesSection({super.key, required this.badges});

  final List<ProfessionalBadge> badges;

  @override
  Widget build(BuildContext context) {
    final unlockedCount = badges.where((badge) => badge.isUnlocked).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.badge_outlined, color: AppColors.slate, size: 22),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                'Huy hiệu chuyên môn',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.obsidian,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '$unlockedCount/${badges.length} đã mở khóa',
              style: const TextStyle(
                color: AppColors.ember,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 11),
        for (final badge in badges) ...[
          ProfessionalBadgeCard(
            title: badge.title,
            description: badge.description,
            icon: badge.icon,
            isUnlocked: badge.isUnlocked,
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
