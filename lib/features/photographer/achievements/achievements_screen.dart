import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/creator_empty_state.dart';
import '../../../core/widgets/creator_loading_state.dart';
import 'achievement_provider.dart';
import 'models/photographer_achievements.dart';
import 'models/photographer_rank.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(photographerAchievementsProvider);
    return Scaffold(
      backgroundColor: AppColors.mist,
      appBar: AppBar(title: const Text('Thành tựu & cấp bậc')),
      body: state.when(
        loading: () => const CreatorLoadingState(label: 'Đang tải thành tựu…'),
        error: (error, _) => CreatorEmptyState(
          icon: Icons.cloud_off_outlined,
          title: 'Không thể tải thành tựu',
          actionLabel: 'Thử lại',
          onAction: () => ref.invalidate(photographerAchievementsProvider),
        ),
        data: (value) => _content(value),
      ),
    );
  }

  Widget _content(PhotographerAchievements value) {
    final currentRank = value.ranks
        .where((rank) => rank.code == value.currentRankCode)
        .firstOrNull;
    final activeBadges = value.badges
        .where(
          (badge) =>
              badge.isActive || value.earnedBadgeCodes.contains(badge.code),
        )
        .toList();
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppTokens.contentMaxWidth),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
          children: [
            const Text(
              'Thông tin cấp bậc và huy hiệu lấy trực tiếp từ hồ sơ và danh mục Backend.',
              style: TextStyle(color: AppColors.steel, height: 1.45),
            ),
            const SizedBox(height: 14),
            Card(
              color: AppColors.snow,
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFFEEE5),
                  child: Icon(
                    Icons.workspace_premium_outlined,
                    color: AppColors.ember,
                  ),
                ),
                title: Text(
                  value.currentRankName.isEmpty
                      ? 'Chưa có cấp bậc'
                      : value.currentRankName,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  currentRank == null
                      ? 'Backend chưa trả về cấp bậc hiện tại.'
                      : 'Commission ${currentRank.commissionPercent}% · ngưỡng ${currentRank.minimumSessions} booking hoàn tất',
                ),
              ),
            ),
            const SizedBox(height: 12),
            _StatsCard(value: value),
            const SizedBox(height: 22),
            const _SectionTitle(title: 'Cấp bậc từ Backend'),
            const SizedBox(height: 8),
            if (value.ranks.isEmpty)
              const _EmptyText('Backend chưa có danh mục cấp bậc.')
            else
              for (final rank in value.ranks)
                _RankTile(
                  rank: rank,
                  current: rank.code == value.currentRankCode,
                ),
            const SizedBox(height: 22),
            _SectionTitle(
              title:
                  'Huy hiệu từ Backend (${value.earnedBadgeCodes.length} đã nhận)',
            ),
            const SizedBox(height: 8),
            if (activeBadges.isEmpty)
              const _EmptyText('Backend chưa có huy hiệu khả dụng.')
            else
              for (final badge in activeBadges)
                _BadgeTile(
                  badge: badge,
                  earned: value.earnedBadgeCodes.contains(badge.code),
                ),
          ],
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.value});
  final PhotographerAchievements value;

  @override
  Widget build(BuildContext context) => Card(
    color: AppColors.snow,
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Wrap(
        spacing: 20,
        runSpacing: 14,
        children: [
          _Stat(label: 'Tổng booking', value: '${value.totalBookings}'),
          _Stat(
            label: 'Điểm trung bình',
            value: value.averageRating.toStringAsFixed(1),
          ),
          _Stat(label: 'Lượt đánh giá', value: '${value.totalFeedbacks}'),
          _Stat(label: 'Khách quay lại', value: '${value.returnCustomers}'),
        ],
      ),
    ),
  );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 130,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        Text(
          label,
          style: const TextStyle(color: AppColors.steel, fontSize: 11),
        ),
      ],
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
  );
}

class _RankTile extends StatelessWidget {
  const _RankTile({required this.rank, required this.current});
  final PhotographerRank rank;
  final bool current;

  @override
  Widget build(BuildContext context) => Card(
    color: current ? const Color(0xFFFFEEE5) : AppColors.snow,
    child: ListTile(
      leading: Icon(
        current ? Icons.check_circle : Icons.workspace_premium_outlined,
        color: current ? AppColors.ember : AppColors.steel,
      ),
      title: Text(
        rank.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        'Từ ${rank.minimumSessions} booking hoàn tất · commission ${rank.commissionPercent}%',
      ),
      trailing: current ? const Text('Hiện tại') : null,
    ),
  );
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge, required this.earned});
  final PhotographerBadge badge;
  final bool earned;

  @override
  Widget build(BuildContext context) => Card(
    color: AppColors.snow,
    child: ListTile(
      leading: Icon(
        earned ? Icons.verified_outlined : Icons.workspace_premium_outlined,
        color: earned ? AppColors.ember : AppColors.steel,
      ),
      title: Text(
        badge.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${badge.description}\nĐiều kiện: ${_metricLabel(badge.metric)} ≥ ${badge.minimumValue} · tối thiểu ${badge.minimumReviews} review',
      ),
      isThreeLine: true,
      trailing: Text(earned ? 'Đã nhận' : 'Chưa nhận'),
    ),
  );
}

String _metricLabel(String metric) => switch (metric) {
  'average_rating' => 'điểm trung bình',
  'average_punctuality' => 'điểm đúng giờ',
  'return_customers' => 'khách quay lại',
  _ => metric,
};

class _EmptyText extends StatelessWidget {
  const _EmptyText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Text(text, style: const TextStyle(color: AppColors.steel)),
  );
}
