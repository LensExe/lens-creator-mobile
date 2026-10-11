import '../../../features/photographer/achievements/models/photographer_achievements.dart';

class MockAchievementDataSource {
  static const _delay = Duration(milliseconds: 300);

  static const _demoCreator = PhotographerAchievements(
    photographerId: 'me',
    currentRankCode: '',
    currentRankName: '',
    averageRating: 0,
    totalFeedbacks: 0,
    totalBookings: 0,
    returnCustomers: 0,
    ranks: [],
    badges: [],
    earnedBadgeCodes: {},
  );

  Future<PhotographerAchievements> getAchievements(
    String photographerId,
  ) async {
    await Future.delayed(_delay);
    if (photographerId == 'me') return _demoCreator;
    return PhotographerAchievements(
      photographerId: photographerId,
      currentRankCode: '',
      currentRankName: '',
      averageRating: 0,
      totalFeedbacks: 0,
      totalBookings: 0,
      returnCustomers: 0,
      ranks: const [],
      badges: const [],
      earnedBadgeCodes: const {},
    );
  }
}
