import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';

class StorageEmptyState extends StatelessWidget {
  const StorageEmptyState({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
    decoration: BoxDecoration(
      color: AppColors.snow,
      borderRadius: BorderRadius.circular(AppTokens.radiusCard),
      border: Border.all(color: AppColors.fog),
    ),
    child: const Column(
      children: [
        Icon(Icons.cloud_queue_outlined, size: 30, color: AppColors.ash),
        SizedBox(height: 9),
        Text(
          'Chưa có bộ sưu tập trong mục này',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.graphite,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
