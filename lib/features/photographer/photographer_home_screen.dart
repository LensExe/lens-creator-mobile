import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../domain/booking_rules.dart';
import '../../domain/models/models.dart';
import '../../providers/data_providers.dart';
import 'bookings/widgets/studio_booking_card.dart';
import 'bookings/widgets/collaboration_invites.dart';

class PhotographerHomeScreen extends ConsumerWidget {
  const PhotographerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(myPhotographerProvider);
    final state = ref.watch(incomingBookingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Lens Studio')),
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
          return ListView(
            padding: AppTokens.pagePadding,
            children: [
              Text(
                'Chào, ${profile?.name ?? 'Nhiếp ảnh gia'} 👋',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                pending.isNotEmpty
                    ? 'Bạn có ${pending.length} yêu cầu mới cần duyệt và $thisWeek buổi chụp trong 7 ngày tới.'
                    : thisWeek > 0
                    ? 'Không có yêu cầu chờ duyệt · $thisWeek buổi chụp trong 7 ngày tới.'
                    : 'Chưa có việc cần xử lý. Mở thêm khung giờ để nhận thêm khách.',
                style: const TextStyle(color: AppColors.steel),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go(
                  pending.isNotEmpty
                      ? '/photographer_home/bookings'
                      : '/photographer_home/availability',
                ),
                child: Text(
                  pending.isNotEmpty
                      ? 'Duyệt yêu cầu'
                      : 'Cập nhật lịch làm việc',
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Metric(
                    label: 'Thu nhập tháng này',
                    value: formatDong(revenue),
                  ),
                  _Metric(label: 'Chờ duyệt', value: '${pending.length}'),
                  _Metric(label: 'Buổi chụp sắp tới', value: '$thisWeek'),
                  _Metric(
                    label: 'Đánh giá',
                    value: profile == null ? '—' : '${profile.rating} ★',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const CollaborationInvites(),
              _SectionTitle(
                'Yêu cầu mới cần duyệt',
                onTap: () => context.go('/photographer_home/bookings'),
              ),
              const SizedBox(height: 8),
              if (pending.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Các yêu cầu đặt lịch mới sẽ xuất hiện ở đây.'),
                  ),
                )
              else
                for (final booking in pending.take(3))
                  StudioBookingCard(
                    booking: booking,
                    onDecide: (status) => ref
                        .read(asyncBookingsProvider.notifier)
                        .updateBookingStatus(booking.id, status),
                  ),
              const SizedBox(height: 20),
              _SectionTitle(
                'Lịch chụp sắp tới',
                onTap: () => context.go('/photographer_home/bookings'),
              ),
              const SizedBox(height: 8),
              if (upcoming.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Chưa có buổi chụp nào đã chốt lịch.'),
                  ),
                )
              else
                for (final booking in upcoming.take(3))
                  StudioBookingCard(booking: booking),
              const SizedBox(height: 20),
              Text(
                'Quản lý Studio',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              _Shortcut(
                'Hồ sơ năng lực',
                Icons.photo_library_outlined,
                () => context.push('/photographer_home/portfolio'),
              ),
              _Shortcut(
                'Gói dịch vụ',
                Icons.inventory_2_outlined,
                () => context.go('/photographer_home/packages'),
              ),
              _Shortcut(
                'Lịch làm việc',
                Icons.calendar_month_outlined,
                () => context.push('/photographer_home/availability'),
              ),
              _Shortcut(
                'Lưu trữ ảnh',
                Icons.cloud_outlined,
                () => context.push('/photographer_home/storage'),
              ),
              _Shortcut(
                'Tin nhắn',
                Icons.message_outlined,
                () => context.go('/photographer_home/messages'),
              ),
              _Shortcut(
                'Ví của tôi',
                Icons.account_balance_wallet_outlined,
                () => context.push('/photographer_home/wallet'),
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
  final String value;

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
          style: const TextStyle(fontSize: 11, color: AppColors.steel),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {required this.onTap});
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(title, style: Theme.of(context).textTheme.titleMedium),
      ),
      TextButton(onPressed: onTap, child: const Text('Tất cả')),
    ],
  );
}

class _Shortcut extends StatelessWidget {
  const _Shortcut(this.label, this.icon, this.onTap);
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: Icon(icon, color: AppColors.ember),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );
}
