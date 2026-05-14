import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/socket_service.dart';
import '../../data/support_ticket_repository.dart';
import '../../domain/entities/support_ticket_message.dart';

final ticketMessagesProvider = AsyncNotifierProvider.family<
    TicketMessagesNotifier, List<SupportTicketMessage>, String>(
  (arg) => TicketMessagesNotifier(arg),
);

class TicketMessagesNotifier extends AsyncNotifier<List<SupportTicketMessage>> {
  TicketMessagesNotifier(this._ticketId);
  final String _ticketId;

  StreamSubscription<Map<String, dynamic>>? _wsSub;

  // Tier 1: Deduplicacao
  final _knownMessageIds = <String>{};

  // Tier 1: Gap fix cursor
  DateTime? _lastRestTimestamp;

  @override
  Future<List<SupportTicketMessage>> build() async {
    final repo = ref.read(supportTicketRepositoryProvider);
    final messages = await repo.getMessages(_ticketId);

    // Popula dedup com IDs carregados via REST
    _knownMessageIds.addAll(messages.map((m) => m.id));

    // Define cursor para gap fix
    if (messages.isNotEmpty) {
      _lastRestTimestamp = messages.last.timestamp;
    }

    _listenWebSocket();

    ref.onDispose(() {
      _wsSub?.cancel();
      ref.read(socketServiceProvider).leaveTicket(_ticketId);
    });

    return messages;
  }

  // Tier 1: UI Otimista
  Future<void> send(String content) async {
    // Gera ID unico para idempotencia no backend
    final clientId =
        '${DateTime.now().millisecondsSinceEpoch}_${_ticketId.hashCode}';

    final optimistic = SupportTicketMessage(
      id: clientId,
      ticketId: _ticketId,
      senderId: 'self',
      senderRole: 'LANDLORD',
      content: content,
      timestamp: DateTime.now(),
    );

    // Append otimista imediato (latencia 0ms)
    final current = state.asData?.value ?? [];
    state = AsyncData([...current, optimistic]);

    try {
      final repo = ref.read(supportTicketRepositoryProvider);
      final msg = await repo.sendMessage(
        ticketId: _ticketId,
        content: content,
        clientMessageId: clientId,
      );

      // Substitui temp pelo real (mantem ordem)
      final updated = (state.asData?.value ?? [])
          .map((m) => m.id == clientId ? msg : m)
          .toList();
      state = AsyncData(updated);
      _knownMessageIds.add(msg.id);
    } catch (_) {
      // Rollback: remove a mensagem otimista em caso de falha
      final rolledBack =
          (state.asData?.value ?? []).where((m) => m.id != clientId).toList();
      state = AsyncData(rolledBack);
    }
  }

  void _listenWebSocket() {
    final socket = ref.read(socketServiceProvider);
    socket.joinTicket(_ticketId);

    _wsSub = socket.onTicketMessage.listen((data) {
      try {
        final payloadTicketId = data['ticketId'] as String?;
        if (payloadTicketId != _ticketId) return;

        final msgJson = data['message'] as Map<String, dynamic>?;
        if (msgJson == null) return;

        final msg = SupportTicketMessage.fromJson(msgJson);

        // Tier 1: Dedup
        if (_knownMessageIds.contains(msg.id)) return;

        // Tier 1: Gap fix
        if (_lastRestTimestamp != null &&
            msg.timestamp.isBefore(_lastRestTimestamp!)) {
          return;
        }

        _knownMessageIds.add(msg.id);

        // Remove temp otimista se existir (caso socket chegue antes do REST)
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
