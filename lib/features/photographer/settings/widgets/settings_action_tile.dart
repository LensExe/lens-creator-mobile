import 'package:flutter/material.dart';

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
    final titleColor = destructive
        ? const Color(0xFFD32F2F)
        : const Color(0xFF1A1C1D);
    final subtitleColor = destructive
        ? const Color(0xFFD32F2F).withValues(alpha: 0.8)
        : const Color(0xFF636466);
    final iconBoxBg = destructive
        ? const Color(0xFFFDE8E8)
        : const Color(0xFFF4F4F5);
    final iconColor = destructive
        ? const Color(0xFFD32F2F)
        : const Color(0xFF1A1C1D);

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBoxBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 14,
                    fontWeight: destructive ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 12,
                      height: 1.35,
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
                  : Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: destructive
                          ? const Color(0xFFD32F2F).withValues(alpha: 0.7)
                          : const Color(0xFF636466),
                    )),
        ],
      ),
    );

    if (onTap == null) {
      return Container(color: Colors.white, child: content);
    }

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        splashColor: destructive
            ? const Color(0xFFFDE8E8)
            : const Color(0xFFF4F4F5),
        highlightColor: destructive
            ? const Color(0xFFFDE8E8).withValues(alpha: 0.5)
            : const Color(0xFFF4F4F5).withValues(alpha: 0.5),
        child: content,
      ),
    );
  }
}
