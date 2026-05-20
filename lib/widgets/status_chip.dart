import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

enum ChipType { riskLevel, tramiteType, diagnosticStatus, sessionStatus }

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.value, required this.type});

  final String value;
  final ChipType type;

  @override
  Widget build(BuildContext context) {
    final (label, color) = _resolve();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  (String, Color) _resolve() {
    switch (type) {
      case ChipType.riskLevel:
        return switch (value) {
          'high' => ('Alto riesgo', AppColors.error),
          'medium' => ('Riesgo medio', AppColors.warning),
          'low' => ('Bajo riesgo', AppColors.success),
          _ => (value, AppColors.textMuted),
        };
      case ChipType.tramiteType:
        return switch (value) {
          'rsa' => ('RSA - INVIMA', AppColors.error),
          'psa' => ('PSA - Sec. Salud', AppColors.warning),
          'nsa' => ('NSA - Sec. Salud', AppColors.info),
          'empresa_creation' => ('Crear empresa', AppColors.textMuted),
          'renewal' => ('Renovación', AppColors.primary),
          _ => (value, AppColors.textMuted),
        };
      case ChipType.diagnosticStatus:
      case ChipType.sessionStatus:
        return switch (value) {
          'completed' => ('Completado', AppColors.success),
          'in_progress' => ('En progreso', AppColors.info),
          'paused' => ('Pausado', AppColors.warning),
          'abandoned' => ('Abandonado', AppColors.textMuted),
          'open' => ('Abierto', AppColors.success),
          _ => (value, AppColors.textMuted),
        };
    }
  }
}
