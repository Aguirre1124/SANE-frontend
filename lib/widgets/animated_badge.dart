import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

/// Animated badge widget with pulse effect
class AnimatedBadge extends StatefulWidget {
  final String label;
  final Color backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry padding;
  final bool showPulse;
  final VoidCallback? onTap;

  const AnimatedBadge(
    this.label, {
    Key? key,
    this.backgroundColor = AppColors.primary,
    this.textColor,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    ),
    this.showPulse = true,
    this.onTap,
  }) : super(key: key);

  @override
  State<AnimatedBadge> createState() => _AnimatedBadgeState();
}

class _AnimatedBadgeState extends State<AnimatedBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.showPulse) {
      _controller = AnimationController(
        duration: const Duration(milliseconds: 2000),
        vsync: this,
      )..repeat();

      _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
    }
  }

  @override
  void dispose() {
    if (widget.showPulse) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
      ),
      child: Text(
        widget.label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: widget.textColor ?? AppColors.onPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    if (!widget.showPulse) {
      return widget.onTap != null
          ? GestureDetector(onTap: widget.onTap, child: badge)
          : badge;
    }

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: widget.onTap != null
              ? GestureDetector(onTap: widget.onTap, child: badge)
              : badge,
        );
      },
    );
  }
}

/// Animated counter badge (for notifications)
class AnimatedCounterBadge extends StatefulWidget {
  final int count;
  final Color backgroundColor;
  final Color? textColor;
  final Duration animationDuration;

  const AnimatedCounterBadge(
    this.count, {
    Key? key,
    this.backgroundColor = const Color(0xFFEF4444),
    this.textColor,
    this.animationDuration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  State<AnimatedCounterBadge> createState() => _AnimatedCounterBadgeState();
}

class _AnimatedCounterBadgeState extends State<AnimatedCounterBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  int _previousCount = 0;

  @override
  void initState() {
    super.initState();
    _previousCount = widget.count;
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _rotateAnimation = Tween<double>(begin: -0.5, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void didUpdateWidget(AnimatedCounterBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.count != oldWidget.count) {
      _previousCount = oldWidget.count;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _rotateAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotateAnimation.value,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                widget.count > 99 ? '99+' : widget.count.toString(),
                style: TextStyle(
                  color: widget.textColor ?? Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
