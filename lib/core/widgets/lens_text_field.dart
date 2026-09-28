import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class LensTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;

  const LensTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: AppColors.ink, fontSize: 14),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.snow,
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColors.ash, fontSize: 14),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.ash, size: 20)
            : null,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}
