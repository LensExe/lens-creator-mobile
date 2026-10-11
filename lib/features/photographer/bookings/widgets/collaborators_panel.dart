import 'package:flutter/material.dart';

import '../../../../domain/models/models.dart';

class CollaboratorsPanel extends StatelessWidget {
  const CollaboratorsPanel({super.key, required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) => const Card(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cộng tác viên'),
          SizedBox(height: 8),
          Text(
            'Backend hiện chưa có API mời cộng tác viên hoặc quản lý chia sẻ booking.',
          ),
        ],
      ),
    ),
  );
}
