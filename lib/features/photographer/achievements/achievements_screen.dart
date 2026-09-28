import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lens_creator_mobile/core/theme/app_colors.dart';
import 'package:lens_creator_mobile/core/widgets/surface_card.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'widgets/dashed_rect_painter.dart';

class PhotographerAchievements {
  final String rank;
  final Stats stats;
  final double commissionRate;
  final List<String> earnedBadgeIds;

  PhotographerAchievements({
    required this.rank,
    required this.stats,
    required this.commissionRate,
    required this.earnedBadgeIds,
  });
}

class Stats {
  final int completedSessions;
  final double fiveStarPct;
  final int returningClients;
  final double cancelRate;

  Stats({
    required this.completedSessions,
    required this.fiveStarPct,
    required this.returningClients,
    required this.cancelRate,
  });
}

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data
    final data = PhotographerAchievements(
      rank: 'Bạc',
      stats: Stats(
        completedSessions: 15,
        fiveStarPct: 98.0,
        returningClients: 3,
        cancelRate: 0.0,
      ),
      commissionRate: 0.15,
      earnedBadgeIds: ['b1', 'b2'],
    );

    // Calculate progress
    // Bronze: 0-10, Silver: 11-50, Gold: 51+
    int nextLevelTarget = 50;
    int remaining = nextLevelTarget - data.stats.completedSessions;
    double progress = data.stats.completedSessions / nextLevelTarget;

    final badges = [
      {'id': 'b1', 'title': 'Tay Máy Vàng', 'desc': 'Hoàn thành 10 show chụp'},
      {
        'id': 'b2',
        'title': 'Ngôi Sao Đang Lên',
        'desc': 'Nhận được 10 đánh giá 5 sao',
      },
      {
        'id': 'b3',
        'title': 'Được Yêu Thích',
        'desc': 'Lưu vào danh sách yêu thích 50 lần',
      },
      {
        'id': 'b4',
        'title': 'Tốc Độ Ánh Sáng',
        'desc': 'Phản hồi trong vòng 5 phút (duy trì 1 tháng)',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.mist,
      appBar: AppBar(
        backgroundColor: AppColors.mist,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.obsidian),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          const Text(
            'Thành tựu',
            style: TextStyle(
              color: AppColors.obsidian,
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
          ).animate().fade().slideY(begin: -0.1),
          const SizedBox(height: 8),
          const Text(
            'Cấp bậc, huy hiệu và quyền lợi của bạn trên Lens.',
            style: TextStyle(color: AppColors.steel, fontSize: 15),
          ).animate().fade(delay: 100.ms).slideY(begin: -0.1),
          const SizedBox(height: 32),

          // Rank & Progress Card
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppColors.fog,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shield,
                        color: AppColors.obsidian,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hạng ${data.rank}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: AppColors.obsidian,
                            ),
                          ),
                          Text(
                            '${data.stats.completedSessions} buổi chụp đã hoàn thành',
                            style: const TextStyle(
                              color: AppColors.steel,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.trending_up,
                          size: 16,
                          color: AppColors.ember,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Còn $remaining buổi để lên Gold',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.obsidian,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.obsidian,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: progress),
                    duration: const Duration(seconds: 1),
                    curve: Curves.easeOut,
                    builder: (context, value, _) {
                      return LinearProgressIndicator(
                        value: value,
                        backgroundColor: AppColors.pebble,
                        color: AppColors.obsidian,
                        minHeight: 8,
                      );
                    },
                  ),
                ),
              ],
            ),
          ).animate().fade(delay: 200.ms).slideY(begin: 0.1),

          const SizedBox(height: 32),

          // Stats Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                '${data.stats.completedSessions}',
                'Buổi hoàn thành',
              ),
              _buildStatCard(
                '${data.stats.fiveStarPct.toInt()}%',
                'Đánh giá 5 sao',
              ),
              _buildStatCard(
                '${data.stats.returningClients}',
                'Khách quay lại',
              ),
              _buildStatCard('${data.stats.cancelRate.toInt()}%', 'Tỷ lệ hủy'),
            ],
          ).animate().fade(delay: 300.ms).slideY(begin: 0.1),

          const SizedBox(height: 32),

          // Rank Perks
          const Text(
            'Quyền lợi cấp bậc',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.obsidian,
            ),
          ).animate().fade(delay: 400.ms),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.mist,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildPerkRow(
                  Icons.percent,
                  'Phí hoa hồng nền tảng: ${(data.commissionRate * 100).toInt()}%',
                ),
                const SizedBox(height: 12),
                _buildPerkRow(
                  Icons.trending_up,
                  'Ưu tiên hiển thị trong tìm kiếm & gợi ý',
                ),
                const SizedBox(height: 12),
                _buildPerkRow(
                  Icons.support_agent,
                  'Hỗ trợ ưu tiên từ đội ngũ CSKH',
                ),
              ],
            ),
          ).animate().fade(delay: 500.ms),

          const SizedBox(height: 32),

          // Badges Grid
          const Text(
            'Huy hiệu chuyên môn',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.obsidian,
            ),
          ).animate().fade(delay: 600.ms),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemCount: badges.length,
            itemBuilder: (context, index) {
              final badge = badges[index];
              final isEarned = data.earnedBadgeIds.contains(badge['id']);
              return _buildBadgeItem(badge['title']!, badge['desc']!, isEarned)
                  .animate()
                  .fade(delay: (700 + index * 100).ms)
                  .scale(begin: const Offset(0.9, 0.9));
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.pebble),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.obsidian,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.steel),
          ),
        ],
      ),
    );
  }

  Widget _buildPerkRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.obsidian),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.obsidian,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeItem(String title, String desc, bool isEarned) {
    if (isEarned) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.snow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.pebble),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.verified, color: Colors.green, size: 36),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.obsidian,
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                desc,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: AppColors.steel),
              ),
            ),
          ],
        ),
      );
    } else {
      return Opacity(
        opacity: 0.6,
        child: CustomPaint(
          painter: DashedRectPainter(
            color: AppColors.steel,
            strokeWidth: 1.5,
            gap: 5,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock, color: AppColors.steel, size: 36),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.steel,
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: Text(
                    desc,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.steel,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
