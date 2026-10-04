import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/creator_avatar.dart';
import '../../../providers/data_providers.dart';
import 'widgets/empty_packages_card.dart';
import 'widgets/package_card_item.dart';
import 'widgets/package_policy_card.dart';

class PackagesScreen extends ConsumerWidget {
  const PackagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(myPhotographerProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FA),
      appBar: AppBar(
        toolbarHeight: 64,
        titleSpacing: 16,
        backgroundColor: const Color(0xFFF9F9FA),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.ember,
                borderRadius: BorderRadius.circular(AppTokens.radiusPill),
              ),
              child: const Icon(
                Icons.photo_camera_outlined,
                color: AppColors.snow,
                size: 19,
              ),
            ),
            const SizedBox(width: 9),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'LENS',
                        style: TextStyle(
                          color: AppColors.ink,
                          fontSize: 17,
                          height: 1.15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                      SizedBox(width: 6),
                      _StudioTag(),
                    ],
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Bảng quản lý dịch vụ',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.steel,
                      fontSize: 10,
                      height: 1.2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (profile != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton(
                tooltip: 'Cài đặt hồ sơ',
                onPressed: () => context.push('/photographer_home/settings'),
                icon: CreatorAvatar(
                  name: profile.name,
                  imageUrl: profile.avatar,
                  size: 36,
                ),
              ),
            ),
        ],
      ),
      body: profile == null
          ? const Center(
              child: Text('Vui lòng đăng nhập tài khoản nhiếp ảnh gia'),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppTokens.contentMaxWidth,
                ),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
                  children: [
                    const _PackagesPageHeader(),
                    const SizedBox(height: 22),
                    SizedBox(
                      height: 52,
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => context.push(
                          '/photographer_home/packages/edit/new',
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.ember,
                          foregroundColor: AppColors.snow,
                          elevation: 2,
                          shadowColor: AppColors.ember.withValues(alpha: 0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        icon: const Icon(Icons.add_rounded, size: 20),
                        label: const Text('Thêm gói chụp'),
                      ),
                    ),
                    const SizedBox(height: 25),
                    _PackageListHeading(count: profile.packages.length),
                    const SizedBox(height: 12),
                    if (profile.packages.isEmpty)
                      const EmptyPackagesCard()
                    else
                      for (final package in profile.packages)
                        PackageCardItem(package: package),
                    const SizedBox(height: 8),
                    const PackagePolicyCard(),
                  ],
                ),
              ),
            ),
    );
  }
}

class _StudioTag extends StatelessWidget {
  const _StudioTag();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
      color: AppColors.ember.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(AppTokens.radiusPill),
    ),
    child: const Text(
      'STUDIO',
      style: TextStyle(
        color: AppColors.ember,
        fontSize: 8,
        height: 1,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
      ),
    ),
  );
}

class _PackagesPageHeader extends StatelessWidget {
  const _PackagesPageHeader();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFFFDBCF),
          borderRadius: BorderRadius.circular(AppTokens.radiusPill),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.photo_camera_outlined,
              size: 14,
              color: Color(0xFF802900),
            ),
            SizedBox(width: 5),
            Text(
              'DỊCH VỤ & BẢNG GIÁ',
              style: TextStyle(
                color: Color(0xFF802900),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 11),
      const Text(
        'Gói dịch vụ',
        style: TextStyle(
          color: AppColors.ink,
          fontSize: 28,
          height: 1.15,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.7,
        ),
      ),
      const SizedBox(height: 5),
      const Text(
        'Các gói chụp khách có thể chọn khi đặt lịch.',
        style: TextStyle(color: AppColors.steel, fontSize: 14, height: 1.4),
      ),
    ],
  );
}

class _PackageListHeading extends StatelessWidget {
  const _PackageListHeading({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) => Wrap(
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: 8,
    children: [
      const Text(
        'Gói chụp của bạn',
        style: TextStyle(
          color: AppColors.ink,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.25,
        ),
      ),
      Container(
        width: 21,
        height: 21,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Color(0xFFE8E8E9),
          shape: BoxShape.circle,
        ),
        child: Text(
          '$count',
          style: const TextStyle(
            color: AppColors.graphite,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ],
  );
}
