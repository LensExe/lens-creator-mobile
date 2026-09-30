import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../models/photographer_rank.dart';

class CurrentRankCard extends StatelessWidget {
  const CurrentRankCard({
    super.key,
    required this.rank,
    required this.sessionsCompleted,
    required this.progress,
    required this.nextRank,
    required this.sessionsToNextRank,
  });

  final PhotographerRank rank;
  final int sessionsCompleted;
  final double progress;
  final PhotographerRank? nextRank;
  final int sessionsToNextRank;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.obsidian,
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1809090B),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -48,
            top: -54,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.ember.withValues(alpha: 0.12),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.ember,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      color: AppColors.snow,
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 11),
                  const Expanded(
                    child: Text(
                      'CẤP BẬC HIỆN TẠI',
                      style: TextStyle(
                        color: AppColors.pebble,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                rank.name,
                style: const TextStyle(
                  color: AppColors.snow,
                  fontSize: 25,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '$sessionsCompleted buổi chụp hoàn thành  ·  Hoa hồng cấp bậc ${rank.commissionPercent}%',
                style: const TextStyle(
                  color: AppColors.pebble,
                  fontSize: 10,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 19),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: progress.clamp(0.0, 1.0),
                  color: AppColors.ember,
                  backgroundColor: AppColors.snow.withValues(alpha: 0.16),
                ),
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      nextRank == null
                          ? 'Đã đạt cấp bậc cao nhất'
                          : 'Còn $sessionsToNextRank buổi để lên ${nextRank!.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.snow,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (nextRank != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      '$sessionsCompleted/${nextRank!.minimumSessions}',
                      style: const TextStyle(
                        color: AppColors.pebble,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
