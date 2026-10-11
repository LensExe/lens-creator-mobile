import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import 'calendar_api_repository.dart';

class AvailabilityScreen extends ConsumerWidget {
  const AvailabilityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
                children: [
                  const _CalendarContractNote(),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: () => _addBlockedTime(context, ref),
                      icon: const Icon(Icons.event_busy_outlined),
                      label: const Text('Chặn thời gian'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.ember,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  _SectionTitle(
                    title: 'Booking trong lịch',
                    count: snapshot.bookings.length,
                  ),
                  const SizedBox(height: 8),
                  if (snapshot.bookings.isEmpty)
                    const _EmptyCalendarSection(
                      message: 'Backend không có booking trong khoảng thời gian này.',
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

  Future<void> _addBlockedTime(BuildContext context, WidgetRef ref) async {
    final draft = await showDialog<_BlockTimeDraft>(
      context: context,
      builder: (_) => const _BlockTimeDialog(),
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
              'Backend tìm thấy ${affected.length} booking đang chờ chồng lên khoảng này. Nếu tiếp tục, các yêu cầu đó sẽ bị từ chối. Bạn có muốn tiếp tục?',
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backend đã xác nhận chặn lịch.')),
      );
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
        content: const Text('Backend sẽ xoá blocked time đã chọn.'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backend đã xác nhận mở lịch.')),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Không thể mở lịch: $error')));
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
      'Lịch đang hiển thị booking và blocked time do Backend trả về trong 91 ngày tới. Backend hỗ trợ chặn cả ngày hoặc một khoảng giờ; lịch lặp hàng tuần và ô 30 phút không được hỗ trợ.',
      style: TextStyle(color: AppColors.steel, fontSize: 12, height: 1.45),
    ),
  );
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
          '${dateFormat.format(entry.from.toLocal())}\nđến ${dateFormat.format(entry.to.toLocal())}'
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
          Text(
            'Không tải được lịch: $error',
            textAlign: TextAlign.center,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
          TextButton(onPressed: onRetry, child: const Text('Thử lại')),
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
  const _BlockTimeDialog();

  @override
  State<_BlockTimeDialog> createState() => _BlockTimeDialogState();
}

class _BlockTimeDialogState extends State<_BlockTimeDialog> {
  final reasonController = TextEditingController();
  DateTime selectedDate = DateUtils.dateOnly(
    DateTime.now().add(const Duration(days: 1)),
  );
  TimeOfDay start = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay end = const TimeOfDay(hour: 17, minute: 0);
  bool allDay = true;

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
            _TimePickerRow(
              label: 'Từ',
              value: start,
              onPicked: (v) => setState(() => start = v),
            ),
            _TimePickerRow(
              label: 'Đến',
              value: end,
              onPicked: (v) => setState(() => end = v),
            ),
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
    final today = DateUtils.dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
      locale: const Locale('vi', 'VN'),
    );
    if (picked != null && mounted) setState(() => selectedDate = picked);
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
        final picked = await showTimePicker(
          context: context,
          initialTime: value,
        );
        if (picked != null) onPicked(picked);
      },
      child: Text(value.format(context)),
    ),
  );
}

String _dateOnly(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
