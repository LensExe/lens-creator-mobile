import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lens_creator_mobile/core/theme/app_colors.dart';
import 'package:lens_creator_mobile/core/widgets/review_item.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data
    final reviews = [
      Review(
        id: 'r1',
        photographerId: 'p1',
        authorName: 'Nguyễn Trần Vy',
        authorAvatar: 'https://i.pravatar.cc/150?img=1',
        rating: 5.0,
        comment: 'Anh chụp ảnh rất có tâm, nhiệt tình hướng dẫn tạo dáng. Bộ ảnh cưới của vợ chồng mình ra màu ưng ý lắm luôn! Sẽ giới thiệu cho bạn bè.',
        date: '2026-09-20T10:00:00Z',
      ),
      Review(
        id: 'r2',
        photographerId: 'p1',
        authorName: 'Lê Hoàng',
        authorAvatar: 'https://i.pravatar.cc/150?img=12',
        rating: 4.5,
        comment: 'Ảnh đẹp, giao file nhanh gọn. Tuy nhiên hôm chụp trời hơi nắng nên mặt mình hơi nhăn tí, nhưng photographer chỉnh sửa lại nhìn rất ổn.',
        date: '2026-09-15T14:30:00Z',
      ),
      Review(
        id: 'r3',
        photographerId: 'p1',
        authorName: 'Minh Anh',
        authorAvatar: '',
        rating: 5.0,
        comment: 'Dịch vụ tuyệt vời 10/10.',
        date: '2026-09-02T09:15:00Z',
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.snow,
      appBar: AppBar(
        backgroundColor: AppColors.snow,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.obsidian),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                const Text(
                  'Đánh giá',
                  style: TextStyle(
                    color: AppColors.obsidian,
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${reviews.length} nhận xét)',
                  style: const TextStyle(color: AppColors.steel, fontSize: 16),
                ),
              ],
            ).animate().fade().slideX(begin: -0.1),
            const SizedBox(height: 32),

            if (reviews.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Text(
                    'Chưa có đánh giá nào.',
                    style: TextStyle(color: AppColors.steel, fontSize: 15),
                  ),
                ),
              ).animate().fade()
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  return ReviewItemWidget(
                        review: reviews[index],
                        showDivider: index < reviews.length - 1,
                      )
                      .animate()
                      .fade(delay: (100 * index).ms)
                      .slideX(begin: 0.1, end: 0);
                },
              ),
          ],
        ),
      ),
    );
  }
}
