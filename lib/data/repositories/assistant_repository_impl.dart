import '../../features/photographer/assistant/assistant_models.dart';
import '../../features/photographer/assistant/assistant_repository.dart';
import '../datasources/mock/mock_assistant_data_source.dart';

class AssistantRepositoryImpl implements AssistantRepository {
  const AssistantRepositoryImpl(this.dataSource);

  final MockAssistantDataSource dataSource;

  @override
  AssistantConfig cachedConfig(String photographerId) =>
      dataSource.cachedConfig(photographerId);

  @override
  Future<AssistantConfig> getConfig(String photographerId) =>
      dataSource.getConfig(photographerId);

  @override
  Future<AssistantConfig> saveConfig(
    String photographerId,
    AssistantConfig config,
  ) => dataSource.saveConfig(photographerId, config);
}
