class ChatSession {
  final String chatId;
  final String entrepreneurId;
  final String sessionType;
  final String status;

  const ChatSession({
    required this.chatId,
    required this.entrepreneurId,
    required this.sessionType,
    required this.status,
  });

  factory ChatSession.fromJson(Map<String, dynamic> j) => ChatSession(
        chatId: j['chat_id'] as String,
        entrepreneurId: j['entrepreneur_id'] as String,
        sessionType: j['session_type'] as String,
        status: j['status'] as String,
      );
}

class ChatMessage {
  final String id;
  final String role;
  final String content;
  final String? createdAt;
  final List<String> sourceDocs;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    this.createdAt,
    this.sourceDocs = const [],
  });

  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
        id: j['id'] as String,
        role: j['role'] as String,
        content: j['content'] as String,
        createdAt: j['created_at'] as String?,
        sourceDocs: (j['source_docs'] as List? ?? [])
            .map((e) => e as String)
            .toList(),
      );

  ChatMessage copyWith({String? content}) => ChatMessage(
        id: id,
        role: role,
        content: content ?? this.content,
        createdAt: createdAt,
        sourceDocs: sourceDocs,
      );
}

class ChatHistoryResponse {
  final String chatId;
  final int total;
  final List<ChatMessage> messages;

  const ChatHistoryResponse({
    required this.chatId,
    required this.total,
    required this.messages,
  });

  factory ChatHistoryResponse.fromJson(Map<String, dynamic> j) =>
      ChatHistoryResponse(
        chatId: j['chat_id'] as String,
        total: j['total'] as int,
        messages: (j['messages'] as List)
            .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
            .toList(),
      );
}
