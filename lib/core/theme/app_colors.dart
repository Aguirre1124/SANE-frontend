import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Fondos ──────────────────────────────────────────────
  static const Color background  = Color(0xFF080808); // negro casi puro
  static const Color surface     = Color(0xFF111111); // cards / superficies
  static const Color surfaceHigh = Color(0xFF1A1A1A); // cards elevadas / hover

  // ── Acento primario (botones, links, activo) ────────────
  static const Color primary     = Color(0xFFE8E8E8); // blanco/gris claro
  static const Color primaryHover = Color(0xFFFFFFFF);
  static const Color onPrimary   = Color(0xFF080808); // texto negro sobre botón

  // ── Estados ─────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error   = Color(0xFFEF4444);
  static const Color info    = Color(0xFF38BDF8);

  // ── Texto ───────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFE8E8E8); // casi blanco
  static const Color textSecondary = Color(0xFF8A8A8A); // gris medio
  static const Color textMuted     = Color(0xFF555555); // gris oscuro

  // ── Bordes / divisores ──────────────────────────────────
  static const Color border = Color(0xFF252525);

  // ── Categorias de iconos del diagnostico ───────────────
  static const Color catHome   = Color(0xFFE8E8E8);
  static const Color catMobile = Color(0xFF22C55E);
  static const Color catLocal  = Color(0xFF8B5CF6);
  static const Color catPlant  = Color(0xFFF59E0B);
}
