import 'work_schedule.dart';

abstract interface class AvailabilityRepository {
  Future<WorkSchedule> getSchedule(String photographerId);

  Future<WorkSchedule> saveSchedule(
    String photographerId,
    WorkSchedule schedule,
  );
}
