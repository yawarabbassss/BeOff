import 'package:flutter/material.dart';

/// BeOff Color Palette — Modern, Trustworthy, Privacy-First
class AppColors {
  // Brand Core
  static const Color primary = Color(0xFF10B981); // Emerald Green (Shield Active)
  static const Color primaryDark = Color(0xFF059669);
  static const Color primaryLight = Color(0xFF34D399);
  
  static const Color accent = Color(0xFF06B6D4); // Cyan
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color danger = Color(0xFFEF4444); // Coral / Red (Threats / Inactive)
  static const Color info = Color(0xFF3B82F6); // Blue

  // Dark Theme Backgrounds (Default)
  static const Color backgroundDark = Color(0xFF0B1120); // Deep Obsidian Slate
  static const Color surfaceDark = Color(0xFF131E33); // Card Surface
  static const Color surfaceDarkSecondary = Color(0xFF1E293B); // Raised Surface
  static const Color borderDark = Color(0xFF334155); // Border stroke

  // Light Theme Backgrounds
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceLightSecondary = Color(0xFFF1F5F9);
  static const Color borderLight = Color(0xFFE2E8F0);

  // Text Colors
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textMutedLight = Color(0xFF94A3B8);

  // Gradients
  static const LinearGradient shieldActiveGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient shieldInactiveGradient = LinearGradient(
    colors: [Color(0xFF475569), Color(0xFF334155)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGlowGradient = LinearGradient(
    colors: [Color(0x1A10B981), Color(0x0010B981)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
