import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  // We use standard Roboto/system font for now as fallback
  static const String fontFamily = 'Roboto';

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.interTextTheme();

    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.obsidian,
      scaffoldBackgroundColor: AppColors.mist,
      colorScheme: const ColorScheme.light(
        primary: AppColors.obsidian,
        secondary: AppColors.ember,
        surface: AppColors.snow,
        error: AppColors.destructive,
        onPrimary: AppColors.snow,
        onSecondary: AppColors.snow,
        onSurface: AppColors.ink,
        onError: AppColors.snow,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: AppColors.obsidian,
          letterSpacing: -0.5,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: AppColors.obsidian,
          letterSpacing: -0.5,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.obsidian,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.obsidian,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.obsidian,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.ink,
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.steel,
        ),
      ),
    );
  }
}
