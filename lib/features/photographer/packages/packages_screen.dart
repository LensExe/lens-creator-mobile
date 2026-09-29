import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../providers/data_providers.dart';
import '../bookings/widgets/studio_booking_card.dart';

class PackagesScreen extends ConsumerWidget {
  const PackagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(myPhotographerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Gói dịch vụ')),
      body: profile == null
          ? const Center(
              child: Text('Vui lòng đăng nhập tài khoản nhiếp ảnh gia'),
            )
          : ListView(
              padding: AppTokens.pagePadding,
              children: [
                const Text(
                  'Thiết lập các gói chụp khách có thể chọn khi đặt lịch.',
                ),
                const SizedBox(height: 16),
                Card(
                  color: const Color(0xFFFFF7ED),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Số lượng ảnh và thời hạn giao là cam kết của buổi chụp. Lịch đã đặt giữ nguyên điều khoản khi bạn sửa gói.',
                      style: const TextStyle(color: Color(0xFF9A3412)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (profile.packages.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Chưa có gói dịch vụ. Thêm gói để khách chọn khi đặt lịch.',
                      ),
                    ),
                  ),
                for (final package in profile.packages)
                  Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppTokens.radiusCard),
                      onTap: () => context.push(
                        '/photographer_home/packages/edit/${package.id}',
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    package.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium,
                                  ),
                                ),
                                const Icon(
                                  Icons.edit_outlined,
                                  size: 20,
                                  color: AppColors.steel,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              package.description,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${package.photoCount} ảnh · ${package.durationHours} giờ · giao trong ${package.deliveryDays} ngày',
                              style: const TextStyle(
                                color: AppColors.steel,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              formatDong(package.price),
                              style: const TextStyle(
                                color: AppColors.ember,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () =>
                      context.push('/photographer_home/packages/edit/new'),
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm gói dịch vụ'),
                ),
              ],
            ),
    );
  }
}
