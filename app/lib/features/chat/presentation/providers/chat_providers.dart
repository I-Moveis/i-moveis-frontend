import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/dio_provider.dart';
import '../../../../core/services/socket_service.dart';
import '../../data/models/chat_models.dart';

// ── Sessions (lista de conversas) ────────────────────────────────────────────

class SessionsNotifier extends AsyncNotifier<List<ChatSessionModel>> {
  @override
  Future<List<ChatSessionModel>> build() async {
    _listenWebSocket();
    return _fetchSessions();
  }

  Future<List<ChatSessionModel>> _fetchSessions() async {
    final dio = ref.read(dioProvider);
    try {
      final response = await dio.get<dynamic>('/chat/sessions');
      final data = response.data;
      final list = data is List
          ? data
          : (data is Map && data['data'] is List)
              ? data['data'] as List
              : null;
      if (list == null) return const [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(ChatSessionModel.fromJson)
          .toList()
        ..sort((a, b) {
          final aTime = a.lastMessageAt ?? a.startedAt;
          final bTime = b.lastMessageAt ?? b.startedAt;
          return bTime.compareTo(aTime);
        });
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[chat] GET /chat/sessions falhou '
          '(${e.response?.statusCode ?? '---'}): ${e.message}',
        );
      }
      return const [];
    } on Object catch (e) {
      if (kDebugMode) debugPrint('[chat] GET falha inesperada: $e');
      return const [];
    }
  }

  void _listenWebSocket() {
    final socket = ref.read(socketServiceProvider);
    final sub = socket.onNewMessage.listen((data) {
      final sessionId = data['sessionId'] as String?;
      if (sessionId == null) return;
      final current = state.asData?.value ?? [];
      final updated = current.map((s) {
        if (s.id != sessionId) return s;
        try {
          final msgJson = data['message'] as Map<String, dynamic>?;
          if (msgJson == null) return s;
          final msg = MessageModel.fromJson(msgJson);
          return s.copyWith(messages: [...s.messages, msg]);
        } on Object {
          return s;
        }
      }).toList();
      state = AsyncData(updated);
    });
    ref.onDispose(sub.cancel);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _fetchSessions());
  }
}

final sessionsProvider =
    AsyncNotifierProvider<SessionsNotifier, List<ChatSessionModel>>(
  SessionsNotifier.new,
);

// ── Session messages (histórico de uma conversa) ─────────────────────────────

class SessionMessagesNotifier extends AsyncNotifier<List<MessageModel>> {
  SessionMessagesNotifier(this._sessionId);
  final String _sessionId;

  StreamSubscription<Map<String, dynamic>>? _wsSub;

  @override
  Future<List<MessageModel>> build() async {
    final dio = ref.read(dioProvider);

    List<MessageModel> messages = [];
    try {
      final response = await dio.get<dynamic>('/chat/sessions/$_sessionId');
      final data = response.data;
      if (data is Map) {
        final rawMsgs = data['messages'];
        if (rawMsgs is List) {
          messages = rawMsgs
              .whereType<Map<String, dynamic>>()
              .map(MessageModel.fromJson)
              .toList();
        }
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint(
            '[chat] GET /chat/sessions/$_sessionId falhou: ${e.message}');
      }
    } on Object catch (e) {
      if (kDebugMode) debugPrint('[chat] GET session falha inesperada: $e');
    }

    _listenWebSocket(_sessionId);
    ref.onDispose(() => _wsSub?.cancel());

    return messages;
  }

  void _listenWebSocket(String sessionId) {
    final socket = ref.read(socketServiceProvider);
    _wsSub = socket.onNewMessage.listen((data) {
      try {
        final payloadSessionId = data['sessionId'] as String?;
        if (payloadSessionId != sessionId) return;

        final msgJson = data['message'] as Map<String, dynamic>?;
        if (msgJson == null) return;

        final msg = MessageModel.fromJson(msgJson);
        final current = state.asData?.value ?? [];
        state = AsyncData([...current, msg]);
      } on Object {
        // ignora payloads malformados
      }
    });
  }
}

final sessionMessagesProvider =
    AsyncNotifierProvider.family<SessionMessagesNotifier, List<MessageModel>,
        String>(
  (arg) => SessionMessagesNotifier(arg),
);

// ── Send message ─────────────────────────────────────────────────────────────

Future<void> sendChatMessage({
  required WidgetRef ref,
  required String sessionId,
  required String content,
}) async {
  final dio = ref.read(dioProvider);
  await dio.post<dynamic>(
    '/chat/messages',
    data: {
      'sessionId': sessionId,
      'senderType': 'LANDLORD',
      'content': content,
    },
  );
}
