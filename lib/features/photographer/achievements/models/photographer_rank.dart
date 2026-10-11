class PhotographerRank {
  const PhotographerRank({
    required this.id,
    required this.code,
    required this.name,
    required this.minimumSessions,
    required this.commissionPercent,
  });

  final String id;
  final String code;
  final String name;
  final int minimumSessions;
  final int commissionPercent;
}

class PhotographerBadge {
  const PhotographerBadge({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.metric,
    required this.minimumValue,
    required this.minimumReviews,
    required this.isActive,
  });

  final String id;
  final String code;
  final String name;
  final String description;
  final String metric;
  final double minimumValue;
  final int minimumReviews;
  final bool isActive;
}
