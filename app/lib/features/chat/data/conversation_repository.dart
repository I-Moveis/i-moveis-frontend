import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/dio_provider.dart';
import '../domain/entities/conversation_summary.dart';
import '../domain/entities/conversation_message.dart';

class ConversationRepository {
  const ConversationRepository({required this.dio});
  final Dio dio;

  Future<List<ConversationSummary>> list() async {
    final response = await dio.get<dynamic>('/conversations');
    final data = response.data;
    final list = data is List
        ? data
        : (data is Map && data['data'] is List)
            ? data['data'] as List
            : null;
    if (list == null) return const [];
    return list
        .whereType<Map<dynamic, dynamic>>()
        .map((m) =>
            ConversationSummary.fromJson(Map<String, dynamic>.from(m)))
        .toList()
      ..sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
  }

  Future<List<ConversationMessage>> getMessages(String conversationId) async {
    final response =
        await dio.get<dynamic>('/conversations/$conversationId/messages');
    final data = response.data;
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map((m) => ConversationMessage.fromJson(m))
          .toList();
    }
    return [];
  }

  Future<ConversationMessage> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    final response = await dio.post<Map<String, dynamic>>(
      '/conversations/$conversationId/messages',
      data: {'content': content},
    );
    return ConversationMessage.fromJson(response.data!);
  }

  Future<String> resolve(String propertyId, String tenantId) async {
    final response = await dio.get<dynamic>(
      '/conversations/resolve',
      queryParameters: {
        'propertyId': propertyId,
        'tenantId': tenantId,
      },
    );
    return (response.data as Map<String, dynamic>)['id'] as String;
  }
}

final conversationRepositoryProvider = Provider<ConversationRepository>((ref) {
  return ConversationRepository(dio: ref.watch(dioProvider));
});
