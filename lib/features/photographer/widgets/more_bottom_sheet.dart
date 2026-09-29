import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/data_providers.dart';

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
    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
    child: SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'Lens Studio',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ),
          _item(
            context,
            'Lịch làm việc',
            Icons.calendar_month_outlined,
            'availability',
          ),
          _item(
            context,
            'Hồ sơ năng lực',
            Icons.photo_library_outlined,
            'portfolio',
          ),
          _item(context, 'Lưu trữ ảnh', Icons.cloud_outlined, 'storage'),
          _item(
            context,
            'Thành tựu',
            Icons.emoji_events_outlined,
            'achievements',
          ),
          _item(context, 'Trợ lý AI', Icons.auto_awesome_outlined, 'assistant'),
          _item(
            context,
            'Ví của tôi',
            Icons.account_balance_wallet_outlined,
            'wallet',
          ),
          _item(context, 'Cài đặt', Icons.settings_outlined, 'settings'),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.destructive),
            title: const Text('Đăng xuất'),
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

  Widget _item(
    BuildContext context,
    String title,
    IconData icon,
    String suffix,
  ) => ListTile(
    leading: Icon(icon, color: AppColors.obsidian),
    title: Text(title),
    trailing: const Icon(Icons.chevron_right, size: 18),
    onTap: () => _open(context, '/photographer_home/$suffix'),
  );
}
