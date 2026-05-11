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
    this.lastSenderType,
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
  final String? lastSenderType;
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

    String? lastMsg;
    DateTime? lastMsgAt;
    String? lastSendType;
    if (messageList.isNotEmpty) {
      lastMsg = messageList.last.content;
      lastMsgAt = messageList.last.timestamp;
      lastSendType = messageList.last.senderType;
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
      lastSenderType: json['lastSenderType'] as String? ?? lastSendType,
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
      lastSenderType:
          msgs.isNotEmpty ? msgs.last.senderType : lastSenderType,
      messages: msgs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startedAt': startedAt.toIso8601String(),
      'tenantId': tenantId,
      'tenantName': tenantName,
      'propertyId': propertyId,
      'propertyTitle': propertyTitle,
      'status': status,
      'lastMessage': lastMessage,
      'lastMessageAt': lastMessageAt?.toIso8601String(),
      'lastSenderType': lastSenderType,
      'messages': messages.map((m) => m.toJson()).toList(),
    };
  }
}

class MessageModel {
  const MessageModel({
    required this.id,
    required this.sessionId,
    required this.senderType,
    required this.content,
    this.mediaUrl,
    required this.status,
    required this.timestamp,
    this.wamid,
  });

  final String id;
  final String sessionId;
  final String senderType;
  final String content;
  final String? mediaUrl;
  final String status;
  final DateTime timestamp;
  final String? wamid;

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String? ?? json['session_id'] as String,
      senderType:
          json['senderType'] as String? ?? json['sender_type'] as String,
      content: json['content'] as String,
      mediaUrl: json['mediaUrl'] as String?,
      status: json['status'] as String? ?? 'sent',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      wamid: json['wamid'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'senderType': senderType,
      'content': content,
      'mediaUrl': mediaUrl,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
      'wamid': wamid,
    };
  }
}

String senderTypeLabel(String senderType) {
  switch (senderType) {
    case 'BOT':
      return 'Assistente';
    case 'TENANT':
      return 'Cliente';
    case 'LANDLORD':
      return 'Fornecedor';
    default:
      return senderType;
  }
}
