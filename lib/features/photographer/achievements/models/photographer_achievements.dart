import 'photographer_rank.dart';

class PhotographerAchievements {
  const PhotographerAchievements({
    required this.photographerId,
    required this.currentRankCode,
    required this.currentRankName,
    required this.averageRating,
    required this.totalFeedbacks,
    required this.totalBookings,
    required this.returnCustomers,
    required this.ranks,
    required this.badges,
    required this.earnedBadgeCodes,
  });

  final String photographerId;
  final String currentRankCode;
  final String currentRankName;
  final double averageRating;
  final int totalFeedbacks;
  final int totalBookings;
  final int returnCustomers;
  final List<PhotographerRank> ranks;
  final List<PhotographerBadge> badges;
  final Set<String> earnedBadgeCodes;
}
