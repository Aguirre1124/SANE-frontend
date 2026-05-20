import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../core/api/api_client.dart';
import '../core/storage/token_storage.dart';
import '../models/chat_model.dart';

class ChatState {
  final ChatSession? session;
  final List<ChatMessage> messages;
  final bool isConnected;
  final bool isSending;
  final String streamingBuffer;
  final List<String> lastSourceDocs;

  const ChatState({
    this.session,
    this.messages = const [],
    this.isConnected = false,
    this.isSending = false,
    this.streamingBuffer = '',
    this.lastSourceDocs = const [],
  });

  ChatState copyWith({
    ChatSession? session,
    List<ChatMessage>? messages,
    bool? isConnected,
    bool? isSending,
    String? streamingBuffer,
    List<String>? lastSourceDocs,
  }) =>
      ChatState(
        session: session ?? this.session,
        messages: messages ?? this.messages,
        isConnected: isConnected ?? this.isConnected,
        isSending: isSending ?? this.isSending,
        streamingBuffer: streamingBuffer ?? this.streamingBuffer,
        lastSourceDocs: lastSourceDocs ?? this.lastSourceDocs,
      );
}

class ChatNotifier
    extends FamilyAsyncNotifier<ChatState, String?> {
  WebSocketChannel? _channel;
  StreamSubscription? _sub;

  @override
  Future<ChatState> build(String? businessId) async => const ChatState();

  Future<void> startSession({
    required String entrepreneurId,
    String sessionType = 'general_legal',
  }) async {
    try {
      final dio = ref.read(dioProvider);
      final body = <String, dynamic>{
        'entrepreneur_id': entrepreneurId,
        'session_type': sessionType,
        'language': 'es',
        'context': {},
      };
      if (arg != null) body['business_id'] = arg;

      final res = await dio.post('/chat/start', data: body);
      final session = ChatSession.fromJson(res.data as Map<String, dynamic>);

      await _loadHistory(session.chatId);
      await _connectWebSocket(session.chatId);

      state = AsyncData((state.asData?.value ?? const ChatState())
          .copyWith(session: session));
    } on DioException catch (e) {
      throw dioToApi(e);
    }
  }

  Future<void> _loadHistory(String chatId) async {
    try {
      final dio = ref.read(dioProvider);
      final res = await dio.get('/chat/$chatId/history');
      final history =
          ChatHistoryResponse.fromJson(res.data as Map<String, dynamic>);
      state = AsyncData(
        (state.asData?.value ?? const ChatState())
            .copyWith(messages: history.messages),
      );
    } on DioException {
      // History might not exist yet, ignore
    }
  }

  Future<void> _connectWebSocket(String chatId) async {
    final token = await TokenStorage.read();
    final uri = Uri.parse(
        '${kBaseUrl.replaceFirst('http', 'ws')}/chat/$chatId/stream?token=$token');
    _channel = WebSocketChannel.connect(uri);

    _sub = _channel!.stream.listen(
      (message) {
        final data = jsonDecode(message as String) as Map<String, dynamic>;
        final currentState = state.asData?.value ?? const ChatState();

        switch (data['type']) {
          case 'ready':
            state = AsyncData(currentState.copyWith(isConnected: true));
          case 'token':
            final chunk = data['data'] as String? ?? '';
            state = AsyncData(currentState.copyWith(
              streamingBuffer: currentState.streamingBuffer + chunk,
              isSending: true,
            ));
          case 'done':
            final sourceDocs = (data['source_docs'] as List? ?? [])
                .map((e) => e as String)
                .toList();
            if (currentState.streamingBuffer.isNotEmpty) {
              final aiMsg = ChatMessage(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                role: 'ai',
                content: currentState.streamingBuffer,
                sourceDocs: sourceDocs,
              );
              state = AsyncData(currentState.copyWith(
                messages: [...currentState.messages, aiMsg],
                streamingBuffer: '',
                isSending: false,
                lastSourceDocs: sourceDocs,
              ));
            }
          case 'error':
            state = AsyncData(currentState.copyWith(
              isSending: false,
              streamingBuffer: '',
            ));
        }
      },
      onError: (_) {
        state = AsyncData(
          (state.asData?.value ?? const ChatState())
              .copyWith(isConnected: false, isSending: false),
        );
      },
      onDone: () {
        state = AsyncData(
          (state.asData?.value ?? const ChatState())
              .copyWith(isConnected: false),
        );
      },
    );
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;
    final currentState = state.asData?.value ?? const ChatState();

    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'user',
      content: text.trim(),
    );
    state = AsyncData(currentState.copyWith(
      messages: [...currentState.messages, userMsg],
      isSending: true,
      streamingBuffer: '',
    ));

    _channel?.sink.add(text.trim());
  }

  void closeConnection() {
    _sub?.cancel();
    _channel?.sink.close();
  }
}

final chatProvider =
    AsyncNotifierProviderFamily<ChatNotifier, ChatState, String?>(
        ChatNotifier.new);
