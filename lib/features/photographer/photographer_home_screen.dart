import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../domain/booking_rules.dart';
import '../../domain/models/models.dart';
import '../../providers/data_providers.dart';
import 'bookings/widgets/collaboration_invites.dart';
import 'bookings/widgets/studio_booking_card.dart' show formatDong;
import 'home/widgets/home_booking_card.dart';
import 'home/widgets/home_metric_card.dart';
import 'home/widgets/home_section_header.dart';
import 'home/widgets/home_shortcut_card.dart';

class PhotographerHomeScreen extends ConsumerWidget {
  const PhotographerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(myPhotographerProvider);
    final state = ref.watch(incomingBookingsProvider);
    return Scaffold(
      backgroundColor: AppColors.mist,
      appBar: AppBar(
        toolbarHeight: 68,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.ember.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                color: AppColors.ember,
                size: 19,
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'LENS',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.1,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'CREATOR STUDIO',
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600,
                    color: AppColors.steel,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (profile != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton(
                tooltip: 'Cài đặt hồ sơ',
                onPressed: () => context.push('/photographer_home/settings'),
                icon: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.fog,
                  foregroundImage: profile.avatar.isEmpty
                      ? null
                      : NetworkImage(profile.avatar),
                  onForegroundImageError: profile.avatar.isEmpty
                      ? null
                      : (_, _) {},
                  child: Text(
                    profile.name.characters.first.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Không thể tải bảng điều khiển'),
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
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                children: [
                  _WelcomeHeader(
                    name: profile?.name ?? 'Nhiếp ảnh gia',
                    pendingCount: pending.length,
                    sessionsThisWeek: thisWeek,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: () => context.go(
                        pending.isNotEmpty
                            ? '/photographer_home/bookings'
                            : '/photographer_home/availability',
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.obsidian,
                        shape: const StadiumBorder(),
                        elevation: 1,
                      ),
                      icon: Icon(
                        pending.isNotEmpty
                            ? Icons.task_alt_rounded
                            : Icons.calendar_month_outlined,
                      ),
                      label: Text(
                        pending.isNotEmpty
                            ? 'Duyệt yêu cầu'
                            : 'Cập nhật lịch làm việc',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final aspect = constraints.maxWidth < 380 ? 1.34 : 1.48;
                      return GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: aspect,
                        children: [
                          HomeMetricCard(
                            label: 'Thu nhập tháng này',
                            value: formatDong(revenue),
                            icon: Icons.payments_outlined,
                          ),
                          HomeMetricCard(
                            label: 'Chờ duyệt',
                            value: '${pending.length}',
                            icon: Icons.notifications_active_outlined,
                            accent: AppColors.ember,
                          ),
                          HomeMetricCard(
                            label: 'Buổi chụp sắp tới',
                            value: '$thisWeek',
                            icon: Icons.event_available_outlined,
                          ),
                          HomeMetricCard(
                            label: 'Đánh giá',
                            value: profile == null
                                ? '—'
                                : '${profile.rating} ★',
                            icon: Icons.star_rounded,
                            accent: const Color(0xFFD58B00),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  const CollaborationInvites(),
                  HomeSectionHeader(
                    title: 'Yêu cầu mới cần duyệt',
                    count: pending.length,
                    onSeeAll: () => context.go('/photographer_home/bookings'),
                  ),
                  const SizedBox(height: 10),
                  if (pending.isEmpty)
                    const _EmptyCard(
                      icon: Icons.inbox_outlined,
                      message: 'Các yêu cầu đặt lịch mới sẽ xuất hiện ở đây.',
                    )
                  else
                    for (final booking in pending.take(3)) ...[
                      HomeBookingCard(
                        booking: booking,
                        onDecide: (status) => ref
                            .read(asyncBookingsProvider.notifier)
                            .updateBookingStatus(booking.id, status),
                      ),
                      const SizedBox(height: 10),
                    ],
                  const SizedBox(height: 12),
                  HomeSectionHeader(
                    title: 'Lịch chụp sắp tới',
                    onSeeAll: () => context.go('/photographer_home/bookings'),
                  ),
                  const SizedBox(height: 10),
                  if (upcoming.isEmpty)
                    const _EmptyCard(
                      icon: Icons.event_busy_outlined,
                      message: 'Chưa có buổi chụp nào đã chốt lịch.',
                    )
                  else
                    for (final booking in upcoming.take(3)) ...[
                      HomeBookingCard(booking: booking),
                      const SizedBox(height: 10),
                    ],
                  const SizedBox(height: 12),
                  Text(
                    'Quản lý Studio',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final aspect = constraints.maxWidth < 380 ? 2.05 : 2.55;
                      return GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: aspect,
                        children: [
                          HomeShortcutCard(
                            label: 'Hồ sơ năng lực',
                            icon: Icons.photo_library_outlined,
                            onTap: () =>
                                context.push('/photographer_home/portfolio'),
                          ),
                          HomeShortcutCard(
                            label: 'Gói dịch vụ',
                            icon: Icons.inventory_2_outlined,
                            onTap: () =>
                                context.go('/photographer_home/packages'),
                          ),
                          HomeShortcutCard(
                            label: 'Lịch làm việc',
                            icon: Icons.calendar_month_outlined,
                            onTap: () =>
                                context.push('/photographer_home/availability'),
                          ),
                          HomeShortcutCard(
                            label: 'Lưu trữ ảnh',
                            icon: Icons.cloud_outlined,
                            onTap: () =>
                                context.push('/photographer_home/storage'),
                          ),
                          HomeShortcutCard(
                            label: 'Tin nhắn',
                            icon: Icons.chat_bubble_outline,
                            onTap: () =>
                                context.go('/photographer_home/messages'),
                          ),
                          HomeShortcutCard(
                            label: 'Ví của tôi',
                            icon: Icons.account_balance_wallet_outlined,
                            onTap: () =>
                                context.push('/photographer_home/wallet'),
                          ),
                        ],
                      );
                    },
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

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({
    required this.name,
    required this.pendingCount,
    required this.sessionsThisWeek,
  });

  final String name;
  final int pendingCount;
  final int sessionsThisWeek;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.ember.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(AppTokens.radiusPill),
        ),
        child: const Text(
          'LENS STUDIO',
          style: TextStyle(
            color: AppColors.ember,
            fontSize: 10,
            letterSpacing: 1.1,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      const SizedBox(height: 12),
      Text(
        'Chào, $name 👋',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontSize: 26,
          height: 1.15,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.7,
        ),
      ),
      const SizedBox(height: 7),
      Text.rich(
        TextSpan(
          style: const TextStyle(
            fontSize: 13,
            height: 1.5,
            color: AppColors.steel,
          ),
          children: [
            if (pendingCount > 0) ...[
              const TextSpan(text: 'Bạn có '),
              TextSpan(
                text: '$pendingCount yêu cầu mới',
                style: const TextStyle(
                  color: AppColors.ember,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(
                text:
                    ' cần duyệt và $sessionsThisWeek buổi chụp trong 7 ngày tới.',
              ),
            ] else if (sessionsThisWeek > 0)
              TextSpan(
                text:
                    'Không có yêu cầu chờ duyệt · $sessionsThisWeek buổi chụp trong 7 ngày tới.',
              )
            else
              const TextSpan(
                text: 'Chưa có việc cần xử lý. Mở thêm khung giờ để nhận thêm khách.',
              ),
          ],
        ),
      ),
    ],
  );
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.snow,
      border: Border.all(color: AppColors.fog),
      borderRadius: BorderRadius.circular(AppTokens.radiusCard),
    ),
    child: Row(
      children: [
        Icon(icon, color: AppColors.ash),
        const SizedBox(width: 12),
        Expanded(
          child: Text(message, style: const TextStyle(color: AppColors.steel)),
        ),
      ],
    ),
  );
}
