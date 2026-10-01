import 'package:flutter/material.dart';

import 'achievement_section_heading.dart';
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
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const AchievementSectionHeading(
        title: 'Huy hiệu chuyên môn',
        subtitle: 'Những phẩm chất tạo nên trải nghiệm tốt cho khách.',
      ),
      const SizedBox(height: 11),
      for (final badge in badges) ...[
        ProfessionalBadgeCard(
          title: badge.title,
          description: badge.description,
          icon: badge.icon,
          isUnlocked: badge.isUnlocked,
        ),
      ],
    ],
  );
}
