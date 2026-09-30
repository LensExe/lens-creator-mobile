import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';

class EmptyPackagesCard extends StatelessWidget {
  const EmptyPackagesCard({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 27),
    decoration: BoxDecoration(
      color: AppColors.snow,
      borderRadius: BorderRadius.circular(AppTokens.radiusCard),
      border: Border.all(color: AppColors.fog),
    ),
    child: const Column(
      children: [
        Icon(Icons.photo_library_outlined, size: 30, color: AppColors.ash),
        SizedBox(height: 9),
        Text(
          'Chưa có gói dịch vụ',
          style: TextStyle(
            color: AppColors.obsidian,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Tạo gói đầu tiên để khách có thể chọn khi đặt lịch.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.steel, fontSize: 11, height: 1.4),
        ),
      ],
    ),
  );
}
