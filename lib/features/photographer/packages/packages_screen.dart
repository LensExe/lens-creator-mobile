import 'package:flutter/material.dart';
import 'package:lens_creator_mobile/core/theme/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'widgets/package_card_item.dart';

class PackagesScreen extends StatelessWidget {
  const PackagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock packages data
    final packages = [
      {
        'id': 'pkg-1',
        'title': 'Chụp ảnh thẻ chuyên nghiệp',
        'price': '150.000đ',
        'description': 'Bao gồm makeup nhẹ, chụp không giới hạn, PTS và in 4 tấm 3x4, 4 tấm 4x6.',
        'status': 'Hoạt động',
        'isActive': true,
      },
      {
        'id': 'pkg-2',
        'title': 'Ngoại cảnh cá nhân',
        'price': '800.000đ',
        'description': 'Gói chụp 2 tiếng tại 1 địa điểm nội thành. Giao 20 file chỉnh sửa kỹ, toàn bộ file gốc.',
        'status': 'Hoạt động',
        'isActive': true,
      },
      {
        'id': 'pkg-3',
        'title': 'Chụp Tiệc Cưới Truyền Thống',
        'price': '3.500.000đ / ngày',
        'description': '1 máy ảnh, bao trọn gói nhà trai - nhà gái và nhà hàng. Không giới hạn số lượng ảnh.',
        'status': 'Bản nháp',
        'isActive': false,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.mist,
      appBar: AppBar(
        backgroundColor: AppColors.snow,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Gói dịch vụ',
          style: TextStyle(
            color: AppColors.obsidian,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: 100,
        ), // extra padding bottom for FAB
        itemCount: packages.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final pkg = packages[index];
          return PackageCardItem(
                id: pkg['id'] as String,
                title: pkg['title'] as String,
                price: pkg['price'] as String,
                description: pkg['description'] as String,
                status: pkg['status'] as String,
                isActive: pkg['isActive'] as bool,
              )
              .animate()
              .fade(duration: 400.ms, delay: (index * 100).ms)
              .slideY(
                begin: 0.1,
                end: 0,
                duration: 400.ms,
                curve: Curves.easeOutQuad,
              );
        },
      ),
      floatingActionButton:
          FloatingActionButton(
            onPressed: () {
              // TODO: Mở màn hình tạo gói mới
            },
            backgroundColor: AppColors.obsidian,
            elevation: 4,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: AppColors.snow),
          ).animate().scale(
            delay: 400.ms,
            duration: 300.ms,
            curve: Curves.easeOutBack,
          ),
    );
  }
}
