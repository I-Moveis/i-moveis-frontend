import 'package:dio/dio.dart';

import '../../../support/domain/entities/support_ticket.dart';

class AdminSupportRemoteDataSource {
  AdminSupportRemoteDataSource(this._dio);

  final Dio _dio;

  Future<({List<SupportTicket> items, int total})> listTickets({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/admin/support/tickets',
      queryParameters: {
        if (status != null) 'status': status,
        'page': page,
        'limit': limit,
      },
    );
    final body = res.data ?? const {};
    final rawData = body['data'];
    final items = <SupportTicket>[
      if (rawData is List)
        for (final e in rawData)
          if (e is Map) SupportTicket.fromJson(Map<String, dynamic>.from(e)),
    ];
    final meta = (body['meta'] as Map?)?.cast<String, dynamic>() ?? const {};
    final total = (meta['total'] as num?)?.toInt() ?? items.length;
    return (items: items, total: total);
  }

  Future<SupportTicket> updateTicket(
    String id, {
    required String status,
    String? resolution,
  }) async {
    final body = <String, dynamic>{'status': status};
    if (resolution != null && resolution.isNotEmpty) {
      body['resolution'] = resolution;
    }
    final res = await _dio.put<Map<String, dynamic>>(
      '/admin/support/tickets/$id',
      data: body,
    );
    return SupportTicket.fromJson(res.data ?? const {});
  }
}
