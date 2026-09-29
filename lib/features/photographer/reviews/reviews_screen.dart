import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/review_item.dart';
import '../../../providers/data_providers.dart';

final _sampleReviews = [
  Review(
    id: 'me-r1',
    photographerId: 'me',
    authorName: 'Phạm Thu Hà',
    authorAvatar: '',
    rating: 5,
    comment: 'Buổi chụp rất thoải mái, ảnh ra đẹp hơn mong đợi. Sẽ quay lại lần sau!',
    date: '2026-09-20',
  ),
  Review(
    id: 'me-r2',
    photographerId: 'me',
    authorName: 'Ngô Bảo Long',
    authorAvatar: '',
    rating: 5,
    comment: 'Chụp có tâm, chỉnh sửa kỹ và giao ảnh đúng hẹn. Rất hài lòng.',
    date: '2026-09-15',
  ),
  Review(
    id: 'me-r3',
    photographerId: 'me',
    authorName: 'Đặng Mỹ Linh',
    authorAvatar: '',
    rating: 4,
    comment: 'Tư vấn góc chụp và trang phục rất nhiệt tình, kết quả ưng ý lắm.',
    date: '2026-09-02',
  ),
];

class ReviewsScreen extends ConsumerWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(myPhotographerProvider);
    final reviews = _sampleReviews
        .where((review) => review.photographerId == profile?.id)
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Đánh giá')),
      body: ListView(
        padding: AppTokens.pagePadding,
        children: [
          Text(
            profile == null
                ? 'Đánh giá của bạn'
                : '${profile.rating.toStringAsFixed(1)} ★ · ${profile.reviewCount} đánh giá',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          const Text(
            'Nhận xét từ khách hàng sau buổi chụp.',
            style: TextStyle(color: AppColors.steel),
          ),
          const SizedBox(height: 20),
          if (reviews.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Chưa có đánh giá nào.'),
              ),
            )
          else
            for (final (index, review) in reviews.indexed)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ReviewItemWidget(
                    review: review,
                    showDivider: index < reviews.length - 1,
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
