import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Material 3 Color Schemes for MediCare
class AppColorSchemes {
  AppColorSchemes._();

  static const ColorScheme lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.primaryDark,
    secondary: AppColors.secondary,
    onSecondary: AppColors.onSecondary,
    secondaryContainer: AppColors.secondaryLight,
    onSecondaryContainer: AppColors.secondaryDark,
    error: AppColors.error,
    onError: Colors.white,
    errorContainer: AppColors.errorLight,
    onErrorContainer: AppColors.error,
    surface: AppColors.surfaceLight,
    onSurface: AppColors.textPrimaryLight,
    surfaceContainerHighest: AppColors.surfaceVariantLight,
    onSurfaceVariant: AppColors.textSecondaryLight,
    outline: AppColors.cardBorderLight,
    outlineVariant: AppColors.textMutedLight,
    shadow: Colors.black12,
  );

  static const ColorScheme darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF38BDF8),
    onPrimary: Color(0xFF003544),
    primaryContainer: Color(0xFF004D5C),
    onPrimaryContainer: Color(0xFFB5ECF3),
    secondary: Color(0xFF7DD3FC),
    onSecondary: Color(0xFF00354E),
    secondaryContainer: Color(0xFF075985),
    onSecondaryContainer: Color(0xFFE0F2FE),
    error: Color(0xFFF87171),
    onError: Color(0xFF450A0A),
    errorContainer: Color(0xFF7F1D1D),
    onErrorContainer: Color(0xFFFEE2E2),
    surface: AppColors.surfaceDark,
    onSurface: AppColors.textPrimaryDark,
    surfaceContainerHighest: AppColors.surfaceVariantDark,
    onSurfaceVariant: AppColors.textSecondaryDark,
    outline: AppColors.cardBorderDark,
    outlineVariant: AppColors.textMutedDark,
    shadow: Colors.black45,
  );
}
