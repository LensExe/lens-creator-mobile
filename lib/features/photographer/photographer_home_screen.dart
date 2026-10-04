import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/creator_empty_state.dart';
import '../../core/widgets/creator_list_row.dart';
import '../../core/widgets/creator_loading_state.dart';
import '../../core/widgets/creator_section_header.dart';
import '../../domain/models/models.dart';
import '../../providers/data_providers.dart';
import 'bookings/widgets/collaboration_invites.dart';
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
      backgroundColor: AppColors.mist,
      appBar: const PhotographerAppBar(),
      body: state.when(
        loading: () => const CreatorLoadingState(label: 'Đang tải công việc…'),
        error: (error, _) => CreatorEmptyState(
          icon: Icons.cloud_off_outlined,
          title: 'Không thể tải trang chủ',
          description: 'Kiểm tra kết nối rồi thử tải lại lịch đặt.',
          actionLabel: 'Thử lại',
          onAction: () => ref.invalidate(asyncBookingsProvider),
        ),
        data: (bookings) {
          final today = DateUtils.dateOnly(DateTime.now());
          final pending =
              bookings
                  .where((booking) => booking.status == BookingStatus.pending)
                  .toList()
                ..sort((a, b) {
                  final byDate = a.date.compareTo(b.date);
                  return byDate != 0
                      ? byDate
                      : (a.timeSlot ?? '').compareTo(b.timeSlot ?? '');
                });
          final upcoming =
              bookings.where((booking) {
                final date = DateTime.tryParse(booking.date);
                return (booking.status == BookingStatus.confirmed ||
                        booking.status == BookingStatus.held) &&
                    date != null &&
                    !DateUtils.dateOnly(date).isBefore(today);
              }).toList()..sort((a, b) {
                final byDate = a.date.compareTo(b.date);
                return byDate != 0
                    ? byDate
                    : (a.timeSlot ?? '').compareTo(b.timeSlot ?? '');
              });

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppTokens.contentMaxWidth,
              ),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
                children: [
                  _HomeGreeting(
                    name: profile?.name ?? 'Nhiếp ảnh gia',
                    city: profile?.city ?? '',
                    date: today,
                  ),
                  const SizedBox(height: 20),
                  _AttentionPanel(
                    count: pending.length,
                    onPressed: () => context.go(
                      pending.isNotEmpty
                          ? '/photographer_home/bookings'
                          : '/photographer_home/availability',
                    ),
                  ),
                  const SizedBox(height: 24),
                  CreatorSectionHeader(
                    title: 'Yêu cầu đặt lịch',
                    count: pending.length,
                    actionLabel: pending.isEmpty ? null : 'Xem tất cả',
                    onAction: pending.isEmpty
                        ? null
                        : () => context.go('/photographer_home/bookings'),
                  ),
                  const SizedBox(height: 8),
                  if (pending.isEmpty)
                    const CreatorEmptyState(
                      icon: Icons.inbox_outlined,
                      title: 'Chưa có yêu cầu cần duyệt',
                      description: 'Yêu cầu đặt lịch mới sẽ xuất hiện ở đây.',
                    )
                  else
                    for (final booking in pending.take(2))
                      HomeBookingCard(
                        booking: booking,
                        onMessage: () =>
                            openClientConversation(context, ref, booking),
                        onDecide: (status) => ref
                            .read(asyncBookingsProvider.notifier)
                            .updateBookingStatus(booking.id, status),
                      ),
                  const SizedBox(height: 15),
                  CreatorSectionHeader(
                    title: 'Lịch chụp tiếp theo',
                    actionLabel: upcoming.isEmpty ? null : 'Mở lịch đặt',
                    onAction: upcoming.isEmpty
                        ? null
                        : () => context.go('/photographer_home/bookings'),
                  ),
                  const SizedBox(height: 8),
                  if (upcoming.isEmpty)
                    const CreatorEmptyState(
                      icon: Icons.event_available_outlined,
                      title: 'Chưa có buổi chụp sắp tới',
                      description:
                          'Các lịch đã xác nhận sẽ được hiển thị tại đây.',
                    )
                  else
                    for (final booking in upcoming.take(2))
                      HomeBookingCard(
                        booking: booking,
                        onMessage: () =>
                            openClientConversation(context, ref, booking),
                      ),
                  const SizedBox(height: 8),
                  const CollaborationInvites(subdued: true),
                  const SizedBox(height: 14),
                  const _WorkspaceToolsHeading(),
                  const SizedBox(height: 7),
                  _WorkspaceLinks(
                    onAvailability: () =>
                        context.push('/photographer_home/availability'),
                    onPortfolio: () =>
                        context.push('/photographer_home/portfolio'),
                    onPackages: () => context.go('/photographer_home/packages'),
                    onMessages: () => context.go('/photographer_home/messages'),
                    onWallet: () => context.push('/photographer_home/wallet'),
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

class _HomeGreeting extends StatelessWidget {
  const _HomeGreeting({
    required this.name,
    required this.city,
    required this.date,
  });

  final String name;
  final String city;
  final DateTime date;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.ember,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'HÔM NAY  ·  ${DateFormat('dd/MM/yyyy').format(date)}',
            style: const TextStyle(
              color: AppColors.steel,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
      const SizedBox(height: 9),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              'Chào, $name',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 22,
                height: 1.15,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.6,
              ),
            ),
          ),
          if (city.trim().isNotEmpty) ...[
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 92),
              child: Text(
                city,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: const TextStyle(
                  color: AppColors.steel,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
      const SizedBox(height: 5),
      const Text(
        'Đây là những việc bạn cần xử lý hôm nay.',
        style: TextStyle(color: AppColors.steel, fontSize: 13, height: 1.4),
      ),
    ],
  );
}

class _WorkspaceToolsHeading extends StatelessWidget {
  const _WorkspaceToolsHeading();

  @override
  Widget build(BuildContext context) => const Text(
    'CÔNG CỤ LÀM VIỆC',
    style: TextStyle(
      color: AppColors.steel,
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 1,
    ),
  );
}

class _AttentionPanel extends StatelessWidget {
  const _AttentionPanel({required this.count, required this.onPressed});

  final int count;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.obsidian,
    borderRadius: BorderRadius.circular(22),
    child: InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 17, 14, 17),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.ember.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.inbox_outlined,
                color: AppColors.snow,
                size: 21,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    count == 0
                        ? 'Không có yêu cầu cần phản hồi'
                        : '$count yêu cầu đang chờ phản hồi',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.snow,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    count == 0
                        ? 'Cập nhật lịch nhận khách'
                        : 'Mở danh sách để phản hồi khách',
                    style: const TextStyle(
                      color: AppColors.pebble,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_rounded,
              color: AppColors.snow,
              size: 18,
            ),
          ],
        ),
      ),
    ),
  );
}

