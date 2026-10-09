import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

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
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFEEEEEF)),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 3,
          offset: const Offset(0, 1),
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  const Text(
                    'LENS Copilot',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1C1D),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: value
                          ? const Color(0xFFFFDBCF).withValues(alpha: 0.6)
                          : const Color(0xFFEEEEEF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: value
                                ? AppColors.ember
                                : const Color(0xFF71717A),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          value ? 'Đang bật' : 'Đã tắt',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: value
                                ? const Color(0xFFC04300)
                                : const Color(0xFF5F5E60),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Tự động phản hồi khách hàng dựa trên dữ liệu bạn cung cấp bên dưới.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF5F5E60),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Transform.scale(
          scale: 0.85,
          child: Switch.adaptive(
            value: value,
            activeTrackColor: AppColors.ember,
            activeThumbColor: Colors.white,
            onChanged: onChanged,
          ),
        ),
      ],
    ),
  );
}
