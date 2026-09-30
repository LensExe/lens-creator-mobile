import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../models/photographer_rank.dart';

enum RankTileState { achieved, current, upcoming }

class AchievementRankTile extends StatelessWidget {
  const AchievementRankTile({
    super.key,
    required this.rank,
    required this.state,
    required this.index,
  });

  final PhotographerRank rank;
  final RankTileState state;
  final int index;

  static const _icons = [
    Icons.photo_camera_outlined,
    Icons.workspace_premium_outlined,
    Icons.military_tech_outlined,
    Icons.stars_outlined,
    Icons.diamond_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final isCurrent = state == RankTileState.current;
    final isAchieved = state == RankTileState.achieved;
    final isTarget = state == RankTileState.upcoming;
    final accent = isCurrent || isAchieved ? AppColors.ember : AppColors.steel;
    final stateLabel = isCurrent
        ? 'Hiện tại'
        : isAchieved
        ? 'Đã đạt'
        : isTarget
        ? 'Mục tiêu'
        : 'Chưa đạt';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.fog)),
      ),
      child: Row(
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: isCurrent || isAchieved
                  ? AppColors.ember.withValues(alpha: 0.11)
                  : AppColors.mist,
              shape: BoxShape.circle,
            ),
            child: Icon(_icons[index], color: accent, size: 19),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rank.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isCurrent ? AppColors.ember : AppColors.obsidian,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${rank.minimumSessions} buổi chụp  ·  Phí sàn ${rank.commissionPercent}%',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.steel,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 7),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: isCurrent
                  ? AppColors.ember
                  : isTarget
                  ? const Color(0xFFFFE7D9)
                  : AppColors.mist,
              borderRadius: BorderRadius.circular(AppTokens.radiusPill),
            ),
            child: Text(
              stateLabel,
              style: TextStyle(
                color: isCurrent
                    ? AppColors.snow
                    : isTarget
                    ? AppColors.ember
                    : AppColors.steel,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
