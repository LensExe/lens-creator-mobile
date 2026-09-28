import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lens_creator_mobile/core/theme/app_colors.dart';
import 'package:lens_creator_mobile/core/widgets/surface_card.dart';
import 'package:lens_creator_mobile/core/widgets/lens_badge.dart';

class PackageCardItem extends StatelessWidget {
  final String id;
  final String title;
  final String price;
  final String description;
  final String status;
  final bool isActive;

  const PackageCardItem({
    super.key,
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.status,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/photographer_home/packages/edit/$id');
      },
      child: SurfaceCard(
        isMuted: !isActive,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isActive ? AppColors.obsidian : AppColors.steel,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                LensBadge(
                  text: status,
                  type: isActive ? BadgeType.ember : BadgeType.darkFilled,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              price,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isActive ? AppColors.ember : AppColors.steel,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: isActive ? AppColors.slate : AppColors.ash,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
