import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../domain/models/models.dart';
import '../../providers/data_providers.dart';
import 'bookings/widgets/booking_group_tabs.dart';
import 'bookings/widgets/booking_kpi_card.dart';
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
      backgroundColor: AppColors.mist,
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
              constraints: const BoxConstraints(maxWidth: 600),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
                children: [
                  const Text(
                    'Quản lý đặt lịch',
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
                    'Theo dõi và xử lý các buổi chụp của bạn.',
                    style: TextStyle(
                      color: AppColors.steel,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 22),
                  const CollaborationInvites(),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final tileWidth = (constraints.maxWidth - 12) / 2;
                      return GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: tileWidth / 98,
                        children: [
                          BookingKpiCard(
                            label: 'Chờ duyệt',
                            value: pending,
                            caption: 'Yêu cầu mới',
                            icon: Icons.mark_email_unread_outlined,
                            accent: AppColors.ember,
                            tint: const Color(0xFFFFEEE5),
                          ),
                          BookingKpiCard(
                            label: 'Tuần này',
                            value: upcoming,
                            caption: 'Lịch sắp tới',
                            icon: Icons.calendar_today_outlined,
                            accent: const Color(0xFF3E6E9E),
                            tint: const Color(0xFFEAF2FA),
                          ),
                          BookingKpiCard(
                            label: 'Cần giao ảnh',
                            value: due,
                            caption: 'Chờ bàn giao',
                            icon: Icons.photo_library_outlined,
                            accent: const Color(0xFF8059D6),
                            tint: const Color(0xFFF0ECFF),
                          ),
                          BookingKpiCard(
                            label: 'Hoàn thành',
                            value: completed,
                            caption: 'Đã hoàn tất',
                            icon: Icons.task_alt_rounded,
                            accent: const Color(0xFF16865A),
                            tint: const Color(0xFFE7F6EF),
                          ),
                        ],
                      );
                    },
                  ),
                  if (pending + due > 0) ...[
                    const SizedBox(height: 15),
                    _AttentionBanner(pending: pending, due: due),
                  ],
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Lịch chụp của bạn',
                          style: TextStyle(
                            color: AppColors.obsidian,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        '${filtered.length} lịch',
                        style: const TextStyle(
                          color: AppColors.ash,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 11),
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
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (value) => setState(() => query = value),
                          decoration: InputDecoration(
                            hintText: 'Tìm tên khách, mã lịch...',
                            hintStyle: const TextStyle(
                              color: AppColors.ash,
                              fontSize: 12,
                            ),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              size: 19,
                            ),
                            prefixIconColor: AppColors.ash,
                            filled: true,
                            fillColor: AppColors.snow,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(13),
                              borderSide: const BorderSide(
                                color: AppColors.fog,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(13),
                              borderSide: const BorderSide(
                                color: AppColors.fog,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(13),
                              borderSide: const BorderSide(
                                color: AppColors.ember,
                              ),
                            ),
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
                  const SizedBox(height: 13),
                  if (filtered.isEmpty)
                    const _EmptyBookings()
                  else
                    for (final booking in filtered) ...[
                      BookingManagementCard(
                        booking: booking,
                        busy: decidingId == booking.id,
                        onDecide: (status) => _decide(booking, status),
                      ),
                      const SizedBox(height: 10),
                    ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AttentionBanner extends StatelessWidget {
  const _AttentionBanner({required this.pending, required this.due});

  final int pending;
  final int due;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF5EB),
      borderRadius: BorderRadius.circular(AppTokens.radiusInput),
      border: Border.all(color: const Color(0xFFFFE0C2)),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.notifications_active_outlined,
          size: 18,
          color: Color(0xFFB45C16),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text.rich(
            TextSpan(
              style: const TextStyle(
                color: Color(0xFF8F4C16),
                fontSize: 11,
                height: 1.35,
              ),
              children: [
                TextSpan(
                  text: '$pending yêu cầu chờ duyệt',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const TextSpan(text: '  ·  '),
                TextSpan(
                  text: '$due buổi cần giao ảnh',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
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

class _EmptyBookings extends StatelessWidget {
  const _EmptyBookings();

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 2),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
    decoration: BoxDecoration(
      color: AppColors.snow,
      borderRadius: BorderRadius.circular(AppTokens.radiusCard),
      border: Border.all(color: AppColors.fog),
    ),
    child: const Column(
      children: [
        Icon(Icons.event_busy_outlined, size: 30, color: AppColors.ash),
        SizedBox(height: 9),
        Text(
          'Không có lịch chụp phù hợp',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.graphite,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
