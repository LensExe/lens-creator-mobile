import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/datasources/mock/mock_review_data_source.dart';
import '../../../data/repositories/review_repository_impl.dart';
import '../../../domain/models/review.dart';
import '../../../providers/data_providers.dart';
import 'review_repository.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>(
  (ref) => ReviewRepositoryImpl(MockReviewDataSource()),
);

final photographerReviewsProvider = FutureProvider<List<Review>>((ref) {
  final user = ref.watch(authUserProvider);
  if (user == null || user.role != 'photographer') {
    throw StateError('Vui lòng đăng nhập tài khoản nhiếp ảnh gia');
  }
  return ref.read(reviewRepositoryProvider).getPhotographerReviews(user.id);
});
