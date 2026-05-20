import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
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
              backgroundColor: AppColors.error),
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
  Widget build(BuildContext context) {
    final chatAsync = ref.watch(chatProvider(widget.businessId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Asistente SANE'),
        actions: [
          chatAsync.whenOrNull(
                data: (state) => state.isConnected
                    ? Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 16),
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      )
                    : Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 16),
                        decoration: const BoxDecoration(
                          color: AppColors.textMuted,
                          shape: BoxShape.circle,
                        ),
                      ),
              ) ??
              const SizedBox.shrink(),
        ],
      ),
      body: chatAsync.when(
        loading: () => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Iniciando sesión de chat...',
                  style: TextStyle(color: AppColors.textMuted)),
            ],
          ),
        ),
        error: (e, _) => Center(
          child: Text('Error: $e',
              style: const TextStyle(color: AppColors.error)),
        ),
        data: (state) => Column(
          children: [
            Expanded(
              child: state.messages.isEmpty && state.streamingBuffer.isEmpty
                  ? _WelcomeView()
                  : _MessageList(
                      messages: state.messages,
                      streamingBuffer: state.streamingBuffer,
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
    );
  }
}

class _WelcomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_outlined,
                  size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'Asistente SANE',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
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

class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.messages,
    required this.streamingBuffer,
    required this.scrollCtrl,
    required this.onUpdate,
  });

  final List messages;
  final String streamingBuffer;
  final ScrollController scrollCtrl;
  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    return ResponsiveCenter(
      child: ListView.builder(
        controller: scrollCtrl,
        padding: const EdgeInsets.all(16),
        itemCount: messages.length + (streamingBuffer.isNotEmpty ? 1 : 0),
        itemBuilder: (_, i) {
          if (i == messages.length && streamingBuffer.isNotEmpty) {
            return _MessageBubble(
              role: 'ai',
              content: streamingBuffer,
              isStreaming: true,
            );
          }
          final msg = messages[i];
          return _MessageBubble(
            role: msg.role as String,
            content: msg.content as String,
            sourceDocs: msg.sourceDocs as List<String>,
          );
        },
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.role,
    required this.content,
    this.sourceDocs = const [],
    this.isStreaming = false,
  });

  final String role;
  final String content;
  final List<String> sourceDocs;
  final bool isStreaming;

  bool get isUser => role == 'user';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.75,
          ),
          child: Column(
            crossAxisAlignment:
                isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isUser
                      ? AppColors.primary
                      : AppColors.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isUser ? 16 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 16),
                  ),
                  border: isUser
                      ? null
                      : Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        content,
                        style: TextStyle(
                          color: isUser
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                    if (isStreaming) ...[
                      const SizedBox(width: 6),
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: AppColors.textMuted),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SourceDocsBar extends StatelessWidget {
  const _SourceDocsBar({required this.docs});

  final List<String> docs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.surfaceHigh,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Fuentes normativas',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textMuted, fontSize: 11)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: docs
                .map((d) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.info.withValues(alpha: 0.3)),
                      ),
                      child: Text(d,
                          style: const TextStyle(
                              color: AppColors.info, fontSize: 11)),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: ResponsiveCenter(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: isConnected && !isSending,
                maxLines: 3,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: isConnected
                      ? 'Escribe tu pregunta...'
                      : 'Conectando...',
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(12),
              ),
              onPressed: isConnected && !isSending ? onSend : null,
              icon: isSending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
