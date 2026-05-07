import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/dio_provider.dart';
import '../domain/entities/current_payment.dart';
import '../domain/entities/rent_payment.dart' show RentPaymentStatus;

/// Lê e escreve o status de pagamento do mês corrente de um imóvel.
/// Endpoints (US-009/US-010):
/// - `GET  /api/properties/:id/payments/current`
/// - `PUT  /api/properties/:id/payments/current`  body: `{ status }`
///
/// `period` é sempre derivado pelo servidor — cliente nunca envia.
class CurrentPaymentRepository {
  CurrentPaymentRepository({required Dio dio}) : _dio = dio;
  final Dio _dio;

  Future<CurrentPayment?> get(String propertyId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/properties/$propertyId/payments/current',
      );
      final data = response.data;
      if (data == null) return null;
      return CurrentPayment.fromJson(data);
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[rentals] GET /properties/$propertyId/payments/current '
          'falhou (${e.response?.statusCode ?? '---'}): ${e.message}',
        );
      }
      return null;
    } on Object catch (e) {
      if (kDebugMode) debugPrint('[rentals] current GET falha: $e');
      return null;
    }
  }

  /// Atualiza o status do mês atual. Retorna o objeto atualizado (com
  /// `updatedAt`/`updatedBy` recém-escritos) — útil pra refrescar cache
  /// sem um segundo GET. Propaga [DioException] pro caller decidir se
  /// mostra snackbar.
  Future<CurrentPayment> update({
    required String propertyId,
    required RentPaymentStatus status,
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/properties/$propertyId/payments/current',
      data: {'status': status.toApi()},
    );
    final data = response.data ?? const <String, dynamic>{};
    return CurrentPayment.fromJson(data);
  }
}

final currentPaymentRepositoryProvider = Provider<CurrentPaymentRepository>(
  (ref) => CurrentPaymentRepository(dio: ref.watch(dioProvider)),
);

/// Snapshot por `propertyId`. Invalidate após PUT pra forçar refetch.
final currentPaymentProvider =
    FutureProvider.family<CurrentPayment?, String>((ref, propertyId) {
  return ref.read(currentPaymentRepositoryProvider).get(propertyId);
});
