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

  @override
  Future<List<SupportTicketMessage>> build() async {
    final repo = ref.read(supportTicketRepositoryProvider);
    final messages = await repo.getMessages(_ticketId);

    _listenWebSocket();

    ref.onDispose(() {
      _wsSub?.cancel();
      ref.read(socketServiceProvider).leaveTicket(_ticketId);
    });

    return messages;
  }

  Future<void> send(String content) async {
    final repo = ref.read(supportTicketRepositoryProvider);
    final msg =
        await repo.sendMessage(ticketId: _ticketId, content: content);
    final current = state.asData?.value ?? [];
    state = AsyncData([...current, msg]);
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
        final current = state.asData?.value ?? [];
        state = AsyncData([...current, msg]);
      } on Object {
        // ignora payloads malformados
      }
    });
  }
}
