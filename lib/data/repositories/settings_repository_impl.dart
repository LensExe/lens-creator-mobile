import '../../domain/models/models.dart';
import '../../features/photographer/settings/settings_repository.dart';
import '../datasources/mock/mock_settings_data_source.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this.dataSource);

  final MockSettingsDataSource dataSource;

  @override
  User? cachedProfile(String userId) => dataSource.cachedProfile(userId);

  @override
  Map<String, bool>? cachedNotifications(String userId) =>
      dataSource.cachedNotifications(userId);

  @override
  bool? cachedTwoFactor(String userId) => dataSource.cachedTwoFactor(userId);

  @override
  Future<User> updateProfile(User user) => dataSource.updateProfile(user);

  @override
  Future<Map<String, bool>> updateNotification(
    String userId,
    String key,
    bool enabled,
  ) => dataSource.updateNotification(userId, key, enabled);

  @override
  Future<bool> setTwoFactor(String userId, bool enabled) =>
      dataSource.setTwoFactor(userId, enabled);

  @override
  Future<void> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) => dataSource.changePassword(
    userId: userId,
    currentPassword: currentPassword,
    newPassword: newPassword,
  );

  @override
  Future<void> signOutOtherDevices(String userId) =>
      dataSource.signOutOtherDevices(userId);
}
