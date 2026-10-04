import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/creator_empty_state.dart';
import '../../../core/widgets/creator_loading_state.dart';
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

  void _showRankInfo(BuildContext context, int currentRankIndex) {
    if (MediaQuery.sizeOf(context).width >= 600) {
      showDialog<void>(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 680),
            child: _RankInfoPanel(
              currentRankIndex: currentRankIndex,
              onClose: () => Navigator.pop(context),
            ),
          ),
        ),
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _RankInfoPanel(
        currentRankIndex: currentRankIndex,
        onClose: () => Navigator.pop(context),
        isBottomSheet: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementState = ref.watch(photographerAchievementsProvider);
    return Scaffold(
      backgroundColor: AppColors.mist,
      appBar: AppBar(
        title: const Text('Thành Tựu & Cấp Bậc'),
        actions: [
          Tooltip(
            message: 'Giải thích cấp bậc & phí sàn',
            child: TextButton.icon(
              onPressed: () => _showRankInfo(
                context,
                achievementState.hasValue
                    ? _rankIndexForSessions(
                        achievementState.requireValue.completedSessions,
                      )
                    : 0,
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.slate,
                padding: const EdgeInsets.symmetric(horizontal: 7),
                minimumSize: const Size(0, AppTokens.touchTarget),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: const Icon(Icons.help_outline_rounded, size: 20),
              label: const Text(
                'Giải thích',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: achievementState.when(
        loading: () => const CreatorLoadingState(label: 'Đang tải thành tựu…'),
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
    final currentRankIndex = _rankIndexForSessions(sessions);
    final currentRank = photographerRanks[currentRankIndex];
    final nextRank = currentRankIndex + 1 < photographerRanks.length
        ? photographerRanks[currentRankIndex + 1]
        : null;
    // The reference communicates completed sessions against the next tier's
    // threshold, so this is a display ratio. Rank selection remains unchanged.
    final progress = nextRank == null
        ? 1.0
        : (sessions / nextRank.minimumSessions).clamp(0.0, 1.0).toDouble();
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
          padding: const EdgeInsets.fromLTRB(16, 17, 16, 30),
          children: [
            const _AchievementIntro(),
            const SizedBox(height: 19),
            CurrentRankCard(
              rank: currentRank,
              sessionsCompleted: sessions,
              progress: progress,
              nextRank: nextRank,
              sessionsToNextRank: nextRank == null
                  ? 0
                  : nextRank.minimumSessions - sessions,
            ),
            const SizedBox(height: 24),
            AchievementRankSection(
              ranks: photographerRanks,
              currentRankIndex: currentRankIndex,
              sessionsCompleted: sessions,
              onDetailsTap: () => _showRankInfo(context, currentRankIndex),
            ),
            const SizedBox(height: 24),
            AchievementStatsSection(
              completedSessions: achievements.completedSessions,
              fiveStarPct: achievements.fiveStarPct,
              returningClients: achievements.returningClients,
              cancelRate: achievements.cancelRate,
            ),
            const SizedBox(height: 24),
            ProfessionalBadgesSection(badges: badges),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: () => context.push('/photographer_home/portfolio'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                foregroundColor: AppColors.obsidian,
                backgroundColor: AppColors.snow,
                side: const BorderSide(color: AppColors.fog),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(
                Icons.edit_note_rounded,
                color: AppColors.ember,
                size: 21,
              ),
              label: const Text(
                'Cập nhật hồ sơ năng lực',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _rankIndexForSessions(int sessions) {
    var currentRankIndex = 0;
    for (var index = 0; index < photographerRanks.length; index++) {
      if (sessions >= photographerRanks[index].minimumSessions) {
        currentRankIndex = index;
      }
    }
    return currentRankIndex;
  }
}

class _AchievementIntro extends StatelessWidget {
  const _AchievementIntro();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'LENS CREATOR JOURNEY',
        style: TextStyle(
          color: AppColors.ember,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.05,
        ),
      ),
      const SizedBox(height: 5),
      Text(
        'Hành trình sáng tạo',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: AppColors.obsidian,
          fontSize: 25,
          height: 1.15,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.6,
        ),
      ),
      const SizedBox(height: 5),
      const Text(
        'Cấp bậc và huy hiệu nghề nghiệp của bạn.',
        style: TextStyle(color: AppColors.steel, fontSize: 13, height: 1.45),
      ),
    ],
  );
}

class _RankInfoPanel extends StatelessWidget {
  const _RankInfoPanel({
    required this.currentRankIndex,
    required this.onClose,
    this.isBottomSheet = false,
  });

  final int currentRankIndex;
  final VoidCallback onClose;
  final bool isBottomSheet;

  @override
  Widget build(BuildContext context) {
    final panel = Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: isBottomSheet
            ? const BorderRadius.vertical(top: Radius.circular(26))
            : BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A09090B),
            blurRadius: 25,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.ember,
                  size: 23,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Giải thích cấp bậc & phí sàn',
                    style: TextStyle(
                      color: AppColors.obsidian,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  tooltip: 'Đóng',
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.mist,
                    foregroundColor: AppColors.slate,
                  ),
                  icon: const Icon(Icons.close_rounded, size: 19),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Mức phí sàn giảm theo các mốc số buổi chụp đã hoàn thành.',
              style: TextStyle(
                color: AppColors.slate,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.mist,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  for (var index = 0; index < photographerRanks.length; index++)
                    _RankFeeRow(
                      rank: photographerRanks[index],
                      isCurrent: index == currentRankIndex,
                      isLast: index == photographerRanks.length - 1,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: FilledButton(
                onPressed: onClose,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.ember,
                  foregroundColor: AppColors.snow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                  ),
                ),
                child: const Text(
                  'Đã hiểu',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (!isBottomSheet) return panel;
    final screenHeight = MediaQuery.sizeOf(context).height;
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: screenHeight * 0.9),
        child: panel,
      ),
    );
  }
}

class _RankFeeRow extends StatelessWidget {
  const _RankFeeRow({
    required this.rank,
    required this.isCurrent,
    required this.isLast,
  });

  final PhotographerRank rank;
  final bool isCurrent;
  final bool isLast;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(
      border: isLast
          ? null
          : const Border(bottom: BorderSide(color: AppColors.fog)),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            '${rank.name} (${rank.minimumSessions} buổi)',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isCurrent ? AppColors.ember : AppColors.obsidian,
              fontSize: 11,
              fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '${rank.commissionPercent}% phí sàn',
          style: TextStyle(
            color: isCurrent ? AppColors.ember : AppColors.graphite,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}
