import '../../domain/models/review.dart';
import '../../features/photographer/reviews/review_repository.dart';
import '../datasources/mock/mock_review_data_source.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  const ReviewRepositoryImpl(this.dataSource);

  final MockReviewDataSource dataSource;

  @override
  Future<List<Review>> getPhotographerReviews(String photographerId) =>
      dataSource.getPhotographerReviews(photographerId);

  @override
  Future<ReviewSummary> getSummary({
    required String photographerId,
    required double average,
    required int total,
    required int fiveStarPercent,
  }) => dataSource.getSummary(
    average: average,
    total: total,
    fiveStarPercent: fiveStarPercent,
  );
}
