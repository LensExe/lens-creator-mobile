import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../storage_provider.dart';

class StoragePlanCard extends StatelessWidget {
  const StoragePlanCard({
    super.key,
    required this.plan,
    required this.selected,
    required this.onChoose,
    this.busy = false,
  });

  final StoragePlan plan;
  final bool selected;
  final VoidCallback onChoose;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final retention = plan.retentionDays == null
        ? 'Lưu dài hạn khi duy trì gói'
        : 'Lưu ${plan.retentionDays} ngày';
    return Container(
      width: 224,
      height: 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        border: Border.all(
          color: selected ? AppColors.ember : AppColors.fog,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  plan.name,
                  style: const TextStyle(
                    color: AppColors.obsidian,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (selected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.ember,
                  size: 19,
                ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            plan.price,
            style: TextStyle(
              color: selected ? AppColors.ember : AppColors.graphite,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          _PlanDetail(
            icon: Icons.cloud_outlined,
            text: '${plan.quotaGb} GB mỗi buổi',
          ),
          const SizedBox(height: 7),
          _PlanDetail(icon: Icons.schedule_rounded, text: retention),
          const Spacer(),
          const SizedBox(height: 13),
          SizedBox(
            width: double.infinity,
            child: selected
                ? OutlinedButton(
                    onPressed: null,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 38),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                    child: const Text('Gói đang sử dụng'),
                  )
                : FilledButton(
                    onPressed: busy ? null : onChoose,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.obsidian,
                      minimumSize: const Size(0, 38),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                    child: Text(busy ? 'Đang cập nhật...' : 'Chọn gói này'),
                  ),
          ),
        ],
      ),
    );
  }
}

class _PlanDetail extends StatelessWidget {
  const _PlanDetail({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: AppColors.ash, size: 14),
      const SizedBox(width: 6),
      Expanded(
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.steel,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ],
  );
}
