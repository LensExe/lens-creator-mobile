import 'package:flutter/material.dart';

import '../../../../core/widgets/creator_summary_strip.dart';
import '../../../../domain/models/models.dart';

class PortfolioStatsCard extends StatelessWidget {
  const PortfolioStatsCard({super.key, required this.profile});

  final Photographer profile;

  @override
  Widget build(BuildContext context) => CreatorSummaryStrip(
    items: [
      CreatorSummaryItem('Tác phẩm', '${profile.portfolio.length}'),
      CreatorSummaryItem('Đánh giá', profile.rating.toStringAsFixed(1)),
      CreatorSummaryItem('Nhận xét', '${profile.reviewCount}'),
      CreatorSummaryItem('Kinh nghiệm', '${profile.experienceYears} năm'),
    ],
  );
}
