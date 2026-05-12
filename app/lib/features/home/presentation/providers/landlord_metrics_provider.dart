import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/dio_provider.dart';

/// Métricas agregadas do landlord exibidas nos cards do topo da dashboard
/// (`profileViews`, `proposalsPending`, `unreadMessages`). Vem do
/// endpoint `GET /api/landlord/metrics` — backend agrega `ProfileView`
/// dos últimos 30d, `Proposal` PENDING e mensagens não lidas.
@immutable
class LandlordMetrics {
  const LandlordMetrics({
    required this.profileViews,
    required this.proposalsPending,
    required this.unreadMessages,
  });

  final int profileViews;
  final int proposalsPending;
  final int unreadMessages;

  factory LandlordMetrics.fromJson(Map<String, dynamic> json) {
    return LandlordMetrics(
      profileViews: (json['profileViews'] as num?)?.toInt() ?? 0,
      proposalsPending: (json['proposalsPending'] as num?)?.toInt() ?? 0,
      unreadMessages: (json['unreadMessages'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Busca as métricas. Falha → null (UI cai pra `—` em cada card afetado).
final landlordMetricsProvider =
    FutureProvider<LandlordMetrics?>((ref) async {
  final dio = ref.read(dioProvider);
  try {
    final response =
        await dio.get<Map<String, dynamic>>('/landlord/metrics');
    final data = response.data;
    if (data == null) return null;
    return LandlordMetrics.fromJson(data);
  } on DioException catch (e) {
    if (kDebugMode) {
      debugPrint(
        '[landlord] GET /landlord/metrics falhou '
        '(${e.response?.statusCode ?? '---'}): ${e.message}',
      );
    }
    return null;
  } on Object catch (e) {
    if (kDebugMode) debugPrint('[landlord] metrics falha inesperada: $e');
    return null;
  }
});
