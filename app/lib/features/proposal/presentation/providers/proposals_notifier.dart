import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/current_user_provider.dart';
import '../../data/proposal_repository.dart';
import '../../domain/entities/proposal.dart';

/// Lista propostas do usuário logado — como tenant (`Minhas Propostas`)
/// quando [asLandlord] é false; como landlord (`Propostas Recebidas`)
/// quando true.
@immutable
class ProposalsArgs {
  const ProposalsArgs({required this.asLandlord});
  final bool asLandlord;

  @override
  bool operator ==(Object other) =>
      other is ProposalsArgs && other.asLandlord == asLandlord;

  @override
  int get hashCode => asLandlord.hashCode;
}

final proposalsProvider = FutureProvider.family<List<Proposal>, ProposalsArgs>(
  (ref, args) async {
    final userId = await ref.watch(currentUserIdProvider.future);
    if (userId == null || userId.isEmpty) return const [];
    final repo = ref.watch(proposalRepositoryProvider);
    return args.asLandlord
        ? repo.list(landlordId: userId)
        : repo.list(tenantId: userId);
  },
);

/// Sincroniza uma mudança de status (aceitar/recusar) e invalida o
/// provider para refazer o fetch. Aceita `WidgetRef` (das páginas) ou
/// `Ref` (de providers) — ambos têm `read` e `invalidate`.
Future<void> updateProposalStatus(
  WidgetRef ref, {
  required String id,
  required ProposalStatus status,
  required bool asLandlord,
}) async {
  await ref
      .read(proposalRepositoryProvider)
      .updateStatus(id: id, status: status);
  ref.invalidate(proposalsProvider(ProposalsArgs(asLandlord: asLandlord)));
}
