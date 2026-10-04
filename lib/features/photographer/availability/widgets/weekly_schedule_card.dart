import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../work_schedule.dart';

class WeeklyScheduleCard extends StatelessWidget {
  const WeeklyScheduleCard({
    super.key,
    required this.schedule,
    required this.selectedWeekday,
    required this.onWeekdaySelected,
    required this.onPresetSelected,
    required this.onDayAvailabilityChanged,
    required this.onSlotToggle,
  });

  final WorkSchedule schedule;
  final int selectedWeekday;
  final ValueChanged<int> onWeekdaySelected;
  final ValueChanged<List<int>> onPresetSelected;
  final void Function(int weekday, bool enabled) onDayAvailabilityChanged;
  final void Function(int weekday, String slot) onSlotToggle;

  // Order matching HTML: T2 (1), T3 (2), T4 (3), T5 (4), T6 (5), T7 (6), CN (0)
  static const _weekdays = [1, 2, 3, 4, 5, 6, 0];
  static const _shortNames = {
    1: 'T2',
    2: 'T3',
    3: 'T4',
    4: 'T5',
    5: 'T6',
    6: 'T7',
    0: 'CN',
  };
  static const _fullNames = {
    1: 'Thứ hai',
    2: 'Thứ ba',
    3: 'Thứ tư',
    4: 'Thứ năm',
    5: 'Thứ sáu',
    6: 'Thứ bảy',
    0: 'Chủ nhật',
  };

  static const _morningSlots = [
    '07:00',
    '07:30',
    '08:00',
    '08:30',
    '09:00',
    '09:30',
    '10:00',
    '10:30',
    '11:00',
    '11:30',
  ];

  static const _afternoonSlots = [
    '12:00',
    '12:30',
    '13:00',
    '13:30',
    '14:00',
    '14:30',
    '15:00',
    '15:30',
    '16:00',
    '16:30',
    '17:00',
    '17:30',
  ];

  static const _eveningSlots = [
    '18:00',
    '18:30',
    '19:00',
    '19:30',
    '20:00',
    '20:30',
    '21:00',
    '21:30',
    '22:00',
    '22:30',
    '23:00',
    '23:30',
  ];

