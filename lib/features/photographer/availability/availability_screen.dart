import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../providers/data_providers.dart';
import 'schedule_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final saved = ref.watch(scheduleProvider);
    final schedule = draft ?? saved;
    final bookings = ref.watch(myBookingsProvider);
    final key = WorkSchedule.iso(selected);
    final busy = schedule.busy[key] ?? <String>{};
    final booked = [
      for (final slot in WorkSchedule.slots)
        if (bookings.any((booking) => schedule.isBooked(booking, key, slot)))
          slot,
    ];
    final dayWorking = schedule.weekly[selected.weekday % 7];
    return PopScope(
      canPop: !dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && await _confirmDiscard() && context.mounted) {
          setState(() {
            draft = null;
            dirty = false;
          });
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Lịch làm việc')),
        body: ListView(
          padding: AppTokens.pagePadding,
          children: [
            const Text(
              'Khách có thể bắt đầu từ 07:00 đến trước 24:00. Lịch đã đặt được khóa.',
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lịch định kỳ',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Text(
                      'Chạm ngày để đóng hoặc mở toàn bộ khung giờ. Thay đổi chỉ lưu khi bạn bấm Lưu lịch.',
                      style: TextStyle(color: AppColors.steel, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    Wrap(spacing: 6, runSpacing: 6, children: [
                      for (final preset in const [
                        ('Cả tuần', [0, 1, 2, 3, 4, 5, 6]),
                        ('Ngày thường', [1, 2, 3, 4, 5]),
                        ('Cuối tuần', [0, 6]),
                        ('Xoá hết', <int>[]),
                      ]) ActionChip(label: Text(preset.$1), onPressed: () => _edit((next) {
                        for (var day = 0; day < 7; day++) {
                          next.weekly[day] = preset.$2.contains(day)
                              ? {...WorkSchedule.slots} : <String>{};
                        }
                      })),
                    ]),
                    const SizedBox(height: 12),
                    for (final (index, label) in const [
                      'CN',
                      'T2',
                      'T3',
                      'T4',
                      'T5',
                      'T6',
                      'T7',
                    ].indexed)
                      SwitchListTile(
                        dense: true,
                        title: Text(label),
                        subtitle: Text(
                          schedule.weekly[index].isEmpty
                              ? 'Nghỉ'
                              : '${schedule.weekly[index].length} khung 30 phút',
                        ),
                        value: schedule.weekly[index].isNotEmpty,
                        onChanged: (value) => _edit(
                          (next) => next.weekly[index] = value
                              ? {...WorkSchedule.slots}
                              : <String>{},
                        ),
                      ),
                    const Divider(),
                    Text('Khung giờ định kỳ', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Wrap(spacing: 6, runSpacing: 6, children: [
                      for (final (index, label) in const ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'].indexed)
                        ChoiceChip(label: Text(label), selected: selectedWeekday == index,
                            onSelected: (_) => setState(() => selectedWeekday = index)),
                    ]),
                    const SizedBox(height: 8),
                    Wrap(spacing: 6, runSpacing: 6, children: [
                      for (final slot in WorkSchedule.slots) FilterChip(
                        label: Text(slot),
                        selected: schedule.weekly[selectedWeekday].contains(slot),
                        onSelected: (_) => _edit((next) {
                          final cells = next.weekly[selectedWeekday];
                          if (!cells.add(slot)) cells.remove(slot);
                        }),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ngoại lệ theo ngày',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_today_outlined),
                      label: Text(
                        DateFormat(
                          'EEEE, dd/MM/yyyy',
                          'vi_VN',
                        ).format(selected),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${booked.length} khung đã có khách · ${busy.length} khung bận',
                      style: const TextStyle(color: AppColors.steel),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: const Text('Bận cả ngày'),
                      value:
                          dayWorking.isNotEmpty && busy.containsAll(dayWorking),
                      onChanged: dayWorking.isEmpty
                          ? null
                          : (value) => _edit((next) {
                              if (value) {
                                next.busy[key] = {...dayWorking};
                              } else {
                                next.busy.remove(key);
                              }
                            }),
                    ),
                    const Text(
                      'Chạm một khung để đánh dấu bận. Lịch khách đã đặt không thể sửa.',
                      style: TextStyle(color: AppColors.steel, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final slot in WorkSchedule.slots)
                          if (dayWorking.contains(slot))
                            FilterChip(
                              label: Text(slot),
                              selected:
                                  busy.contains(slot) || booked.contains(slot),
                              onSelected: booked.contains(slot)
                                  ? null
                                  : (_) => _edit((next) {
                                      final cells = next.busy.putIfAbsent(
                                        key,
                                        () => <String>{},
                                      );
                                      if (!cells.add(slot)) cells.remove(slot);
                                      if (cells.isEmpty) next.busy.remove(key);
                                    }),
                              selectedColor: booked.contains(slot)
                                  ? AppColors.fog
                                  : const Color(0xFFFEF3C7),
                            ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (dirty)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() {
                        draft = null;
                        dirty = false;
                      }),
                      child: const Text('Bỏ thay đổi'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        ref.read(scheduleProvider.notifier).save(schedule);
                        setState(() {
                          draft = null;
                          dirty = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã lưu lịch làm việc')),
                        );
                      },
                      child: const Text('Lưu lịch'),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
