import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class PackagePolicyCard extends StatelessWidget {
  const PackagePolicyCard({super.key});

  @override
  Widget build(BuildContext context) => const Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(Icons.verified_user_outlined, color: AppColors.steel, size: 19),
      SizedBox(width: 10),
      Expanded(
        child: Text(
          'Số lượng ảnh và thời hạn giao là cam kết của buổi chụp. Lịch đã đặt giữ nguyên điều khoản khi bạn sửa gói.',
          style: TextStyle(color: AppColors.steel, fontSize: 12, height: 1.45),
        ),
      ),
    ],
  );
}
