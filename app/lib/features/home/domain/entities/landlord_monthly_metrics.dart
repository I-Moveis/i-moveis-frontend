import 'package:flutter/foundation.dart';

/// Métricas mensais do landlord para os gráficos da dashboard.
/// Três séries paralelas alinhadas com [months]:
/// - [rentals]: quantidade de imóveis alugados em cada mês
/// - [newTenants]: inquilinos novos registrados em cada mês
/// - [monthlyRevenue]: receita total de aluguéis em cada mês (em BRL)
///
/// Shape esperado do backend no
/// `GET /api/properties/analytics/monthly` (ver BACKEND_HANDOFF.md §11).
@immutable
class LandlordMonthlyMetrics {
  const LandlordMonthlyMetrics({
    required this.months,
    required this.rentals,
    required this.newTenants,
    required this.monthlyRevenue,
  });

  /// Labels dos meses no formato `YYYY-MM` (ex: "2026-05").
  final List<String> months;
  final List<int> rentals;
  final List<int> newTenants;
  final List<double> monthlyRevenue;

  /// Conjunto vazio com [monthCount] meses zerados — usado como
  /// fallback quando o endpoint ainda não existe ou falhou. Gera os
  /// últimos [monthCount] meses incluindo o atual.
  factory LandlordMonthlyMetrics.emptyLast({int monthCount = 6}) {
    final now = DateTime.now();
    final months = <String>[];
    for (var i = monthCount - 1; i >= 0; i--) {
      final d = DateTime(now.year, now.month - i);
      months.add(
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}',
      );
    }
    return LandlordMonthlyMetrics(
      months: months,
      rentals: List.filled(monthCount, 0),
      newTenants: List.filled(monthCount, 0),
      monthlyRevenue: List.filled(monthCount, 0),
    );
  }

  factory LandlordMonthlyMetrics.fromJson(Map<String, dynamic> json) {
    List<T> _read<T>(String key, T Function(Object?) convert) {
      final raw = json[key];
      if (raw is! List) return const [];
      return raw.map(convert).toList();
    }

    return LandlordMonthlyMetrics(
      months: _read(
          'months', (e) => e?.toString() ?? ''),
      rentals: _read(
          'rentals', (e) => (e is num) ? e.toInt() : 0),
      newTenants: _read(
          'newTenants', (e) => (e is num) ? e.toInt() : 0),
      monthlyRevenue: _read(
          'monthlyRevenue', (e) => (e is num) ? e.toDouble() : 0.0),
    );
  }

  /// Labels curtas (`Jan`, `Fev`, ..., `Dez`) na ordem de [months] —
  /// pra usar como rótulo nos eixos X dos gráficos.
  List<String> get shortMonthLabels {
    const abbr = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
    ];
    return months.map((key) {
      final parts = key.split('-');
      if (parts.length < 2) return key;
      final m = int.tryParse(parts[1]);
      if (m == null || m < 1 || m > 12) return key;
      return abbr[m - 1];
    }).toList();
  }
}
