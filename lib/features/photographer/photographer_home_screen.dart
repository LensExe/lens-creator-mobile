import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/creator_empty_state.dart';
import '../../core/widgets/creator_list_row.dart';
import '../../core/widgets/creator_page_header.dart';
import '../../core/widgets/creator_section_header.dart';
import '../../core/widgets/creator_summary_strip.dart';
import '../../domain/booking_rules.dart';
import '../../domain/models/models.dart';
import '../../providers/data_providers.dart';
import 'bookings/widgets/collaboration_invites.dart';
import 'bookings/widgets/studio_booking_card.dart' show formatDong;
import 'home/widgets/home_booking_card.dart';
import 'messages/conversation_navigation.dart';
import 'widgets/photographer_app_bar.dart';

class PhotographerHomeScreen extends ConsumerWidget {
  const PhotographerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(myPhotographerProvider);
    final state = ref.watch(incomingBookingsProvider);
    return Scaffold(
      backgroundColor: AppColors.snow,
      appBar: const PhotographerAppBar(),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => CreatorEmptyState(
          icon: Icons.cloud_off_outlined,
          title: 'Không thể tải trang chủ',
          actionLabel: 'Thử lại',
          onAction: () => ref.invalidate(asyncBookingsProvider),
        ),
        data: (bookings) {
          final today = DateUtils.dateOnly(DateTime.now());
          final weekEnd = today.add(const Duration(days: 7));
          final pending = bookings
              .where((b) => b.status == BookingStatus.pending)
              .toList();
          final upcoming = bookings.where((b) {
            final date = DateTime.tryParse(b.date);
            return (b.status == BookingStatus.confirmed ||
                    b.status == BookingStatus.held) &&
                date != null &&
                !date.isBefore(today);
          }).toList()..sort((a, b) => a.date.compareTo(b.date));
          final thisWeek = upcoming
              .where((b) => !DateTime.parse(b.date).isAfter(weekEnd))
              .length;
          final revenue = bookings
              .where((b) {
                final date = DateTime.tryParse(b.date);
                return b.status == BookingStatus.released &&
                    date != null &&
                    date.year == today.year &&
                    date.month == today.month;
              })
              .fold<int>(0, (sum, b) => sum + BookingRules.payout(b.price));
          final subtitle = pending.isNotEmpty
              ? '${pending.length} yêu cầu cần duyệt · $thisWeek buổi chụp trong 7 ngày tới.'
              : thisWeek > 0
              ? '$thisWeek buổi chụp trong 7 ngày tới.'
              : 'Chưa có việc cần xử lý. Cập nhật lịch để nhận thêm khách.';

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppTokens.contentMaxWidth,
              ),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 19, 16, 32),
                children: [
                  CreatorPageHeader(
                    title: 'Chào, ${profile?.name ?? 'Nhiếp ảnh gia'}',
                    subtitle: subtitle,
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => context.go(
                        pending.isNotEmpty
                            ? '/photographer_home/bookings'
                            : '/photographer_home/availability',
                      ),
                      icon: Icon(
                        pending.isNotEmpty
                            ? Icons.task_alt_rounded
                            : Icons.calendar_month_outlined,
                      ),
                      label: Text(
                        pending.isNotEmpty
                            ? 'Xử lý yêu cầu đặt lịch'
                            : 'Cập nhật lịch làm việc',
                      ),
                    ),
                  ),
                  const SizedBox(height: 27),
                  CreatorSectionHeader(
                    title: 'Cần duyệt',
                    count: pending.length,
                    actionLabel: 'Xem tất cả',
                    onAction: () => context.go('/photographer_home/bookings'),
                  ),
                  const SizedBox(height: 7),
                  const CollaborationInvites(),
                  if (pending.isEmpty)
                    const CreatorEmptyState(
                      icon: Icons.inbox_outlined,
                      title: 'Chưa có yêu cầu mới',
                      description: 'Yêu cầu đặt lịch sẽ xuất hiện tại đây.',
                    )
                  else
                    for (final booking in pending.take(3))
                      HomeBookingCard(
                        booking: booking,
                        onMessage: () =>
                            openClientConversation(context, ref, booking),
                        onDecide: (status) => ref
                            .read(asyncBookingsProvider.notifier)
                            .updateBookingStatus(booking.id, status),
                      ),
                  const SizedBox(height: 27),
                  CreatorSectionHeader(
                    title: 'Sắp tới',
                    actionLabel: 'Xem lịch đặt',
                    onAction: () => context.go('/photographer_home/bookings'),
                  ),
                  const SizedBox(height: 7),
                  if (upcoming.isEmpty)
                    const CreatorEmptyState(
                      icon: Icons.event_available_outlined,
                      title: 'Chưa có buổi chụp sắp tới',
                    )
                  else
                    for (final booking in upcoming.take(3))
                      HomeBookingCard(
                        booking: booking,
                        onMessage: () =>
                            openClientConversation(context, ref, booking),
                      ),
                  const SizedBox(height: 27),
                  const CreatorSectionHeader(title: 'Quản lý Studio'),
                  const SizedBox(height: 5),
                  CreatorListRow(
                    icon: Icons.calendar_month_outlined,
                    title: 'Lịch làm việc',
                    onTap: () =>
                        context.push('/photographer_home/availability'),
                  ),
                  CreatorListRow(
                    icon: Icons.photo_library_outlined,
                    title: 'Hồ sơ năng lực',
                    onTap: () => context.push('/photographer_home/portfolio'),
                  ),
                  CreatorListRow(
                    icon: Icons.inventory_2_outlined,
                    title: 'Gói dịch vụ',
                    onTap: () => context.go('/photographer_home/packages'),
                  ),
                  CreatorListRow(
                    icon: Icons.cloud_outlined,
                    title: 'Lưu trữ ảnh',
                    onTap: () => context.push('/photographer_home/storage'),
                  ),
                  CreatorListRow(
                    icon: Icons.chat_bubble_outline,
                    title: 'Tin nhắn',
                    onTap: () => context.go('/photographer_home/messages'),
                  ),
                  CreatorListRow(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Ví của tôi',
                    onTap: () => context.push('/photographer_home/wallet'),
                  ),
                  const SizedBox(height: 26),
                  const CreatorSectionHeader(title: 'Tổng quan'),
                  const SizedBox(height: 12),
                  CreatorSummaryStrip(
                    items: [
                      CreatorSummaryItem('Thu nhập tháng', formatDong(revenue)),
                      CreatorSummaryItem('Chờ duyệt', '${pending.length}'),
                      CreatorSummaryItem('Buổi chụp sắp tới', '$thisWeek'),
                      CreatorSummaryItem(
                        'Đánh giá',
                        profile == null ? '—' : '${profile.rating} ★',
                      ),
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
