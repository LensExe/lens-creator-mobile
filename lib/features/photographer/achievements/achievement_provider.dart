import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../../data/repositories/api_achievement_repository.dart';
import '../../../providers/data_providers.dart';
import 'achievement_repository.dart';
import 'models/photographer_achievements.dart';

final achievementRepositoryProvider = Provider<AchievementRepository>(
  (ref) => ApiAchievementRepository(ref.watch(dioProvider)),
);

final photographerAchievementsProvider =
    FutureProvider<PhotographerAchievements>((ref) {
      final user = ref.watch(authUserProvider);
      if (user == null || user.role != 'photographer') {
        throw StateError('Vui lòng đăng nhập tài khoản nhiếp ảnh gia');
      }
      return ref.read(achievementRepositoryProvider).getAchievements(user.id);
    });
