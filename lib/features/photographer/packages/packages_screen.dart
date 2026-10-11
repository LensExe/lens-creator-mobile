import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../providers/data_providers.dart';
import '../widgets/photographer_app_bar.dart';
import 'booking_plan_repository.dart';
import 'widgets/empty_packages_card.dart';
import 'widgets/package_card_item.dart';

class PackagesScreen extends ConsumerWidget {
  const PackagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(bookingPlansProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FA),
      appBar: const PhotographerAppBar(),
      body: ref.watch(authUserProvider) == null
          ? const Center(
              child: Text('Vui lòng đăng nhập tài khoản nhiếp ảnh gia'),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppTokens.contentMaxWidth,
                ),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
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
                    plans.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (error, _) => _PlansError(
                        message: '$error',
                        onRetry: () => ref.invalidate(bookingPlansProvider),
                      ),
                      data: (items) => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _PackageListHeading(count: items.length),
                          const SizedBox(height: 12),
                          if (items.isEmpty)
                            const EmptyPackagesCard()
                          else
                            for (final package in items)
                              PackageCardItem(package: package),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _PlansError extends StatelessWidget {
  const _PlansError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text('Không tải được gói dịch vụ: $message'),
      TextButton(onPressed: onRetry, child: const Text('Thử lại')),
    ],
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
