import 'package:flutter/foundation.dart';

/// Status da proposta — espelha o enum `ProposalStatus` do backend
/// (`PENDING | ACCEPTED | REJECTED | COUNTER_OFFER | WITHDRAWN`).
enum ProposalStatus {
  pending,
  accepted,
  rejected,
  counterOffer,
  withdrawn;

  static ProposalStatus fromBackend(String? raw) {
    switch (raw) {
      case 'ACCEPTED':
        return ProposalStatus.accepted;
      case 'REJECTED':
        return ProposalStatus.rejected;
      case 'COUNTER_OFFER':
        return ProposalStatus.counterOffer;
      case 'WITHDRAWN':
        return ProposalStatus.withdrawn;
      case 'PENDING':
      default:
        return ProposalStatus.pending;
    }
  }

  String toBackend() {
    switch (this) {
      case ProposalStatus.accepted:
        return 'ACCEPTED';
      case ProposalStatus.rejected:
        return 'REJECTED';
      case ProposalStatus.counterOffer:
        return 'COUNTER_OFFER';
      case ProposalStatus.withdrawn:
        return 'WITHDRAWN';
      case ProposalStatus.pending:
        return 'PENDING';
    }
  }

  /// Label PT-BR pra chip de status na UI.
  String get label {
    switch (this) {
      case ProposalStatus.pending:
        return 'Aguardando';
      case ProposalStatus.accepted:
        return 'Aceita';
      case ProposalStatus.rejected:
        return 'Recusada';
      case ProposalStatus.counterOffer:
        return 'Contraproposta';
      case ProposalStatus.withdrawn:
        return 'Retirada';
    }
  }
}

@immutable
class Proposal {
  const Proposal({
    required this.id,
    required this.propertyId,
    required this.tenantId,
    required this.proposedPrice,
    required this.status,
    required this.createdAt,
    this.message,
    this.tenantName,
    this.tenantEmail,
    this.tenantPhone,
    this.propertyTitle,
    this.propertyOriginalPrice,
    this.landlordId,
  });

  final String id;
  final String propertyId;
  final String tenantId;
  final double proposedPrice;
  final ProposalStatus status;
  final DateTime createdAt;
  final String? message;

  /// Vem do `include` do backend — tenant.name. Quando o ponto de vista
  /// é landlord, é o nome de quem mandou a proposta. Para tenant, é o
  /// próprio nome (geralmente irrelevante na UI dele).
  final String? tenantName;
  final String? tenantEmail;
  final String? tenantPhone;

  /// `property.title` no include. Mostrado em ambos os lados.
  final String? propertyTitle;

  /// `property.price` original (string formatada do backend).
  final String? propertyOriginalPrice;

  final String? landlordId;

  factory Proposal.fromJson(Map<String, dynamic> json) {
    final tenant = json['tenant'] as Map<String, dynamic>?;
    final property = json['property'] as Map<String, dynamic>?;
    return Proposal(
      id: (json['id'] ?? '').toString(),
      propertyId: (json['propertyId'] ?? property?['id'] ?? '').toString(),
      tenantId: (json['tenantId'] ?? tenant?['id'] ?? '').toString(),
      proposedPrice: _parseDouble(json['proposedPrice']),
      status: ProposalStatus.fromBackend(json['status'] as String?),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString())
              ?.toLocal() ??
          DateTime.now(),
      message: json['message'] as String?,
      tenantName: tenant?['name'] as String?,
      tenantEmail: tenant?['email'] as String?,
      tenantPhone: tenant?['phoneNumber'] as String?,
      propertyTitle: property?['title'] as String?,
      propertyOriginalPrice: property?['price']?.toString(),
      landlordId: property?['landlordId'] as String?,
    );
  }

  static double _parseDouble(dynamic raw) {
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw) ?? 0;
    return 0;
  }
}
