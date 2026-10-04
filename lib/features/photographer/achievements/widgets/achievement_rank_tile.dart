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
    required this.isLast,
    required this.sessionsCompleted,
    required this.isNextTarget,
  });

  final PhotographerRank rank;
  final RankTileState state;
  final int index;
  final bool isLast;
  final int sessionsCompleted;
  final bool isNextTarget;

  static const _icons = [
    Icons.photo_camera_outlined,
    Icons.shield_rounded,
    Icons.lock_clock_rounded,
    Icons.lock_outline_rounded,
    Icons.diamond_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final isCurrent = state == RankTileState.current;
    final isAchieved = state == RankTileState.achieved;
    final isUpcoming = state == RankTileState.upcoming;
    final remaining = (rank.minimumSessions - sessionsCompleted).clamp(
      0,
      rank.minimumSessions,
    );
    final status = isCurrent
        ? 'Hiện tại'
        : isAchieved
        ? 'Đã đạt'
        : isNextTarget
        ? 'Còn $remaining buổi'
        : 'Khóa';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? AppColors.ember
                        : isAchieved
                        ? AppColors.emberSoft
                        : AppColors.mist,
                    shape: BoxShape.circle,
                    border: isCurrent
                        ? Border.all(color: AppColors.emberSoft, width: 4)
                        : null,
                    boxShadow: isCurrent
                        ? const [
                            BoxShadow(
                              color: Color(0x1AFF5A00),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    isAchieved ? Icons.check_rounded : _icons[index],
                    color: isCurrent
                        ? AppColors.snow
                        : isAchieved
                        ? AppColors.ember
                        : AppColors.steel,
                    size: 20,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      color: isAchieved
                          ? AppColors.ember.withValues(alpha: 0.55)
                          : AppColors.fog,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : 13),
              padding: EdgeInsets.fromLTRB(10, 9, 9, isLast ? 8 : 10),
              decoration: isCurrent
                  ? BoxDecoration(
                      color: const Color(0xFFFFF7F3),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.emberSoft),
                    )
                  : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              rank.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isUpcoming
                                    ? AppColors.slate
                                    : AppColors.obsidian,
                                fontSize: 15,
                                fontWeight: isCurrent || isAchieved
                                    ? FontWeight.w800
                                    : FontWeight.w700,
                              ),
                            ),
                          ),
                          if (isCurrent) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified_rounded,
                              color: AppColors.ember,
                              size: 16,
                            ),
                          ],
                        ],
                      ),
                      _statusChip(
                        status,
                        isCurrent: isCurrent,
                        isNextTarget: isNextTarget,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 3,
                    children: [
                      _metadata('${rank.minimumSessions} buổi chụp'),
                      _metadata('Phí sàn ${rank.commissionPercent}%'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(
    String label, {
    required bool isCurrent,
    required bool isNextTarget,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: isCurrent
          ? AppColors.emberSoft
          : isNextTarget
          ? const Color(0xFFFFF0E8)
          : AppColors.mist,
      borderRadius: BorderRadius.circular(AppTokens.radiusPill),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: isCurrent || isNextTarget ? AppColors.ember : AppColors.steel,
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  Widget _metadata(String text) => Text(
    text,
    style: const TextStyle(
      color: AppColors.steel,
      fontSize: 11,
      fontWeight: FontWeight.w500,
    ),
  );
}
