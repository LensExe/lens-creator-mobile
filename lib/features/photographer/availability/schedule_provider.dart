import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'work_schedule.dart';
import '../../../providers/data_providers.dart';

class ScheduleNotifier extends Notifier<WorkSchedule> {
  @override
  WorkSchedule build() => WorkSchedule.open(
      demoSeed: ref.watch(authUserProvider)?.id == 'me');

  void save(WorkSchedule draft) => state = draft.copy();
}

final scheduleProvider = NotifierProvider<ScheduleNotifier, WorkSchedule>(
  ScheduleNotifier.new,
);
