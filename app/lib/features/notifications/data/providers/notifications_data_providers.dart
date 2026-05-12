import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notifications_repository.dart';

// Re-exporta o provider do data source pra callers existentes não
// quebrarem. A definição mora em
// datasources/notifications_remote_data_source_provider.dart pra evitar
// import cíclico com o repository.
export '../datasources/notifications_remote_data_source_provider.dart';

/// Sincroniza notificações do backend pro cache local. Retorna a
/// contagem sincronizada. Em falha, devolve 0 e mantém o cache.
final syncNotificationsProvider = FutureProvider<int>((ref) async {
  try {
    final list = await ref
        .read(notificationsRepositoryProvider)
        .fetchRemote();
    if (kDebugMode) {
      debugPrint('[notifications] sync: ${list.length} itens');
    }
    return list.length;
  } on Exception catch (e) {
    if (kDebugMode) debugPrint('[notifications] sync falhou: $e');
    return 0;
  }
});
