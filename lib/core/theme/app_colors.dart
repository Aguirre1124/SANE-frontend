import 'package:flutter/material.dart';

/// Paleta central de SANE. Un solo lugar para todos los colores de la app.
/// Basada en los mockups: fondo azul marino oscuro, acento azul brillante,
/// verde para progreso/exito.
class AppColors {
  AppColors._(); // evita que se instancie

  // ── Fondos ──────────────────────────────────────────────
  static const Color background = Color(0xFF0D1B2A); // azul marino muy oscuro
  static const Color surface = Color(0xFF16263A);    // cards / superficies
  static const Color surfaceHigh = Color(0xFF1E3149); // cards elevadas / hover

  // ── Acento primario (botones, links, activo) ────────────
  static const Color primary = Color(0xFF2563EB);     // azul brillante
  static const Color primaryHover = Color(0xFF3B82F6);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // ── Estados ─────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);     // verde progreso
  static const Color warning = Color(0xFFF59E0B);     // ambar
  static const Color error = Color(0xFFEF4444);       // rojo
  static const Color info = Color(0xFF38BDF8);        // celeste

  // ── Texto ───────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFE8EDF2);   // casi blanco
  static const Color textSecondary = Color(0xFF94A3B8); // gris azulado
  static const Color textMuted = Color(0xFF64748B);     // mas tenue

  // ── Bordes / divisores ──────────────────────────────────
  static const Color border = Color(0xFF2A3B52);

  // ── Categorias de iconos del diagnostico (mockup 2) ─────
  static const Color catHome = Color(0xFF3B82F6);     // desde casa
  static const Color catMobile = Color(0xFF22C55E);   // puesto ambulante
  static const Color catLocal = Color(0xFF8B5CF6);    // local comercial
  static const Color catPlant = Color(0xFFF59E0B);    // produccion empacada
}
