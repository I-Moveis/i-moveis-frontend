import 'package:flutter/foundation.dart';

/// Contrato ativo (Contract.status='ACTIVE') vinculando uma Property e
/// um Tenant. Shape retornado por
/// `GET /api/contracts?propertyId=&tenantId=` (US-014).
///
/// O backend espelha o enum Prisma `ContractStatus` mas para este
/// endpoint só ACTIVE retorna — TERMINATED/COMPLETED caem em 404
/// CONTRACT_NOT_FOUND.
/// Status documental do contrato — vem do backend (`Contract.documentStatus`)
/// e dirige a chip de status na tela "Meus Inquilinos".
enum ContractDocumentStatus {
  /// Inquilino ainda precisa enviar documentos pendentes (RG, comprovante,
  /// fiador, etc.). Estado inicial após criação do contrato.
  pendingDocuments,

  /// Documentação OK, aguardando assinatura digital (PDF do contrato).
  awaitingSignature,

  /// Documentação completa e contrato assinado — fluxo concluído.
  approved;

  /// Mapeia o valor literal do enum Prisma `ContractDocumentStatus` no
  /// backend (`PENDING_DOCUMENTS | AWAITING_SIGNATURE | APPROVED`). Default
  /// seguro: `pendingDocuments` quando o backend não devolveu — ainda é
  /// o estado inicial mais provável.
  static ContractDocumentStatus fromApi(String? raw) {
    switch (raw) {
      case 'APPROVED':
        return ContractDocumentStatus.approved;
      case 'AWAITING_SIGNATURE':
        return ContractDocumentStatus.awaitingSignature;
      case 'PENDING_DOCUMENTS':
      default:
        return ContractDocumentStatus.pendingDocuments;
    }
  }
}

@immutable
class Contract {
  const Contract({
    required this.id,
    required this.propertyId,
    required this.tenantId,
    required this.startDate,
    required this.endDate,
    required this.monthlyRent,
    this.pdfUrl,
    this.signedAt,
    this.documentStatus = ContractDocumentStatus.pendingDocuments,
  });

  final String id;
  final String propertyId;
  final String tenantId;
  final DateTime startDate;
  final DateTime endDate;

  /// Valor mensal em BRL. Backend armazena como `Decimal(10,2)` e o
  /// JSON atravessa como number (converted com `Number(row.monthlyRent)`
  /// no serviço). Ver progress.txt US-014 — "Decimal → number".
  final double monthlyRent;

  /// URL do PDF. Pode ser:
  /// - relativa (`/uploads/contracts/<id>/<file>.pdf`) → stream via
  ///   `GET /contracts/:id/pdf`
  /// - absoluta (`https://...`) → redirect da API pra CDN/signed URL
  /// Null quando o landlord ainda não subiu o PDF assinado (US-016).
  final String? pdfUrl;

  /// Timestamp em que o contrato foi marcado como assinado digitalmente
  /// — preenchido só depois do upload do PDF assinado (US-016). Null
  /// antes disso.
  final DateTime? signedAt;

  /// Status documental — guia a chip "Pendente Documentos /
  /// Aguardando Assinatura / Documentação OK" na tela "Meus Inquilinos".
  final ContractDocumentStatus documentStatus;

  factory Contract.fromJson(Map<String, dynamic> json) {
    return Contract(
      id: (json['id'] ?? '').toString(),
      propertyId: (json['propertyId'] ?? '').toString(),
      tenantId: (json['tenantId'] ?? '').toString(),
      startDate: DateTime.parse((json['startDate'] ?? '').toString()).toLocal(),
      endDate: DateTime.parse((json['endDate'] ?? '').toString()).toLocal(),
      monthlyRent: (json['monthlyRent'] is num)
          ? (json['monthlyRent'] as num).toDouble()
          : double.tryParse('${json['monthlyRent'] ?? ''}') ?? 0,
      pdfUrl: json['pdfUrl'] as String?,
      signedAt:
          DateTime.tryParse((json['signedAt'] ?? '').toString())?.toLocal(),
      documentStatus:
          ContractDocumentStatus.fromApi(json['documentStatus'] as String?),
    );
  }
}
