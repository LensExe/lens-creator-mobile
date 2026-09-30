import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../providers/data_providers.dart';
import '../widgets/photographer_app_bar.dart';
import 'widgets/empty_packages_card.dart';
import 'widgets/package_card_item.dart';
import 'widgets/package_policy_card.dart';

class PackagesScreen extends ConsumerWidget {
  const PackagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(myPhotographerProvider);
    return Scaffold(
      backgroundColor: AppColors.mist,
      appBar: const PhotographerAppBar(),
      body: profile == null
          ? const Center(
              child: Text('Vui lòng đăng nhập tài khoản nhiếp ảnh gia'),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Gói dịch vụ',
                                style: TextStyle(
                                  color: AppColors.obsidian,
                                  fontSize: 25,
                                  height: 1.15,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.6,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Thiết lập các gói chụp khách có thể chọn khi đặt lịch.',
                                style: TextStyle(
                                  color: AppColors.steel,
                                  fontSize: 12,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.snow,
                            borderRadius: BorderRadius.circular(
                              AppTokens.radiusPill,
                            ),
                            border: Border.all(color: AppColors.fog),
                          ),
                          child: Text(
                            '${profile.packages.length} gói',
                            style: const TextStyle(
                              color: AppColors.graphite,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 17),
                    const PackagePolicyCard(),
                    const SizedBox(height: 15),
                    if (profile.packages.isEmpty)
                      const EmptyPackagesCard()
                    else
                      for (final package in profile.packages) ...[
                        PackageCardItem(package: package),
                        const SizedBox(height: 11),
                      ],
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 50,
                      child: FilledButton.icon(
                        onPressed: () => context.push(
                          '/photographer_home/packages/edit/new',
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.ember,
                          foregroundColor: AppColors.snow,
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        icon: const Icon(Icons.add_circle_outline_rounded),
                        label: const Text(
                          'Thêm gói dịch vụ mới',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
