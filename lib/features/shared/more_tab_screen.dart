import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/creator_avatar.dart';
import '../../core/widgets/creator_list_row.dart';
import '../../core/widgets/creator_page_header.dart';
import '../../core/widgets/creator_section_header.dart';
import '../../providers/data_providers.dart';
import '../photographer/widgets/more_destinations.dart';

class MoreTabScreen extends ConsumerWidget {
  const MoreTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authUserProvider);
    return Scaffold(
      backgroundColor: AppColors.snow,
      appBar: AppBar(title: const Text('Studio')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppTokens.contentMaxWidth,
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              const CreatorPageHeader(title: 'Studio của bạn'),
              if (user != null) ...[
                const SizedBox(height: 21),
                Row(
                  children: [
                    CreatorAvatar(name: user.name, size: 48),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              color: AppColors.obsidian,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            user.email,
                            style: const TextStyle(
                              color: AppColors.steel,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 27),
              const CreatorSectionHeader(title: 'Quản lý'),
              const SizedBox(height: 5),
              for (final destination in [
                const CreatorDestination(
                  'Gói dịch vụ',
                  '/photographer_home/packages',
                  Icons.inventory_2_outlined,
                ),
                ...creatorMoreDestinations,
              ]) ...[
                CreatorListRow(
                  icon: destination.icon,
                  title: destination.label,
                  onTap: () => context.push(destination.path),
                ),
                const Divider(),
              ],
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () {
                  ref.read(authUserProvider.notifier).setUser(null);
                  context.go('/login');
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Đăng xuất'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
