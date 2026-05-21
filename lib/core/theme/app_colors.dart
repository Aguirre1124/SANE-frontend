import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ══════════════════════════════════════════════════════════════════
  // 🎨 BACKGROUNDS (Dark Mode Base)
  // ══════════════════════════════════════════════════════════════════

  static const Color background = Color(0xFF0F0F0F); // Pure dark background
  static const Color surface = Color(0xFF1A1A1A); // Primary surface for cards
  static const Color surfaceAlt = Color(0xFF252525); // Alternative surface
  static const Color surfaceHigh = Color(0xFF2D2D2D); // Elevated surfaces, hover states

  // ══════════════════════════════════════════════════════════════════
  // 🎨 PRIMARY ACCENT (Bright Cyan - Vibrant Blue)
  // ══════════════════════════════════════════════════════════════════

  static const Color primary = Color(0xFF00C9FF); // Bright cyan/blue
  static const Color primaryLight = Color(0xFF80E7FF); // Light cyan
  static const Color primaryDark = Color(0xFF0099BB); // Dark cyan
  static const Color onPrimary = Color(0xFF000000); // Black text on bright bg

  // ══════════════════════════════════════════════════════════════════
  // 🎨 ACCENT COLORS (Bright Lime Green - Vibrant)
  // ══════════════════════════════════════════════════════════════════

  static const Color secondary = Color(0xFF00FF88); // Bright lime green
  static const Color secondaryLight = Color(0xFF80FFCC); // Light lime
  static const Color tertiary = Color(0xFF00FF99); // Teal accent

  // ══════════════════════════════════════════════════════════════════
  // 🎨 SEMANTIC COLORS (Status indicators)
  // ══════════════════════════════════════════════════════════════════

  static const Color success = Color(0xFF10B981); // Emerald green
  static const Color successLight = Color(0xFF34D399);
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color warningLight = Color(0xFFFFBF4C);
  static const Color error = Color(0xFFEF4444); // Red
  static const Color errorLight = Color(0xFFF87171);
  static const Color info = Color(0xFF06B6D4); // Cyan info

  // ══════════════════════════════════════════════════════════════════
  // 🎨 TEXT COLORS (Hierarchy)
  // ══════════════════════════════════════════════════════════════════

  static const Color textPrimary = Color(0xFFFAFAFA); // Almost white - primary text
  static const Color textSecondary = Color(0xFFA3A3A3); // Gray - secondary text
  static const Color textMuted = Color(0xFF6B7280); // Muted gray - tertiary text
  static const Color textDisabled = Color(0xFF4B5563); // Disabled state

  // ══════════════════════════════════════════════════════════════════
  // 🎨 BORDERS & DIVIDERS
  // ══════════════════════════════════════════════════════════════════

  static const Color border = Color(0xFF2D2D2D); // Primary border
  static const Color borderLight = Color(0xFF404040); // Light border for hover/focus
  static const Color divider = Color(0xFF1F1F1F); // Subtle divider

  // ══════════════════════════════════════════════════════════════════
  // 🎨 GLASS MORPHISM (Frosted glass effects)
  // ══════════════════════════════════════════════════════════════════

  static const Color glassSurface = Color(0x1AFFFFFF); // 10% white overlay
  static const Color glassLight = Color(0x33FFFFFF); // 20% white overlay

  // ══════════════════════════════════════════════════════════════════
  // 🎨 DIAGNOSTIC CATEGORIES (Risk levels - Updated palette)
  // ══════════════════════════════════════════════════════════════════

  static const Color catHome = Color(0xFF00C9FF); // Cyan primary
  static const Color catMobile = Color(0xFF00FF88); // Lime green secondary
  static const Color catLocal = Color(0xFF00FF99); // Teal accent
  static const Color catPlant = Color(0xFF00FFB3); // Bright mint
  static const Color catFoodService = Color(0xFF00E0FF); // Light cyan
  static const Color catRiskHigh = Color(0xFFEF4444); // Error red
  static const Color catRiskMedium = Color(0xFFF59E0B); // Warning amber
  static const Color catRiskLow = Color(0xFF00FF88); // Green success
}
