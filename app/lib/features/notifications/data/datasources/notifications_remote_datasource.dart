import '../../domain/entities/app_notification.dart';

abstract class NotificationsRemoteDataSource {
  /// GET /notifications — retorna as notificações do usuário do backend.
  Future<List<AppNotification>> getNotifications();

  /// PATCH /notifications/read-all — marca todas como lidas no backend.
  Future<void> markAllAsRead();
}
