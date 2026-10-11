import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../features/photographer/messages/conversation_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

class PhotographerShell extends ConsumerWidget {
  final Widget child;

  const PhotographerShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref
        .watch(conversationsProvider)
        .fold<int>(0, (sum, conversation) => sum + conversation.unreadCount);
    final selectedIndex = _calculateSelectedIndex(context);
    const destinations = [
      _NavDestination(LucideIcons.house, 'Trang chủ'),
      _NavDestination(LucideIcons.calendarDays, 'Lịch đặt'),
      _NavDestination(LucideIcons.camera, 'Gói chụp'),
      _NavDestination(LucideIcons.messageCircle, 'Tin nhắn'),
      _NavDestination(LucideIcons.menu, 'Khác'),
    ];

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xCCFFFFFF),
              border: Border(
                top: BorderSide(color: Color(0x99D4D4D8), width: 1),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 7, 8, 3),
                child: Row(
                  children: [
                    for (var index = 0; index < destinations.length; index++)
                      Expanded(
                        child: _PhotographerNavItem(
                          destination: destinations[index],
                          selected: selectedIndex == index,
                          unreadCount: index == 3 ? unread : 0,
                          onTap: () => _onItemTapped(index, context),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
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
      case 1:
        context.go('/photographer_home/bookings');
      case 2:
        context.go('/photographer_home/packages');
      case 3:
        context.go('/photographer_home/messages');
      case 4:
        context.go('/photographer_home/more');
    }
  }
}

class _NavDestination {
  final IconData icon;
  final String label;

  const _NavDestination(this.icon, this.label);
}

class _PhotographerNavItem extends StatelessWidget {
  final _NavDestination destination;
  final bool selected;
  final int unreadCount;
  final VoidCallback onTap;

  const _PhotographerNavItem({
    required this.destination,
    required this.selected,
    required this.unreadCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final labelColor = selected ? AppColors.obsidian : AppColors.steel;
    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 54,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    width: 36,
                    height: 27,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.ember.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppTokens.pillRadius),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      destination.icon,
                      size: 19,
                      color: selected ? AppColors.ember : labelColor,
                    ),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      top: -4,
                      right: -5,
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppColors.ember,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          unreadCount > 99 ? '99+' : '$unreadCount',
                          style: const TextStyle(
                            color: AppColors.snow,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                destination.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: labelColor,
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w700 : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
