import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_tokens.dart';
import '../../providers/data_providers.dart';

class MoreTabScreen extends ConsumerWidget {
  const MoreTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authUserProvider);
    const destinations = [
      ('Lịch làm việc', 'availability', Icons.calendar_month_outlined),
      ('Hồ sơ năng lực', 'portfolio', Icons.photo_library_outlined),
      ('Gói dịch vụ', 'packages', Icons.inventory_2_outlined),
      ('Lưu trữ ảnh', 'storage', Icons.cloud_outlined),
      ('Thành tựu', 'achievements', Icons.emoji_events_outlined),
      ('Trợ lý AI', 'assistant', Icons.auto_awesome_outlined),
      ('Ví của tôi', 'wallet', Icons.account_balance_wallet_outlined),
      ('Cài đặt', 'settings', Icons.settings_outlined),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Studio')),
      body: ListView(
        padding: AppTokens.pagePadding,
        children: [
          if (user != null)
            Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                title: Text(user.name),
                subtitle: Text(user.email),
              ),
            ),
          for (final (label, route, icon) in destinations)
            Card(
              child: ListTile(
                leading: Icon(icon),
                title: Text(label),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/photographer_home/$route'),
              ),
            ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              ref.read(authUserProvider.notifier).setUser(null);
              context.go('/login');
            },
            icon: const Icon(Icons.logout),
            label: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}
