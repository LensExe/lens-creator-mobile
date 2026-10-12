import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/vietnam_time.dart';
import 'calendar_api_repository.dart';

class AvailabilityScreen extends ConsumerStatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  ConsumerState<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends ConsumerState<AvailabilityScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = VietnamTime.today();
  }

  @override
  Widget build(BuildContext context) {
    final calendar = ref.watch(creatorCalendarProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FA),
      appBar: AppBar(
        title: const Text('Lịch làm việc'),
        backgroundColor: const Color(0xFFF9F9FA),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppTokens.contentMaxWidth,
          ),
          child: calendar.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _CalendarError(
              error: '$error',
              onRetry: () => ref.invalidate(creatorCalendarProvider),
            ),
            data: (snapshot) => RefreshIndicator(
              onRefresh: () async => ref.invalidate(creatorCalendarProvider),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 110),
                children: [
                  const _CalendarContractNote(),
                  const SizedBox(height: 14),
                  _WeekCalendarOverview(
                    snapshot: snapshot,
                    selectedDate: _selectedDate,
                    onSelectDate: (date) =>
                        setState(() => _selectedDate = date),
                    onPreviousWeek: () => _moveWeek(-1),
                    onNextWeek: () => _moveWeek(1),
                    onPickDate: _pickCalendarDate,
                  ),
                  const SizedBox(height: 20),
                  _SectionTitle(
                    title:
                        'Lịch ngày ${DateFormat('d MMMM', 'vi_VN').format(_selectedDate)}',
                    count: _entriesForSelectedDay(snapshot).length,
                  ),
                  const SizedBox(height: 8),
                  if (_entriesForSelectedDay(snapshot).isEmpty)
                    const _EmptyCalendarSection(
                      message: 'Ngày này chưa có booking hoặc khoảng thời gian đã chặn.',
                    )
                  else
                    for (final event in _entriesForSelectedDay(snapshot))
                      _CalendarEntryCard(
                        entry: event,
                        onRemove: event.kind == 'blocked'
                            ? () => _removeBlockedTime(context, ref, event)
                            : null,
                      ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: () =>
                          _addBlockedTime(context, ref, _selectedDate),
                      icon: const Icon(Icons.event_busy_outlined),
                      label: const Text('Chặn thời gian'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.ember,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  _SectionTitle(
                    title: 'Booking 60 ngày tới',
                    count: snapshot.bookings.length,
                  ),
                  const SizedBox(height: 8),
                  if (snapshot.bookings.isEmpty)
                    const _EmptyCalendarSection(
                      message: 'Không có booking trong 60 ngày tới.',
                    )
                  else
                    for (final event in _sorted(snapshot.bookings))
                      _CalendarEntryCard(entry: event),
                  const SizedBox(height: 22),
                  _SectionTitle(
                    title: 'Thời gian đã chặn',
                    count: snapshot.blocked.length,
                  ),
                  const SizedBox(height: 8),
                  if (snapshot.blocked.isEmpty)
                    const _EmptyCalendarSection(
                      message: 'Chưa có khoảng thời gian nào được chặn.',
                    )
                  else
                    for (final event in _sorted(snapshot.blocked))
                      _CalendarEntryCard(
                        entry: event,
                        onRemove: () => _removeBlockedTime(context, ref, event),
                      ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () => ref.invalidate(creatorCalendarProvider),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tải lại lịch'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _addBlockedTime(
    BuildContext context,
    WidgetRef ref,
    DateTime initialDate,
  ) async {
    final draft = await showDialog<_BlockTimeDraft>(
      context: context,
      builder: (_) => _BlockTimeDialog(initialDate: initialDate),
    );
    if (draft == null || !context.mounted) return;
    final body = draft.toBody();
    try {
      final repository = ref.read(calendarApiRepositoryProvider);
      final affected = await repository.previewBlock(body);
      if (!context.mounted) return;
      if (affected.isNotEmpty) {
        final decline = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Có yêu cầu booking bị ảnh hưởng'),
            content: Text(
              'Có ${affected.length} booking đang chờ trùng khoảng thời gian này. Nếu tiếp tục, các yêu cầu đó sẽ bị từ chối. Bạn có muốn tiếp tục?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Quay lại'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Chặn và từ chối yêu cầu'),
              ),
            ],
          ),
        );
        if (decline != true || !context.mounted) return;
        body['decline_pending'] = true;
      }
      await repository.block(body);
      ref.invalidate(creatorCalendarProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Đã chặn thời gian.')));
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể chặn thời gian: $error')),
      );
    }
  }

  Future<void> _removeBlockedTime(
    BuildContext context,
    WidgetRef ref,
    CalendarEntry entry,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Mở lại khoảng thời gian này?'),
        content: const Text('Khoảng thời gian này sẽ bị xoá khỏi lịch.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Mở lịch'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(calendarApiRepositoryProvider).unblock(entry.id);
      ref.invalidate(creatorCalendarProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Đã mở lại lịch.')));
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Không thể mở lịch: $error')));
    }
  }

  List<CalendarEntry> _entriesForSelectedDay(CalendarSnapshot snapshot) {
    final dayStart = DateTime.utc(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    final dayEnd = dayStart.add(const Duration(days: 1));
    return [
      ...snapshot.bookings.where(
        (entry) =>
            _appearsOnSchedule(entry.status) &&
            entry.from.isBefore(dayEnd) &&
            entry.to.isAfter(dayStart),
      ),
      ...snapshot.blocked.where(
        (entry) => entry.from.isBefore(dayEnd) && entry.to.isAfter(dayStart),
      ),
    ]..sort((a, b) => a.from.compareTo(b.from));
  }

  void _moveWeek(int delta) {
    final today = VietnamTime.today();
    final lastDate = today.add(const Duration(days: 60));
    final thisWeek = _startOfWeek(today);
    final lastWeek = _startOfWeek(lastDate);
    final targetWeek = _startOfWeek(_selectedDate)
        .add(Duration(days: delta * 7));
    if (targetWeek.isBefore(thisWeek) || targetWeek.isAfter(lastWeek)) return;

    var target = targetWeek;
    if (target.isBefore(today)) target = today;
    if (target.isAfter(lastDate)) target = lastDate;
    setState(() => _selectedDate = target);
  }

  Future<void> _pickCalendarDate() async {
    final today = VietnamTime.today();
    try {
      final selected = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: today,
        lastDate: today.add(const Duration(days: 60)),
        locale: const Locale('vi', 'VN'),
      );
      if (selected == null || !mounted) return;
      setState(
        () => _selectedDate = DateTime.utc(
          selected.year,
          selected.month,
          selected.day,
        ),
      );
    } catch (e) {
      debugPrint('Lỗi chọn ngày: $e');
    }
  }
}

List<CalendarEntry> _sorted(List<CalendarEntry> entries) =>
    [...entries]..sort((a, b) => a.from.compareTo(b.from));

class _CalendarContractNote extends StatelessWidget {
  const _CalendarContractNote();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.snow,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFF0F0F2)),
    ),
    child: const Text(
      'Theo dõi booking và khoảng thời gian đã đánh dấu bận trong 60 ngày tới. Lịch bận có thể áp dụng cho cả ngày hoặc một khoảng giờ cụ thể.',
      style: TextStyle(color: AppColors.steel, fontSize: 12, height: 1.45),
    ),
  );
}

