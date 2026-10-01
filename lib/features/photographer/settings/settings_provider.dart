import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/datasources/mock/mock_settings_data_source.dart';
import '../../../data/repositories/settings_repository_impl.dart';
import '../../../providers/data_providers.dart';
import 'settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepositoryImpl(MockSettingsDataSource()),
);

class NotificationSettingsNotifier extends Notifier<Map<String, bool>> {
  @override
  Map<String, bool> build() {
    final userId = ref.watch(authUserProvider.select((user) => user?.id));
    if (userId == null) return const {};
    return ref.read(settingsRepositoryProvider).cachedNotifications(userId) ??
        const {
          'bookingUpdates': true,
          'messages': true,
          'promotions': false,
          'emailDigest': false,
        };
  }

  Future<void> set(String key, bool value) async {
    final userId = ref.read(authUserProvider)?.id;
    if (userId == null) throw StateError('Vui lòng đăng nhập lại');
    final previous = state;
    state = {...state, key: value};
    try {
      state = await ref
          .read(settingsRepositoryProvider)
          .updateNotification(userId, key, value);
    } catch (_) {
      state = previous;
      rethrow;
    }
  }
}

final notificationSettingsProvider =
    NotifierProvider<NotificationSettingsNotifier, Map<String, bool>>(
      NotificationSettingsNotifier.new,
    );
