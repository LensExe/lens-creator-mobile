import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../domain/models/models.dart';

class PortfolioStatsCard extends StatelessWidget {
  const PortfolioStatsCard({super.key, required this.profile});

  final Photographer profile;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
    decoration: BoxDecoration(
      color: AppColors.snow,
      borderRadius: BorderRadius.circular(AppTokens.radiusCard),
      border: Border.all(color: AppColors.fog),
    ),
    child: Row(
      children: [
        Expanded(
          child: _Stat(
            label: 'Tác phẩm',
            value: '${profile.portfolio.length}',
            icon: Icons.photo_library_outlined,
          ),
        ),
        const _StatDivider(),
        Expanded(
          child: _Stat(
            label: 'Đánh giá',
            value: profile.rating.toStringAsFixed(1),
            icon: Icons.star_rounded,
            iconColor: const Color(0xFFD58B00),
          ),
        ),
        const _StatDivider(),
        Expanded(
          child: _Stat(
            label: 'Nhận xét',
            value: '${profile.reviewCount}',
            icon: Icons.forum_outlined,
          ),
        ),
        const _StatDivider(),
        Expanded(
          child: _Stat(
            label: 'Kinh nghiệm',
            value: '${profile.experienceYears} năm',
            icon: Icons.workspace_premium_outlined,
          ),
        ),
      ],
    ),
  );
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor = AppColors.ember,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: iconColor, size: 15),
      const SizedBox(height: 4),
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          value,
          style: const TextStyle(
            color: AppColors.obsidian,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      const SizedBox(height: 3),
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.steel,
            fontSize: 8,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ],
  );
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 40,
    color: AppColors.fog,
    margin: const EdgeInsets.symmetric(horizontal: 3),
  );
}
