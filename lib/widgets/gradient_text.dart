import 'package:flutter/material.dart';

/// Gradient text widget - Makes text pop with vibrant gradients
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? baseStyle;
  final Gradient gradient;
  final TextAlign textAlign;

  const GradientText(
    this.text, {
    Key? key,
    this.baseStyle,
    this.gradient = const LinearGradient(
      colors: [Color(0xFF00C9FF), Color(0xFF00FF88)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    this.textAlign = TextAlign.start,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        textAlign: textAlign,
        style: (baseStyle ?? const TextStyle()).copyWith(
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Animated gradient text that shifts colors
class AnimatedGradientText extends StatefulWidget {
  final String text;
  final TextStyle? baseStyle;
  final List<Gradient> gradients;
  final Duration duration;
  final TextAlign textAlign;

  const AnimatedGradientText(
    this.text, {
    Key? key,
    this.baseStyle,
    this.gradients = const [
      LinearGradient(
        colors: [Color(0xFF00C9FF), Color(0xFF00FF88)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      LinearGradient(
        colors: [Color(0xFF00FF88), Color(0xFF00C9FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ],
    this.duration = const Duration(milliseconds: 3000),
    this.textAlign = TextAlign.start,
  }) : super(key: key);

  @override
  State<AnimatedGradientText> createState() => _AnimatedGradientTextState();
}

class _AnimatedGradientTextState extends State<AnimatedGradientText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
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
        final gradients = widget.gradients;
        if (gradients.isEmpty) return const SizedBox.shrink();

        final nextIndex = (_animation.value * (gradients.length - 1)).round();
        final currentIndex = nextIndex.clamp(0, gradients.length - 1);
        final currentGradient = gradients[currentIndex];

        return ShaderMask(
          shaderCallback: (bounds) => currentGradient.createShader(
            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
          ),
          child: Text(
            widget.text,
            textAlign: widget.textAlign,
            style: (widget.baseStyle ?? const TextStyle()).copyWith(
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
