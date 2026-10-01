import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../../features/photographer/widgets/more_bottom_sheet.dart';

class PhotographerShell extends StatelessWidget {
  final Widget child;

  const PhotographerShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (index) => _onItemTapped(index, context),
        height: 68,
        elevation: 0,
        backgroundColor: AppColors.snow,
        indicatorColor: AppColors.emberSoft,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: AppColors.ember),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(
              Icons.calendar_month_rounded,
              color: AppColors.ember,
            ),
            label: 'Lịch đặt',
          ),
          NavigationDestination(
            icon: Icon(Icons.photo_camera_outlined),
            selectedIcon: Icon(
              Icons.photo_camera_rounded,
              color: AppColors.ember,
            ),
            label: 'Gói chụp',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(
              Icons.chat_bubble_rounded,
              color: AppColors.ember,
            ),
            label: 'Tin nhắn',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view_rounded, color: AppColors.ember),
            label: 'Khác',
          ),
        ],
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/photographer_home/bookings') ||
        location.startsWith('/photographer_home/booking/')) {
      return 1;
    }
    if (location.startsWith('/photographer_home/packages')) return 2;
    if (location.startsWith('/photographer_home/messages')) return 3;
    if (const [
      '/photographer_home/more',
      '/photographer_home/portfolio',
      '/photographer_home/public_profile',
      '/photographer_home/wallet',
      '/photographer_home/achievements',
      '/photographer_home/storage',
      '/photographer_home/availability',
      '/photographer_home/reviews',
      '/photographer_home/assistant',
      '/photographer_home/settings',
    ].any(location.startsWith)) {
      return 4;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/photographer_home');
        break;
      case 1:
        context.go('/photographer_home/bookings');
        break;
      case 2:
        context.go('/photographer_home/packages');
        break;
      case 3:
        context.go('/photographer_home/messages');
        break;
      case 4:
        _showMoreMenu(context);
        break;
    }
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const MoreBottomSheet(),
    );
  }
}
