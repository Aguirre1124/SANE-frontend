import 'package:flutter/material.dart';

/// Material Design 3 shadows for elevation hierarchy
class AppShadows {
  AppShadows._();

  // ── Elevation 1 (cards, small components) ────────────────
  static const List<BoxShadow> shadow1 = [
    BoxShadow(
      color: Color(0x0D000000), // 5% black opacity
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  // ── Elevation 2 (elevated buttons, chips) ────────────────
  static const List<BoxShadow> shadow2 = [
    BoxShadow(
      color: Color(0x12000000), // 7% black opacity
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  // ── Elevation 3 (FAB, modals) ────────────────────────────
  static const List<BoxShadow> shadow3 = [
    BoxShadow(
      color: Color(0x1A000000), // 10% black opacity
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  // ── Elevation 4 (floating elements, dialogs) ─────────────
  static const List<BoxShadow> shadow4 = [
    BoxShadow(
      color: Color(0x1F000000), // 12% black opacity
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];

  // ── Glow effect (for premium cards, accent borders) ──────
  static const List<BoxShadow> glowPrimary = [
    BoxShadow(
      color: Color(0x267C5CFF), // Purple with 15% opacity
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> glowSuccess = [
    BoxShadow(
      color: Color(0x2610B981), // Green with 15% opacity
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];
}

