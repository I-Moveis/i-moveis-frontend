class ChatSessionModel {
  const ChatSessionModel({
    required this.id,
    required this.startedAt,
    this.tenantId,
    this.tenantName,
    this.propertyId,
    this.propertyTitle,
    this.status,
    this.lastMessage,
    this.lastMessageAt,
    this.messages = const [],
  });

  final String id;
  final DateTime startedAt;
  final String? tenantId;
  final String? tenantName;
  final String? propertyId;
  final String? propertyTitle;
  final String? status;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final List<MessageModel> messages;

  String get initials {
    final name = tenantName ?? '';
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  factory ChatSessionModel.fromJson(Map<String, dynamic> json) {
    final msgs = json['messages'];
    final messageList = msgs is List
        ? msgs
            .whereType<Map<dynamic, dynamic>>()
            .map((m) => MessageModel.fromJson(Map<String, dynamic>.from(m)))
            .toList()
        : <MessageModel>[];

    // Extrai a última mensagem para preview
    String? lastMsg;
    DateTime? lastMsgAt;
    if (messageList.isNotEmpty) {
      lastMsg = messageList.last.content;
      lastMsgAt = messageList.last.timestamp;
    }

    return ChatSessionModel(
      id: json['id'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      tenantId: json['tenantId'] as String?,
      tenantName: (json['tenant'] as Map<String, dynamic>?)?['name'] as String?,
      propertyId: json['propertyId'] as String?,
      propertyTitle:
          (json['property'] as Map<String, dynamic>?)?['title'] as String?,
      status: json['status'] as String?,
      lastMessage: lastMsg,
      lastMessageAt: lastMsgAt,
      messages: messageList,
    );
  }

  ChatSessionModel copyWith({List<MessageModel>? messages}) {
    final msgs = messages ?? this.messages;
    return ChatSessionModel(
      id: id,
      startedAt: startedAt,
      tenantId: tenantId,
      tenantName: tenantName,
      propertyId: propertyId,
      propertyTitle: propertyTitle,
      status: status,
      lastMessage: msgs.isNotEmpty ? msgs.last.content : lastMessage,
      lastMessageAt: msgs.isNotEmpty ? msgs.last.timestamp : lastMessageAt,
      messages: msgs,
    );
  }
}

class MessageModel {
  const MessageModel({
    required this.id,
    required this.sessionId,
    required this.senderType,
    required this.content,
    required this.timestamp,
  });

  final String id;
  final String sessionId;
  final String senderType; // 'BOT' | 'TENANT' | 'LANDLORD'
  final String content;
  final DateTime timestamp;

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        id: json['id'] as String,
        sessionId: json['sessionId'] as String,
        senderType: json['senderType'] as String? ?? 'BOT',
        content: json['content'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}
