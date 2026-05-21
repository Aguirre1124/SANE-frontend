import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Shimmer loading effect - Great for skeleton screens
class ShimmerLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final Duration duration;

  const ShimmerLoader({
    Key? key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius,
    this.duration = const Duration(milliseconds: 1200),
  }) : super(key: key);

  @override
  State<ShimmerLoader> createState() => _ShimmerLoaderState();
}

class _ShimmerLoaderState extends State<ShimmerLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius:
                widget.borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ],
              colors: [
                AppColors.surfaceAlt,
                AppColors.surface,
                AppColors.surfaceAlt,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Shimmer container for multiple shimmer lines
class ShimmerLoaderContainer extends StatelessWidget {
  final int lineCount;
  final double spacing;
  final Duration duration;

  const ShimmerLoaderContainer({
    Key? key,
    this.lineCount = 3,
    this.spacing = 12,
    this.duration = const Duration(milliseconds: 1200),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        lineCount,
        (index) => Padding(
          padding: EdgeInsets.only(
            bottom: index < lineCount - 1 ? spacing : 0,
          ),
          child: ShimmerLoader(
            height: 16,
            duration: duration,
          ),
        ),
      ),
    );
  }
}
