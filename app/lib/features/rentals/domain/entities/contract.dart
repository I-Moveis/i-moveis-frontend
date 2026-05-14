import 'package:flutter/foundation.dart';

/// Contrato ativo (Contract.status='ACTIVE') vinculando uma Property e
/// um Tenant. Shape retornado por
/// `GET /api/contracts?propertyId=&tenantId=` (US-014).
///
/// O backend espelha o enum Prisma `ContractStatus` mas para este
/// endpoint só ACTIVE retorna — TERMINATED/COMPLETED caem em 404
/// CONTRACT_NOT_FOUND.
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
    );
  }
}
