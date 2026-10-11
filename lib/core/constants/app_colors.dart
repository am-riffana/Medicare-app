import 'package:flutter/material.dart';

/// App color palette for MediCare healthcare application
class AppColors {
  AppColors._();

  // Primary Brand Colors (Healthcare Teal & Cyan)
  static const Color primary = Color(0xFF007B88);
  static const Color primaryDark = Color(0xFF005B66);
  static const Color primaryLight = Color(0xFFE0F4F5);
  static const Color primaryContainer = Color(0xFFD2EFF2);
  static const Color onPrimary = Colors.white;

  // Secondary & Accent Colors (Modern Medical Blue)
  static const Color secondary = Color(0xFF0284C7);
  static const Color secondaryLight = Color(0xFFE0F2FE);
  static const Color secondaryDark = Color(0xFF0369A1);
  static const Color onSecondary = Colors.white;

  // Neutral Background & Surface Colors (Light Mode)
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF1F5F9);
  static const Color cardBorderLight = Color(0xFFE2E8F0);

  // Neutral Background & Surface Colors (Dark Mode)
  static const Color backgroundDark = Color(0xFF0B131E);
  static const Color surfaceDark = Color(0xFF152232);
  static const Color surfaceVariantDark = Color(0xFF1E2E42);
  static const Color cardBorderDark = Color(0xFF2B3D53);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textMutedLight = Color(0xFF94A3B8);

  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  // Semantic Status Colors
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF2563EB);
  static const Color infoLight = Color(0xFFDBEAFE);

  // Decorative & Category Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF007B88), Color(0xFF0284C7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFF005B66), Color(0xFF007B88), Color(0xFF0284C7)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
