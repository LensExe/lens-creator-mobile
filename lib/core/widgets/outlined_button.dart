import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class OutlinedWhiteButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const OutlinedWhiteButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: AppColors.graphite, width: 1.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(36),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 20,
            ), // padded 20px per design doc
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.graphite,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
