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
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.snow,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.fog.withValues(alpha: 0.8)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0A09090B),
          blurRadius: 18,
          offset: Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 12,
          spacing: 12,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: const BoxDecoration(
                    color: AppColors.emberSoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shield_rounded,
                    color: AppColors.ember,
                    size: 31,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CẤP BẬC HIỆN TẠI',
                        style: TextStyle(
                          color: AppColors.ember,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        rank.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.obsidian,
                          fontSize: 20,
                          height: 1.2,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.emberSoft,
                borderRadius: BorderRadius.circular(AppTokens.radiusPill),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, size: 7, color: AppColors.ember),
                  SizedBox(width: 6),
                  Text(
                    'Đang kích hoạt',
                    style: TextStyle(
                      color: AppColors.ember,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Text(
                nextRank == null
                    ? 'Bạn đã đạt cấp bậc cao nhất'
                    : 'Tiến độ thăng hạng ${nextRank!.name}',
                style: const TextStyle(
                  color: AppColors.slate,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (nextRank != null)
              Text(
                '$sessionsCompleted / ${nextRank!.minimumSessions} buổi',
                style: const TextStyle(
                  color: AppColors.ember,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
          ],
        ),
        const SizedBox(height: 9),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppTokens.radiusPill),
          child: LinearProgressIndicator(
            minHeight: 9,
            value: progress.clamp(0.0, 1.0),
            color: AppColors.ember,
            backgroundColor: AppColors.fog,
          ),
        ),
        const SizedBox(height: 13),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7F3),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (nextRank == null)
                const Text(
                  'Bạn đang ở cấp bậc cao nhất của lộ trình.',
                  style: TextStyle(
                    color: AppColors.graphite,
                    fontSize: 12,
                    height: 1.35,
                  ),
                )
              else ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.stars_rounded,
                      color: AppColors.ember,
                      size: 19,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text.rich(
                        TextSpan(
                          style: const TextStyle(
                            color: AppColors.graphite,
                            fontSize: 12,
                            height: 1.35,
                          ),
                          children: [
                            const TextSpan(text: 'Còn '),
                            TextSpan(
                              text: '$sessionsToNextRank buổi',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const TextSpan(text: ' để đạt '),
                            TextSpan(
                              text: nextRank!.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.snow,
                    borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                    border: Border.all(color: AppColors.emberSoft),
                  ),
                  child: Text(
                    'Phí ${rank.commissionPercent}% → ${nextRank!.commissionPercent}%',
                    style: const TextStyle(
                      color: AppColors.ember,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}
