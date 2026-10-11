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
        data: (reviews) => _content(context, ref, profile, reviews),
      ),
    );
  }

  Widget _content(
    BuildContext context,
    WidgetRef ref,
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
            for (final (index, review) in reviews.indexed) ...[
              ReviewItemWidget(review: review, showDivider: false),
              if (review.photographerReply?.trim().isNotEmpty == true)
                Padding(
                  padding: const EdgeInsets.only(left: 52, bottom: 8),
                  child: Text('Phản hồi của bạn: ${review.photographerReply}'),
                ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _reply(context, ref, review),
                  icon: const Icon(Icons.reply_outlined, size: 17),
                  label: Text(
                    review.photographerReply?.trim().isNotEmpty == true
                        ? 'Chỉnh sửa phản hồi'
                        : 'Trả lời đánh giá',
                  ),
                ),
              ),
              if (index < reviews.length - 1)
                const Divider(height: 24, color: AppColors.fog),
            ],
        ],
      ),
    ),
  );

  Future<void> _reply(
    BuildContext context,
    WidgetRef ref,
    Review review,
  ) async {
    final controller = TextEditingController(
      text: review.photographerReply ?? '',
    );
    final reply = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Phản hồi đánh giá'),
        content: TextField(
          controller: controller,
          minLines: 3,
          maxLines: 6,
          maxLength: 10000,
          decoration: const InputDecoration(hintText: 'Nhập phản hồi của bạn'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Gửi phản hồi'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (reply == null || !context.mounted) return;
    try {
      await ref.read(reviewRepositoryProvider).reply(review.id, reply);
      ref.invalidate(photographerReviewsProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Backend đã lưu phản hồi.')));
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể gửi phản hồi: $error')));
    }
  }
}
