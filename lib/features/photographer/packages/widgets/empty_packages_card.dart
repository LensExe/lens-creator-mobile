import 'package:flutter/material.dart';

import '../../../../core/widgets/creator_empty_state.dart';

class EmptyPackagesCard extends StatelessWidget {
  const EmptyPackagesCard({super.key});

  @override
  Widget build(BuildContext context) => const CreatorEmptyState(
    icon: Icons.photo_library_outlined,
    title: 'Chưa có gói dịch vụ',
    description: 'Tạo gói đầu tiên để khách có thể chọn khi đặt lịch.',
  );
}
