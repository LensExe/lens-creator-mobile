import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../domain/models/models.dart';
import '../../../providers/data_providers.dart';

const _ranks = [
  ('Tân binh', 0, 10),
  ('Thợ Đồng', 10, 9),
  ('Thợ Bạc', 30, 8),
  ('Thợ Vàng', 60, 7),
  ('Thợ Kim Cương', 120, 5),
];

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(myBookingsProvider);
    // The portal seed for the demo creator includes historical sessions that
    // are not listed in the current bookings feed.
    final historical = ref.watch(authUserProvider)?.id == 'me' ? 27 : 0;
    final sessions =
        historical +
        bookings.where((b) => b.status == BookingStatus.released).length;
    var rankIndex = 0;
    for (var i = 0; i < _ranks.length; i++) {
      if (sessions >= _ranks[i].$2) rankIndex = i;
    }
    final current = _ranks[rankIndex];
    final next = rankIndex + 1 < _ranks.length ? _ranks[rankIndex + 1] : null;
    final progress = next == null
        ? 1.0
        : (sessions - current.$2) / (next.$2 - current.$2);
    return Scaffold(
      appBar: AppBar(title: const Text('Thành tựu')),
      body: ListView(
        padding: AppTokens.pagePadding,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.emoji_events_outlined,
                    color: AppColors.ember,
                    size: 36,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    current.$1,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$sessions buổi chụp hoàn thành · Hoa hồng cấp bậc ${current.$3}%',
                  ),
                  if (next != null) ...[
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: progress,
                      color: AppColors.ember,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Còn ${next.$2 - sessions} buổi để lên ${next.$1}',
                      style: const TextStyle(color: AppColors.steel),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Hành trình cấp bậc',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          for (final rank in _ranks)
            Card(
              child: ListTile(
                leading: Icon(
                  sessions >= rank.$2 ? Icons.check_circle : Icons.lock_outline,
                  color: sessions >= rank.$2
                      ? AppColors.ember
                      : AppColors.steel,
                ),
                title: Text(rank.$1),
                subtitle: Text('${rank.$2} buổi chụp · Phí sàn ${rank.$3}%'),
              ),
            ),
          const SizedBox(height: 20),
          Text(
            'Huy hiệu chuyên môn',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          for (final badge in const [
            ('Phản hồi nhanh', 'Trả lời khách dưới 5 phút'),
            ('Đúng giờ tuyệt đối', 'Luôn có mặt đúng giờ hẹn'),
            ('Khách quay lại', 'Nhiều khách hàng đặt lại lần nữa'),
          ])
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.workspace_premium_outlined,
                  color: AppColors.ember,
                ),
                title: Text(badge.$1),
                subtitle: Text(badge.$2),
              ),
            ),
        ],
      ),
    );
  }
}
