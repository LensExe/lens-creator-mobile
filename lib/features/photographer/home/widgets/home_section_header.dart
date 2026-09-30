import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class HomeSectionHeader extends StatelessWidget {
  const HomeSectionHeader({
    super.key,
    required this.title,
    required this.onSeeAll,
    this.count,
  });

  final String title;
  final VoidCallback onSeeAll;
  final int? count;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Row(
          children: [
            Flexible(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.ember.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: AppColors.ember,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      TextButton.icon(
        onPressed: onSeeAll,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.steel,
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.only(left: 8),
        ),
        iconAlignment: IconAlignment.end,
        icon: const Icon(Icons.chevron_right_rounded, size: 18),
        label: const Text('Tất cả', style: TextStyle(fontSize: 12)),
      ),
    ],
  );
}
