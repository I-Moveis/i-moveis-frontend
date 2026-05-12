import '../../domain/entities/app_notification.dart';

abstract class NotificationsRemoteDataSource {
  /// GET /notifications — retorna as notificações do usuário do backend.
  Future<List<AppNotification>> getNotifications({bool? unreadOnly});

  /// PATCH /notifications/read-all — marca todas como lidas no backend.
  Future<void> markAllAsRead();

  /// PUT /notifications/:id/read — marca uma notificação como lida.
  /// Idempotente: chamadas subsequentes preservam o `readAt` original.
  Future<void> markAsRead(String id);

  /// GET /notifications/unread-count — retorna o badge counter atual.
  Future<int> unreadCount();
}
