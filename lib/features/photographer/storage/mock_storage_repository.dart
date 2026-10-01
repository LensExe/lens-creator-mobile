import 'storage_repository.dart';
import 'storage_tier.dart';

class MockStorageRepository implements StorageRepository {
  static const _delay = Duration(milliseconds: 300);
  static final Map<String, StorageTier> _plans = {};

  @override
  StorageTier? cachedPlan(String photographerId) => _plans[photographerId];

  @override
  Future<StorageTier> setPlan(String photographerId, StorageTier tier) async {
    await Future.delayed(_delay);
    _plans[photographerId] = tier;
    return tier;
  }
}
