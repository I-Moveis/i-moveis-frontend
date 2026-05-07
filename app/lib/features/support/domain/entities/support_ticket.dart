import 'package:flutter/foundation.dart';

/// Status do chamado de suporte. Espelha o que o backend vai expor em
/// `GET /api/support/tickets` quando o recurso existir (ver
/// `BACKEND_HANDOFF.md §10`).
enum SupportTicketStatus {
  open,
  awaitingUser,
  resolved;

  String get label {
    switch (this) {
      case SupportTicketStatus.open:
        return 'Aberto';
      case SupportTicketStatus.awaitingUser:
        return 'Aguardando você';
      case SupportTicketStatus.resolved:
        return 'Resolvido';
    }
  }

  static SupportTicketStatus fromApi(String? raw) {
    switch (raw) {
      case 'AWAITING_USER':
        return SupportTicketStatus.awaitingUser;
      case 'RESOLVED':
      case 'CLOSED':
        return SupportTicketStatus.resolved;
      case 'OPEN':
      default:
        return SupportTicketStatus.open;
    }
  }

  String toApi() {
    switch (this) {
      case SupportTicketStatus.awaitingUser:
        return 'AWAITING_USER';
      case SupportTicketStatus.resolved:
        return 'RESOLVED';
      case SupportTicketStatus.open:
        return 'OPEN';
    }
  }
}

/// Entidade leve do chamado, desenhada pra funcionar com ou sem backend.
/// Enquanto o `POST /api/support/tickets` não existir, o repo usa
/// SharedPreferences. Quando existir, a entity absorve o shape do JSON
/// sem mudanças — ver `BACKEND_HANDOFF.md §10`.
@immutable
class SupportTicket {
  const SupportTicket({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.status,
    this.userRole,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) => SupportTicket(
        id: (json['id'] as String?) ?? (json['code'] as String? ?? ''),
        code: (json['code'] as String?) ?? (json['id'] as String? ?? ''),
        title: (json['title'] as String?) ?? '',
        description: (json['description'] as String?) ?? '',
        createdAt: DateTime.tryParse((json['createdAt'] as String?) ?? '')
                ?.toLocal() ??
            DateTime.now(),
        status: SupportTicketStatus.fromApi(json['status'] as String?),
        userRole: json['userRole'] as String?,
      );

  /// Id estável — quando vem do backend, UUID. Quando local, o próprio
  /// `code` (formato `SUP-AAMMDD-XXXX`).
  final String id;

  /// Código humano-legível que o usuário vê e usa pra rastrear.
  final String code;

  final String title;
  final String description;
  final DateTime createdAt;
  final SupportTicketStatus status;

  /// `TENANT | LANDLORD | ADMIN` — só serve quando o admin for visualizar.
  /// Do lado do landlord/tenant a tela não precisa disso; guardamos pra
  /// quando a mesma entity for consumida pelo painel admin.
  final String? userRole;

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'title': title,
        'description': description,
        'createdAt': createdAt.toIso8601String(),
        'status': status.toApi(),
        if (userRole != null) 'userRole': userRole,
      };
}
