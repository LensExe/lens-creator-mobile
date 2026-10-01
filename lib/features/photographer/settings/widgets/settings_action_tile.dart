import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';

class SettingsActionTile extends StatelessWidget {
  const SettingsActionTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.destructive : AppColors.graphite;
    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: destructive
                  ? AppColors.destructive.withValues(alpha: 0.08)
                  : AppColors.mist,
              borderRadius: BorderRadius.circular(AppTokens.radiusInput),
            ),
            child: Icon(icon, size: 19, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: destructive ? AppColors.destructive : AppColors.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.steel,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing ??
              (onTap == null
                  ? const SizedBox.shrink()
                  : const Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: AppColors.ash,
                    )),
        ],
      ),
    );

    return Material(
      color: AppColors.snow,
      child: onTap == null ? row : InkWell(onTap: onTap, child: row),
    );
  }
}
