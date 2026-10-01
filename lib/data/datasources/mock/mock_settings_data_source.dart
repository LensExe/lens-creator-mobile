import '../../../domain/models/models.dart';

class MockSettingsDataSource {
  static const _delay = Duration(milliseconds: 300);
  static final Map<String, Map<String, bool>> _notifications = {
    'me': {
      'bookingUpdates': true,
      'messages': true,
      'promotions': true,
      'emailDigest': false,
    },
  };
  static final Map<String, bool> _twoFactor = {'me': true};
  static final Map<String, User> _profiles = {};

  Map<String, bool>? cachedNotifications(String userId) {
    final settings = _notifications[userId];
    return settings == null ? null : Map.unmodifiable(settings);
  }

  User? cachedProfile(String userId) => _profiles[userId];

  bool? cachedTwoFactor(String userId) => _twoFactor[userId];

  Future<User> updateProfile(User user) async {
    await Future.delayed(_delay);
    _profiles[user.id] = user;
    return user;
  }

  Future<Map<String, bool>> updateNotification(
    String userId,
    String key,
    bool enabled,
  ) async {
    await Future.delayed(_delay);
    final current = _notifications.putIfAbsent(
      userId,
      () => {
        'bookingUpdates': true,
        'messages': true,
        'promotions': false,
        'emailDigest': false,
      },
    );
    current[key] = enabled;
    return Map.unmodifiable(current);
  }

  Future<bool> setTwoFactor(String userId, bool enabled) async {
    await Future.delayed(_delay);
    _twoFactor[userId] = enabled;
    return enabled;
  }

  Future<void> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    await Future.delayed(_delay);
    if (currentPassword.isEmpty || newPassword.length < 8) {
      throw StateError('Mật khẩu không hợp lệ');
    }
    // The web mock validates the request shape but has no password store.
  }

  Future<void> signOutOtherDevices(String userId) async {
    await Future.delayed(_delay);
  }
}
