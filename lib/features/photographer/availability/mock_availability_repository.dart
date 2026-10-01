import 'availability_repository.dart';
import 'work_schedule.dart';

class MockAvailabilityRepository implements AvailabilityRepository {
  static const _delay = Duration(milliseconds: 300);
  static final Map<String, WorkSchedule> _savedSchedules = {};

  @override
  Future<WorkSchedule> getSchedule(String photographerId) async {
    await Future.delayed(_delay);
    return (_savedSchedules[photographerId] ??
            WorkSchedule.open(demoSeed: photographerId == 'me'))
        .copy();
  }

  @override
  Future<WorkSchedule> saveSchedule(
    String photographerId,
    WorkSchedule schedule,
  ) async {
    await Future.delayed(_delay);
    final saved = schedule.copy();
    _savedSchedules[photographerId] = saved;
    return saved.copy();
  }
}
