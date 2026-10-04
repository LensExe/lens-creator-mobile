import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../providers/data_providers.dart';
import '../widgets/photographer_app_bar.dart';
import 'schedule_provider.dart';
import 'widgets/availability_overview.dart';
import 'widgets/availability_save_bar.dart';
import 'widgets/calendar_view.dart';
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
  bool saving = false;
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
    ref.read(availabilityDirtyProvider.notifier).setDirty(true);
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
    ref.read(availabilityDirtyProvider.notifier).setDirty(false);
  }

  Future<void> _saveDraft() async {
    final current = draft;
    if (current == null || saving) return;
    setState(() => saving = true);
    try {
      await ref.read(scheduleProvider.notifier).save(current);
      if (!mounted) return;
      setState(() {
        draft = null;
        dirty = false;
      });
      ref.read(availabilityDirtyProvider.notifier).setDirty(false);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Đã lưu lịch làm việc')));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể lưu lịch làm việc: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
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
    final firstSelectable = DateUtils.dateOnly(
      DateTime.now().add(const Duration(days: 1)),
    );
    final lastSelectable = DateUtils.dateOnly(
      DateTime.now().add(const Duration(days: 35)),
    );
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
    final bookedDays = <DateTime>[];
    for (final booking in bookings) {
      final date = DateTime.tryParse(booking.date);
      if (date == null) continue;
      final day = DateUtils.dateOnly(date);
      final bookingKey = WorkSchedule.iso(day);
      if (WorkSchedule.slots.any(
        (slot) => schedule.isBooked(booking, bookingKey, slot),
      )) {
        bookedDays.add(day);
      }
    }
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

    const weekdays = [
      'Thứ hai',
      'Thứ ba',
      'Thứ tư',
      'Thứ năm',
      'Thứ sáu',
      'Thứ bảy',
      'Chủ nhật',
    ];
    final formattedSelectedDay =
        '${weekdays[selected.weekday - 1]}, ${selected.day.toString().padLeft(2, '0')}/${selected.month.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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
          ? SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: AvailabilitySaveBar(
                  changeSummary: 'Đã chỉnh sửa $formattedSelectedDay',
                  onDiscard: saving ? null : _discardDraft,
                  onSave: saving ? null : _saveDraft,
                  saving: saving,
                ),
              ),
            )
          : null,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppTokens.contentMaxWidth,
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              // 1. Page Title & Scope Section
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Lịch làm việc',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Quản lý thời gian bạn có thể nhận booking',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: openDays > 0
                          ? const Color(0xFFECFDF5)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: openDays > 0
                            ? const Color(0xFFA7F3D0).withValues(alpha: 0.6)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: openDays > 0
                                ? const Color(0xFF10B981)
                                : const Color(0xFF94A3B8),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          openDays > 0 ? 'Đang nhận lịch' : 'Tạm dừng nhận',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: openDays > 0
                                ? const Color(0xFF047857)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // 2. Compact Single-row Availability Summary Strip
              AvailabilityOverview(
                weeklyHours: _hoursLabel(weeklySlots),
                upcomingBookings: upcomingBookings,
                busySlots: busySlotCount,
                openDays: openDays,
              ),

              const SizedBox(height: 16),

              // 3. Monthly Calendar (Hero Interaction)
              CalendarView(
                selectedDay: selected,
                firstDay: firstSelectable,
                lastDay: lastSelectable,
                bookedDays: bookedDays,
                schedule: schedule,
                onDaySelected: (day) => setState(() => selected = day),
              ),

              const SizedBox(height: 16),

              // 4. Selected Day & Daily Availability Matrix
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

              const SizedBox(height: 16),

              // 5. Weekly Recurring Schedule
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
            ],
          ),
        ),
      ),
    );
  }
}
