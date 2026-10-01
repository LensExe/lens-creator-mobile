import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/datasources/mock/mock_assistant_data_source.dart';
import '../../../data/repositories/assistant_repository_impl.dart';
import '../../../providers/data_providers.dart';
import 'assistant_models.dart';
import 'assistant_repository.dart';

final assistantRepositoryProvider = Provider<AssistantRepository>(
  (ref) => AssistantRepositoryImpl(MockAssistantDataSource()),
);

class AssistantNotifier extends Notifier<AssistantConfig> {
  @override
  AssistantConfig build() {
    final user = ref.watch(authUserProvider);
    if (user == null || user.role != 'photographer') {
      return const AssistantConfig(
        enabled: false,
        services: '',
        style: '',
        area: '',
        tone: '',
        faqs: [],
      );
    }
    return ref.read(assistantRepositoryProvider).cachedConfig(user.id);
  }

  Future<void> save(AssistantConfig value) async {
    final user = ref.read(authUserProvider);
    if (user == null || user.role != 'photographer') {
      throw StateError('Vui lòng đăng nhập tài khoản nhiếp ảnh gia');
    }
    state = await ref
        .read(assistantRepositoryProvider)
        .saveConfig(user.id, value);
  }
}

final assistantProvider = NotifierProvider<AssistantNotifier, AssistantConfig>(
  AssistantNotifier.new,
);
