import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/support_ticket_repository.dart';
import '../../domain/entities/support_ticket.dart';

/// Lista de chamados de suporte do usuário corrente. Usa o
/// [SupportTicketRepository] pra carregar — tenta remoto, cai no cache
/// local em falha. Ver `BACKEND_HANDOFF.md §10`.
class SupportTicketsNotifier
    extends AsyncNotifier<List<SupportTicket>> {
  @override
  Future<List<SupportTicket>> build() async {
    return ref.read(supportTicketRepositoryProvider).list();
  }

  Future<SupportTicket> create({
    required String title,
    required String description,
  }) async {
    final repo = ref.read(supportTicketRepositoryProvider);
    final ticket = await repo.create(title: title, description: description);
    // Atualiza o state otimisticamente — coloca o novo no topo. Se o
    // backend devolveu outro código, ele já vem no `ticket` retornado.
    final current = state.asData?.value ?? const <SupportTicket>[];
    state = AsyncValue.data([ticket, ...current]);
    return ticket;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(supportTicketRepositoryProvider).list(),
    );
  }
}

final supportTicketsProvider =
    AsyncNotifierProvider<SupportTicketsNotifier, List<SupportTicket>>(
  SupportTicketsNotifier.new,
);
