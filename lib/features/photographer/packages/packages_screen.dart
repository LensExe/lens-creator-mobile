import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/creator_page_header.dart';
import '../../../core/widgets/creator_section_header.dart';
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
                constraints: const BoxConstraints(
                  maxWidth: AppTokens.contentMaxWidth,
                ),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
                  children: [
                    const CreatorPageHeader(
                      title: 'Gói dịch vụ',
                      subtitle: 'Các gói chụp khách có thể chọn khi đặt lịch.',
                    ),
                    const SizedBox(height: 17),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => context.push(
                          '/photographer_home/packages/edit/new',
                        ),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Thêm gói chụp'),
                      ),
                    ),
                    const SizedBox(height: 27),
                    CreatorSectionHeader(
                      title: 'Gói chụp của bạn',
                      count: profile.packages.length,
                    ),
                    const SizedBox(height: 7),
                    if (profile.packages.isEmpty)
                      const EmptyPackagesCard()
                    else
                      for (final package in profile.packages)
                        PackageCardItem(package: package),
                    const SizedBox(height: 25),
                    const PackagePolicyCard(),
                  ],
                ),
              ),
            ),
    );
  }
}
