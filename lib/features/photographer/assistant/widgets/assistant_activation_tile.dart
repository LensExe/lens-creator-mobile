import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';

class AssistantActivationTile extends StatelessWidget {
  const AssistantActivationTile({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(14, 13, 10, 13),
    decoration: BoxDecoration(
      color: AppColors.snow,
      border: Border.all(color: AppColors.fog),
      borderRadius: BorderRadius.circular(AppTokens.radiusCard),
    ),
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: value ? AppColors.emberSoft : AppColors.mist,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            Icons.auto_awesome_rounded,
            color: value ? AppColors.ember : AppColors.steel,
            size: 21,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kích hoạt trợ lý',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontSize: 15),
              ),
              const SizedBox(height: 3),
              Text(
                value ? 'Đang bật' : 'Đang tắt',
                style: const TextStyle(color: AppColors.steel, fontSize: 12),
              ),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    ),
  );
}
