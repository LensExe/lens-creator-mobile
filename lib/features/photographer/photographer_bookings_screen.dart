import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/creator_empty_state.dart';
import '../../core/widgets/creator_page_header.dart';
import '../../core/widgets/creator_section_header.dart';
import '../../core/widgets/creator_summary_strip.dart';
import '../../domain/models/models.dart';
import '../../providers/data_providers.dart';
import 'bookings/widgets/booking_group_tabs.dart';
import 'bookings/widgets/booking_management_card.dart';
import 'bookings/widgets/collaboration_invites.dart';
import 'widgets/photographer_app_bar.dart';

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
      backgroundColor: AppColors.snow,
      appBar: PhotographerAppBar(
        actions: [
          IconButton(
            tooltip: 'Lịch làm việc',
            onPressed: () => context.push('/photographer_home/availability'),
            icon: const Icon(Icons.calendar_month_outlined),
          ),
        ],
      ),
      body: bookingsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: AppColors.snow,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cloud_off_outlined,
                    color: AppColors.steel,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Không thể tải lịch đặt',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () => ref.invalidate(asyncBookingsProvider),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
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
          final active = bookings
              .where(
                (b) =>
                    b.status == BookingStatus.confirmed ||
                    b.status == BookingStatus.held,
              )
              .length;
          final cancelled = bookings
              .where((b) => b.status == BookingStatus.cancelled)
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

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppTokens.contentMaxWidth,
              ),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
                children: [
                  CreatorPageHeader(
                    title: 'Lịch đặt',
                    subtitle: pending + due > 0
                        ? '$pending yêu cầu chờ duyệt · $due buổi cần giao ảnh'
                        : 'Theo dõi các buổi chụp và tiến độ bàn giao.',
                  ),
                  const SizedBox(height: 17),
                  const CollaborationInvites(),
                  BookingGroupTabs(
                    selectedIndex: _BookingGroup.values.indexOf(group),
                    onSelected: (index) =>
                        setState(() => group = _BookingGroup.values[index]),
                    items: [
                      BookingGroupTab('Chờ duyệt', pending),
                      BookingGroupTab('Đang diễn ra', active),
                      BookingGroupTab('Hoàn thành', completed),
                      BookingGroupTab('Đã huỷ', cancelled),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (value) => setState(() => query = value),
                          decoration: const InputDecoration(
                            hintText: 'Tìm tên khách, mã lịch...',
                            prefixIcon: Icon(Icons.search_rounded, size: 20),
                            prefixIconColor: AppColors.ash,
                          ),
                        ),
                      ),
                      const SizedBox(width: 9),
                      _DateScopeDropdown(
                        value: scope,
                        onChanged: (value) => setState(() => scope = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  CreatorSectionHeader(
                    title: 'Buổi chụp',
                    count: filtered.length,
                  ),
                  const SizedBox(height: 4),
                  if (filtered.isEmpty)
                    const CreatorEmptyState(
                      icon: Icons.event_busy_outlined,
                      title: 'Không có lịch chụp phù hợp',
                    )
                  else
                    for (final booking in filtered)
                      BookingManagementCard(
                        booking: booking,
                        busy: decidingId == booking.id,
                        onDecide: (status) => _decide(booking, status),
                      ),
                  const SizedBox(height: 26),
                  const CreatorSectionHeader(title: 'Tổng quan'),
                  const SizedBox(height: 12),
                  CreatorSummaryStrip(
                    items: [
                      CreatorSummaryItem('Chờ duyệt', '$pending'),
                      CreatorSummaryItem('Tuần này', '$upcoming'),
                      CreatorSummaryItem('Cần giao ảnh', '$due'),
                      CreatorSummaryItem('Hoàn thành', '$completed'),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DateScopeDropdown extends StatelessWidget {
  const _DateScopeDropdown({required this.value, required this.onChanged});

  final _DateScope value;
  final ValueChanged<_DateScope> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    height: 48,
    width: 126,
    padding: const EdgeInsets.only(left: 10, right: 6),
    decoration: BoxDecoration(
      color: AppColors.snow,
      border: Border.all(color: AppColors.fog),
      borderRadius: BorderRadius.circular(13),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<_DateScope>(
        value: value,
        isExpanded: true,
        icon: const Icon(Icons.expand_more_rounded, size: 18),
        style: const TextStyle(
          color: AppColors.graphite,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        items: const [
          DropdownMenuItem(value: _DateScope.all, child: Text('Mọi ngày')),
          DropdownMenuItem(value: _DateScope.upcoming, child: Text('Sắp tới')),
          DropdownMenuItem(value: _DateScope.past, child: Text('Đã qua')),
        ],
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
      ),
    ),
  );
}