  void _toggleShift(int weekday, List<String> shiftSlots) {
    final currentSlots = schedule.weekly[weekday];
    final allActive = shiftSlots.every(currentSlots.contains);
    for (final slot in shiftSlots) {
      if (allActive) {
        if (currentSlots.contains(slot)) {
          onSlotToggle(weekday, slot);
        }
      } else {
        if (!currentSlots.contains(slot)) {
          onSlotToggle(weekday, slot);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final slots = schedule.weekly[selectedWeekday];

    // Detect active preset
    final all7Open = [
      0,
      1,
      2,
      3,
      4,
      5,
      6,
    ].every((d) => schedule.weekly[d].isNotEmpty);
    final weekdaysOpenOnly =
        [1, 2, 3, 4, 5].every((d) => schedule.weekly[d].isNotEmpty) &&
        schedule.weekly[0].isEmpty &&
        schedule.weekly[6].isEmpty;
    final weekendsOpenOnly =
        [0, 6].every((d) => schedule.weekly[d].isNotEmpty) &&
        [1, 2, 3, 4, 5].every((d) => schedule.weekly[d].isEmpty);

    final morningActive =
        slots.isNotEmpty && _morningSlots.every(slots.contains);
    final afternoonActive =
        slots.isNotEmpty && _afternoonSlots.every(slots.contains);
    final eveningActive =
        slots.isNotEmpty && _eveningSlots.every(slots.contains);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header & Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Lịch cố định hàng tuần',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Áp dụng khung giờ mẫu cho các ngày nhận lịch',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Tự động lặp',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 2. Segmented Preset Chips
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _SegmentChip(
                  label: 'Tất cả',
                  isActive: all7Open,
                  onTap: () => onPresetSelected([0, 1, 2, 3, 4, 5, 6]),
                ),
                const SizedBox(width: 4),
                _SegmentChip(
                  label: 'Thứ 2 - Thứ 6',
                  isActive: weekdaysOpenOnly,
                  onTap: () => onPresetSelected([1, 2, 3, 4, 5]),
                ),
                const SizedBox(width: 4),
                _SegmentChip(
                  label: 'Cuối tuần',
                  isActive: weekendsOpenOnly,
                  onTap: () => onPresetSelected([0, 6]),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 3. Weekday Picker Pills (T2, T3, T4, T5, T6, T7, CN)
          Row(
            children: [
              for (var i = 0; i < _weekdays.length; i++) ...[
                Expanded(
                  child: _WeekdayPill(
                    label: _shortNames[_weekdays[i]]!,
                    isSelected: selectedWeekday == _weekdays[i],
                    hasSlots: schedule.weekly[_weekdays[i]].isNotEmpty,
                    isSunday: _weekdays[i] == 0,
                    onTap: () => onWeekdaySelected(_weekdays[i]),
                  ),
                ),
                if (i < _weekdays.length - 1) const SizedBox(width: 4),
              ],
            ],
          ),

          const SizedBox(height: 12),

          // 4. Selected Day Status & Toggle Switch
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _fullNames[selectedWeekday]!,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        slots.isEmpty
                            ? 'Đang nghỉ'
                            : '${slots.length} khung giờ · mỗi khung 30 phút',
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 24,
                  width: 38,
                  child: Switch.adaptive(
                    value: slots.isNotEmpty,
                    activeThumbColor: Colors.white,
                    activeTrackColor: AppColors.ember,
                    onChanged: (enabled) =>
                        onDayAvailabilityChanged(selectedWeekday, enabled),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 5. Quick Shift Selectors
          Row(
            children: [
              Expanded(
                child: _ShiftCard(
                  title: 'Ca Sáng',
                  timeRange: '07:00 - 12:00',
                  isActive: morningActive,
                  onTap: () => _toggleShift(selectedWeekday, _morningSlots),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ShiftCard(
                  title: 'Ca Chiều',
                  timeRange: '13:00 - 18:00',
                  isActive: afternoonActive,
                  onTap: () => _toggleShift(selectedWeekday, _afternoonSlots),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ShiftCard(
                  title: 'Ca Tối',
                  timeRange: '18:00 - 22:00',
                  isActive: eveningActive,
                  onTap: () => _toggleShift(selectedWeekday, _eveningSlots),
                ),
              ),
            ],
          ),

          // 6. Detailed Recurring Slots Grid (if day has slots)
          if (slots.isNotEmpty) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Khung giờ chi tiết',
                    style: TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Icon(
                  Icons.timelapse_rounded,
                  color: Color(0xFFA1A1AA),
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  '${slots.length}/${WorkSchedule.slots.length} mốc đã chọn',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final slot in WorkSchedule.slots)
                  _RecurringSlotChip(
                    label: slot,
                    selected: slots.contains(slot),
                    onTap: () => onSlotToggle(selectedWeekday, slot),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SegmentChip extends StatelessWidget {
  const _SegmentChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: isActive ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 7),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: isActive
                  ? const [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? AppColors.ember : const Color(0xFF475569),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WeekdayPill extends StatelessWidget {
  const _WeekdayPill({
    required this.label,
    required this.isSelected,
    required this.hasSlots,
    required this.isSunday,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool hasSlots;
  final bool isSunday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color borderColor;
    final Color textColor;
    final Color dotColor;
    final bool lineThrough;

    if (isSelected) {
      bgColor = const Color(0xFF0F172A); // slate-900
      borderColor = AppColors.ember.withValues(alpha: 0.4);
      textColor = Colors.white;
      dotColor = AppColors.ember;
      lineThrough = false;
    } else if (hasSlots) {
      bgColor = const Color(0xFFF8FAFC);
      borderColor = const Color(0xFFE2E8F0);
      textColor = const Color(0xFF334155);
      dotColor = const Color(0xFF10B981);
      lineThrough = false;
    } else {
      bgColor = const Color(0xFFF1F5F9).withValues(alpha: 0.6);
      borderColor = const Color(0xFFE2E8F0);
      textColor = const Color(0xFF94A3B8);
      dotColor = Colors.transparent;
      lineThrough = true;
    }

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (isSunday && !lineThrough
                            ? const Color(0xFFFB7185)
                            : textColor),
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  decoration: lineThrough ? TextDecoration.lineThrough : null,
                ),
              ),
              const SizedBox(height: 3),
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShiftCard extends StatelessWidget {
  const _ShiftCard({
    required this.title,
    required this.timeRange,
    required this.isActive,
    required this.onTap,
  });

  final String title;
  final String timeRange;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive
          ? const Color(0xFFF8FAFC)
          : const Color(0xFFF8FAFC).withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive
                  ? const Color(0xFFA7F3D0)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: isActive
                            ? const Color(0xFF1E293B)
                            : const Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF10B981)
                          : const Color(0xFFCBD5E1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  timeRange,
                  style: TextStyle(
                    fontSize: 10,
                    color: isActive
                        ? const Color(0xFF64748B)
                        : const Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecurringSlotChip extends StatelessWidget {
  const _RecurringSlotChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFFFF0E8) : Colors.white,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: selected
                  ? const Color(0xFFFFD4BC)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.ember : const Color(0xFF64748B),
              fontSize: 10.5,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
