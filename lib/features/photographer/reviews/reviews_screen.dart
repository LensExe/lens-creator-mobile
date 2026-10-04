import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/creator_empty_state.dart';
import '../../../core/widgets/creator_loading_state.dart';
import '../../../core/widgets/creator_page_header.dart';
import '../../../core/widgets/review_item.dart';
import '../../../domain/models/review.dart';
import '../../../domain/models/models.dart';
import '../../../providers/data_providers.dart';
import 'review_provider.dart';

class ReviewsScreen extends ConsumerWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(myPhotographerProvider);
    final reviewState = ref.watch(photographerReviewsProvider);
    return Scaffold(
      backgroundColor: AppColors.mist,
      appBar: AppBar(title: const Text('Đánh giá')),
      body: reviewState.when(
        loading: () => const CreatorLoadingState(label: 'Đang tải đánh giá…'),
        error: (error, _) => CreatorEmptyState(
          icon: Icons.cloud_off_outlined,
          title: 'Không thể tải đánh giá',
          actionLabel: 'Thử lại',
          onAction: () => ref.invalidate(photographerReviewsProvider),
        ),
        data: (reviews) => _content(context, profile, reviews),
      ),
    );
  }

  Widget _content(
    BuildContext context,
    Photographer? profile,
    List<Review> reviews,
  ) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: AppTokens.contentMaxWidth),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 15, 16, 30),
        children: [
          CreatorPageHeader(
            title: profile == null
                ? 'Đánh giá của bạn'
                : '${profile.rating.toStringAsFixed(1)} ★',
            subtitle: profile == null
                ? 'Nhận xét từ khách hàng sau buổi chụp.'
                : '${profile.reviewCount} đánh giá · Nhận xét từ khách hàng sau buổi chụp.',
          ),
          const SizedBox(height: 25),
          if (reviews.isEmpty)
            const CreatorEmptyState(
              icon: Icons.rate_review_outlined,
              title: 'Chưa có đánh giá nào',
            )
          else
            for (final (index, review) in reviews.indexed)
              ReviewItemWidget(
                review: review,
                showDivider: index < reviews.length - 1,
              ),
        ],
      ),
    ),
  );
}
