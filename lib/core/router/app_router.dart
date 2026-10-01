import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_creator_mobile/features/landing/ui_gallery_screen.dart';
import 'package:lens_creator_mobile/features/auth/login_screen.dart';
import 'package:lens_creator_mobile/features/splash/splash_screen.dart';
import 'package:lens_creator_mobile/features/photographer/photographer_home_screen.dart';
import 'package:lens_creator_mobile/features/photographer/photographer_bookings_screen.dart';
import 'package:lens_creator_mobile/features/photographer/booking_request_detail_screen.dart';
import 'package:lens_creator_mobile/features/shared/more_tab_screen.dart';

import 'photographer_shell.dart';

import 'package:lens_creator_mobile/features/photographer/packages/packages_screen.dart';
import 'package:lens_creator_mobile/features/photographer/packages/edit_package_screen.dart';
import 'package:lens_creator_mobile/features/photographer/availability/availability_screen.dart';
import 'package:lens_creator_mobile/features/photographer/portfolio/portfolio_screen.dart';
import 'package:lens_creator_mobile/features/photographer/portfolio/public_profile_screen.dart';
import 'package:lens_creator_mobile/features/photographer/messages/messages_list_screen.dart';
import 'package:lens_creator_mobile/features/photographer/messages/chat_detail_screen.dart';
import 'package:lens_creator_mobile/features/photographer/wallet/wallet_screen.dart';
import 'package:lens_creator_mobile/features/photographer/achievements/achievements_screen.dart';
import 'package:lens_creator_mobile/features/photographer/storage/storage_screen.dart';
import 'package:lens_creator_mobile/features/photographer/reviews/reviews_screen.dart';
import 'package:lens_creator_mobile/features/photographer/bookings/delivery_gallery_screen.dart';
import 'package:lens_creator_mobile/providers/data_providers.dart';
import 'package:lens_creator_mobile/features/photographer/assistant/assistant_screen.dart';
import 'package:lens_creator_mobile/features/photographer/settings/settings_screen.dart';
import 'package:lens_creator_mobile/features/photographer/availability/schedule_provider.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final user = ref.read(authUserProvider);
      final isPhotographerRoute = state.matchedLocation.startsWith(
        '/photographer_home',
      );
      if (isPhotographerRoute && user == null) {
        final requested = state.uri.toString();
        return '/login?from=${Uri.encodeComponent(requested)}';
      }
      if (isPhotographerRoute && user?.role != 'photographer') {
        return '/login?reason=photographer-only';
      }
      if (state.matchedLocation == '/login' && user?.role == 'photographer') {
        return '/photographer_home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/gallery',
        builder: (context, state) => const UiGalleryScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      ShellRoute(
        builder: (context, state, child) => PhotographerShell(child: child),
        routes: [
          GoRoute(
            path: '/photographer_home',
            builder: (context, state) => const PhotographerHomeScreen(),
          ),
          GoRoute(
            path: '/photographer_home/bookings',
            builder: (context, state) => const PhotographerBookingsScreen(),
          ),
          GoRoute(
            path: '/photographer_home/booking/:id',
            builder: (context, state) => BookingRequestDetailScreen(
              bookingId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/photographer_home/booking/:id/gallery',
            builder: (context, state) =>
                DeliveryGalleryScreen(bookingId: state.pathParameters['id']!),
          ),

          GoRoute(
            path: '/photographer_home/packages',
            builder: (context, state) => const PackagesScreen(),
          ),
          GoRoute(
            path: '/photographer_home/packages/edit/:id',
            builder: (context, state) =>
                EditPackageScreen(id: state.pathParameters['id']!),
          ),

          GoRoute(
            path: '/photographer_home/messages',
            builder: (context, state) => const MessagesListScreen(),
          ),

          GoRoute(
            path: '/photographer_home/more',
            builder: (context, state) => const MoreTabScreen(),
          ),
          GoRoute(
            path: '/photographer_home/portfolio',
            builder: (context, state) => const PortfolioScreen(),
          ),
          GoRoute(
            path: '/photographer_home/public_profile',
            builder: (context, state) => const PublicProfileScreen(),
          ),
          GoRoute(
            path: '/photographer_home/wallet',
            builder: (context, state) => const WalletScreen(),
          ),
          GoRoute(
            path: '/photographer_home/achievements',
            builder: (context, state) => const AchievementsScreen(),
          ),
          GoRoute(
            path: '/photographer_home/storage',
            builder: (context, state) => const StorageScreen(),
          ),
          GoRoute(
            path: '/photographer_home/availability',
            builder: (context, state) => const AvailabilityScreen(),
            onExit: (context, state) async {
              if (!ref.read(availabilityDirtyProvider)) return true;
              final discard = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Rời trang khi chưa lưu?'),
                  content: const Text(
                    'Các thay đổi lịch làm việc chưa được lưu sẽ bị bỏ. Khách vẫn thấy lịch cũ.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Ở lại'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Rời trang'),
                    ),
                  ],
                ),
              );
              if (discard == true) {
                ref.read(availabilityDirtyProvider.notifier).setDirty(false);
              }
              return discard ?? false;
            },
          ),
          GoRoute(
            path: '/photographer_home/reviews',
            builder: (context, state) => const ReviewsScreen(),
          ),
          GoRoute(
            path: '/photographer_home/assistant',
            builder: (context, state) => const AssistantScreen(),
          ),
          GoRoute(
            path: '/photographer_home/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/photographer_home/messages/:id',
            builder: (context, state) =>
                ChatDetailScreen(id: state.pathParameters['id']!),
          ),
        ],
      ),
    ],
  );
});
