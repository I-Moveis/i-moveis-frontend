import '../../domain/entities/app_notification.dart';
import 'notifications_remote_datasource.dart';

class NotificationsRemoteMockDataSource implements NotificationsRemoteDataSource {
  @override
  Future<List<AppNotification>> getNotifications({bool? unreadOnly}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    final all = <AppNotification>[
      AppNotification(
        id: 'mock-1',
        title: 'Manutenção programada',
        body: 'O sistema ficará em manutenção neste sábado das 02h às 04h.',
        receivedAt: now.subtract(const Duration(hours: 2)),
        read: false,
        category: 'announcement',
      ),
      AppNotification(
        id: 'mock-2',
        title: 'Nova política de uso',
        body: 'Atualizamos nossos termos de uso. Acesse o perfil para conferir.',
        receivedAt: now.subtract(const Duration(days: 1)),
        read: false,
        category: 'system',
      ),
      AppNotification(
        id: 'mock-3',
        title: 'Bem-vindo ao i-Moveis',
        body: 'Sua conta foi criada com sucesso. Explore os imóveis disponíveis.',
        receivedAt: now.subtract(const Duration(days: 5)),
        read: true,
        category: 'update',
      ),
    ];
    if (unreadOnly == true) return all.where((n) => !n.read).toList();
    return all;
  }

  @override
  Future<void> markAllAsRead() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> markAsRead(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
  }

  @override
  Future<int> unreadCount() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return 2;
  }
}
