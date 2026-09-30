import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/data_providers.dart';
import '../widgets/photographer_app_bar.dart';
import 'schedule_provider.dart';
import 'widgets/availability_overview.dart';
import 'widgets/availability_save_bar.dart';
import 'widgets/day_schedule_card.dart';
import 'widgets/weekly_schedule_card.dart';
import 'work_schedule.dart';

class AvailabilityScreen extends ConsumerStatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  ConsumerState<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends ConsumerState<AvailabilityScreen> {
  WorkSchedule? draft;
  DateTime selected = DateUtils.dateOnly(
    DateTime.now().add(const Duration(days: 1)),
  );
  bool dirty = false;
  int selectedWeekday = 1;

  void _edit(void Function(WorkSchedule) change) {
    final current = draft;
    final next = current == null
        ? ref.read(scheduleProvider).copy()
        : current.copy();
    change(next);
    setState(() {
      draft = next;
      dirty = true;
    });
  }

  Future<bool> _confirmDiscard() async {
    if (!dirty) return true;
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Bỏ thay đổi lịch?'),
            content: const Text('Các khung giờ chưa lưu sẽ bị huỷ.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Tiếp tục sửa'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Bỏ thay đổi'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _pickDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final date = await showDatePicker(
      context: context,
      initialDate: selected,
      firstDate: today.add(const Duration(days: 1)),
      lastDate: today.add(const Duration(days: 35)),
      locale: const Locale('vi', 'VN'),
    );
    if (date != null) setState(() => selected = date);
  }

  void _discardDraft() {
    setState(() {
      draft = null;
      dirty = false;
    });
  }

  void _saveDraft() {
    final current = draft;
    if (current == null) return;
    ref.read(scheduleProvider.notifier).save(current);
    setState(() {
      draft = null;
      dirty = false;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Đã lưu lịch làm việc')));
  }

  String _hoursLabel(int halfHourSlots) {
    final hours = halfHourSlots / 2;
    return hours == hours.truncateToDouble()
        ? hours.toStringAsFixed(0)
        : hours.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final saved = ref.watch(scheduleProvider);
    final schedule = draft ?? saved;
    final bookings = ref.watch(myBookingsProvider);
    final key = WorkSchedule.iso(selected);
    final workingSlots = schedule.weekly[selected.weekday % 7];
    final busySlots = schedule.busy[key] ?? <String>{};
    final bookingsOnDay =
        bookings
            .where(
              (booking) => WorkSchedule.slots.any(
                (slot) => schedule.isBooked(booking, key, slot),
              ),
            )
            .toList()
          ..sort((a, b) => (a.timeSlot ?? '').compareTo(b.timeSlot ?? ''));
    final bookedSlots = <String>{
      for (final slot in WorkSchedule.slots)
        if (bookings.any((booking) => schedule.isBooked(booking, key, slot)))
          slot,
    };
    final availableCount = workingSlots
        .where(
          (slot) => !busySlots.contains(slot) && !bookedSlots.contains(slot),
        )
        .length;
    final weeklySlots = schedule.weekly.fold<int>(
      0,
      (total, day) => total + day.length,
    );
    final openDays = schedule.weekly.where((day) => day.isNotEmpty).length;
    final busySlotCount = schedule.busy.values.fold<int>(
      0,
      (total, day) => total + day.length,
    );
    final today = DateUtils.dateOnly(DateTime.now());
    final nextWeekEnd = today.add(const Duration(days: 7));
    final upcomingBookings = bookings.where((booking) {
      final date = DateTime.tryParse(booking.date);
      if (date == null) return false;
      final day = DateUtils.dateOnly(date);
      if (day.isBefore(today) || !day.isBefore(nextWeekEnd)) return false;
      return WorkSchedule.slots.any(
        (slot) => schedule.isBooked(booking, WorkSchedule.iso(day), slot),
      );
    }).length;

    return PopScope(
      canPop: !dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && await _confirmDiscard() && context.mounted) {
          _discardDraft();
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.mist,
        appBar: PhotographerAppBar(
          actions: [
            IconButton(
              tooltip: 'Chọn ngày',
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_month_outlined),
            ),
          ],
        ),
        bottomNavigationBar: dirty
            ? AvailabilitySaveBar(onDiscard: _discardDraft, onSave: _saveDraft)
            : null,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 17, 16, 26),
              children: [
                const Text(
                  'Lịch làm việc',
                  style: TextStyle(
                    color: AppColors.obsidian,
                    fontSize: 25,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Sắp xếp thời gian nhận lịch và những lúc bạn bận.',
                  style: TextStyle(
                    color: AppColors.steel,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 17),
                AvailabilityOverview(
                  weeklyHours: _hoursLabel(weeklySlots),
                  upcomingBookings: upcomingBookings,
                  busySlots: busySlotCount,
                  openDays: openDays,
                ),
                const SizedBox(height: 20),
                WeeklyScheduleCard(
                  schedule: schedule,
                  selectedWeekday: selectedWeekday,
                  onWeekdaySelected: (weekday) =>
                      setState(() => selectedWeekday = weekday),
                  onPresetSelected: (days) => _edit((next) {
                    for (var day = 0; day < 7; day++) {
                      next.weekly[day] = days.contains(day)
                          ? {...WorkSchedule.slots}
                          : <String>{};
                    }
                  }),
                  onDayAvailabilityChanged: (weekday, enabled) => _edit(
                    (next) => next.weekly[weekday] = enabled
                        ? {...WorkSchedule.slots}
                        : <String>{},
                  ),
                  onSlotToggle: (weekday, slot) => _edit((next) {
                    final cells = next.weekly[weekday];
                    if (!cells.add(slot)) cells.remove(slot);
                  }),
                ),
                const SizedBox(height: 13),
                DayScheduleCard(
                  date: selected,
                  bookings: bookingsOnDay,
                  workingSlots: workingSlots,
                  busySlots: busySlots,
                  bookedSlots: bookedSlots,
                  availableCount: availableCount,
                  busyAllDay:
                      workingSlots.isNotEmpty &&
                      busySlots.containsAll(workingSlots),
                  onPickDate: _pickDate,
                  onBusyAllDayChanged: (value) => _edit((next) {
                    if (value) {
                      next.busy[key] = {...workingSlots};
                    } else {
                      next.busy.remove(key);
                    }
                  }),
                  onBusySlotTap: (slot) => _edit((next) {
                    final cells = next.busy.putIfAbsent(key, () => <String>{});
                    if (!cells.add(slot)) cells.remove(slot);
                    if (cells.isEmpty) next.busy.remove(key);
                  }),
                ),
                if (dirty) ...[
                  const SizedBox(height: 12),
                  const _UnsavedNotice(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UnsavedNotice extends StatelessWidget {
  const _UnsavedNotice();

  @override
  Widget build(BuildContext context) => const Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.edit_note_rounded, size: 15, color: AppColors.ember),
      SizedBox(width: 5),
      Text(
        'Bạn có thay đổi chưa lưu',
        style: TextStyle(
          color: AppColors.steel,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}
