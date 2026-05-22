import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ══════════════════════════════════════════════════════════════════
  // BACKGROUNDS (Dark Navy Base)
  // ══════════════════════════════════════════════════════════════════

  static const Color background = Color(0xFF090D13); // Deep dark navy
  static const Color surface = Color(0xFF111C2A); // Dark navy surface for cards
  static const Color surfaceAlt = Color(0xFF182434); // Medium dark navy
  static const Color surfaceHigh = Color(0xFF1E2D3E); // Elevated surfaces, hover states

  // ══════════════════════════════════════════════════════════════════
  // PRIMARY ACCENT (Professional Cyan)
  // ══════════════════════════════════════════════════════════════════

  static const Color primary = Color(0xFF1AAFCC); // Controlled professional cyan
  static const Color primaryLight = Color(0xFF4ECDE0); // Light cyan
  static const Color primaryDark = Color(0xFF1289A0); // Deep cyan
  static const Color onPrimary = Color(0xFFFFFFFF); // White text on cyan

  // ══════════════════════════════════════════════════════════════════
  // SECONDARY ACCENT (Corporate Steel Blue)
  // ══════════════════════════════════════════════════════════════════

  static const Color secondary = Color(0xFF2E86AB); // Steel blue — corporate
  static const Color secondaryLight = Color(0xFF5BA3C0); // Light steel blue
  static const Color tertiary = Color(0xFF1A6E8A); // Deep teal for variation

  // ══════════════════════════════════════════════════════════════════
  // SEMANTIC COLORS (Status indicators)
  // ══════════════════════════════════════════════════════════════════

  static const Color success = Color(0xFF10B981); // Emerald green
  static const Color successLight = Color(0xFF34D399);
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color warningLight = Color(0xFFFFBF4C);
  static const Color error = Color(0xFFEF4444); // Red
  static const Color errorLight = Color(0xFFF87171);
  static const Color info = Color(0xFF1AAFCC); // Matches primary

  // ══════════════════════════════════════════════════════════════════
  // TEXT COLORS (Hierarchy)
  // ══════════════════════════════════════════════════════════════════

  static const Color textPrimary = Color(0xFFEEF2F7); // Cool white — cohesive with navy
  static const Color textSecondary = Color(0xFF94A3B8); // Slate blue-gray
  static const Color textMuted = Color(0xFF64748B); // Muted slate
  static const Color textDisabled = Color(0xFF475569); // Disabled state

  // ══════════════════════════════════════════════════════════════════
  // BORDERS & DIVIDERS
  // ══════════════════════════════════════════════════════════════════

  static const Color border = Color(0xFF1E3A52); // Navy border
  static const Color borderLight = Color(0xFF2A4D6E); // Lighter navy border for focus
  static const Color divider = Color(0xFF0F1A26); // Subtle navy divider

  // ══════════════════════════════════════════════════════════════════
  // GLASS MORPHISM (Frosted glass effects)
  // ══════════════════════════════════════════════════════════════════

  static const Color glassSurface = Color(0x1A1AAFCC); // 10% cyan overlay
  static const Color glassLight = Color(0x331AAFCC); // 20% cyan overlay

  // ══════════════════════════════════════════════════════════════════
  // DIAGNOSTIC CATEGORIES (Risk levels)
  // ══════════════════════════════════════════════════════════════════

  static const Color catHome = Color(0xFF1AAFCC); // Primary cyan
  static const Color catMobile = Color(0xFF2E86AB); // Steel blue
  static const Color catLocal = Color(0xFF14B8A6); // Teal
  static const Color catPlant = Color(0xFF0EA5E9); // Sky blue
  static const Color catFoodService = Color(0xFF7DD3FC); // Light sky blue
  static const Color catRiskHigh = Color(0xFFEF4444); // Error red
  static const Color catRiskMedium = Color(0xFFF59E0B); // Warning amber
  static const Color catRiskLow = Color(0xFF10B981); // Emerald green
}
