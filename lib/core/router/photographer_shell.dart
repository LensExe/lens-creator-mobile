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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (int index) => _onItemTapped(index, context),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.obsidian,
        unselectedItemColor: AppColors.steel,
        backgroundColor: AppColors.snow,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Lịch đặt',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            label: 'Gói chụp',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Tin nhắn',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Khác'),
        ],
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/photographer_home/bookings')) return 1;
    if (location.startsWith('/photographer_home/packages')) return 2;
    if (location.startsWith('/photographer_home/messages')) return 3;
    return 0; // Default to Dashboard (or when opening bottom sheet)
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