class _WeekCalendarOverview extends StatelessWidget {
  const _WeekCalendarOverview({
    required this.snapshot,
    required this.selectedDate,
    required this.onSelectDate,
    required this.onPreviousWeek,
    required this.onNextWeek,
    required this.onPickDate,
  });

  final CalendarSnapshot snapshot;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelectDate;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    final today = VietnamTime.today();
    final lastDate = today.add(const Duration(days: 60));
    final weekStart = _startOfWeek(selectedDate);
    final firstWeek = _startOfWeek(today);
    final lastWeek = _startOfWeek(lastDate);
    final weekEnd = weekStart.add(const Duration(days: 6));
    final weekLabel =
        '${DateFormat('d MMM', 'vi_VN').format(weekStart)} – ${DateFormat('d MMM', 'vi_VN').format(weekEnd)}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9E9ED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_view_week_outlined,
                color: AppColors.ember,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Lịch theo tuần',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Tuần trước',
                onPressed: weekStart.isAfter(firstWeek) ? onPreviousWeek : null,
                icon: const Icon(Icons.chevron_left, size: 22),
              ),
              const SizedBox(width: 8),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Tuần sau',
                onPressed: weekStart.isBefore(lastWeek) ? onNextWeek : null,
                icon: const Icon(Icons.chevron_right, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            weekLabel,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.steel,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var index = 0; index < 7; index++) ...[
                  if (index > 0) const SizedBox(width: 7),
                  _WeekDayChip(
                    date: weekStart.add(Duration(days: index)),
                    today: today,
                    lastDate: lastDate,
                    selected: _sameDate(
                      weekStart.add(Duration(days: index)),
                      selectedDate,
                    ),
                    bookingCount: _countEventsOnDay(
                      snapshot.bookings.where(
                        (entry) => _appearsOnSchedule(entry.status),
                      ),
                      weekStart.add(Duration(days: index)),
                    ),
                    blockedCount: _countEventsOnDay(
                      snapshot.blocked,
                      weekStart.add(Duration(days: index)),
                    ),
                    onTap: onSelectDate,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              TextButton.icon(
                onPressed: () => onSelectDate(today),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
                icon: const Icon(Icons.today_outlined, size: 16),
                label: const Text('Hôm nay', style: TextStyle(fontSize: 12)),
              ),
              TextButton.icon(
                onPressed: onPickDate,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
                icon: const Icon(Icons.edit_calendar_outlined, size: 16),
                label: const Text('Chọn ngày', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeekDayChip extends StatelessWidget {
  const _WeekDayChip({
    required this.date,
    required this.today,
    required this.lastDate,
    required this.selected,
    required this.bookingCount,
    required this.blockedCount,
    required this.onTap,
  });

  final DateTime date;
  final DateTime today;
  final DateTime lastDate;
  final bool selected;
  final int bookingCount;
  final int blockedCount;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = !date.isBefore(today) && !date.isAfter(lastDate);
    final summary = bookingCount > 0
        ? '$bookingCount booking'
        : blockedCount > 0
        ? '$blockedCount bận'
        : 'Trống';
    return Material(
      color: selected ? const Color(0xFFFFF0E8) : const Color(0xFFF7F7F9),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: enabled ? () => onTap(date) : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 58,
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.ember : const Color(0xFFE9E9ED),
            ),
          ),
          child: Column(
            children: [
              Text(
                DateFormat('EEE', 'vi_VN').format(date),
                style: TextStyle(
                  color: enabled
                      ? AppColors.steel
                      : AppColors.steel.withValues(alpha: .5),
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('d', 'vi_VN').format(date),
                style: TextStyle(
                  color: selected ? AppColors.ember : Colors.black87,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                summary,
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: TextStyle(
                  color: enabled
                      ? AppColors.steel
                      : AppColors.steel.withValues(alpha: .5),
                  fontSize: 8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

DateTime _startOfWeek(DateTime date) {
  final day = DateTime.utc(date.year, date.month, date.day);
  return day.subtract(Duration(days: day.weekday - DateTime.monday));
}

bool _sameDate(DateTime left, DateTime right) =>
    left.year == right.year &&
    left.month == right.month &&
    left.day == right.day;

bool _appearsOnSchedule(String? status) => const {
  'pending',
  'accepted',
  'in_progress',
  'shot',
  'completed',
}.contains(status);

int _countEventsOnDay(Iterable<CalendarEntry> entries, DateTime date) {
  final start = DateTime.utc(date.year, date.month, date.day);
  final end = start.add(const Duration(days: 1));
  return entries
      .where((entry) => entry.from.isBefore(end) && entry.to.isAfter(start))
      .length;
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.count});
  final String title;
  final int count;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      Text('$count', style: const TextStyle(color: AppColors.steel)),
    ],
  );
}

class _EmptyCalendarSection extends StatelessWidget {
  const _EmptyCalendarSection({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.snow,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Text(message, style: const TextStyle(color: AppColors.steel)),
  );
}

class _CalendarEntryCard extends StatelessWidget {
  const _CalendarEntryCard({required this.entry, this.onRemove});
  final CalendarEntry entry;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final isBooking = entry.kind == 'booking';
    final dateFormat = DateFormat('EEE, d MMM yyyy · HH:mm', 'vi_VN');
    return Card(
      color: AppColors.snow,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          isBooking ? Icons.event_available : Icons.event_busy,
          color: isBooking ? AppColors.ember : AppColors.steel,
        ),
        title: Text(
          isBooking
              ? 'Booking · ${_statusLabel(entry.status)}'
              : (entry.reason?.trim().isNotEmpty == true
                    ? entry.reason!
                    : 'Khoảng thời gian đã chặn'),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${dateFormat.format(entry.from)}\nđến ${dateFormat.format(entry.to)}'
          '${entry.location?.trim().isNotEmpty == true ? '\n${entry.location}' : ''}',
        ),
        isThreeLine: true,
        trailing: onRemove == null
            ? null
            : IconButton(
                tooltip: 'Mở lịch',
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline),
              ),
      ),
    );
  }
}

String _statusLabel(String? status) => switch (status) {
  'pending' => 'Đang chờ',
  'accepted' => 'Đã xác nhận',
  'rejected' => 'Đã từ chối',
  'cancelled' => 'Đã huỷ',
  'expired' => 'Hết hạn',
  'in_progress' => 'Đang thực hiện',
  'shot' => 'Đã chụp',
  'completed' => 'Hoàn tất',
  _ => 'Không rõ trạng thái',
};

class _CalendarError extends StatelessWidget {
  const _CalendarError({required this.error, required this.onRetry});
  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.cloud_off_rounded,
              color: Color(0xFFDC2626),
              size: 26,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Không thể tải lịch làm việc',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1C1D),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            error.contains('Exception') || error.contains('DioException')
                ? 'Lỗi kết nối máy chủ hoặc phiên đã hết hạn. Vui lòng thử lại.'
                : error,
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Color(0xFF71717A)),
          ),
          const SizedBox(height: 14),
          FilledButton.tonalIcon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Tải lại'),
          ),
        ],
      ),
    ),
  );
}

