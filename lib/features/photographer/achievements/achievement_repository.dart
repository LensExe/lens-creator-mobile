import 'models/photographer_achievements.dart';

abstract interface class AchievementRepository {
  Future<PhotographerAchievements> getAchievements(String photographerId);
}
