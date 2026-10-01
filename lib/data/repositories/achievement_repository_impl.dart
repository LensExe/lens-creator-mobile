import '../../features/photographer/achievements/achievement_repository.dart';
import '../../features/photographer/achievements/models/photographer_achievements.dart';
import '../datasources/mock/mock_achievement_data_source.dart';

class AchievementRepositoryImpl implements AchievementRepository {
  const AchievementRepositoryImpl(this.dataSource);

  final MockAchievementDataSource dataSource;

  @override
  Future<PhotographerAchievements> getAchievements(String photographerId) =>
      dataSource.getAchievements(photographerId);
}
