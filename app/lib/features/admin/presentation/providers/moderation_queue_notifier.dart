import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../search/data/providers/data_providers.dart';
import '../../../search/domain/entities/property.dart';
import '../../data/providers/admin_data_providers.dart';

/// Fila de moderação — lê `/admin/properties?status=<X>` e aciona
/// `PUT /properties/:id/moderation` via o repositório de Property.
class ModerationQueueNotifier extends AsyncNotifier<List<Property>> {
  /// Status corrente sendo visualizado (PENDING | APPROVED | REJECTED).
  String _status = 'PENDING';
  String get status => _status;

  @override
  Future<List<Property>> build() async {
    return _fetch(_status);
  }

  Future<List<Property>> _fetch(String status) async {
    final repo = ref.read(adminRepositoryProvider);
    final page = await repo.listForModeration(status: status);
    return page.items;
  }

  Future<void> setStatus(String status) async {
    if (status == _status) return;
    _status = status;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch(_status));
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch(_status));
  }

  /// Aprova; remove da lista se a fila atual é PENDING.
  Future<void> approve(String id) async {
    await ref.read(dataPropertyRepositoryProvider).moderate(
          id: id,
          decision: 'APPROVED',
        );
    _evictIfCurrentStatusHides('APPROVED', id);
  }

  /// Rejeita com motivo obrigatório.
  Future<void> reject(String id, String reason) async {
    await ref.read(dataPropertyRepositoryProvider).moderate(
          id: id,
          decision: 'REJECTED',
          reason: reason,
        );
    _evictIfCurrentStatusHides('REJECTED', id);
  }

  /// Remove imóvel (DELETE) — delega ao repo de Property.
  Future<void> deleteProperty(String id) async {
    await ref.read(dataPropertyRepositoryProvider).delete(id);
    final current = state.value ?? const <Property>[];
    state = AsyncValue.data(current.where((p) => p.id != id).toList());
  }

  void _evictIfCurrentStatusHides(String newStatus, String id) {
    final current = state.value ?? const <Property>[];
    if (newStatus != _status) {
      state = AsyncValue.data(current.where((p) => p.id != id).toList());
    } else {
      // Status continua no filtro — só atualiza o campo moderationStatus.
      state = AsyncValue.data([
        for (final p in current)
          if (p.id == id) p.copyWith(moderationStatus: newStatus) else p,
      ]);
    }
  }
}

final moderationQueueNotifierProvider =
    AsyncNotifierProvider<ModerationQueueNotifier, List<Property>>(
  ModerationQueueNotifier.new,
);
