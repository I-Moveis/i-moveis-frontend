import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/dio_provider.dart';
import '../../domain/entities/landlord_monthly_metrics.dart';

/// Busca as métricas mensais do landlord para os 3 gráficos da
/// dashboard. Tenta `GET /api/properties/analytics/monthly`; se falhar
/// (endpoint ausente, erro transitório), devolve um payload com 6
/// meses zerados — a UI renderiza os gráficos vazios mas com a
/// estrutura visual intacta.
///
/// Ver `BACKEND_HANDOFF.md §11` para o shape esperado.
final landlordMonthlyMetricsProvider =
    FutureProvider<LandlordMonthlyMetrics>((ref) async {
  final dio = ref.read(dioProvider);
  try {
    final response = await dio.get<Map<String, dynamic>>(
      '/properties/analytics/monthly',
    );
    final data = response.data;
    if (data == null) return LandlordMonthlyMetrics.emptyLast();
    final parsed = LandlordMonthlyMetrics.fromJson(data);
    // Se backend devolver algo incoerente (arrays vazios ou de tamanhos
    // diferentes), cai no fallback pra não quebrar a UI.
    if (parsed.months.isEmpty ||
        parsed.rentals.length != parsed.months.length ||
        parsed.newTenants.length != parsed.months.length ||
        parsed.monthlyRevenue.length != parsed.months.length) {
      if (kDebugMode) {
        debugPrint(
          '[analytics] /properties/analytics/monthly devolveu shape '
          'inconsistente — usando fallback zerado',
        );
      }
      return LandlordMonthlyMetrics.emptyLast();
    }
    return parsed;
  } on DioException catch (e) {
    if (kDebugMode) {
      debugPrint(
        '[analytics] GET /properties/analytics/monthly falhou '
        '(${e.response?.statusCode ?? '---'}): ${e.message} — '
        'usando fallback zerado',
      );
    }
    return LandlordMonthlyMetrics.emptyLast();
  } on Object catch (e) {
    if (kDebugMode) debugPrint('[analytics] falha inesperada: $e');
    return LandlordMonthlyMetrics.emptyLast();
  }
});
