class MessageModel {
  final String id;
  final String sessionId;
  final String senderType;
  final String content;
  final String? mediaUrl;
  final String status;
  final DateTime timestamp;
  final String? wamid;

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

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String? ?? json['session_id'] as String,
      senderType: json['senderType'] as String? ?? json['sender_type'] as String,
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

class ChatSessionModel {
  final String id;
  final String tenantId;
  final String? propertyId;
  final String? propertyTitle;
  final String? propertyLandlordId;
  final String status;
  final DateTime startedAt;
  final DateTime? expiresAt;
  final String? tenantName;
  final String? tenantPhone;
  final int? messageCount;
  final String? lastMessage;
  final String? lastSenderType;
  final DateTime? lastMessageAt;

  const ChatSessionModel({
    required this.id,
    required this.tenantId,
    this.propertyId,
    this.propertyTitle,
    this.propertyLandlordId,
    required this.status,
    required this.startedAt,
    this.expiresAt,
    this.tenantName,
    this.tenantPhone,
    this.messageCount,
    this.lastMessage,
    this.lastSenderType,
    this.lastMessageAt,
  });

  factory ChatSessionModel.fromJson(Map<String, dynamic> json) {
    final tenant = json['tenant'] as Map<String, dynamic>?;
    final property = json['property'] as Map<String, dynamic>?;
    final count = json['_count'] as Map<String, dynamic>?;
    final messages = json['messages'] as List<dynamic>?;
    final lastMsg = (messages != null && messages.isNotEmpty)
        ? messages.first as Map<String, dynamic>
        : null;

    return ChatSessionModel(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String? ?? json['tenant_id'] as String,
      propertyId: json['propertyId'] as String? ?? json['property_id'] as String?,
      propertyTitle: property?['title'] as String?,
      propertyLandlordId: property?['landlordId'] as String? ?? property?['landlord_id'] as String?,
      status: json['status'] as String,
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'] as String? ?? json['started_at'] as String)
          : DateTime.now(),
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'] as String? ?? json['expires_at'] as String)
          : null,
      tenantName: tenant?['name'] as String?,
      tenantPhone: tenant?['phoneNumber'] as String?,
      messageCount: count?['messages'] as int?,
      lastMessage: lastMsg?['content'] as String?,
      lastSenderType: lastMsg != null ? ((lastMsg['senderType'] ?? lastMsg['sender_type']) as String?) : null,
      lastMessageAt: lastMsg != null && lastMsg['timestamp'] != null
          ? DateTime.parse(lastMsg['timestamp'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenantId': tenantId,
      'propertyId': propertyId,
      'propertyTitle': propertyTitle,
      'propertyLandlordId': propertyLandlordId,
      'status': status,
      'startedAt': startedAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'tenantName': tenantName,
      'tenantPhone': tenantPhone,
      'messageCount': messageCount,
      'lastMessage': lastMessage,
      'lastSenderType': lastSenderType,
      'lastMessageAt': lastMessageAt?.toIso8601String(),
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
