import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../domain/models/models.dart';
import '../../providers/data_providers.dart';
import 'bookings/widgets/studio_booking_card.dart';
import 'bookings/widgets/collaboration_invites.dart';

enum _BookingGroup { pending, active, done, cancelled }

enum _DateScope { all, upcoming, past }

class PhotographerBookingsScreen extends ConsumerStatefulWidget {
  const PhotographerBookingsScreen({super.key});

  @override
  ConsumerState<PhotographerBookingsScreen> createState() =>
      _PhotographerBookingsScreenState();
}

class _PhotographerBookingsScreenState
    extends ConsumerState<PhotographerBookingsScreen> {
  _BookingGroup group = _BookingGroup.pending;
  _DateScope scope = _DateScope.all;
  String query = '';
  String? decidingId;

  bool _inGroup(Booking booking) => switch (group) {
    _BookingGroup.pending => booking.status == BookingStatus.pending,
    _BookingGroup.active =>
      booking.status == BookingStatus.confirmed ||
          booking.status == BookingStatus.held,
    _BookingGroup.done => booking.status == BookingStatus.released,
    _BookingGroup.cancelled => booking.status == BookingStatus.cancelled,
  };

  Future<void> _decide(Booking booking, BookingStatus status) async {
    setState(() => decidingId = booking.id);
    try {
      await ref
          .read(asyncBookingsProvider.notifier)
          .updateBookingStatus(booking.id, status);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == BookingStatus.confirmed
                  ? 'Đã xác nhận lịch chụp với ${booking.clientName}'
                  : 'Đã từ chối và hoàn cọc cho ${booking.clientName}',
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể cập nhật yêu cầu: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => decidingId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingsState = ref.watch(incomingBookingsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý đặt lịch'),
        actions: [
          IconButton(
            tooltip: 'Lịch làm việc',
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: () => context.push('/photographer_home/availability'),
          ),
        ],
      ),
      body: bookingsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Không thể tải lịch đặt'),
              TextButton(
                onPressed: () => ref.invalidate(asyncBookingsProvider),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
        data: (bookings) {
          final today = DateUtils.dateOnly(DateTime.now());
          final weekEnd = today.add(const Duration(days: 7));
          final pending = bookings
              .where((b) => b.status == BookingStatus.pending)
              .length;
          final due = bookings
              .where((b) => b.status == BookingStatus.held)
              .length;
          final upcoming = bookings.where((b) {
            final date = DateTime.tryParse(b.date);
            return b.status == BookingStatus.confirmed &&
                date != null &&
                !date.isBefore(today) &&
                !date.isAfter(weekEnd);
          }).length;
          final completed = bookings
              .where((b) => b.status == BookingStatus.released)
              .length;
          final search = query.trim().toLowerCase();
          final filtered = bookings.where((b) {
            if (!_inGroup(b)) return false;
            final date = DateTime.tryParse(b.date);
            if (scope == _DateScope.upcoming &&
                (date == null || date.isBefore(today))) {
              return false;
            }
            if (scope == _DateScope.past &&
                (date == null || !date.isBefore(today))) {
              return false;
            }
            return search.isEmpty ||
                [
                  b.id,
                  b.clientName,
                  b.contactPhone ?? '',
                  b.location,
                  b.style,
                  b.packageName ?? '',
                ].join(' ').toLowerCase().contains(search);
          }).toList()..sort((a, b) => a.date.compareTo(b.date));
          return ListView(
            padding: AppTokens.pagePadding,
            children: [
              const CollaborationInvites(),
              Text(
                'Theo dõi và xử lý các buổi chụp của bạn.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Metric(label: 'Chờ duyệt', value: pending),
                  _Metric(label: 'Tuần này', value: upcoming),
                  _Metric(label: 'Cần giao ảnh', value: due),
                  _Metric(label: 'Hoàn thành', value: completed),
                ],
              ),
              if (pending + due > 0) ...[
                const SizedBox(height: 16),
                Card(
                  color: const Color(0xFFFFF7ED),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      '$pending yêu cầu chờ duyệt · $due buổi cần giao ảnh',
                      style: const TextStyle(
                        color: Color(0xFF9A3412),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final item in _BookingGroup.values) ...[
                      ChoiceChip(
                        label: Text(switch (item) {
                          _BookingGroup.pending => 'Cần duyệt',
                          _BookingGroup.active => 'Đang diễn ra',
                          _BookingGroup.done => 'Hoàn thành',
                          _BookingGroup.cancelled => 'Đã huỷ',
                        }),
                        selected: group == item,
                        onSelected: (_) => setState(() => group = item),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Tìm tên khách, mã lịch, địa điểm...',
                ),
                onChanged: (value) => setState(() => query = value),
              ),
              const SizedBox(height: 8),
              DropdownButton<_DateScope>(
                value: scope,
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(
                    value: _DateScope.all,
                    child: Text('Tất cả ngày'),
                  ),
                  DropdownMenuItem(
                    value: _DateScope.upcoming,
                    child: Text('Sắp tới'),
                  ),
                  DropdownMenuItem(
                    value: _DateScope.past,
                    child: Text('Đã qua'),
                  ),
                ],
                onChanged: (value) =>
                    setState(() => scope = value ?? _DateScope.all),
              ),
              if (filtered.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: Text('Không có lịch chụp phù hợp')),
                )
              else
                for (final booking in filtered)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: StudioBookingCard(
                      booking: booking,
                      busy: decidingId == booking.id,
                      onDecide: (status) => _decide(booking, status),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) => Container(
    width: 155,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.snow,
      border: Border.all(color: AppColors.fog),
      borderRadius: BorderRadius.circular(AppTokens.radiusCard),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.steel),
        ),
        const SizedBox(height: 5),
        Text(
          '$value',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}
