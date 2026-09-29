import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../providers/data_providers.dart';
import '../bookings/widgets/studio_booking_card.dart';

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
        appBar: AppBar(title: const Text('Xem hồ sơ công khai')),
        body: ListView(
          padding: AppTokens.pagePadding,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTokens.radiusCard),
              child: profile.cover.isEmpty
                  ? const SizedBox(
                      height: 160,
                      child: ColoredBox(
                        color: AppColors.fog,
                        child: Icon(Icons.photo_outlined),
                      ),
                    )
                  : Image.network(
                      profile.cover,
                      height: 160,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const SizedBox(
                        height: 160,
                        child: ColoredBox(
                          color: AppColors.fog,
                          child: Icon(Icons.photo_outlined),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            Text(
              profile.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            Text(
              '${profile.city} · ${profile.experienceYears} năm kinh nghiệm',
              style: const TextStyle(color: AppColors.steel),
            ),
            const SizedBox(height: 6),
            Text(
              '${profile.rating.toStringAsFixed(1)} ★ · ${profile.reviewCount} đánh giá',
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: [
                for (final style in profile.styles) Chip(label: Text(style)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Giá từ ${formatDong(profile.pricePerSession)}',
              style: const TextStyle(
                color: AppColors.ember,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            const TabBar(
              tabs: [
                Tab(text: 'Tác phẩm'),
                Tab(text: 'Giới thiệu'),
                Tab(text: 'Đánh giá'),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 420,
              child: TabBarView(
                children: [
                  profile.portfolio.isEmpty
                      ? const Center(child: Text('Chưa có tác phẩm'))
                      : GridView.builder(
                          itemCount: profile.portfolio.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 0.8,
                              ),
                          itemBuilder: (context, index) => ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.network(
                              profile.portfolio[index],
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const ColoredBox(
                                color: AppColors.fog,
                                child: Icon(Icons.broken_image_outlined),
                              ),
                            ),
                          ),
                        ),
                  ListView(
                    children: [
                      Text(profile.bio),
                      const SizedBox(height: 20),
                      Text(
                        'Gói dịch vụ',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      for (final package in profile.packages)
                        Card(
                          child: ListTile(
                            title: Text(package.name),
                            subtitle: Text(
                              '${package.photoCount} ảnh · ${package.durationHours} giờ · giao ${package.deliveryDays} ngày',
                            ),
                            trailing: Text(formatDong(package.price)),
                          ),
                        ),
                    ],
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${profile.rating.toStringAsFixed(1)} ★ · ${profile.reviewCount} đánh giá',
                        ),
                        const SizedBox(height: 8),
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
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.push('/photographer_home/portfolio'),
              child: const Text('Chỉnh sửa hồ sơ'),
            ),
          ],
        ),
      ),
    );
  }
}
