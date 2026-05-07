import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/dio_provider.dart';
import '../../domain/entities/conversation_summary.dart';

/// Carrega a lista de conversas do usuário via `GET /api/conversations`.
/// Endpoint ainda não existe no backend (ver `BACKEND_HANDOFF.md §4`),
/// então o notifier cai em lista vazia em qualquer erro. Quando o
/// backend subir, o mesmo código começa a popular automaticamente.
class ConversationsNotifier
    extends AsyncNotifier<List<ConversationSummary>> {
  @override
  Future<List<ConversationSummary>> build() async {
    final dio = ref.read(dioProvider);
    try {
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
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[chat] GET /conversations falhou '
          '(${e.response?.statusCode ?? '---'}): ${e.message}',
        );
      }
      return const [];
    } on Object catch (e) {
      if (kDebugMode) debugPrint('[chat] GET falha inesperada: $e');
      return const [];
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(build);
  }
}

final conversationsProvider =
    AsyncNotifierProvider<ConversationsNotifier, List<ConversationSummary>>(
  ConversationsNotifier.new,
);
