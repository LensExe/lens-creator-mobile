import '../../../features/photographer/achievements/models/photographer_achievements.dart';

class MockAchievementDataSource {
  static const _delay = Duration(milliseconds: 300);

  static const _demoCreator = PhotographerAchievements(
    photographerId: 'me',
    completedSessions: 27,
    fiveStarPct: 92,
    returningClients: 8,
    cancelRate: 4,
    badges: ['fast-reply', 'punctual', 'loyal'],
  );

  Future<PhotographerAchievements> getAchievements(
    String photographerId,
  ) async {
    await Future.delayed(_delay);
    if (photographerId == 'me') return _demoCreator;
    return PhotographerAchievements(
      photographerId: photographerId,
      completedSessions: 0,
      fiveStarPct: 0,
      returningClients: 0,
      cancelRate: 0,
      badges: const [],
    );
  }
}
