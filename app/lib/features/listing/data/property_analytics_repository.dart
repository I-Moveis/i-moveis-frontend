import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/dio_provider.dart';

/// Métricas agregadas por imóvel para a tela "Análise do Imóvel".
/// Espelho do response de `GET /api/properties/:id/analytics?window=`.
@immutable
class PropertyAnalytics {
  const PropertyAnalytics({
    required this.views,
    required this.favorites,
    required this.proposalsTotal,
    required this.proposalsOpen,
    required this.visitsScheduled,
    required this.contactClicks,
    required this.dailyViews,
  });

  final int views;
  final int favorites;
  final int proposalsTotal;
  final int proposalsOpen;
  final int visitsScheduled;
  final int contactClicks;

  /// Série diária de visualizações para um possível minigráfico futuro.
  /// Cada entrada: `{ date: 'yyyy-MM-dd', count: int }`. Vazio quando o
  /// backend não devolveu (não bloqueia os cards de topo).
  final List<({DateTime date, int count})> dailyViews;

  factory PropertyAnalytics.fromJson(Map<String, dynamic> json) {
    final raw = json['dailyViews'];
    final daily = <({DateTime date, int count})>[];
    if (raw is List) {
      for (final entry in raw) {
        if (entry is! Map) continue;
        final dateStr = entry['date']?.toString();
        if (dateStr == null) continue;
        final date = DateTime.tryParse(dateStr);
        if (date == null) continue;
        daily.add((
          date: date,
          count: (entry['count'] as num?)?.toInt() ?? 0,
        ));
      }
    }
    return PropertyAnalytics(
      views: (json['views'] as num?)?.toInt() ?? 0,
      favorites: (json['favorites'] as num?)?.toInt() ?? 0,
      proposalsTotal: (json['proposalsTotal'] as num?)?.toInt() ?? 0,
      proposalsOpen: (json['proposalsOpen'] as num?)?.toInt() ?? 0,
      visitsScheduled: (json['visitsScheduled'] as num?)?.toInt() ?? 0,
      contactClicks: (json['contactClicks'] as num?)?.toInt() ?? 0,
      dailyViews: daily,
    );
  }
}

/// Janela temporal aceita pelo endpoint (`window` query param). A UI
/// usa labels em PT-BR mas serializa nesses 3 valores.
enum AnalyticsWindow {
  d7,
  d30,
  total;

  String toApi() {
    switch (this) {
      case AnalyticsWindow.d7:
        return '7d';
      case AnalyticsWindow.d30:
        return '30d';
      case AnalyticsWindow.total:
        return '1y';
    }
  }

  static AnalyticsWindow fromUiLabel(String label) {
    switch (label) {
      case '7 dias':
        return AnalyticsWindow.d7;
      case 'Total':
        return AnalyticsWindow.total;
      case '30 dias':
      default:
        return AnalyticsWindow.d30;
    }
  }
}

@immutable
class PropertyAnalyticsQuery {
  const PropertyAnalyticsQuery({
    required this.propertyId,
    required this.window,
  });
  final String propertyId;
  final AnalyticsWindow window;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PropertyAnalyticsQuery &&
          other.propertyId == propertyId &&
          other.window == window;

  @override
  int get hashCode => Object.hash(propertyId, window);
}

final propertyAnalyticsProvider = FutureProvider.family<PropertyAnalytics?,
    PropertyAnalyticsQuery>((ref, query) async {
  final dio = ref.read(dioProvider);
  try {
    final response = await dio.get<Map<String, dynamic>>(
      '/properties/${query.propertyId}/analytics',
      queryParameters: {'window': query.window.toApi()},
    );
    final data = response.data;
    if (data == null) return null;
    return PropertyAnalytics.fromJson(data);
  } on DioException catch (e) {
    if (kDebugMode) {
      debugPrint(
        '[analytics] GET /properties/${query.propertyId}/analytics '
        'falhou (${e.response?.statusCode ?? '---'}): ${e.message}',
      );
    }
    return null;
  } on Object catch (e) {
    if (kDebugMode) {
      debugPrint('[analytics] property analytics falha inesperada: $e');
    }
    return null;
  }
});
