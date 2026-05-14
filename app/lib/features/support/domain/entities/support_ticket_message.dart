import 'package:flutter/foundation.dart';

@immutable
class SupportTicketMessage {
  const SupportTicketMessage({
    required this.id,
    required this.ticketId,
    required this.senderId,
    required this.senderRole,
    required this.content,
    required this.timestamp,
  });

  final String id;
  final String ticketId;
  final String senderId;
  final String senderRole;
  final String content;
  final DateTime timestamp;

  bool get isFromAdmin => senderRole == 'ADMIN';
  bool get isFromMe => !isFromAdmin;

  String get senderLabel {
    switch (senderRole) {
      case 'ADMIN':
        return 'Suporte';
      case 'LANDLORD':
        return 'Proprietário';
      case 'TENANT':
        return 'Inquilino';
      default:
        return senderRole;
    }
  }

  factory SupportTicketMessage.fromJson(Map<String, dynamic> json) =>
      SupportTicketMessage(
        id: json['id'] as String,
        ticketId: json['ticketId'] as String,
        senderId: json['senderId'] as String,
        senderRole: json['senderRole'] as String? ?? 'TENANT',
        content: json['content'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'ticketId': ticketId,
        'senderId': senderId,
        'senderRole': senderRole,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
      };
}
