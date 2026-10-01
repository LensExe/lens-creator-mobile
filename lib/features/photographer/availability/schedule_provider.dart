import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'work_schedule.dart';
import '../../../providers/data_providers.dart';
import 'availability_repository.dart';
import 'mock_availability_repository.dart';

final availabilityRepositoryProvider = Provider<AvailabilityRepository>(
  (ref) => MockAvailabilityRepository(),
);

class ScheduleNotifier extends Notifier<WorkSchedule> {
  @override
  WorkSchedule build() =>
      WorkSchedule.open(demoSeed: ref.watch(authUserProvider)?.id == 'me');

  Future<void> save(WorkSchedule draft) async {
    final photographerId = ref.read(authUserProvider)?.id;
    if (photographerId == null) {
      throw StateError('Vui lòng đăng nhập lại để lưu lịch');
    }
    state = await ref
        .read(availabilityRepositoryProvider)
        .saveSchedule(photographerId, draft);
  }
}

final scheduleProvider = NotifierProvider<ScheduleNotifier, WorkSchedule>(
  ScheduleNotifier.new,
);

class AvailabilityDirtyNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setDirty(bool value) => state = value;
}

final availabilityDirtyProvider =
    NotifierProvider<AvailabilityDirtyNotifier, bool>(
      AvailabilityDirtyNotifier.new,
    );
