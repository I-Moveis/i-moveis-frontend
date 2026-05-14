import 'package:flutter/foundation.dart';

@immutable
class ConversationMessage {
  const ConversationMessage({
    required this.id,
    required this.conversationId,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.timestamp,
    this.isMine = false,
  });

  final String id;
  final String conversationId;
  final String authorId;
  final String authorName;
  final String content;
  final DateTime timestamp;
  final bool isMine;

  factory ConversationMessage.fromJson(Map<String, dynamic> json) =>
      ConversationMessage(
        id: json['id'] as String,
        conversationId: json['conversationId'] as String? ?? '',
        authorId: json['authorId'] as String? ?? '',
        authorName: json['authorName'] as String? ?? 'Usuário',
        content: json['content'] as String,
        timestamp: DateTime.parse(
          (json['createdAt'] ?? json['timestamp']) as String,
        ),
        isMine: json['isMine'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'conversationId': conversationId,
        'authorId': authorId,
        'authorName': authorName,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
      };
}
