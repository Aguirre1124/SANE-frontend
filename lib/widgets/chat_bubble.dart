import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

// Radios de esquina para las burbujas
const _kRound = Radius.circular(18);
const _kTail = Radius.circular(4);

// ── Burbuja de mensaje ────────────────────────────────────────────────────────

class ChatBubble extends StatefulWidget {
  const ChatBubble({
    super.key,
    required this.role,
    required this.content,
    this.isStreaming = false,
  });

  final String role;
  final String content;
  final bool isStreaming;

  bool get _isUser => role == 'user';

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    )..forward();
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Align(
            alignment: widget._isUser
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.75,
              ),
              child: widget._isUser
                  ? _UserBubble(
                      content: widget.content,
                      isStreaming: widget.isStreaming,
                    )
                  : _AiBubble(
                      content: widget.content,
                      isStreaming: widget.isStreaming,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Burbuja del usuario ───────────────────────────────────────────────────────

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.content, required this.isStreaming});

  final String content;
  final bool isStreaming;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: _kRound,
          topRight: _kRound,
          bottomLeft: _kRound,
          bottomRight: _kTail,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onPrimary,
                    height: 1.45,
                  ),
            ),
          ),
          if (isStreaming) ...[
            const SizedBox(width: AppSpacing.sm),
            const _StreamingCursor(),
          ],
        ],
      ),
    );
  }
}

// ── Burbuja del asistente ─────────────────────────────────────────────────────

class _AiBubble extends StatelessWidget {
  const _AiBubble({required this.content, required this.isStreaming});

  final String content;
  final bool isStreaming;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        const _BotAvatar(size: 28),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: _GlassBubble(content: content, isStreaming: isStreaming),
        ),
      ],
    );
  }
}

// ── Contenido glass de la burbuja del asistente ───────────────────────────────

class _GlassBubble extends StatelessWidget {
  const _GlassBubble({required this.content, required this.isStreaming});

  final String content;
  final bool isStreaming;

  static const _radius = BorderRadius.only(
    topLeft: _kRound,
    topRight: _kRound,
    bottomLeft: _kTail,
    bottomRight: _kRound,
  );

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: _radius,
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: const BoxDecoration(
            color: AppColors.glassSurface,
            borderRadius: _radius,
            border: Border.fromBorderSide(
              BorderSide(color: AppColors.borderLight),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  content,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.45,
                      ),
                ),
              ),
              if (isStreaming) ...[
                const SizedBox(width: AppSpacing.sm),
                const _StreamingCursor(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Avatar del bot ────────────────────────────────────────────────────────────

class _BotAvatar extends StatelessWidget {
  const _BotAvatar({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        Icons.smart_toy_outlined,
        size: size * 0.52,
        color: AppColors.onPrimary,
      ),
    );
  }
}

// ── Burbuja de indicador "escribiendo…" ───────────────────────────────────────

class TypingIndicatorBubble extends StatefulWidget {
  const TypingIndicatorBubble({super.key});

  @override
  State<TypingIndicatorBubble> createState() => _TypingIndicatorBubbleState();
}

class _TypingIndicatorBubbleState extends State<TypingIndicatorBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    )..forward();
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                const _BotAvatar(size: 28),
                const SizedBox(width: AppSpacing.sm),
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: _kRound,
                    topRight: _kRound,
                    bottomLeft: _kTail,
                    bottomRight: _kRound,
                  ),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.glassSurface,
                        borderRadius: BorderRadius.only(
                          topLeft: _kRound,
                          topRight: _kRound,
                          bottomLeft: _kTail,
                          bottomRight: _kRound,
                        ),
                        border: Border.fromBorderSide(
                          BorderSide(color: AppColors.borderLight),
                        ),
                      ),
                      child: const _TypingDots(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Tres puntos animados ──────────────────────────────────────────────────────

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  double _bounce(int i) {
    final t = _ctrl.value;
    final start = i * 0.25;
    final end = start + 0.5;
    if (t < start || t > end) return 0;
    return math.sin((t - start) / 0.5 * math.pi);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final b = _bounce(i);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              width: 6,
              height: 6,
              transform: Matrix4.translationValues(0, -6 * b, 0),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.4 + 0.6 * b),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}

// ── Cursor de streaming (barra parpadeante) ───────────────────────────────────

class _StreamingCursor extends StatefulWidget {
  const _StreamingCursor();

  @override
  State<_StreamingCursor> createState() => _StreamingCursorState();
}

class _StreamingCursorState extends State<_StreamingCursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 550),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) => Opacity(
        opacity: _ctrl.value,
        child: Container(
          width: 2,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }
}
