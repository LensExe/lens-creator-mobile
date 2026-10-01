import '../../../domain/models/review.dart';

abstract interface class ReviewRepository {
  Future<List<Review>> getPhotographerReviews(String photographerId);

  Future<ReviewSummary> getSummary({
    required String photographerId,
    required double average,
    required int total,
    required int fiveStarPercent,
  });
}
