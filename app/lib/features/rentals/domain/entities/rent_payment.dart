import 'package:flutter/foundation.dart';

/// Status de um pagamento mensal de aluguel na visão do landlord.
/// Espelha o que o backend deve devolver em
/// `GET /api/properties/:id/payments` (ver `BACKEND_HANDOFF.md §3`).
enum RentPaymentStatus {
  paid,
  awaiting,
  late;

  static RentPaymentStatus fromApi(String? raw) {
    switch (raw) {
      case 'PAID':
        return RentPaymentStatus.paid;
      case 'LATE':
      case 'OVERDUE':
        return RentPaymentStatus.late;
      case 'AWAITING':
      case 'PENDING':
      default:
        return RentPaymentStatus.awaiting;
    }
  }

  String get label {
    switch (this) {
      case RentPaymentStatus.paid:
        return 'Pago';
      case RentPaymentStatus.late:
        return 'Atrasado';
      case RentPaymentStatus.awaiting:
        return 'Aguardando';
    }
  }
}

/// Pagamento mensal de aluguel — um por mês de vigência do contrato.
/// A UI lista do mais recente ao mais antigo, exibindo o mês, valor,
/// status, e data de recebimento (só pros pagos).
@immutable
class RentPayment {
  const RentPayment({
    required this.period,
    required this.amount,
    required this.status,
    this.paidAt,
  });

  /// Mês referente ao pagamento, formato `YYYY-MM` (ex: `2026-04`).
  /// A UI renderiza como "Abril" / "Março" / etc.
  final String period;

  /// Valor esperado do aluguel, em BRL.
  final double amount;

  final RentPaymentStatus status;

  /// Data em que o pagamento foi confirmado. Null quando aguardando
  /// ou atrasado. Quando presente, a UI mostra `dd/mm`.
  final DateTime? paidAt;

  factory RentPayment.fromJson(Map<String, dynamic> json) {
    return RentPayment(
      period: (json['period'] ?? '').toString(),
      amount: (json['amount'] is num)
          ? (json['amount'] as num).toDouble()
          : double.tryParse('${json['amount'] ?? ''}') ?? 0,
      status: RentPaymentStatus.fromApi(json['status'] as String?),
      paidAt: DateTime.tryParse((json['paidAt'] ?? '').toString())?.toLocal(),
    );
  }

  /// Nome do mês em português — derivado de `period` (YYYY-MM).
  /// Fallback para o próprio period quando não dá pra parsear.
  String get monthLabel {
    const names = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
    ];
    final parts = period.split('-');
    if (parts.length < 2) return period;
    final m = int.tryParse(parts[1]);
    if (m == null || m < 1 || m > 12) return period;
    return names[m - 1];
  }

  /// Data formatada `dd/MM` ou `-` quando paidAt é null.
  String get paidDateLabel {
    if (paidAt == null) return '-';
    final d = paidAt!;
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}';
  }

  /// Valor formatado `2.500` (sem símbolo de moeda — a UI prefixa o R$).
  String get amountLabel {
    final rounded = amount.round();
    // Formata com separador de milhar simples em estilo BR.
    final str = rounded.toString();
    final buf = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write('.');
      buf.write(str[i]);
    }
    return buf.toString();
  }
}
