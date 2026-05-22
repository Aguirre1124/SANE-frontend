import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class _OrbConfig {
  final Color color;
  final double baseX, baseY, radius;
  final double phaseX, phaseY;
  final double ampX, ampY;
  final double opacity;

  const _OrbConfig({
    required this.color,
    required this.baseX,
    required this.baseY,
    required this.radius,
    required this.phaseX,
    required this.phaseY,
    required this.ampX,
    required this.ampY,
    required this.opacity,
  });
}

const _kOrbs = [
  _OrbConfig(
    color: AppColors.primary,
    baseX: 0.15, baseY: 0.18,
    radius: 0.42,
    phaseX: 0.0, phaseY: 0.0,
    ampX: 0.08, ampY: 0.06,
    opacity: 0.18,
  ),
  _OrbConfig(
    color: AppColors.secondary,
    baseX: 0.82, baseY: 0.28,
    radius: 0.36,
    phaseX: math.pi / 2.5, phaseY: math.pi / 2,
    ampX: 0.07, ampY: 0.09,
    opacity: 0.14,
  ),
  _OrbConfig(
    color: AppColors.tertiary,
    baseX: 0.50, baseY: 0.72,
    radius: 0.38,
    phaseX: math.pi / 1.5, phaseY: math.pi / 4,
    ampX: 0.09, ampY: 0.07,
    opacity: 0.13,
  ),
  _OrbConfig(
    color: AppColors.primary,
    baseX: 0.85, baseY: 0.82,
    radius: 0.30,
    phaseX: math.pi, phaseY: math.pi * 0.75,
    ampX: 0.06, ampY: 0.08,
    opacity: 0.11,
  ),
  _OrbConfig(
    color: AppColors.secondary,
    baseX: 0.18, baseY: 0.62,
    radius: 0.32,
    phaseX: math.pi * 1.4, phaseY: math.pi * 1.2,
    ampX: 0.07, ampY: 0.06,
    opacity: 0.10,
  ),
];

/// Fondo animado con orbes flotantes difuminados. Reutilizable en cualquier pantalla.
/// Pasa [child] para superponer contenido sobre el fondo.
class AnimatedOrbsBackground extends StatefulWidget {
  final Widget? child;

  const AnimatedOrbsBackground({super.key, this.child});

  @override
  State<AnimatedOrbsBackground> createState() => _AnimatedOrbsBackgroundState();
}

class _AnimatedOrbsBackgroundState extends State<AnimatedOrbsBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 14),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: AppColors.background),
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, _) => CustomPaint(
              painter: _OrbsPainter(_controller.value),
              child: const SizedBox.expand(),
            ),
          ),
        ),
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class _OrbsPainter extends CustomPainter {
  final double t;

  const _OrbsPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final maxDim = math.max(size.width, size.height);
    for (final orb in _kOrbs) {
      final x = (orb.baseX + orb.ampX * math.sin(math.pi * 2 * t + orb.phaseX)) * size.width;
      final y = (orb.baseY + orb.ampY * math.cos(math.pi * 2 * t + orb.phaseY)) * size.height;
      final r = orb.radius * maxDim;
      final center = Offset(x, y);

      canvas.drawCircle(
        center,
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [
              orb.color.withValues(alpha: orb.opacity),
              orb.color.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: r)),
      );
    }
  }

  @override
  bool shouldRepaint(_OrbsPainter old) => old.t != t;
}
