import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_tokens.dart';
import '../../core/widgets/creator_avatar.dart';
import '../../providers/data_providers.dart';
import '../photographer/widgets/photographer_app_bar.dart';

class _ManagementItem {
  const _ManagementItem({
    required this.label,
    required this.path,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    this.badge,
  });

  final String label;
  final String path;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String? badge;
}

class MoreTabScreen extends ConsumerWidget {
  const MoreTabScreen({super.key});

  static const List<_ManagementItem> _items = [
    _ManagementItem(
      label: 'Gói dịch vụ',
      path: '/photographer_home/packages',
      icon: Icons.inventory_2_rounded,
      iconColor: Color(0xFF6366F1),
      bgColor: Color(0xFFEEF2FF),
    ),
    _ManagementItem(
      label: 'Lịch làm việc',
      path: '/photographer_home/availability',
      icon: Icons.calendar_month_rounded,
      iconColor: Color(0xFF2563EB),
      bgColor: Color(0xFFEFF6FF),
    ),
    _ManagementItem(
      label: 'Hồ sơ năng lực',
      path: '/photographer_home/portfolio',
      icon: Icons.photo_library_rounded,
      iconColor: Color(0xFF8B5CF6),
      bgColor: Color(0xFFF5F3FF),
    ),
    _ManagementItem(
      label: 'Lưu trữ ảnh',
      path: '/photographer_home/storage',
      icon: Icons.cloud_rounded,
      iconColor: Color(0xFF0284C7),
      bgColor: Color(0xFFF0F9FF),
    ),
    _ManagementItem(
      label: 'Thành tựu',
      path: '/photographer_home/achievements',
      icon: Icons.emoji_events_rounded,
      iconColor: Color(0xFFD97706),
      bgColor: Color(0xFFFFFBEB),
    ),
    _ManagementItem(
      label: 'Trợ lý AI',
      path: '/photographer_home/assistant',
      icon: Icons.auto_awesome_rounded,
      iconColor: Color(0xFFDB2777),
      bgColor: Color(0xFFFDF2F8),
      badge: 'Beta',
    ),
    _ManagementItem(
      label: 'Ví của tôi',
      path: '/photographer_home/wallet',
      icon: Icons.account_balance_wallet_rounded,
      iconColor: Color(0xFFFF5A00),
      bgColor: Color(0xFFFFF4EE),
    ),
    _ManagementItem(
      label: 'Cài đặt',
      path: '/photographer_home/settings',
      icon: Icons.settings_rounded,
      iconColor: Color(0xFF64748B),
      bgColor: Color(0xFFF1F5F9),
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authUserProvider);
    final profile = ref.watch(myPhotographerProvider);
    final displayName = profile?.name ?? user?.name ?? 'Nhiếp ảnh gia';
    final email = user?.email ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FA),
      appBar: const PhotographerAppBar(),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppTokens.contentMaxWidth,
          ),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              // Header
              const Text(
                'Studio của bạn',
                style: TextStyle(
                  color: Color(0xFF1A1C1D),
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),

              // Profile Card
              if (user != null)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE8E8ED)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x06000000),
                        blurRadius: 12,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => context.push('/photographer_home/settings'),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                CreatorAvatar(
                                  name: displayName,
                                  imageUrl: profile?.avatar,
                                  size: 52,
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          displayName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Color(0xFF1A1C1D),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    email,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFF71717A),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF4EE),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.verified_rounded,
                                          size: 11,
                                          color: Color(0xFFFF5A00),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'LENS Creator',
                                          style: TextStyle(
                                            color: Color(0xFFFF5A00),
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4F4F6),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 13,
                                color: Color(0xFF71717A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Section Quản lý Header
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'Quản lý',
                  style: TextStyle(
                    color: Color(0xFF1A1C1D),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Grouped Management Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE8E8ED)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x06000000),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    children: [
                      for (var i = 0; i < _items.length; i++) ...[
                        _buildRow(context, _items[i]),
                        if (i < _items.length - 1)
                          const Divider(
                            height: 1,
                            thickness: 1,
                            indent: 62,
                            endIndent: 16,
                            color: Color(0xFFF4F4F6),
                          ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // Logout Button
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () async {
                    try {
                      await ref.read(authUserProvider.notifier).logout();
                    } catch (error) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Đã đăng xuất trên thiết bị này, nhưng máy chủ chưa thể thu hồi phiên: $error',
                            ),
                          ),
                        );
                      }
                    }
                    if (!context.mounted) return;
                    context.go('/login');
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFEE2E2)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          size: 18,
                          color: Color(0xFFE11D48),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Đăng xuất',
                          style: TextStyle(
                            color: Color(0xFFE11D48),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, _ManagementItem item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(item.path),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: item.bgColor,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(item.icon, size: 20, color: item.iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  item.label,
                  style: const TextStyle(
                    color: Color(0xFF1A1C1D),
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (item.badge != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2.5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDF2F8),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFFBCFE8)),
                  ),
                  child: Text(
                    item.badge!,
                    style: const TextStyle(
                      color: Color(0xFFDB2777),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: Color(0xFFC4C4C8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
