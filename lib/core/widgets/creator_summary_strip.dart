import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class CreatorSummaryItem {
  const CreatorSummaryItem(this.label, this.value);

  final String label;
  final String value;
}

class CreatorSummaryStrip extends StatelessWidget {
  const CreatorSummaryStrip({super.key, required this.items});

  final List<CreatorSummaryItem> items;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0)
            Container(
              height: 34,
              width: 1,
              margin: const EdgeInsets.symmetric(horizontal: 17),
              color: AppColors.fog,
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                items[i].value,
                style: const TextStyle(
                  color: AppColors.obsidian,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                items[i].label,
                style: const TextStyle(color: AppColors.steel, fontSize: 11),
              ),
            ],
          ),
        ],
      ],
    ),
  );
}
