import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';

class PackagePolicyCard extends StatelessWidget {
  const PackagePolicyCard({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF7F1),
      borderRadius: BorderRadius.circular(AppTokens.radiusCard),
      border: Border.all(color: const Color(0xFFFFE0CF)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.ember.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(
            Icons.verified_user_outlined,
            color: AppColors.ember,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cam kết chất lượng & dịch vụ',
                style: TextStyle(
                  color: AppColors.obsidian,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Số lượng ảnh và thời hạn giao là cam kết của buổi chụp. Lịch đã đặt giữ nguyên điều khoản khi bạn sửa gói.',
                style: TextStyle(
                  color: AppColors.steel,
                  fontSize: 10.5,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
