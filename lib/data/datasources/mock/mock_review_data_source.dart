import '../../../domain/models/review.dart';

class MockReviewDataSource {
  static const _delay = Duration(milliseconds: 300);
  static const _reviewers = [
    'Phạm Thu Hà',
    'Ngô Bảo Long',
    'Đặng Mỹ Linh',
    'Bùi Quang Huy',
    'Vũ Khánh Vy',
    'Hoàng Anh Tuấn',
    'Lý Thảo Nhi',
    'Trịnh Văn Nam',
    'Đỗ Phương Anh',
    'Cao Minh Đức',
  ];
  static const _comments = [
    'Buổi chụp rất thoải mái, ảnh ra đẹp hơn mong đợi. Sẽ quay lại lần sau!',
    'Anh/chị chụp có tâm, chỉnh sửa kỹ và giao ảnh đúng hẹn. Rất hài lòng.',
    'Tư vấn góc chụp và trang phục rất nhiệt tình, kết quả ưng ý lắm.',
    'Ảnh tự nhiên, màu đẹp, không bị gượng. Mình giới thiệu cho bạn bè luôn.',
    'Chuyên nghiệp từ khâu liên hệ đến lúc nhận ảnh. Đáng đồng tiền.',
    'Rất kiên nhẫn với bé nhà mình, bắt được nhiều khoảnh khắc dễ thương.',
    'Chất lượng ảnh tốt, bố cục chắc tay. Chỉ tiếc là hơi ít ảnh hậu trường.',
    'Đúng phong cách mình thích, nhẹ nhàng mà vẫn cuốn. 10 điểm!',
  ];

  int _hash(String value) => value.codeUnits.fold<int>(
    0,
    (hash, unit) => (hash * 31 + unit) & 0x7fffffff,
  );

  String _avatar(String seed) {
    final hash = _hash(seed);
    final gender = hash.isEven ? 'men' : 'women';
    return 'https://randomuser.me/api/portraits/$gender/${hash % 100}.jpg';
  }

  String _date(int daysAgo) {
    final now = DateTime.now();
    final date = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: daysAgo));
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<List<Review>> getPhotographerReviews(String photographerId) async {
    await Future.delayed(_delay);
    if (photographerId != 'me') return const [];
    const profileRating = 4.9;
    const profileIndex = 0;
    const count = 3 + (profileIndex % 3);
    return [
      for (var index = 0; index < count; index++)
        Review(
          id: '$photographerId-r${index + 1}',
          photographerId: photographerId,
          authorName:
              _reviewers[(profileIndex * 5 + index) % _reviewers.length],
          authorAvatar: _avatar('reviewer-${profileIndex * 5 + index}'),
          rating: (profileRating.round() - (index % 2)).toDouble(),
          comment: _comments[(profileIndex * 5 + index) % _comments.length],
          date: _date((index + 1) * 9 + (profileIndex % 7)),
        ),
    ];
  }

  Future<ReviewSummary> getSummary({
    required double average,
    required int total,
    required int fiveStarPercent,
  }) async {
    await Future.delayed(_delay);
    final five = (total * fiveStarPercent / 100).round();
    final rest = total - five;
    final four = (rest * 0.75).round();
    final three = (rest * 0.17).round();
    final two = (rest * 0.05).round();
    final one = (rest - four - three - two).clamp(0, total);
    return ReviewSummary(
      average: average,
      total: total,
      breakdown: {5: five, 4: four, 3: three, 2: two, 1: one},
    );
  }
}
