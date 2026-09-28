import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/data_providers.dart';

class MoreTabScreen extends ConsumerWidget {
  const MoreTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authUserProvider);

    return Scaffold(
      backgroundColor: AppColors.mist,
      appBar: AppBar(
        backgroundColor: AppColors.snow,
        elevation: 0,
        title: const Text(
          'Tùy chọn khác',
          style: TextStyle(
            color: AppColors.obsidian,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // User Info Card
          if (user != null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.snow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.pebble),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.mist,
                    backgroundImage: user.role == 'photographer'
                        ? const NetworkImage(
                            'https://i.pravatar.cc/150?img=11',
                          ) // Mock photographer avatar
                        : null,
                    child: user.role == 'client'
                        ? const Icon(
                            Icons.person,
                            color: AppColors.steel,
                            size: 30,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.id == 'u1'
                              ? 'Nguyễn Văn Khách'
                              : (user.role == 'photographer'
                                    ? 'Nhiếp ảnh gia'
                                    : 'Người dùng'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.obsidian,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.role == 'client' ? 'Khách hàng' : 'Đối tác Lens',
                          style: const TextStyle(
                            color: AppColors.steel,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 32),

          if (user?.role == 'photographer') ...[
            _buildMenuSection('Nghiệp vụ', [
              _buildMenuItem(
                Icons.wallet,
                'Ví của tôi',
                () => context.go('/photographer_home/wallet'),
              ),
              _buildMenuItem(
                Icons.chat_bubble_outline,
                'Tin nhắn',
                () => context.go('/photographer_home/messages'),
              ),
              _buildMenuItem(
                Icons.emoji_events_outlined,
                'Thành tích',
                () => context.go('/photographer_home/achievements'),
              ),
            ]),
            const SizedBox(height: 24),
          ],

          // Menu Items
          _buildMenuSection('Cài đặt tài khoản', [
            _buildMenuItem(Icons.person_outline, 'Thông tin cá nhân', () {}),
            _buildMenuItem(Icons.lock_outline, 'Đổi mật khẩu', () {}),
            _buildMenuItem(
              Icons.notifications_outlined,
              'Cài đặt thông báo',
              () {},
            ),
          ]),

          const SizedBox(height: 24),

          _buildMenuSection('Hỗ trợ', [
            _buildMenuItem(Icons.help_outline, 'Trung tâm trợ giúp', () {}),
            _buildMenuItem(Icons.policy_outlined, 'Chính sách bảo mật', () {}),
            _buildMenuItem(Icons.star_outline, 'Đánh giá ứng dụng', () {}),
          ]),

          const SizedBox(height: 32),

          // Logout Button
          ElevatedButton(
            onPressed: () {
              _showLogoutConfirm(context, ref);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.snow,
              foregroundColor: Colors.red,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.red),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout, size: 20),
                SizedBox(width: 8),
                Text(
                  'Đăng xuất',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
          const Center(
            child: Text(
              'Phiên bản 1.0.0',
              style: TextStyle(color: AppColors.steel, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.steel,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.snow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.pebble),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.obsidian, size: 22),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.obsidian,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.steel,
        size: 20,
      ),
      onTap: onTap,
    );
  }

  void _showLogoutConfirm(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng?'),
        backgroundColor: AppColors.snow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: AppColors.steel)),
          ),
          TextButton(
            onPressed: () {
              // Perform logout first
              ref.read(authUserProvider.notifier).setUser(null);

              // Pop dialog and navigate using GoRouter
              Navigator.of(ctx).pop();
              GoRouter.of(context).go('/');
            },
            child: const Text(
              'Đăng xuất',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
