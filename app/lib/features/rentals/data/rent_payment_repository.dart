import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/dio_provider.dart';
import '../domain/entities/rent_payment.dart';

/// Carrega o histórico MULTI-MÊS de pagamentos de aluguel de um imóvel
/// para um inquilino específico. **Endpoint ainda não entregue.** O
/// backend entregou só `/payments/current` (US-009/US-010 — single
/// month); a versão multi-mês está marcada como pendente em
/// `BACKEND_HANDOFF.md §3`. Enquanto isso, qualquer erro (inclusive 404
/// esperado) devolve lista vazia e a UI faz fallback para o mês
/// corrente via `currentPaymentProvider` (ver
/// `tenant_rent_history_page.dart`).
class RentPaymentRepository {
  RentPaymentRepository({required Dio dio}) : _dio = dio;
  final Dio _dio;

  Future<List<RentPayment>> list({
    required String propertyId,
    required String tenantId,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/properties/$propertyId/payments',
        queryParameters: {'tenantId': tenantId},
      );
      final data = response.data;
      final raw = data is List
          ? data
          : (data is Map && data['data'] is List)
              ? data['data'] as List
              : null;
      if (raw == null) return const [];
      return raw
          .whereType<Map<dynamic, dynamic>>()
          .map((m) => RentPayment.fromJson(Map<String, dynamic>.from(m)))
          .toList()
        // Mais recente primeiro — serve igual mesmo se o backend já
        // ordenar, e protege caso backend mude de ideia um dia.
        ..sort((a, b) => b.period.compareTo(a.period));
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[rentals] GET /properties/$propertyId/payments falhou '
          '(${e.response?.statusCode ?? '---'}): ${e.message}',
        );
      }
      return const [];
    } on Object catch (e) {
      if (kDebugMode) debugPrint('[rentals] falha inesperada: $e');
      return const [];
    }
  }
}

final rentPaymentRepositoryProvider = Provider<RentPaymentRepository>(
  (ref) => RentPaymentRepository(dio: ref.watch(dioProvider)),
);

/// Argumentos compostos para identificar unicamente o histórico de
/// pagamentos. Implementa `==`/`hashCode` pra que o Riverpod faça
/// dedup automático de consultas com os mesmos IDs.
@immutable
class RentPaymentQuery {
  const RentPaymentQuery({required this.propertyId, required this.tenantId});
  final String propertyId;
  final String tenantId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RentPaymentQuery &&
          other.propertyId == propertyId &&
          other.tenantId == tenantId;

  @override
  int get hashCode => propertyId.hashCode ^ tenantId.hashCode;
}

/// Histórico de pagamentos para um `(propertyId, tenantId)` específico.
/// Lista vazia quando backend ausente ou sem dados — ver docstring do
/// repositório.
final rentPaymentHistoryProvider = FutureProvider.family<
    List<RentPayment>, RentPaymentQuery>((ref, query) async {
  return ref
      .read(rentPaymentRepositoryProvider)
      .list(propertyId: query.propertyId, tenantId: query.tenantId);
});
