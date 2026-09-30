import 'package:flutter/material.dart';

import '../models/photographer_rank.dart';
import 'achievement_rank_tile.dart';
import 'achievement_section_heading.dart';

class AchievementRankSection extends StatelessWidget {
  const AchievementRankSection({
    super.key,
    required this.ranks,
    required this.currentRankIndex,
  });

  final List<PhotographerRank> ranks;
  final int currentRankIndex;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AchievementSectionHeading(
        title: 'Hành trình cấp bậc',
        subtitle: 'Theo dõi các cột mốc trên hành trình nghề nghiệp.',
        trailing: '${ranks.length} cấp độ',
      ),
      const SizedBox(height: 11),
      for (var index = 0; index < ranks.length; index++) ...[
        AchievementRankTile(
          rank: ranks[index],
          index: index,
          state: index < currentRankIndex
              ? RankTileState.achieved
              : index == currentRankIndex
              ? RankTileState.current
              : RankTileState.upcoming,
        ),
        if (index < ranks.length - 1) const SizedBox(height: 8),
      ],
    ],
  );
}
