import 'package:flutter/foundation.dart';

/// Notificação recebida pelo usuário (tenant ou landlord). Hoje a fonte
/// principal é o **broadcast do admin** (`POST /api/admin/broadcast` no
/// backend — FCM dispara push pra todos os devices com `fcmToken` ativo).
///
/// Enquanto o app não tem listener FCM integrado, a tela lê o cache
/// local (SharedPreferences) que pode ser populado: (a) por um listener
/// `onMessage` quando o Firebase Messaging for ligado; (b) manualmente
/// em dev pra testar a UI; ou (c) por um endpoint
/// `GET /api/notifications` quando o backend existir (ver
/// `BACKEND_PENDENCIAS_LANDLORD.md §11`).
@immutable
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.receivedAt,
    this.read = false,
    this.category,
  });

  /// Id estável — UUID quando vem do backend, timestamp-based quando
  /// gerado localmente a partir de um push.
  final String id;
  final String title;
  final String body;
  final DateTime receivedAt;

  /// Marcado quando o usuário abre a tela de notificações. Persistido
  /// junto no SharedPreferences pro estado sobreviver ao restart.
  final bool read;

  /// Tag opcional pra agrupar/colorir na UI (`'update'`, `'announcement'`,
  /// `'system'`, etc.). Sem valor padrão — UI renderiza neutro quando
  /// ausente.
  final String? category;

  AppNotification copyWith({bool? read}) => AppNotification(
        id: id,
        title: title,
        body: body,
        receivedAt: receivedAt,
        read: read ?? this.read,
        category: category,
      );

  factory AppNotification.fromJson(Map<String, dynamic> json) {
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'receivedAt': receivedAt.toIso8601String(),
        'read': read,
        if (category != null) 'category': category,
      };
}
