import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

/// Animated button with ripple, scale, and glow effects
class AnimatedElevatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isLoading;
  final Duration animationDuration;
  final double elevation;

  const AnimatedElevatedButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.isLoading = false,
    this.animationDuration = const Duration(milliseconds: 200),
    this.elevation = 0,
  }) : super(key: key);

  @override
  State<AnimatedElevatedButton> createState() => _AnimatedElevatedButtonState();
}

class _AnimatedElevatedButtonState extends State<AnimatedElevatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _isPressed = true;
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _isPressed = false;
    _controller.reverse();
    if (!widget.isLoading) {
      widget.onPressed();
    }
  }

  void _onTapCancel() {
    _isPressed = false;
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _opacityAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  boxShadow: widget.elevation > 0
                      ? [
                          BoxShadow(
                            color: (widget.backgroundColor ?? AppColors.primary)
                                .withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: ElevatedButton(
                  onPressed: widget.isLoading ? null : widget.onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        widget.backgroundColor ?? AppColors.primary,
                    foregroundColor:
                        widget.foregroundColor ?? AppColors.onPrimary,
                    elevation: 0,
                  ),
                  child: widget.isLoading
                      ? SizedBox(
                          height: AppSpacing.md,
                          width: AppSpacing.md,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.onPrimary,
                            ),
                          ),
                        )
                      : widget.child,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
