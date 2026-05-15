import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/providers/shared_preferences_provider.dart';
import '../domain/entities/app_notification.dart';
import 'datasources/notifications_remote_data_source_provider.dart';
import 'datasources/notifications_remote_datasource.dart';

/// Camada de persistência das notificações. **Estratégia atual**: o
/// backend é a fonte de verdade (`GET /api/notifications` cross-device);
/// o cache local em SharedPreferences serve como fallback offline e como
/// destino de pushes recebidos via FCM enquanto o usuário está com o
/// app aberto.
///
/// Marcar como lido propaga pro backend (`PUT /:id/read` ou
/// `PATCH /read-all`) e também atualiza o cache local em sync, pra a
/// UI refletir imediatamente sem esperar refetch.
class NotificationsRepository {
  NotificationsRepository({
    required SharedPreferences prefs,
    required NotificationsRemoteDataSource remote,
  })  : _prefs = prefs,
        _remote = remote;

  final SharedPreferences _prefs;
  final NotificationsRemoteDataSource _remote;

  static const _key = 'notifications.cache';

  /// Lê a versão cacheada localmente. Use [fetchRemote] pra sincronizar.
  List<AppNotification> list() {
    final raw = _prefs.getString(_key);
    if (raw == null) return const [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<dynamic, dynamic>>()
          .map(
              (m) => AppNotification.fromJson(Map<String, dynamic>.from(m)))
          .toList()
        ..sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
    } on Object catch (e) {
      if (kDebugMode) debugPrint('[notifications] decode falha: $e');
      return const [];
    }
  }

  /// Busca a lista atualizada do backend e sobrescreve o cache local.
  /// Em falha, mantém o cache atual e devolve a lista cacheada.
  Future<List<AppNotification>> fetchRemote({bool unreadOnly = false}) async {
    try {
      final remote = await _remote.getNotifications(unreadOnly: unreadOnly);
      // Quando filtrado, NÃO sobrescreve o cache (perderia notificações lidas).
      if (!unreadOnly) await _write(remote);
      return remote;
    } on Object catch (e) {
      if (kDebugMode) debugPrint('[notifications] fetchRemote falha: $e');
      return list();
    }
  }

  Future<int> unreadCount() async {
    try {
      return await _remote.unreadCount();
    } on Object {
      return list().where((n) => !n.read).length;
    }
  }

  Future<void> add(AppNotification notification) async {
    final current = list();
    final deduped = [
      notification,
      ...current.where((n) => n.id != notification.id),
    ];
    await _write(deduped);
  }

  Future<void> markAllRead() async {
    try {
      await _remote.markAllAsRead();
    } on Object catch (e) {
      if (kDebugMode) debugPrint('[notifications] markAllRead remoto: $e');
    }
    final updated =
        list().map((n) => n.read ? n : n.copyWith(read: true)).toList();
    await _write(updated);
  }

  Future<void> markRead(String id) async {
    try {
      await _remote.markAsRead(id);
    } on Object catch (e) {
      if (kDebugMode) debugPrint('[notifications] markRead($id) remoto: $e');
    }
    final updated = list()
        .map((n) => n.id == id && !n.read ? n.copyWith(read: true) : n)
        .toList();
    await _write(updated);
  }

  Future<void> clear() async {
    await _prefs.remove(_key);
  }

  Future<void> _write(List<AppNotification> notifications) async {
    await _prefs.setString(
      _key,
      jsonEncode(notifications.map((n) => n.toJson()).toList()),
    );
  }
}

final notificationsRepositoryProvider =
    Provider<NotificationsRepository>((ref) {
  return NotificationsRepository(
    prefs: ref.watch(sharedPreferencesProvider),
    remote: ref.watch(notificationsRemoteDataSourceProvider),
  );
});
