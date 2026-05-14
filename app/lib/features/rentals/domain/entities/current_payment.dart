import 'package:flutter/foundation.dart';

import 'rent_payment.dart' show RentPaymentStatus;

/// Snapshot do pagamento do mês corrente para um imóvel — shape do
/// `GET /api/properties/:id/payments/current` (US-009) e resposta do
/// `PUT /api/properties/:id/payments/current` (US-010).
///
/// O backend é autoritativo sobre [period] (YYYY-MM na timezone UTC) —
/// o frontend nunca manda esse campo. Quando não há row persistido,
/// o backend devolve [status] = AWAITING com [updatedAt]/[updatedBy]
/// nulos (contrato "read without persist", ver
/// `BACKEND_HANDOFF.md §5`).
@immutable
class CurrentPayment {
  const CurrentPayment({
    required this.period,
    required this.status,
    this.updatedAt,
    this.updatedBy,
  });

  final String period;
  final RentPaymentStatus status;
  final DateTime? updatedAt;
  final String? updatedBy;

  factory CurrentPayment.fromJson(Map<String, dynamic> json) {
    return CurrentPayment(
      period: (json['period'] ?? '').toString(),
      status: RentPaymentStatus.fromApi(json['status'] as String?),
      updatedAt:
          DateTime.tryParse((json['updatedAt'] ?? '').toString())?.toLocal(),
      updatedBy: json['updatedBy'] as String?,
    );
  }
}
