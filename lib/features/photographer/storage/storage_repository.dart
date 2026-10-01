import 'storage_tier.dart';

abstract interface class StorageRepository {
  StorageTier? cachedPlan(String photographerId);

  Future<StorageTier> setPlan(String photographerId, StorageTier tier);
}
