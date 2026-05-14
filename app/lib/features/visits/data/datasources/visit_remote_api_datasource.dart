import 'package:dio/dio.dart';

import '../../domain/entities/available_slot.dart';
import '../../domain/entities/visit.dart';
import '../../domain/entities/visit_status.dart';
import '../models/visit_api_model.dart';
import 'visit_datasources.dart';

/// Real backend implementation hitting `/api/visits*`.
///
/// Dio is expected to already be configured with baseUrl and the standard
/// interceptor stack — transport errors surface as `DioException` with a
/// `NetworkException` attached to `DioException.error`.
class VisitRemoteApiDataSource implements VisitRemoteDataSource {
  VisitRemoteApiDataSource(this._dio);

  final Dio _dio;

  @override
  Future<Visit> schedule({
    required String propertyId,
    required String tenantId,
    required DateTime scheduledAt,
    int? durationMinutes,
    String? rentalProcessId,
    String? notes,
  }) async {
    final body = visitToCreateJson(
      propertyId: propertyId,
      tenantId: tenantId,
      scheduledAt: scheduledAt,
      durationMinutes: durationMinutes,
      rentalProcessId: rentalProcessId,
      notes: notes,
    );
    final res = await _dio.post<Map<String, dynamic>>(
      '/visits',
      data: body,
    );
    return visitFromApiJson(res.data ?? const {});
  }

  @override
  Future<List<Visit>> list({
    String? propertyId,
    String? tenantId,
    String? landlordId,
    VisitStatus? status,
    DateTime? from,
    DateTime? to,
  }) async {
    final params = <String, dynamic>{};
    if (propertyId != null) params['propertyId'] = propertyId;
    if (tenantId != null) params['tenantId'] = tenantId;
    if (landlordId != null) params['landlordId'] = landlordId;
    if (status != null) params['status'] = status.toApi();
    if (from != null) params['from'] = from.toUtc().toIso8601String();
    if (to != null) params['to'] = to.toUtc().toIso8601String();

    final res = await _dio.get<List<dynamic>>(
      '/visits',
      queryParameters: params,
    );

    final data = res.data ?? const [];
    return data
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => visitFromApiJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<Visit> getById(String id) async {
    final res = await _dio.get<Map<String, dynamic>>('/visits/$id');
    return visitFromApiJson(res.data ?? const {});
  }

  @override
  Future<List<AvailableSlot>> availability({
    required String propertyId,
    required DateTime from,
    required DateTime to,
    int? slotMinutes,
  }) async {
    final params = <String, dynamic>{
      'propertyId': propertyId,
      'from': from.toUtc().toIso8601String(),
      'to': to.toUtc().toIso8601String(),
    };
    if (slotMinutes != null) params['slotMinutes'] = slotMinutes;

    final res = await _dio.get<List<dynamic>>(
      '/visits/availability',
      queryParameters: params,
    );

    final data = res.data ?? const [];
    return data
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => slotFromApiJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<Visit> update(
    String id, {
    DateTime? scheduledAt,
    int? durationMinutes,
    VisitStatus? status,
    String? notes,
  }) async {
    final body = visitToPatchJson(
      scheduledAt: scheduledAt,
      durationMinutes: durationMinutes,
      status: status,
      notes: notes,
    );
    final res = await _dio.patch<Map<String, dynamic>>(
      '/visits/$id',
      data: body,
    );
    return visitFromApiJson(res.data ?? const {});
  }

  @override
  Future<void> cancel(String id) async {
    await _dio.delete<void>('/visits/$id');
  }
}
