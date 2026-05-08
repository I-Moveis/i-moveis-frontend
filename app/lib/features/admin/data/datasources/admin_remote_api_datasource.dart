import 'package:dio/dio.dart';

import '../../../search/data/models/property_api_model.dart';
import '../../../search/domain/entities/property.dart';
import '../../domain/entities/admin_metrics.dart';
import '../../domain/entities/paginated_properties.dart';
import '../models/admin_metrics_api_model.dart';
import 'admin_remote_datasource.dart';

/// Fala com `/api/admin/*`. Exige ADMIN.
class AdminRemoteApiDataSource implements AdminRemoteDataSource {
  AdminRemoteApiDataSource(this._dio);

  final Dio _dio;

  @override
  Future<AdminMetrics> getMetrics() async {
    final res = await _dio.get<Map<String, dynamic>>('/admin/metrics');
    return adminMetricsFromApiJson(res.data ?? const {});
  }

  @override
  Future<PaginatedProperties> listForModeration({
    required String status,
    int page = 1,
    int limit = 20,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/admin/properties',
      queryParameters: {
        'status': status,
        'page': page,
        'limit': limit,
      },
    );
    final body = res.data ?? const {};
    final rawData = body['data'];
    final items = <Property>[
      if (rawData is List)
        for (final e in rawData)
          if (e is Map)
            propertyFromApiJson(Map<String, dynamic>.from(e)),
    ];
    final meta = (body['meta'] as Map?)?.cast<String, dynamic>() ?? const {};
    return PaginatedProperties(
      items: items,
      page: _int(meta['page'], fallback: page),
      limit: _int(meta['limit'], fallback: limit),
      total: _int(meta['total']),
      totalPages: _int(meta['totalPages']),
    );
  }

  @override
  Future<void> sendBroadcast({
    required String title,
    required String body,
  }) async {
    await _dio.post<void>(
      '/admin/broadcast',
      data: {'title': title, 'body': body},
    );
  }
}

int _int(Object? v, {int fallback = 0}) =>
    (v is num) ? v.toInt() : fallback;
