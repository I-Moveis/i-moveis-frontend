import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/socket_service.dart';
import '../../data/conversation_repository.dart';
import '../../domain/entities/conversation_message.dart';

final conversationMessagesProvider = AsyncNotifierProvider.family<
    ConversationMessagesNotifier, List<ConversationMessage>, String>(
  (arg) => ConversationMessagesNotifier(arg),
);

class ConversationMessagesNotifier
    extends AsyncNotifier<List<ConversationMessage>> {
  ConversationMessagesNotifier(this._conversationId);
  final String _conversationId;

  StreamSubscription<Map<String, dynamic>>? _wsSub;

  final _knownMessageIds = <String>{};

  @override
  Future<List<ConversationMessage>> build() async {
    final repo = ref.read(conversationRepositoryProvider);
    final messages = await repo.getMessages(_conversationId);

    _knownMessageIds.addAll(messages.map((m) => m.id));

    _listenWebSocket();
    ref.onDispose(() => _wsSub?.cancel());

    return messages;
  }

  Future<void> send(String content) async {
    final clientId =
        '${DateTime.now().millisecondsSinceEpoch}_${_conversationId.hashCode}';

    final optimistic = ConversationMessage(
      id: clientId,
      conversationId: _conversationId,
      authorId: 'self',
      authorName: 'Você',
      content: content,
      timestamp: DateTime.now(),
      isMine: true,
    );

    final current = state.asData?.value ?? [];
    state = AsyncData([...current, optimistic]);

    try {
      final repo = ref.read(conversationRepositoryProvider);
      final msg = await repo.sendMessage(
        conversationId: _conversationId,
        content: content,
      );

      final updated = (state.asData?.value ?? [])
          .map((m) => m.id == clientId ? msg : m)
          .toList();
      state = AsyncData(updated);
      _knownMessageIds.add(msg.id);
    } catch (_) {
      final rolledBack =
          (state.asData?.value ?? []).where((m) => m.id != clientId).toList();
      state = AsyncData(rolledBack);
    }
  }

  void _listenWebSocket() {
    final socket = ref.read(socketServiceProvider);

    _wsSub = socket.onConversationMessage.listen((data) {
      try {
        final payloadConversationId = data['conversationId'] as String?;
        if (payloadConversationId != _conversationId) return;

        final msgJson = data['message'] as Map<String, dynamic>?;
        if (msgJson == null) return;

        final msg = ConversationMessage.fromJson(msgJson);

        if (_knownMessageIds.contains(msg.id)) return;

        _knownMessageIds.add(msg.id);

        final withoutTemps = (state.asData?.value ?? [])
            .where((m) => m.id != msg.id)
            .toList();
        state = AsyncData([...withoutTemps, msg]);
      } on Object {
        // ignora payloads malformados
      }
    });
  }
}
