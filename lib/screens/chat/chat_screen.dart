import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/chat_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/animated_orbs_background.dart';
import '../../widgets/chat_bubble.dart';
import '../../widgets/error_view.dart';
import '../../widgets/responsive_layout.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, this.businessId});

  final String? businessId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _initialized = false;

  @override
  void dispose() {
    ref.read(chatProvider(widget.businessId).notifier).closeConnection();
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    if (_initialized) return;
    _initialized = true;
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    try {
      await ref
          .read(chatProvider(widget.businessId).notifier)
          .startSession(entrepreneurId: user.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al iniciar chat: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _send() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    _msgCtrl.clear();
    ref.read(chatProvider(widget.businessId).notifier).sendMessage(text);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context, ) {
    final chatAsync = ref.watch(chatProvider(widget.businessId));
    final isConnected = chatAsync.asData?.value.isConnected ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedOrbsBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _GlassHeader(isConnected: isConnected),
              Expanded(
                child: chatAsync.when(
                  loading: () => const _ChatLoadingView(),
                  error: (e, _) => ErrorView(error: e),
                  data: (state) => Column(
                    children: [
                      Expanded(
                        child: (state.messages.isEmpty &&
                                state.streamingBuffer.isEmpty &&
                                !state.isSending)
                            ? const _WelcomeView()
                            : _MessageList(
                                messages: state.messages,
                                streamingBuffer: state.streamingBuffer,
                                isSending: state.isSending,
                                scrollCtrl: _scrollCtrl,
                                onUpdate: _scrollToBottom,
                              ),
                      ),
                      if (state.lastSourceDocs.isNotEmpty)
                        _SourceDocsBar(docs: state.lastSourceDocs),
                      _InputBar(
                        controller: _msgCtrl,
                        isSending: state.isSending,
                        isConnected: state.isConnected,
                        onSend: _send,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Header glass ──────────────────────────────────────────────────────────────

class _GlassHeader extends StatelessWidget {
  const _GlassHeader({required this.isConnected});

  final bool isConnected;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.glassSurface,
            border: Border(
              bottom: BorderSide(color: AppColors.borderLight, width: 1),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.pop(),
                color: AppColors.textPrimary,
                tooltip: 'Volver',
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Asistente SANE',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isConnected
                                ? AppColors.success
                                : AppColors.textMuted,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          isConnected ? 'Conectado' : 'Desconectado',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: isConnected
                                    ? AppColors.success
                                    : AppColors.textMuted,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Image.asset(
                'assets/images/sane_logo_mark.png',
                width: 34,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Vista de carga inicial ────────────────────────────────────────────────────

class _ChatLoadingView extends StatelessWidget {
  const _ChatLoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PulsingBotAvatar(size: 64),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Iniciando sesión de chat...',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

// ── Vista de bienvenida (sin mensajes) ────────────────────────────────────────

class _WelcomeView extends StatelessWidget {
  const _WelcomeView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PulsingBotAvatar(size: 72),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Asistente SANE',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Haz cualquier pregunta sobre normativas sanitarias, trámites y requisitos para tu negocio alimentario.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Avatar del bot con pulso animado ──────────────────────────────────────────

class _PulsingBotAvatar extends StatefulWidget {
  const _PulsingBotAvatar({required this.size});

  final double size;

  @override
  State<_PulsingBotAvatar> createState() => _PulsingBotAvatarState();
}

class _PulsingBotAvatarState extends State<_PulsingBotAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.07).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _glow = Tween<double>(begin: 0.25, end: 0.55).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
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
      builder: (_, _) {
        final s = widget.size;
        return SizedBox(
          width: s + 24,
          height: s + 24,
          child: Center(
            child: Transform.scale(
              scale: _scale.value,
              child: Container(
                width: s,
                height: s,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: _glow.value),
                      blurRadius: 28,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.smart_toy_outlined,
                  size: s * 0.5,
                  color: AppColors.onPrimary,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Lista de mensajes ─────────────────────────────────────────────────────────

class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.messages,
    required this.streamingBuffer,
    required this.isSending,
    required this.scrollCtrl,
    required this.onUpdate,
  });

  final List<ChatMessage> messages;
  final String streamingBuffer;
  final bool isSending;
  final ScrollController scrollCtrl;
  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    final showTyping = isSending && streamingBuffer.isEmpty;
    final extraItems =
        (streamingBuffer.isNotEmpty ? 1 : 0) + (showTyping ? 1 : 0);

    return ResponsiveCenter(
      child: ListView.builder(
        controller: scrollCtrl,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        itemCount: messages.length + extraItems,
        itemBuilder: (_, i) {
          // Burbuja de streaming (texto incremental)
          if (streamingBuffer.isNotEmpty && i == messages.length) {
            return ChatBubble(
              key: const ValueKey('streaming'),
              role: 'ai',
              content: streamingBuffer,
              isStreaming: true,
            );
          }
          // Indicador "escribiendo…" (esperando primer token)
          if (showTyping && i == messages.length) {
            return const TypingIndicatorBubble(key: ValueKey('typing'));
          }
          final msg = messages[i];
          return ChatBubble(
            key: ValueKey(msg.id),
            role: msg.role,
            content: msg.content,
          );
        },
      ),
    );
  }
}

// ── Barra de fuentes normativas ───────────────────────────────────────────────

class _SourceDocsBar extends StatelessWidget {
  const _SourceDocsBar({required this.docs});

  final List<String> docs;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          decoration: const BoxDecoration(
            color: AppColors.glassSurface,
            border: Border(
              top: BorderSide(color: AppColors.borderLight, width: 1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fuentes normativas',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: docs
                    .map(
                      (d) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.info.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          d,
                          style: const TextStyle(
                            color: AppColors.info,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Barra de entrada ──────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.isSending,
    required this.isConnected,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isSending;
  final bool isConnected;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final canSend = isConnected && !isSending;

    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.glassSurface,
            border: Border(
              top: BorderSide(color: AppColors.borderLight, width: 1),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: ResponsiveCenter(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Campo de texto
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: TextField(
                      controller: controller,
                      enabled: canSend,
                      maxLines: 4,
                      minLines: 1,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: isConnected
                            ? 'Escribe tu pregunta...'
                            : 'Conectando...',
                        hintStyle: const TextStyle(color: AppColors.textMuted),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                      ),
                      onSubmitted: canSend ? (_) => onSend() : null,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // Botón enviar circular con glow
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: canSend
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.45),
                              blurRadius: 16,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Material(
                    color: canSend
                        ? AppColors.primary
                        : AppColors.surfaceHigh,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: canSend ? onSend : null,
                      customBorder: const CircleBorder(),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: isSending
                            ? const SizedBox(
                                width: AppSpacing.iconMedium,
                                height: AppSpacing.iconMedium,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.onPrimary,
                                ),
                              )
                            : const Icon(
                                Icons.send_rounded,
                                color: AppColors.onPrimary,
                                size: AppSpacing.iconMedium,
                              ),
                      ),
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
