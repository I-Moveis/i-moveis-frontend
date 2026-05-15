import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/dio_provider.dart';
import '../domain/entities/proposal.dart';

/// Wraps `/proposals` endpoints — listagem, detalhe, mudança de status.
class ProposalRepository {
  ProposalRepository({required Dio dio}) : _dio = dio;
  final Dio _dio;

  Future<List<Proposal>> list({
    String? tenantId,
    String? landlordId,
    String? propertyId,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (tenantId != null) params['tenantId'] = tenantId;
      if (landlordId != null) params['landlordId'] = landlordId;
      if (propertyId != null) params['propertyId'] = propertyId;

      final response =
          await _dio.get<dynamic>('/proposals', queryParameters: params);
      final data = response.data;
      final list = data is List
          ? data
          : (data is Map && data['data'] is List)
              ? data['data'] as List
              : null;
      if (list == null) return const [];
      return list
          .whereType<Map<dynamic, dynamic>>()
          .map((m) => Proposal.fromJson(Map<String, dynamic>.from(m)))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[proposals] GET /proposals falhou '
          '(${e.response?.statusCode ?? '---'}): ${e.message}',
        );
      }
      return const [];
    } on Object catch (e) {
      if (kDebugMode) debugPrint('[proposals] list falha inesperada: $e');
      return const [];
    }
  }

  Future<Proposal> updateStatus({
    required String id,
    required ProposalStatus status,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/proposals/$id/status',
      data: {'status': status.toBackend()},
    );
    return Proposal.fromJson(response.data ?? const {});
  }
}

final proposalRepositoryProvider = Provider<ProposalRepository>((ref) {
  return ProposalRepository(dio: ref.watch(dioProvider));
});
