import 'package:app/core/constants.dart';
import 'package:app/core/providers/dio_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../datasources/notifications_remote_api_datasource.dart';
import '../datasources/notifications_remote_datasource.dart';
import '../datasources/notifications_remote_mock_datasource.dart';
import '../notifications_repository.dart';

final notificationsRemoteDataSourceProvider =
    Provider<NotificationsRemoteDataSource>((ref) {
  if (kUseMockData) {
    return NotificationsRemoteMockDataSource();
  }
  return NotificationsRemoteApiDataSource(ref.watch(dioProvider));
});

/// Sincroniza notificações do backend para o cache local (SharedPreferences).
/// Retorna a contagem de itens sincronizados. Falha silenciosamente — o
/// cache local é exibido mesmo sem conexão.
final syncNotificationsProvider = FutureProvider<int>((ref) async {
  final remote = ref.watch(notificationsRemoteDataSourceProvider);
  final localRepo = ref.watch(notificationsRepositoryProvider);

  try {
    final notifications = await remote.getNotifications();
    for (final n in notifications) {
      await localRepo.add(n);
    }
    if (kDebugMode) {
      debugPrint('[notifications] sync: ${notifications.length} itens');
    }
    return notifications.length;
  } on Exception catch (e) {
    if (kDebugMode) debugPrint('[notifications] sync falhou: $e');
    return 0;
  }
});
