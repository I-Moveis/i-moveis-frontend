import 'package:dio/dio.dart';

import '../../domain/entities/app_notification.dart';
import 'notifications_remote_datasource.dart';

class NotificationsRemoteApiDataSource implements NotificationsRemoteDataSource {
  NotificationsRemoteApiDataSource(this._dio);

  final Dio _dio;

  /// GET /notifications → bare array [ NotificationView, ... ]
  /// Backend fields (US-013): id, title, body, receivedAt, read (bool), category
  @override
  Future<List<AppNotification>> getNotifications() async {
    final res = await _dio.get<List<dynamic>>('/notifications');
    final list = res.data;
    if (list == null) return const [];
    return [
      for (final e in list)
        if (e is Map) _fromBackend(Map<String, dynamic>.from(e)),
    ];
  }

  /// PATCH /notifications/read-all
  @override
  Future<void> markAllAsRead() async {
    await _dio.patch<void>('/notifications/read-all');
  }

  AppNotification _fromBackend(Map<String, dynamic> json) {
    return AppNotification(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      receivedAt:
          DateTime.tryParse((json['receivedAt'] ?? '').toString())?.toLocal() ??
              DateTime.now(),
      read: json['read'] == true,
      category: json['category'] as String?,
    );
  }
}
