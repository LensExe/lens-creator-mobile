import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/datasources/mock/mock_achievement_data_source.dart';
import '../../../data/repositories/achievement_repository_impl.dart';
import '../../../providers/data_providers.dart';
import 'achievement_repository.dart';
import 'models/photographer_achievements.dart';

final achievementRepositoryProvider = Provider<AchievementRepository>(
  (ref) => AchievementRepositoryImpl(MockAchievementDataSource()),
);

final photographerAchievementsProvider =
    FutureProvider<PhotographerAchievements>((ref) {
      final user = ref.watch(authUserProvider);
      if (user == null || user.role != 'photographer') {
        throw StateError('Vui lòng đăng nhập tài khoản nhiếp ảnh gia');
      }
      return ref.read(achievementRepositoryProvider).getAchievements(user.id);
    });
