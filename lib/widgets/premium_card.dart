import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Premium animated card with powerful shadow, gradient, and depth effects
class PremiumCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Gradient? backgroundGradient;
  final BoxBorder? border;
  final bool enableHoverEffect;
  final Duration animationDuration;
  final bool enableGlow;

  const PremiumCard({
    Key? key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.backgroundColor,
    this.backgroundGradient,
    this.border,
    this.enableHoverEffect = true,
    this.animationDuration = const Duration(milliseconds: 200),
    this.enableGlow = true,
  }) : super(key: key);

  @override
  State<PremiumCard> createState() => _PremiumCardState();
}

class _PremiumCardState extends State<PremiumCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _shadowAnimation = Tween<double>(begin: 1.0, end: 4.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHoverEnter() {
    if (!widget.enableHoverEffect) return;
    _controller.forward();
  }

  void _onHoverExit() {
    if (!widget.enableHoverEffect) return;
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHoverEnter(),
      onExit: (_) => _onHoverExit(),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: Listenable.merge([_scaleAnimation, _shadowAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  // Gradient background (strong visual)
                  gradient: widget.backgroundGradient ??
                      LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.surface,
                          AppColors.surfaceAlt,
                        ],
                      ),
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                  border: widget.border ??
                      Border.all(
                        color: AppColors.borderLight,
                        width: 1.5,
                      ),
                  // POWERFUL SHADOWS - strong depth effect
                  boxShadow: [
                    // Base shadow
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 12 * _shadowAnimation.value,
                      offset: Offset(0, 4 * _shadowAnimation.value),
                    ),
                    // Secondary shadow for depth
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 24 * _shadowAnimation.value,
                      offset: Offset(0, 8 * _shadowAnimation.value),
                    ),
                    // Glow effect
                    if (widget.enableGlow)
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.15),
                        blurRadius: 16 * _shadowAnimation.value,
                        offset: const Offset(0, 0),
                      ),
                  ],
                ),
                padding: widget.padding,
                child: widget.child,
              ),
            );
          },
        ),
      ),
    );
  }
}
