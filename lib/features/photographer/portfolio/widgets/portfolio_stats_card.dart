import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../domain/models/models.dart';

class PortfolioStatsCard extends StatelessWidget {
  const PortfolioStatsCard({super.key, required this.profile});

  final Photographer profile;

  @override
  Widget build(BuildContext context) {
    final items = [
      _ProfileStat(
        'Tác phẩm',
        '${profile.portfolio.length}',
        Icons.photo_library_outlined,
      ),
      _ProfileStat(
        'Đánh giá',
        profile.rating.toStringAsFixed(1),
        Icons.star_rounded,
      ),
      _ProfileStat(
        'Nhận xét',
        '${profile.reviewCount}',
        Icons.rate_review_outlined,
      ),
      _ProfileStat(
        'Kinh nghiệm',
        '${profile.experienceYears} năm',
        Icons.work_history_outlined,
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.fog),
        boxShadow: const [
          BoxShadow(
            color: Color(0x07000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            if (index > 0)
              const SizedBox(
                height: 42,
                child: VerticalDivider(width: 1, color: AppColors.fog),
              ),
            Expanded(child: _StatCell(stat: items[index])),
          ],
        ],
      ),
    );
  }
}

class _ProfileStat {
  const _ProfileStat(this.label, this.value, this.icon);

  final String label;
  final String value;
  final IconData icon;
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.stat});

  final _ProfileStat stat;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 3),
    child: Column(
      children: [
        Icon(
          stat.icon,
          size: 16,
          color: stat.icon == Icons.star_rounded
              ? AppColors.ember
              : AppColors.steel,
        ),
        const SizedBox(height: 5),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            stat.value,
            maxLines: 1,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          stat.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.steel, fontSize: 9),
        ),
      ],
    ),
  );
}