class _WorkspaceLinks extends StatelessWidget {
  const _WorkspaceLinks({
    required this.onAvailability,
    required this.onPortfolio,
    required this.onPackages,
    required this.onMessages,
    required this.onWallet,
  });

  final VoidCallback onAvailability;
  final VoidCallback onPortfolio;
  final VoidCallback onPackages;
  final VoidCallback onMessages;
  final VoidCallback onWallet;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(
      color: AppColors.snow,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.fog),
    ),
    child: Column(
      children: [
        CreatorListRow(
          icon: Icons.calendar_month_outlined,
          title: 'Lịch làm việc',
          onTap: onAvailability,
        ),
        const Divider(height: 1),
        CreatorListRow(
          icon: Icons.photo_library_outlined,
          title: 'Hồ sơ năng lực',
          onTap: onPortfolio,
        ),
        const Divider(height: 1),
        CreatorListRow(
          icon: Icons.inventory_2_outlined,
          title: 'Gói dịch vụ',
          onTap: onPackages,
        ),
        const Divider(height: 1),
        CreatorListRow(
          icon: Icons.chat_bubble_outline,
          title: 'Tin nhắn',
          onTap: onMessages,
        ),
        const Divider(height: 1),
        CreatorListRow(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Ví của tôi',
          onTap: onWallet,
        ),
      ],
    ),
  );
}