class _BlockTimeDraft {
  const _BlockTimeDraft({
    required this.date,
    required this.allDay,
    required this.start,
    required this.end,
    required this.reason,
  });
  final DateTime date;
  final bool allDay;
  final TimeOfDay start;
  final TimeOfDay end;
  final String reason;

  Map<String, Object?> toBody() => {
    if (allDay)
      'date': _dateOnly(date)
    else ...{
      'from': calendarIsoWithOffset(
        DateTime(date.year, date.month, date.day, start.hour, start.minute),
      ),
      'to': calendarIsoWithOffset(
        DateTime(date.year, date.month, date.day, end.hour, end.minute),
      ),
    },
    if (reason.trim().isNotEmpty) 'reason': reason.trim(),
  };
}

class _BlockTimeDialog extends StatefulWidget {
  const _BlockTimeDialog({required this.initialDate});

  final DateTime initialDate;

  @override
  State<_BlockTimeDialog> createState() => _BlockTimeDialogState();
}

class _BlockTimeDialogState extends State<_BlockTimeDialog> {
  final reasonController = TextEditingController();
  late DateTime selectedDate;
  TimeOfDay start = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay end = const TimeOfDay(hour: 17, minute: 0);
  bool allDay = true;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
  }

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Chặn thời gian'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_month_outlined),
            label: Text(
              DateFormat('d MMMM yyyy', 'vi_VN').format(selectedDate),
            ),
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Chặn cả ngày'),
            value: allDay,
            onChanged: (value) => setState(() => allDay = value),
          ),
          if (!allDay) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8FA),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Khoảng giờ chặn (chạm để gõ giờ):',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _TimeInputCard(
                          label: 'Bắt đầu',
                          time: start,
                          onTap: () => _pickTime(
                            current: start,
                            onPicked: (t) => setState(() => start = t),
                            helpText: 'Nhập giờ bắt đầu',
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                      Expanded(
                        child: _TimeInputCard(
                          label: 'Kết thúc',
                          time: end,
                          onTap: () => _pickTime(
                            current: end,
                            onPicked: (t) => setState(() => end = t),
                            helpText: 'Nhập giờ kết thúc',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _QuickTimeChip(
                          label: 'Sáng (08:00 - 12:00)',
                          selected: start.hour == 8 &&
                              start.minute == 0 &&
                              end.hour == 12 &&
                              end.minute == 0,
                          onTap: () => setState(() {
                            start = const TimeOfDay(hour: 8, minute: 0);
                            end = const TimeOfDay(hour: 12, minute: 0);
                          }),
                        ),
                        const SizedBox(width: 6),
                        _QuickTimeChip(
                          label: 'Chiều (13:00 - 17:00)',
                          selected: start.hour == 13 &&
                              start.minute == 0 &&
                              end.hour == 17 &&
                              end.minute == 0,
                          onTap: () => setState(() {
                            start = const TimeOfDay(hour: 13, minute: 0);
                            end = const TimeOfDay(hour: 17, minute: 0);
                          }),
                        ),
                        const SizedBox(width: 6),
                        _QuickTimeChip(
                          label: 'Tối (18:00 - 21:00)',
                          selected: start.hour == 18 &&
                              start.minute == 0 &&
                              end.hour == 21 &&
                              end.minute == 0,
                          onTap: () => setState(() {
                            start = const TimeOfDay(hour: 18, minute: 0);
                            end = const TimeOfDay(hour: 21, minute: 0);
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: reasonController,
            maxLength: 10000,
            decoration: const InputDecoration(
              labelText: 'Lý do (không bắt buộc)',
            ),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Huỷ'),
      ),
      FilledButton(onPressed: _submit, child: const Text('Tiếp tục')),
    ],
  );

  Future<void> _pickDate() async {
    final today = VietnamTime.today();
    try {
      final picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: today,
        lastDate: today.add(const Duration(days: 365)),
        locale: const Locale('vi', 'VN'),
      );
      if (picked != null && mounted) setState(() => selectedDate = picked);
    } catch (e) {
      debugPrint('Lỗi chọn ngày: $e');
    }
  }

  Future<void> _pickTime({
    required TimeOfDay current,
    required ValueChanged<TimeOfDay> onPicked,
    required String helpText,
  }) async {
    try {
      final picked = await showTimePicker(
        context: context,
        initialTime: current,
        initialEntryMode: TimePickerEntryMode.input,
        helpText: helpText,
        cancelText: 'Huỷ',
        confirmText: 'Xong',
        hourLabelText: 'Giờ (0-23)',
        minuteLabelText: 'Phút (0-59)',
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child ?? const SizedBox.shrink(),
          );
        },
      );
      if (picked != null && mounted) {
        onPicked(picked);
      }
    } catch (e) {
      debugPrint('Lỗi chọn giờ: $e');
    }
  }

  void _submit() {
    if (!allDay &&
        (end.hour * 60 + end.minute) <= (start.hour * 60 + start.minute)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Giờ kết thúc phải sau giờ bắt đầu.')),
      );
      return;
    }
    Navigator.pop(
      context,
      _BlockTimeDraft(
        date: selectedDate,
        allDay: allDay,
        start: start,
        end: end,
        reason: reasonController.text,
      ),
    );
  }
}

