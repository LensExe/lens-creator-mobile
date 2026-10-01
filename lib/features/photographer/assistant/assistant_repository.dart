import 'assistant_models.dart';

abstract interface class AssistantRepository {
  AssistantConfig cachedConfig(String photographerId);

  Future<AssistantConfig> getConfig(String photographerId);

  Future<AssistantConfig> saveConfig(
    String photographerId,
    AssistantConfig config,
  );
}
