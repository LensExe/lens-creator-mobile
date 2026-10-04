import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class PackagePolicyCard extends StatelessWidget {
  const PackagePolicyCard({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFFFDBCF).withValues(alpha: 0.32),
      borderRadius: BorderRadius.circular(16),
    ),
    child: const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 34,
          height: 34,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xFFFFDBCF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.verified_user_outlined,
              color: Color(0xFF802900),
              size: 18,
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cam kết và ràng buộc gói chụp',
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 14,
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Số lượng ảnh và thời hạn giao là cam kết của buổi chụp. Lịch đã đặt giữ nguyên điều khoản khi bạn sửa gói.',
                style: TextStyle(
                  color: AppColors.steel,
                  fontSize: 12,
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
