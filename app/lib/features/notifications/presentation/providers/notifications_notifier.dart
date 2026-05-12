import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/notifications_repository.dart';
import '../../domain/entities/app_notification.dart';

/// Estado atual da lista de notificações do usuário.
///
/// Inicializa com o cache local (rápido) e dispara um fetch remoto em
/// background pra atualizar com o que o backend tem (cross-device).
class NotificationsNotifier extends Notifier<List<AppNotification>> {
  @override
  List<AppNotification> build() {
    final repo = ref.read(notificationsRepositoryProvider);
    final cached = repo.list();
    // Fire-and-forget: pega a lista mais nova do backend e troca o state.
    // Cache local foi sobrescrito dentro de fetchRemote().
    Future.microtask(() async {
      final remote = await repo.fetchRemote();
      if (remote.isNotEmpty || cached.isEmpty) state = remote;
    });
    return cached;
  }

  /// Marca todas como lidas. Sincroniza no backend e no cache local.
  Future<void> markAllRead() async {
    await ref.read(notificationsRepositoryProvider).markAllRead();
    state = ref.read(notificationsRepositoryProvider).list();
  }

  Future<void> markRead(String id) async {
    await ref.read(notificationsRepositoryProvider).markRead(id);
    state = ref.read(notificationsRepositoryProvider).list();
  }

  /// Insere uma notificação recebida (FCM em foreground, ou ingest
  /// manual em dev). Adiciona apenas no cache local — o backend já
  /// possui o registro do envio do broadcast.
  Future<void> ingest(AppNotification notification) async {
    await ref.read(notificationsRepositoryProvider).add(notification);
    state = ref.read(notificationsRepositoryProvider).list();
  }

  Future<void> refresh() async {
    final remote = await ref
        .read(notificationsRepositoryProvider)
        .fetchRemote();
    state = remote;
  }

  Future<void> clear() async {
    await ref.read(notificationsRepositoryProvider).clear();
    state = const [];
  }
}

final notificationsNotifierProvider =
    NotifierProvider<NotificationsNotifier, List<AppNotification>>(
  NotificationsNotifier.new,
);

/// Contador derivado da lista local — usado pelo dot vermelho do sino
/// no header. Em sync com `state` do notifier (já espelha o backend).
final unreadNotificationsCountProvider = Provider<int>((ref) {
  final items = ref.watch(notificationsNotifierProvider);
  return items.where((n) => !n.read).length;
});
