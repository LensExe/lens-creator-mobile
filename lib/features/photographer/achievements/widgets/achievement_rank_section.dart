import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../models/photographer_rank.dart';
import 'achievement_rank_tile.dart';

class AchievementRankSection extends StatelessWidget {
  const AchievementRankSection({
    super.key,
    required this.ranks,
    required this.currentRankIndex,
    required this.sessionsCompleted,
    required this.onDetailsTap,
  });

  final List<PhotographerRank> ranks;
  final int currentRankIndex;
  final int sessionsCompleted;
  final VoidCallback onDetailsTap;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      LayoutBuilder(
        builder: (context, constraints) {
          final heading = Row(
            children: [
              const Icon(
                Icons.timeline_rounded,
                color: AppColors.slate,
                size: 22,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Lộ trình cấp bậc LENS',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.obsidian,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.25,
                  ),
                ),
              ),
              if (constraints.maxWidth >= 365) _detailsButton(),
            ],
          );

          if (constraints.maxWidth >= 365) return heading;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heading,
              Align(alignment: Alignment.centerRight, child: _detailsButton()),
            ],
          );
        },
      ),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
        decoration: BoxDecoration(
          color: AppColors.snow,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.fog.withValues(alpha: 0.75)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0809090B),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            for (var index = 0; index < ranks.length; index++)
              AchievementRankTile(
                rank: ranks[index],
                index: index,
                isLast: index == ranks.length - 1,
                sessionsCompleted: sessionsCompleted,
                isNextTarget: index == currentRankIndex + 1,
                state: index < currentRankIndex
                    ? RankTileState.achieved
                    : index == currentRankIndex
                    ? RankTileState.current
                    : RankTileState.upcoming,
              ),
          ],
        ),
      ),
    ],
  );

  Widget _detailsButton() => TextButton.icon(
    onPressed: onDetailsTap,
    style: TextButton.styleFrom(
      foregroundColor: AppColors.ember,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      minimumSize: const Size(0, AppTokens.touchTarget - 8),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    ),
    iconAlignment: IconAlignment.end,
    icon: const Icon(Icons.chevron_right_rounded, size: 18),
    label: const Text(
      'Chi tiết quyền lợi',
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
    ),
  );
}
