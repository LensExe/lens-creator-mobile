import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/creator_list_row.dart';
import '../../../providers/data_providers.dart';
import 'more_destinations.dart';

class MoreBottomSheet extends ConsumerWidget {
  const MoreBottomSheet({super.key});

  void _open(BuildContext context, String path) {
    final router = GoRouter.of(context);
    Navigator.pop(context);
    router.push(path);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => Material(
    color: AppColors.snow,
    borderRadius: const BorderRadius.vertical(
      top: Radius.circular(AppTokens.radiusSheet),
    ),
    child: SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.pebble,
                borderRadius: BorderRadius.circular(AppTokens.radiusPill),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Quản lý Studio',
            style: TextStyle(
              color: AppColors.obsidian,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          for (final destination in creatorMoreDestinations) ...[
            CreatorListRow(
              icon: destination.icon,
              title: destination.label,
              onTap: () => _open(context, destination.path),
            ),
            const Divider(),
          ],
          const SizedBox(height: 12),
          CreatorListRow(
            icon: Icons.logout_rounded,
            title: 'Đăng xuất',
            trailing: const SizedBox.shrink(),
            onTap: () {
              final router = GoRouter.of(context);
              Navigator.pop(context);
              ref.read(authUserProvider.notifier).setUser(null);
              router.go('/login');
            },
          ),
        ],
      ),
    ),
  );
}
