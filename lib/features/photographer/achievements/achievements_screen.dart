import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/creator_empty_state.dart';
import '../../../core/widgets/creator_page_header.dart';
import '../../../core/widgets/creator_section_header.dart';
import 'achievement_provider.dart';
import 'models/photographer_achievements.dart';
import 'models/photographer_rank.dart';
import 'widgets/achievement_rank_section.dart';
import 'widgets/achievement_stats_section.dart';
import 'widgets/current_rank_card.dart';
import 'widgets/professional_badges_section.dart';

const _badgeDefinitions = [
  (
    id: 'yearbook',
    title: 'Chuyên gia kỷ yếu',
    description: 'Nhiều buổi chụp kỷ yếu được đánh giá cao',
    icon: Icons.auto_stories_outlined,
  ),
  (
    id: 'wedding',
    title: 'Chuyên gia ảnh cưới',
    description: 'Kinh nghiệm ảnh cưới dày dạn',
    icon: Icons.favorite_border_rounded,
  ),
  (
    id: 'fast-reply',
    title: 'Phản hồi nhanh',
    description: 'Trả lời khách dưới 5 phút',
    icon: Icons.bolt_rounded,
  ),
  (
    id: 'punctual',
    title: 'Đúng giờ tuyệt đối',
    description: 'Luôn có mặt đúng giờ hẹn',
    icon: Icons.schedule_rounded,
  ),
  (
    id: 'top-rated',
    title: 'Đánh giá xuất sắc',
    description: 'Tỷ lệ đánh giá 5 sao rất cao',
    icon: Icons.star_outline_rounded,
  ),
  (
    id: 'loyal',
    title: 'Khách quay lại',
    description: 'Nhiều khách hàng đặt lại lần nữa',
    icon: Icons.repeat_rounded,
  ),
];

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  void _showRankInfo(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cấp bậc & phí sàn'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final rank in photographerRanks)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Text(
                  '${rank.name} · từ ${rank.minimumSessions} buổi · phí sàn ${rank.commissionPercent}%',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementState = ref.watch(photographerAchievementsProvider);
    return Scaffold(
      backgroundColor: AppColors.snow,
      appBar: AppBar(
        title: const Text('Thành tựu'),
        actions: [
          IconButton(
            tooltip: 'Giải thích cấp bậc',
            onPressed: () => _showRankInfo(context),
            icon: const Icon(Icons.info_outline_rounded),
          ),
        ],
      ),
      body: achievementState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => CreatorEmptyState(
          icon: Icons.cloud_off_outlined,
          title: 'Không thể tải thành tựu',
          actionLabel: 'Thử lại',
          onAction: () => ref.invalidate(photographerAchievementsProvider),
        ),
        data: (achievements) => _content(context, achievements),
      ),
    );
  }

  Widget _content(BuildContext context, PhotographerAchievements achievements) {
    final sessions = achievements.completedSessions;
    var currentRankIndex = 0;
    for (var index = 0; index < photographerRanks.length; index++) {
      if (sessions >= photographerRanks[index].minimumSessions) {
        currentRankIndex = index;
      }
    }
    final currentRank = photographerRanks[currentRankIndex];
    final nextRank = currentRankIndex + 1 < photographerRanks.length
        ? photographerRanks[currentRankIndex + 1]
        : null;
    final progress = nextRank == null
        ? 1.0
        : (sessions - currentRank.minimumSessions) /
              (nextRank.minimumSessions - currentRank.minimumSessions);
    final badges = [
      for (final badge in _badgeDefinitions)
        ProfessionalBadge(
          id: badge.id,
          title: badge.title,
          description: badge.description,
          icon: badge.icon,
          isUnlocked: achievements.badges.contains(badge.id),
        ),
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppTokens.contentMaxWidth),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
          children: [
            const CreatorPageHeader(
              title: 'Hành trình sáng tạo',
              subtitle: 'Cấp bậc và huy hiệu nghề nghiệp của bạn.',
            ),
            const SizedBox(height: 20),
            CurrentRankCard(
              rank: currentRank,
              sessionsCompleted: sessions,
              progress: progress,
              nextRank: nextRank,
              sessionsToNextRank: nextRank == null
                  ? 0
                  : nextRank.minimumSessions - sessions,
            ),
            const SizedBox(height: 23),
            AchievementRankSection(
              ranks: photographerRanks,
              currentRankIndex: currentRankIndex,
            ),
            const SizedBox(height: 23),
            const CreatorSectionHeader(title: 'Chỉ số vận hành'),
            const SizedBox(height: 5),
            AchievementStatsSection(
              completedSessions: achievements.completedSessions,
              fiveStarPct: achievements.fiveStarPct,
              returningClients: achievements.returningClients,
              cancelRate: achievements.cancelRate,
            ),
            const SizedBox(height: 23),
            ProfessionalBadgesSection(badges: badges),
            const SizedBox(height: 22),
            OutlinedButton.icon(
              onPressed: () => context.push('/photographer_home/portfolio'),
              icon: const Icon(Icons.person_outline_rounded),
              label: const Text('Cập nhật hồ sơ năng lực'),
            ),
          ],
        ),
      ),
    );
  }
}
