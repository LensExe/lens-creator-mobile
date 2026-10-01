import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/creator_section_header.dart';

class SettingsGroup extends StatelessWidget {
  const SettingsGroup({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CreatorSectionHeader(title: title, subtitle: subtitle),
      const SizedBox(height: 11),
      Container(
        decoration: BoxDecoration(
          color: AppColors.snow,
          border: Border.all(color: AppColors.fog),
          borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTokens.radiusCard),
          child: Column(
            children: [
              for (var index = 0; index < children.length; index++) ...[
                children[index],
                if (index < children.length - 1)
                  const Divider(height: 1, indent: 68, endIndent: 14),
              ],
            ],
          ),
        ),
      ),
    ],
  );
}
