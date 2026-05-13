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

/// Dados do usuário autor do ticket, populados pelo endpoint admin.
@immutable
class TicketUser {
  const TicketUser({
    required this.id,
    required this.name,
    this.email,
    required this.role,
  });

  factory TicketUser.fromJson(Map<String, dynamic> json) => TicketUser(
        id: (json['id'] as String?) ?? '',
        name: (json['name'] as String?) ?? '',
        email: json['email'] as String?,
        role: (json['role'] as String?) ?? '',
      );

  final String id;
  final String name;
  final String? email;
  final String role;
}

/// Entidade leve do chamado, desenhada pra funcionar com ou sem backend.
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
    this.userName,
    this.userEmail,
    this.assignedToId,
    this.assignedToName,
    this.resolution,
    this.updatedAt,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    final assigned = json['assignedTo'] as Map<String, dynamic>?;
    return SupportTicket(
      id: (json['id'] as String?) ?? (json['code'] as String? ?? ''),
      code: (json['code'] as String?) ?? (json['id'] as String? ?? ''),
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      createdAt: DateTime.tryParse((json['createdAt'] as String?) ?? '')
              ?.toLocal() ??
          DateTime.now(),
      updatedAt: DateTime.tryParse((json['updatedAt'] as String?) ?? '')
              ?.toLocal() ??
          DateTime.now(),
      status: SupportTicketStatus.fromApi(json['status'] as String?),
      userRole: json['userRole'] as String? ?? user?['role'] as String?,
      userName: json['userName'] as String? ?? user?['name'] as String?,
      userEmail: json['userEmail'] as String? ?? user?['email'] as String?,
      assignedToId: json['assignedToId'] as String? ?? assigned?['id'] as String?,
      assignedToName: json['assignedToName'] as String? ?? assigned?['name'] as String?,
      resolution: json['resolution'] as String?,
    );
  }

  final String id;
  final String code;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final SupportTicketStatus status;

  /// Dados do usuário que abriu o chamado (preenchidos pelo endpoint admin).
  final String? userRole;
  final String? userName;
  final String? userEmail;

  /// Admin que está tratando o ticket.
  final String? assignedToId;
  final String? assignedToName;

  /// Texto de resolução final (preenchido no PUT admin).
  final String? resolution;

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'title': title,
        'description': description,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'status': status.toApi(),
        if (userRole != null) 'userRole': userRole,
        if (userName != null) 'userName': userName,
        if (userEmail != null) 'userEmail': userEmail,
        if (assignedToId != null) 'assignedToId': assignedToId,
        if (assignedToName != null) 'assignedToName': assignedToName,
        if (resolution != null) 'resolution': resolution,
      };
}