class _TimeInputCard extends StatelessWidget {
  const _TimeInputCard({
    required this.label,
    required this.time,
    required this.onTap,
  });

  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final formatted =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFD1D5DB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: AppColors.ember,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    formatted,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1C1D),
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.keyboard_outlined,
                    size: 14,
                    color: Color(0xFF9CA3AF),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickTimeChip extends StatelessWidget {
  const _QuickTimeChip({
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
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? AppColors.ember : const Color(0xFFE5E7EB),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? AppColors.ember : const Color(0xFF4B5563),
            ),
          ),
        ),
      ),
    );
  }
}

class _TimePickerRow extends StatelessWidget {
  const _TimePickerRow({
    required this.label,
    required this.value,
    required this.onPicked,
  });
  final String label;
  final TimeOfDay value;
  final ValueChanged<TimeOfDay> onPicked;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(label),
    trailing: TextButton(
      onPressed: () async {
        try {
          final picked = await showTimePicker(
            context: context,
            initialTime: value,
            initialEntryMode: TimePickerEntryMode.input,
            helpText: 'Nhập thời gian',
            cancelText: 'Huỷ',
            confirmText: 'Xong',
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
          if (picked != null) onPicked(picked);
        } catch (e) {
          debugPrint('Lỗi chọn giờ: $e');
        }
      },
      child: Text(
        '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}',
      ),
    ),
  );
}

String _dateOnly(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
