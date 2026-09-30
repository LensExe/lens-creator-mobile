import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/data_providers.dart';
import '../../../domain/models/models.dart';
import 'models/photographer_rank.dart';
import 'widgets/achievement_rank_section.dart';
import 'widgets/current_rank_card.dart';
import 'widgets/professional_badges_section.dart';

const _professionalBadges = [
  ProfessionalBadge(
    title: 'Phản hồi nhanh',
    description: 'Trả lời khách dưới 5 phút',
    icon: Icons.bolt_rounded,
  ),
  ProfessionalBadge(
    title: 'Đúng giờ tuyệt đối',
    description: 'Luôn có mặt đúng giờ hẹn',
    icon: Icons.schedule_rounded,
  ),
  ProfessionalBadge(
    title: 'Khách quay lại',
    description: 'Nhiều khách hàng đặt lại lần nữa',
    icon: Icons.repeat_rounded,
  ),
];

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(myBookingsProvider);
    // The portal seed for the demo creator includes historical sessions that
    // are not listed in the current bookings feed.
    final historical = ref.watch(authUserProvider)?.id == 'me' ? 27 : 0;
    final sessions =
        historical +
        bookings.where((b) => b.status == BookingStatus.released).length;

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
    final sessionsToNextRank = nextRank == null
        ? 0
        : nextRank.minimumSessions - sessions;

    return Scaffold(
      backgroundColor: AppColors.mist,
      appBar: AppBar(
        title: const Text('Thành tựu'),
        backgroundColor: AppColors.mist,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 5, 16, 28),
            children: [
              CurrentRankCard(
                rank: currentRank,
                sessionsCompleted: sessions,
                progress: progress,
                nextRank: nextRank,
                sessionsToNextRank: sessionsToNextRank,
              ),
              const SizedBox(height: 25),
              AchievementRankSection(
                ranks: photographerRanks,
                currentRankIndex: currentRankIndex,
              ),
              const SizedBox(height: 25),
              const ProfessionalBadgesSection(badges: _professionalBadges),
            ],
          ),
        ),
      ),
    );
  }
}
