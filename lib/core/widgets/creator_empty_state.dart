import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class CreatorEmptyState extends StatelessWidget {
  const CreatorEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
    child: Column(
      children: [
        Icon(icon, size: 30, color: AppColors.ash),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (description != null) ...[
          const SizedBox(height: 5),
          Text(
            description!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.steel, fontSize: 13),
          ),
        ],
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: 12),
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ],
    ),
  );
}
