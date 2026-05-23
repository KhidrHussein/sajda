import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color bgPrimaryLight = Color(0xFFF7F5F2);
  static const Color bgPrimaryDark = Color(0xFF1A1D1E);
  static const Color bgIntervention = Color(0xFF232B2F);
  
  static const Color textPrimaryLight = Color(0xFF2B2D2F);
  static const Color textSecondaryLight = Color(0xFF6B7276);
  static const Color textPrimaryDark = Color(0xFFEAEBEB);
  static const Color textSecondaryDark = Color(0xFFA0A6A9);
  static const Color textIntervention = Color(0xFFF7F5F2);
  
  static const Color accentPrimary = Color(0xFF748670);
  static const Color actionDestructive = Color(0xFF8E4A49);
}

class AppTextStyles {
  static TextStyle displayLarge(Color color) => GoogleFonts.inter(
        fontSize: 48,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.96,
        color: color,
      );

  static TextStyle heading1(Color color) => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.24,
        color: color,
      );

  static TextStyle heading2(Color color) => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        color: color,
      );

  static TextStyle bodyLarge(Color color) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: color,
      );

  static TextStyle bodyMedium(Color color) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: color,
      );

  static TextStyle reflection(Color color) => GoogleFonts.lora(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
        height: 1.6,
        color: color,
      );

  static TextStyle button(Color color) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.28,
        color: color,
      );
}

class AppSpacing {
  static const double paddingScreenHorizontal = 24.0;
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;
}

class AppRadius {
  static const double radiusButton = 8.0;
  static const double radiusCard = 12.0;
  static const double radiusPill = 999.0;
}

class SajdaTheme {
  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgPrimaryDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentPrimary,
        onPrimary: AppColors.bgPrimaryDark,
        surface: AppColors.bgPrimaryDark,
        onSurface: AppColors.textPrimaryDark,
        error: AppColors.actionDestructive,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: AppTextStyles.displayLarge(AppColors.textPrimaryDark),
        headlineLarge: AppTextStyles.heading1(AppColors.textPrimaryDark),
        headlineMedium: AppTextStyles.heading2(AppColors.textPrimaryDark),
        bodyLarge: AppTextStyles.bodyLarge(AppColors.textPrimaryDark),
        bodyMedium: AppTextStyles.bodyMedium(AppColors.textPrimaryDark),
      ),
    );
  }

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bgPrimaryLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.accentPrimary,
        onPrimary: AppColors.bgPrimaryLight,
        surface: AppColors.bgPrimaryLight,
        onSurface: AppColors.textPrimaryLight,
        error: AppColors.actionDestructive,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: AppTextStyles.displayLarge(AppColors.textPrimaryLight),
        headlineLarge: AppTextStyles.heading1(AppColors.textPrimaryLight),
        headlineMedium: AppTextStyles.heading2(AppColors.textPrimaryLight),
        bodyLarge: AppTextStyles.bodyLarge(AppColors.textPrimaryLight),
        bodyMedium: AppTextStyles.bodyMedium(AppColors.textPrimaryLight),
      ),
    );
  }
}
