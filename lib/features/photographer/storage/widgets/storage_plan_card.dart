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
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        border: Border.all(
          color: selected ? AppColors.ember : AppColors.fog,
          width: selected ? 1.5 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 9,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 39,
                height: 39,
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFFFFE7DE)
                      : const Color(0xFFF1F1F2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  plan.tier == StorageTier.studio
                      ? Icons.cloud_done_outlined
                      : Icons.cloud_outlined,
                  color: selected ? AppColors.ember : AppColors.graphite,
                  size: 20,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            plan.name,
                            style: const TextStyle(
                              color: AppColors.ink,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (selected)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE7DE),
                              borderRadius: BorderRadius.circular(
                                AppTokens.radiusPill,
                              ),
                            ),
                            child: const Text(
                              'Đang dùng',
                              style: TextStyle(
                                color: AppColors.ember,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      plan.price,
                      style: TextStyle(
                        color: selected ? AppColors.ember : AppColors.graphite,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          const Divider(height: 1, color: AppColors.fog),
          const SizedBox(height: 11),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _PlanDetail(
                icon: Icons.cloud_outlined,
                text: '${plan.quotaGb} GB mỗi buổi',
              ),
              _PlanDetail(icon: Icons.schedule_rounded, text: retention),
            ],
          ),
          const SizedBox(height: 13),
          SizedBox(
            width: double.infinity,
            child: selected
                ? OutlinedButton(
                    onPressed: null,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                    child: const Text('Gói đang sử dụng'),
                  )
                : FilledButton(
                    onPressed: busy ? null : onChoose,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.ink,
                      minimumSize: const Size(0, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                    child: Text(
                      busy
                          ? 'Đang cập nhật...'
                          : plan.tier == StorageTier.pro
                          ? 'Nâng cấp lên Pro'
                          : 'Chọn gói này',
                    ),
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
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: AppColors.ash, size: 15),
      const SizedBox(width: 6),
      Text(
        text,
        style: const TextStyle(
          color: AppColors.steel,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );
}
