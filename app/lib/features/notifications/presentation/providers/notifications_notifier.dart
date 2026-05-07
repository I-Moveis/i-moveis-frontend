import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/notifications_repository.dart';
import '../../domain/entities/app_notification.dart';

/// Estado atual da lista de notificações do usuário. Sincroniza com o
/// [NotificationsRepository] (cache local) em todas as operações.
class NotificationsNotifier extends Notifier<List<AppNotification>> {
  @override
  List<AppNotification> build() {
    return ref.read(notificationsRepositoryProvider).list();
  }

  /// Marca todas como lidas. Não remove o badge do sino — quem gerencia
  /// o badge olha [unreadCount] no estado corrente.
  Future<void> markAllRead() async {
    await ref.read(notificationsRepositoryProvider).markAllRead();
    state = ref.read(notificationsRepositoryProvider).list();
  }

  Future<void> markRead(String id) async {
    await ref.read(notificationsRepositoryProvider).markRead(id);
    state = ref.read(notificationsRepositoryProvider).list();
  }

  /// Insere uma notificação recebida (hoje gerada manualmente em dev;
  /// no futuro, chamada pelo listener do FCM assim que ele for ligado).
  Future<void> ingest(AppNotification notification) async {
    await ref.read(notificationsRepositoryProvider).add(notification);
    state = ref.read(notificationsRepositoryProvider).list();
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

/// Contador derivado — quantidade de notificações não lidas. Usado pelo
/// dot vermelho do sino.
final unreadNotificationsCountProvider = Provider<int>((ref) {
  final items = ref.watch(notificationsNotifierProvider);
  return items.where((n) => !n.read).length;
});
