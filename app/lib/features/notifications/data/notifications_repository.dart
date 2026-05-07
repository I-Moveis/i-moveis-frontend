import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/providers/shared_preferences_provider.dart';
import '../domain/entities/app_notification.dart';

/// Persiste as notificações recebidas pelo usuário num cache local
/// (SharedPreferences). Quando o listener FCM for ligado (ou quando o
/// backend expuser `GET /api/notifications` — ver
/// `BACKEND_PENDENCIAS_LANDLORD.md §11`), este repo vira a fonte de
/// verdade para a tela — os dois podem coexistir: push recebido é
/// inserido aqui, refresh do backend substitui a lista.
class NotificationsRepository {
  NotificationsRepository({required SharedPreferences prefs}) : _prefs = prefs;
  final SharedPreferences _prefs;

  static const _key = 'notifications.cache';

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

  Future<void> add(AppNotification notification) async {
    final current = list();
    final deduped = [
      notification,
      ...current.where((n) => n.id != notification.id),
    ];
    await _write(deduped);
  }

  Future<void> markAllRead() async {
    final updated =
        list().map((n) => n.read ? n : n.copyWith(read: true)).toList();
    await _write(updated);
  }

  Future<void> markRead(String id) async {
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
  );
});
