import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_tokens.dart';
import '../../core/widgets/creator_empty_state.dart';
import '../../core/widgets/creator_loading_state.dart';
import '../../domain/models/models.dart';
import '../../providers/data_providers.dart';
import 'bookings/widgets/collaboration_invites.dart';
import 'home/widgets/home_booking_card.dart';
import 'messages/conversation_navigation.dart';
import 'messages/conversation_provider.dart';
import 'wallet/wallet_provider.dart';
import 'widgets/photographer_app_bar.dart';

class PhotographerHomeScreen extends ConsumerWidget {
  const PhotographerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(myPhotographerProvider);
    final state = ref.watch(incomingBookingsProvider);
    final unreadMessages = ref
        .watch(conversationsProvider)
        .fold<int>(
          0,
          (total, conversation) => total + conversation.unreadCount,
        );
    final walletBalance = ref
        .watch(walletProvider)
        .whenOrNull(
          data: (entries) =>
              entries.fold<int>(0, (total, entry) => total + entry.amount),
        );

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F9),
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
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Flexible(
                              child: Text(
                                'Yêu cầu đặt lịch',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Color(0xFF1A1C1D),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                            if (pending.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF5A00),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  '${pending.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    height: 1.1,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (pending.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () =>
                              context.go('/photographer_home/bookings'),
                          child: const Text(
                            'Xem tất cả',
                            style: TextStyle(
                              color: Color(0xFFA83900),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
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
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: const [
                            Icon(
                              Icons.calendar_month_outlined,
                              size: 18,
                              color: Color(0xFF1A1C1D),
                            ),
                            SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Lịch chụp tiếp theo',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Color(0xFF1A1C1D),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (upcoming.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () =>
                              context.go('/photographer_home/bookings'),
                          child: const Text(
                            'Mở lịch đặt',
                            style: TextStyle(
                              color: Color(0xFFA83900),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
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
                  const SizedBox(height: 10),
                  const CollaborationInvites(subdued: true),
                  const SizedBox(height: 20),
                  const _WorkspaceToolsHeading(),
                  const SizedBox(height: 10),
                  _WorkspaceLinks(
                    unreadMessages: unreadMessages,
                    walletBalance: walletBalance,
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
  Widget build(BuildContext context) {
    final cityDisplay = city.trim().isNotEmpty ? city.trim() : 'Hà Nội';
    final dateDisplay = 'Hôm nay · ${DateFormat("dd 'Tháng' MM").format(date)}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFFFF5A00),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              dateDisplay,
              style: const TextStyle(
                color: Color(0xFF8E8D91),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Text(
                'Chào, $name',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF1A1C1D),
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$cityDisplay · 28°C',
              style: const TextStyle(
                color: Color(0xFF737278),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Đây là những việc bạn cần xử lý hôm nay.',
          style: TextStyle(
            color: Color(0xFF6B696F),
            fontSize: 13,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _WorkspaceToolsHeading extends StatelessWidget {
  const _WorkspaceToolsHeading();

  @override
  Widget build(BuildContext context) => const Text(
    'CÔNG CỤ LÀM VIỆC',
    style: TextStyle(
      color: Color(0xFF8E8D91),
      fontSize: 14,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.8,
    ),
  );
}

class _AttentionPanel extends StatelessWidget {
  const _AttentionPanel({required this.count, required this.onPressed});

  final int count;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xFF1D1F21),
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.pending_actions_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          count == 0
                              ? 'Không có yêu cầu cần phản hồi'
                              : '$count yêu cầu đang chờ phản hồi',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (count > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF5A00),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    count == 0
                        ? 'Cập nhật lịch nhận khách'
                        : 'Chạm để duyệt nhanh danh sách',
                    style: const TextStyle(
                      color: Color(0xFFA1A1AA),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_rounded,
              color: Color(0xFFD4D4D8),
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
    required this.unreadMessages,
    required this.walletBalance,
    required this.onAvailability,
    required this.onPortfolio,
    required this.onPackages,
    required this.onMessages,
    required this.onWallet,
  });

  final int unreadMessages;
  final int? walletBalance;
  final VoidCallback onAvailability;
  final VoidCallback onPortfolio;
  final VoidCallback onPackages;
  final VoidCallback onMessages;
  final VoidCallback onWallet;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE7E5E4)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x05000000),
          blurRadius: 3,
          offset: Offset(0, 1),
        ),
      ],
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(
      children: [
        _ToolRow(
          icon: Icons.calendar_month_outlined,
          title: 'Lịch làm việc',
          onTap: onAvailability,
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFF2F1F3)),
        _ToolRow(
          icon: Icons.photo_library_outlined,
          title: 'Hồ sơ năng lực',
          onTap: onPortfolio,
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFF2F1F3)),
        _ToolRow(
          icon: Icons.style_outlined,
          title: 'Gói dịch vụ',
          onTap: onPackages,
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFF2F1F3)),
        _ToolRow(
          icon: Icons.chat_bubble_outline_rounded,
          title: 'Tin nhắn',
          trailing: unreadMessages > 0
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5A00),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$unreadMessages mới',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              : null,
          onTap: onMessages,
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFF2F1F3)),
        _ToolRow(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Ví của tôi',
          trailing: walletBalance != null
              ? Text(
                  '${NumberFormat.decimalPattern('vi').format(walletBalance)} đ',
                  style: const TextStyle(
                    color: Color(0xFF1A1C1D),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                )
              : null,
          onTap: onWallet,
        ),
      ],
    ),
  );
}

class _ToolRow extends StatelessWidget {
  const _ToolRow({
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF5F5E60)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF1A1C1D),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailing != null) ...[trailing!, const SizedBox(width: 8)],
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: Color(0xFFAAA9AE),
            ),
          ],
        ),
      ),
    ),
  );
}
