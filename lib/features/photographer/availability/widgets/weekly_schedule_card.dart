import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
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

  static const _shortDays = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
  static const _fullDays = [
    'Chủ nhật',
    'Thứ hai',
    'Thứ ba',
    'Thứ tư',
    'Thứ năm',
    'Thứ sáu',
    'Thứ bảy',
  ];

  @override
  Widget build(BuildContext context) {
    final slots = schedule.weekly[selectedWeekday];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        border: Border.all(color: AppColors.fog),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lịch định kỳ',
            style: TextStyle(
              color: AppColors.obsidian,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Chọn ngày và các khung giờ nhận lịch lặp lại hằng tuần.',
            style: TextStyle(color: AppColors.steel, fontSize: 11, height: 1.4),
          ),
          const SizedBox(height: 13),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _PresetChip(
                  label: 'Cả tuần',
                  onTap: () => onPresetSelected([0, 1, 2, 3, 4, 5, 6]),
                ),
                const SizedBox(width: 7),
                _PresetChip(
                  label: 'Ngày thường',
                  onTap: () => onPresetSelected([1, 2, 3, 4, 5]),
                ),
                const SizedBox(width: 7),
                _PresetChip(
                  label: 'Cuối tuần',
                  onTap: () => onPresetSelected([0, 6]),
                ),
                const SizedBox(width: 7),
                _PresetChip(
                  label: 'Đóng tất cả',
                  onTap: () => onPresetSelected(const []),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              for (var index = 0; index < _shortDays.length; index++) ...[
                Expanded(
                  child: _WeekdayButton(
                    label: _shortDays[index],
                    slotCount: schedule.weekly[index].length,
                    selected: selectedWeekday == index,
                    onTap: () => onWeekdaySelected(index),
                  ),
                ),
                if (index < _shortDays.length - 1) const SizedBox(width: 5),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.mist,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _fullDays[selectedWeekday],
                        style: const TextStyle(
                          color: AppColors.graphite,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        slots.isEmpty
                            ? 'Đang nghỉ'
                            : '${slots.length} khung giờ · mỗi khung 30 phút',
                        style: const TextStyle(
                          color: AppColors.steel,
                          fontSize: 9.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: slots.isNotEmpty,
                  activeTrackColor: AppColors.ember,
                  onChanged: (enabled) =>
                      onDayAvailabilityChanged(selectedWeekday, enabled),
                ),
              ],
            ),
          ),
          if (slots.isNotEmpty) ...[
            const SizedBox(height: 13),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Khung giờ định kỳ',
                    style: TextStyle(
                      color: AppColors.graphite,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Icon(
                  Icons.timelapse_rounded,
                  color: AppColors.ash,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  '${WorkSchedule.slots.length} mốc · 30 phút',
                  style: const TextStyle(color: AppColors.ash, fontSize: 9),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 7,
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

class _PresetChip extends StatelessWidget {
  const _PresetChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.snow,
    borderRadius: BorderRadius.circular(AppTokens.radiusPill),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTokens.radiusPill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTokens.radiusPill),
          border: Border.all(color: AppColors.fog),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.graphite,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
  );
}

class _WeekdayButton extends StatelessWidget {
  const _WeekdayButton({
    required this.label,
    required this.slotCount,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int slotCount;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? AppColors.obsidian : AppColors.mist,
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.snow : AppColors.graphite,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              slotCount == 0 ? '—' : '$slotCount',
              style: TextStyle(
                color: slotCount == 0
                    ? AppColors.ash
                    : (selected ? const Color(0xFF8BE0B5) : AppColors.success),
                fontSize: 8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    ),
  );
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
  Widget build(BuildContext context) => Material(
    color: selected ? const Color(0xFFFFF0E8) : AppColors.snow,
    borderRadius: BorderRadius.circular(9),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: selected ? const Color(0xFFFFD4BC) : AppColors.fog,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.ember : AppColors.steel,
            fontSize: 9,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    ),
  );
}
