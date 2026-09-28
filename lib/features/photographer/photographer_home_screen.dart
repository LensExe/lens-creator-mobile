import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lens_creator_mobile/core/theme/app_colors.dart';
import 'package:lens_creator_mobile/core/widgets/lens_badge.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lens_creator_mobile/features/photographer/achievements/widgets/dashed_rect_painter.dart';

class PhotographerHomeScreen extends StatelessWidget {
  const PhotographerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data calculations
    int pendingCount = 2;
    int upcomingCount = 5;
    double revenue = 15500000;
    double rating = 4.9;
    int reviewCount = 120;

    final pendingRequests = [
      {
        'id': 'req-1',
        'clientName': 'Nguyễn Văn A',
        'date': '28/09/2026',
        'style': 'Chân dung',
        'avatar': 'https://i.pravatar.cc/150?img=11',
      },
      {
        'id': 'req-2',
        'clientName': 'Trần Thị B',
        'date': '02/10/2026',
        'style': 'Tiệc cưới',
        'avatar': 'https://i.pravatar.cc/150?img=5',
      },
    ];

    String formatCurrency(double amount) {
      if (amount >= 1000000) {
        return '${(amount / 1000000).toStringAsFixed(1)} Tr';
      }
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }

    return Scaffold(
      backgroundColor: AppColors.mist,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Header
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chào, Studio Ánh Sáng',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.obsidian,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Quản lý yêu cầu đặt lịch, hồ sơ và lịch trống của bạn.',
                  style: TextStyle(fontSize: 15, color: AppColors.steel),
                ),
              ],
            ).animate().fade().slideX(),

            const SizedBox(height: 32),

            // Stats Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.15,
              children: [
                StatCardWidget(
                      icon: Icons.account_balance_wallet_outlined,
                      value: formatCurrency(revenue),
                      label: 'Doanh thu',
                      iconColor: AppColors.ember,
                    )
                    .animate()
                    .fade(delay: 100.ms)
                    .scaleY(
                      curve: Curves.easeOutBack,
                      alignment: Alignment.bottomCenter,
                    ),
                StatCardWidget(
                      icon: Icons.inbox_outlined,
                      value: pendingCount.toString(),
                      label: 'Chờ duyệt',
                      iconColor: AppColors.obsidian,
                    )
                    .animate()
                    .fade(delay: 200.ms)
                    .scaleY(
                      curve: Curves.easeOutBack,
                      alignment: Alignment.bottomCenter,
                    ),
                StatCardWidget(
                      icon: Icons.calendar_month_outlined,
                      value: upcomingCount.toString(),
                      label: 'Sắp tới',
                      iconColor: AppColors.obsidian,
                    )
                    .animate()
                    .fade(delay: 300.ms)
                    .scaleY(
                      curve: Curves.easeOutBack,
                      alignment: Alignment.bottomCenter,
                    ),
                StatCardWidget(
                      icon: Icons.star_outline,
                      value: rating.toString(),
                      label: '$reviewCount đánh giá',
                      iconColor: Colors.orange,
                    )
                    .animate()
                    .fade(delay: 400.ms)
                    .scaleY(
                      curve: Curves.easeOutBack,
                      alignment: Alignment.bottomCenter,
                    ),
              ],
            ),

            const SizedBox(height: 32),

            // Shortcuts
            const Text(
              'Quản lý nhanh',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.obsidian,
              ),
            ).animate().fade(delay: 500.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
              children: [
                SmallShortcutWidget(
                  icon: Icons.inbox_outlined,
                  title: 'Đặt lịch',
                  onTap: () => context.go('/photographer_home/bookings'),
                ).animate().fade(delay: 600.ms),
                SmallShortcutWidget(
                  icon: Icons.category_outlined,
                  title: 'Gói chụp',
                  onTap: () => context.go('/photographer_home/packages'),
                ).animate().fade(delay: 650.ms),
                SmallShortcutWidget(
                  icon: Icons.storefront_outlined,
                  title: 'Shop',
                  onTap: () {},
                ).animate().fade(delay: 700.ms),
                SmallShortcutWidget(
                  icon: Icons.calendar_today_outlined,
                  title: 'Lịch trống',
                  onTap: () => context.push('/photographer_home/availability'),
                ).animate().fade(delay: 750.ms),
                SmallShortcutWidget(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Ví',
                  onTap: () => context.push('/photographer_home/wallet'),
                ).animate().fade(delay: 800.ms),
                SmallShortcutWidget(
                  icon: Icons.image_outlined,
                  title: 'Hồ sơ',
                  onTap: () => context.push('/photographer_home/portfolio'),
                ).animate().fade(delay: 850.ms),
                SmallShortcutWidget(
                  icon: Icons.emoji_events_outlined,
                  title: 'Thành tựu',
                  onTap: () => context.push('/photographer_home/achievements'),
                ).animate().fade(delay: 900.ms),
                SmallShortcutWidget(
                  icon: Icons.star_outline,
                  title: 'Đánh giá',
                  onTap: () => context.push('/photographer_home/reviews'),
                ).animate().fade(delay: 950.ms),
                SmallShortcutWidget(
                  icon: Icons.cloud_outlined,
                  title: 'Lưu trữ',
                  onTap: () => context.push('/photographer_home/storage'),
                ).animate().fade(delay: 1000.ms),
              ],
            ),

            const SizedBox(height: 32),

            // Pending Requests
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(
                      Icons.inbox_outlined,
                      color: AppColors.obsidian,
                      size: 22,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Yêu cầu mới cần duyệt',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.obsidian,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => context.go('/photographer_home/bookings'),
                  child: const Text(
                    'Tất cả →',
                    style: TextStyle(
                      color: AppColors.steel,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ).animate().fade(delay: 1000.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 16),

            if (pendingRequests.isEmpty)
              CustomPaint(
                painter: DashedRectPainter(
                  color: AppColors.steel,
                  strokeWidth: 1.5,
                  gap: 5,
                  radius: 20,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: const [
                      Icon(
                        Icons.inbox_outlined,
                        color: AppColors.steel,
                        size: 48,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Không có yêu cầu nào đang chờ',
                        style: TextStyle(
                          color: AppColors.obsidian,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Các yêu cầu đặt lịch mới từ khách hàng sẽ xuất hiện ở đây.',
                        style: TextStyle(color: AppColors.steel, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ).animate().fade(delay: 1100.ms).slideY(begin: 0.2, end: 0)
            else
              Column(
                children: pendingRequests.take(3).map((req) {
                  return RequestCardWidget(
                    clientName: req['clientName']!,
                    date: req['date']!,
                    style: req['style']!,
                    avatar: req['avatar']!,
                    onTap: () =>
                        context.push('/photographer_home/booking/${req['id']}'),
                  );
                }).toList(),
              ).animate().fade(delay: 1100.ms).slideY(begin: 0.2, end: 0),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class StatCardWidget extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;

  const StatCardWidget({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.pebble),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.obsidian,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.steel,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class SmallShortcutWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const SmallShortcutWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.snow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.pebble),
            ),
            child: Icon(icon, color: AppColors.obsidian, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.obsidian,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class RequestCardWidget extends StatelessWidget {
  final String clientName;
  final String date;
  final String style;
  final String avatar;
  final VoidCallback onTap;

  const RequestCardWidget({
    super.key,
    required this.clientName,
    required this.date,
    required this.style,
    required this.avatar,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.pebble),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(radius: 24, backgroundImage: NetworkImage(avatar)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        clientName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.obsidian,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: AppColors.steel,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            date,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.steel,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.camera_alt_outlined,
                            size: 12,
                            color: AppColors.steel,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              style,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.steel,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const LensBadge(text: 'Chờ duyệt', type: BadgeType.darkOverlay),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
