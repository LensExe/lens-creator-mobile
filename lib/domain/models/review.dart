class Review {
  const Review({
    required this.id,
    required this.photographerId,
    required this.authorName,
    required this.authorAvatar,
    required this.rating,
    required this.comment,
    required this.date,
  });

  final String id;
  final String photographerId;
  final String authorName;
  final String authorAvatar;
  final double rating;
  final String comment;
  final String date;
}

class ReviewSummary {
  const ReviewSummary({
    required this.average,
    required this.total,
    required this.breakdown,
  });

  final double average;
  final int total;
  final Map<int, int> breakdown;
}
