import 'package:flutter/material.dart';
import 'package:lens_creator_mobile/core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_creator_mobile/providers/data_providers.dart';
import 'package:go_router/go_router.dart';

class MoreBottomSheet extends ConsumerWidget {
  const MoreBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: AppColors.snow,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.pebble,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.storefront_outlined,
                  color: AppColors.obsidian,
                ),
                title: const Text(
                  'Shop',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(
                  Icons.access_time,
                  color: AppColors.obsidian,
                ),
                title: const Text(
                  'Lịch trống',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/photographer_home/availability');
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppColors.obsidian,
                ),
                title: const Text(
                  'Ví của tôi',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/photographer_home/wallet');
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.image_outlined,
                  color: AppColors.obsidian,
                ),
                title: const Text(
                  'Hồ sơ năng lực',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/photographer_home/portfolio');
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.emoji_events_outlined,
                  color: AppColors.obsidian,
                ),
                title: const Text(
                  'Thành tựu',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/photographer_home/achievements');
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.star_outline,
                  color: AppColors.obsidian,
                ),
                title: const Text(
                  'Đánh giá',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/photographer_home/reviews');
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.cloud_outlined,
                  color: AppColors.obsidian,
                ),
                title: const Text(
                  'Lưu trữ ảnh',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/photographer_home/storage');
                },
              ),
              const Divider(color: AppColors.fog, height: 24),
              ExpansionTile(
                leading: const Icon(
                  Icons.help_outline,
                  color: AppColors.obsidian,
                ),
                title: const Text(
                  'Help and Support',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                childrenPadding: const EdgeInsets.only(left: 56),
                children: [
                  ListTile(title: const Text('Help centre'), onTap: () {}),
                  ListTile(title: const Text('Contact Lens'), onTap: () {}),
                  ListTile(title: const Text('Give feedback'), onTap: () {}),
                  ListTile(title: const Text('About Lens'), onTap: () {}),
                ],
              ),
              ExpansionTile(
                leading: const Icon(
                  Icons.person_outline,
                  color: AppColors.obsidian,
                ),
                title: const Text(
                  'Account',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                childrenPadding: const EdgeInsets.only(left: 56),
                children: [
                  ListTile(title: const Text('Personal profile'), onTap: () {}),
                  ListTile(title: const Text('Account security'), onTap: () {}),
                  ListTile(title: const Text('Bank account'), onTap: () {}),
                  ListTile(title: const Text('Communication'), onTap: () {}),
                  ListTile(title: const Text('Notification'), onTap: () {}),
                  ListTile(title: const Text('App setting'), onTap: () {}),
                ],
              ),
              const Divider(color: AppColors.fog, height: 32),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context); // Close sheet
                  ref.read(authUserProvider.notifier).setUser(null);
                  context.go('/');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
