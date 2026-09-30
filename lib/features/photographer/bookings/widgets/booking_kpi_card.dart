import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';

class BookingKpiCard extends StatelessWidget {
  const BookingKpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.caption,
    required this.icon,
    required this.accent,
    required this.tint,
  });

  final String label;
  final int value;
  final String caption;
  final IconData icon;
  final Color accent;
  final Color tint;

  @override
  Widget build(BuildContext context) => Container(
    height: 92,
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: AppColors.snow,
      borderRadius: BorderRadius.circular(AppTokens.radiusCard),
      border: Border.all(color: AppColors.fog),
      boxShadow: const [
        BoxShadow(
          color: Color(0x07000000),
          blurRadius: 10,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.steel,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                color: tint,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: accent, size: 15),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '$value',
              style: TextStyle(
                color: accent == AppColors.steel ? AppColors.ink : accent,
                fontSize: 23,
                height: 1,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.7,
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: accent == AppColors.steel ? AppColors.ash : accent,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
