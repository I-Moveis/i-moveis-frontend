import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants.dart';
import '../../../../core/providers/dio_provider.dart';
import 'notifications_remote_api_datasource.dart';
import 'notifications_remote_datasource.dart';
import 'notifications_remote_mock_datasource.dart';

/// Provider único do data source de notificações. Mora em arquivo
/// próprio porque é referenciado pelo repository e pelo
/// `notifications_data_providers.dart` — manter aqui evita ciclo de
/// imports entre repository ↔ providers.
final notificationsRemoteDataSourceProvider =
    Provider<NotificationsRemoteDataSource>((ref) {
  if (kUseMockData) {
    return NotificationsRemoteMockDataSource();
  }
  return NotificationsRemoteApiDataSource(ref.watch(dioProvider));
});
