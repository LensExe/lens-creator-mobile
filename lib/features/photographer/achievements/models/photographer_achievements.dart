class PhotographerAchievements {
  const PhotographerAchievements({
    required this.photographerId,
    required this.completedSessions,
    required this.fiveStarPct,
    required this.returningClients,
    required this.cancelRate,
    required this.badges,
  });

  final String photographerId;
  final int completedSessions;
  final int fiveStarPct;
  final int returningClients;
  final int cancelRate;
  final List<String> badges;
}
