import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../../data/repositories/api_review_repository.dart';
import '../../../domain/models/review.dart';
import '../../../providers/data_providers.dart';
import 'review_repository.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>(
  (ref) => ApiReviewRepository(ref.watch(dioProvider)),
);

final photographerReviewsProvider = FutureProvider<List<Review>>((ref) {
  final user = ref.watch(authUserProvider);
  final profile = ref.watch(myPhotographerProvider);
  if (user == null || user.role != 'photographer') {
    throw StateError('Vui lòng đăng nhập tài khoản nhiếp ảnh gia');
  }
  if (profile == null) throw StateError('Đang tải hồ sơ nhiếp ảnh gia.');
  return ref.read(reviewRepositoryProvider).getPhotographerReviews(profile.id);
});
