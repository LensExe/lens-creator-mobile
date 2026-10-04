import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/creator_empty_state.dart';
import '../../core/widgets/creator_loading_state.dart';
import '../../domain/models/models.dart';
import '../../providers/data_providers.dart';
import 'bookings/widgets/booking_group_tabs.dart';
import 'bookings/widgets/booking_management_card.dart';
import 'bookings/widgets/collaboration_invites.dart';
import 'messages/conversation_navigation.dart';
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
      backgroundColor: AppColors.mist,
      appBar: const PhotographerAppBar(),
      body: bookingsState.when(
        loading: () => const CreatorLoadingState(label: 'Đang tải lịch đặt…'),
        error: (error, _) => CreatorEmptyState(
          icon: Icons.cloud_off_outlined,
          title: 'Không thể tải lịch đặt',
          description: 'Kiểm tra kết nối rồi thử lại.',
          actionLabel: 'Thử lại',
          onAction: () => ref.invalidate(asyncBookingsProvider),
        ),
        data: (bookings) {
          final today = DateUtils.dateOnly(DateTime.now());
          final pending = bookings
              .where((b) => b.status == BookingStatus.pending)
              .length;
          final due = bookings
              .where((b) => b.status == BookingStatus.held)
              .length;
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
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
                children: [
                  _BookingsPageHeader(
                    pending: pending,
                    due: due,
                    onAvailability: () =>
                        context.push('/photographer_home/availability'),
                  ),
                  const SizedBox(height: 14),
                  const CollaborationInvites(compact: true),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: _BookingsSearchField(
                          onChanged: (value) => setState(() => query = value),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _DateScopeDropdown(
                        value: scope,
                        onChanged: (value) => setState(() => scope = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
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
                  const SizedBox(height: 13),
                  _BookingsResultHeading(count: filtered.length),
                  const SizedBox(height: 10),
                  if (filtered.isEmpty)
                    CreatorEmptyState(
                      icon: Icons.event_busy_outlined,
                      title: query.trim().isNotEmpty
                          ? 'Không tìm thấy lịch đặt phù hợp'
                          : 'Không có lịch chụp phù hợp',
                      description: query.trim().isNotEmpty
                          ? 'Thử tìm bằng tên khách, mã lịch hoặc địa điểm khác.'
                          : 'Lịch đặt theo trạng thái và thời gian này sẽ xuất hiện ở đây.',
                    )
                  else
                    for (final booking in filtered)
                      BookingManagementCard(
                        booking: booking,
                        busy: decidingId == booking.id,
                        onDecide: (status) => _decide(booking, status),
                        onMessage: () =>
                            openClientConversation(context, ref, booking),
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

class _BookingsPageHeader extends StatelessWidget {
  const _BookingsPageHeader({
    required this.pending,
    required this.due,
    required this.onAvailability,
  });

  final int pending;
  final int due;
  final VoidCallback onAvailability;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 3,
              children: [
                const Text(
                  'Lịch đặt',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 24,
                    height: 1.15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.6,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.ember.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                  ),
                  child: Text(
                    '$pending mới',
                    style: const TextStyle(
                      color: AppColors.ember,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              pending + due > 0
                  ? '$pending yêu cầu chờ duyệt · $due buổi cần giao ảnh'
                  : 'Theo dõi các buổi chụp và tiến độ bàn giao.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.steel,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(width: 8),
      OutlinedButton.icon(
        onPressed: onAvailability,
        icon: const Icon(Icons.calendar_month_outlined, size: 16),
        label: const Text('Lịch trống'),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 34),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          backgroundColor: AppColors.snow,
          foregroundColor: AppColors.ink,
          side: const BorderSide(color: Color(0xFFE8E8ED)),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );
}

class _BookingsSearchField extends StatelessWidget {
  const _BookingsSearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(minHeight: 40),
    child: TextField(
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Tìm tên khách, mã lịch, địa điểm...',
        hintStyle: const TextStyle(color: AppColors.ash, fontSize: 12),
        prefixIcon: const Icon(Icons.search_rounded, size: 18),
        prefixIconColor: AppColors.ash,
        prefixIconConstraints: const BoxConstraints(
          minWidth: 38,
          minHeight: 40,
        ),
        isDense: true,
        filled: true,
        fillColor: AppColors.snow,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE8E8ED)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.ink, width: 1),
        ),
      ),
    ),
  );
}

class _BookingsResultHeading extends StatelessWidget {
  const _BookingsResultHeading({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.spaceBetween,
    spacing: 8,
    runSpacing: 6,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Buổi chụp',
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFECECEE),
              borderRadius: BorderRadius.circular(AppTokens.radiusPill),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: AppColors.graphite,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Sắp xếp: ',
            style: TextStyle(color: AppColors.steel, fontSize: 10.5),
          ),
          Text(
            'Gần nhất',
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ],
  );
}

class _DateScopeDropdown extends StatelessWidget {
  const _DateScopeDropdown({required this.value, required this.onChanged});

  final _DateScope value;
  final ValueChanged<_DateScope> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    height: 40,
    width: 119,
    padding: const EdgeInsets.only(left: 8, right: 4),
    decoration: BoxDecoration(
      color: AppColors.snow,
      border: Border.all(color: const Color(0xFFE8E8ED)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<_DateScope>(
        value: value,
        isExpanded: true,
        icon: const Icon(Icons.expand_more_rounded, size: 18),
        style: const TextStyle(
          color: AppColors.ink,
          fontSize: 11,
          fontWeight: FontWeight.w500,
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
