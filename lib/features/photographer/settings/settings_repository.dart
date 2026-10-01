import '../../../domain/models/models.dart';

abstract interface class SettingsRepository {
  User? cachedProfile(String userId);

  Map<String, bool>? cachedNotifications(String userId);

  bool? cachedTwoFactor(String userId);

  Future<User> updateProfile(User user);

  Future<Map<String, bool>> updateNotification(
    String userId,
    String key,
    bool enabled,
  );

  Future<bool> setTwoFactor(String userId, bool enabled);

  Future<void> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  });

  Future<void> signOutOtherDevices(String userId);
}
