import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/creator_empty_state.dart';
import '../../../core/widgets/creator_list_row.dart';
import '../../../core/widgets/creator_media_surface.dart';
import '../../../providers/data_providers.dart';
import '../bookings/widgets/studio_booking_card.dart' show formatDong;

class PublicProfileScreen extends ConsumerWidget {
  const PublicProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(myPhotographerProvider);
    if (profile == null) {
      return const Scaffold(body: Center(child: Text('Không tìm thấy hồ sơ')));
    }
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.snow,
        appBar: AppBar(
          title: const Text('Xem hồ sơ công khai'),
          actions: [
            IconButton(
              tooltip: 'Chỉnh sửa hồ sơ',
              onPressed: () => context.push('/photographer_home/portfolio'),
              icon: const Icon(Icons.edit_outlined),
            ),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppTokens.contentMaxWidth,
            ),
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: AppTokens.pagePadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CreatorMediaSurface(
                          imageUrl: profile.cover,
                          height: 180,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          profile.name,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${profile.city} · ${profile.experienceYears} năm kinh nghiệm',
                          style: const TextStyle(
                            color: AppColors.steel,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${profile.rating.toStringAsFixed(1)} ★ · ${profile.reviewCount} đánh giá',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        if (profile.styles.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 7,
                            runSpacing: 7,
                            children: [
                              for (final style in profile.styles)
                                Chip(label: Text(style)),
                            ],
                          ),
                        ],
                        const SizedBox(height: 12),
                        Text(
                          'Giá từ ${formatDong(profile.pricePerSession)}',
                          style: const TextStyle(
                            color: AppColors.ember,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: TabBar(
                    tabs: [
                      Tab(text: 'Tác phẩm'),
                      Tab(text: 'Giới thiệu'),
                      Tab(text: 'Đánh giá'),
                    ],
                  ),
                ),
              ],
              body: TabBarView(
                children: [
                  profile.portfolio.isEmpty
                      ? const CreatorEmptyState(
                          icon: Icons.photo_library_outlined,
                          title: 'Chưa có tác phẩm',
                        )
                      : GridView.builder(
                          padding: AppTokens.pagePadding,
                          itemCount: profile.portfolio.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 0.8,
                              ),
                          itemBuilder: (context, index) => CreatorMediaSurface(
                            imageUrl: profile.portfolio[index],
                            radius: 14,
                            placeholderIcon: Icons.broken_image_outlined,
                          ),
                        ),
                  ListView(
                    padding: AppTokens.pagePadding,
                    children: [
                      Text(
                        profile.bio,
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Gói dịch vụ',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      for (final package in profile.packages) ...[
                        CreatorListRow(
                          icon: Icons.camera_alt_outlined,
                          title: package.name,
                          subtitle:
                              '${package.photoCount} ảnh · ${package.durationHours} giờ · giao ${package.deliveryDays} ngày',
                          trailing: Text(formatDong(package.price)),
                        ),
                        const Divider(height: 1),
                      ],
                    ],
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${profile.rating.toStringAsFixed(1)} ★ · ${profile.reviewCount} đánh giá',
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () =>
                              context.push('/photographer_home/reviews'),
                          child: const Text('Xem nhận xét'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
