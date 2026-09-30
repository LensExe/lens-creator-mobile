import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

class CreatorFilterOption {
  const CreatorFilterOption(this.label, {this.count});

  final String label;
  final int? count;
}

class CreatorFilterTabs extends StatelessWidget {
  const CreatorFilterTabs({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<CreatorFilterOption> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        for (var index = 0; index < options.length; index++) ...[
          Material(
            color: selectedIndex == index
                ? AppColors.emberSoft
                : AppColors.mist,
            borderRadius: BorderRadius.circular(AppTokens.radiusPill),
            child: InkWell(
              onTap: () => onSelected(index),
              borderRadius: BorderRadius.circular(AppTokens.radiusPill),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: AppTokens.touchTarget,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Center(
                    child: Text(
                      options[index].count == null
                          ? options[index].label
                          : '${options[index].label} ${options[index].count}',
                      style: TextStyle(
                        color: selectedIndex == index
                            ? AppColors.ember
                            : AppColors.graphite,
                        fontSize: 13,
                        fontWeight: selectedIndex == index
                            ? FontWeight.w700
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (index < options.length - 1) const SizedBox(width: 8),
        ],
      ],
    ),
  );
}
