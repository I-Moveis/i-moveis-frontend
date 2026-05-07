import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';

import '../../../core/providers/dio_provider.dart';
import '../domain/entities/contract.dart';

/// Wraps os endpoints de Contract entregues pelo backend (US-014/015/016):
/// - `GET /api/contracts?propertyId=&tenantId=` → resolve id real do
///   contrato ativo
/// - `GET /api/contracts/:id/pdf` → download (só geramos a URL, o
///   frontend usa `url_launcher` ou o widget PDFView pra abrir)
/// - `PUT /api/contracts/:id/signed-document` → upload multipart
class ContractRepository {
  ContractRepository({required Dio dio}) : _dio = dio;
  final Dio _dio;

  /// Busca o contrato ATIVO pro par (propertyId, tenantId). Retorna
  /// null em 404 (sem contrato ativo), 401/403 (caller não autorizado),
  /// ou erro de rede.
  Future<Contract?> findActive({
    required String propertyId,
    required String tenantId,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/contracts',
        queryParameters: {'propertyId': propertyId, 'tenantId': tenantId},
      );
      final data = response.data;
      if (data == null) return null;
      return Contract.fromJson(data);
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[contracts] GET /contracts?propertyId&tenantId falhou '
          '(${e.response?.statusCode ?? '---'}): ${e.message}',
        );
      }
      return null;
    } on Object catch (e) {
      if (kDebugMode) debugPrint('[contracts] find falha: $e');
      return null;
    }
  }

  /// Constrói a URL pública do endpoint de download, pronta pra passar
  /// ao `url_launcher`. O browser/OS cuida de abrir inline ou baixar
  /// dependendo do Content-Type que o backend devolver.
  String pdfDownloadUrl(String contractId) {
    final base = _dio.options.baseUrl;
    final normalized = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    return '$normalized/contracts/$contractId/pdf';
  }

  /// Sobe o PDF assinado via multipart/form-data (campo `signedPdf`).
  /// Propaga [DioException] pro caller tratar snackbar/retry.
  Future<Contract> uploadSignedPdf({
    required String contractId,
    required PlatformFile file,
  }) async {
    final bytes = file.bytes;
    if (bytes == null) {
      throw StateError(
        'PDF sem bytes em memória — abra o picker com withData: true.',
      );
    }
    final form = FormData.fromMap({
      'signedPdf': MultipartFile.fromBytes(
        bytes,
        filename: file.name,
        contentType: MediaType('application', 'pdf'),
      ),
    });
    final response = await _dio.put<Map<String, dynamic>>(
      '/contracts/$contractId/signed-document',
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );
    return Contract.fromJson(response.data ?? const <String, dynamic>{});
  }
}

final contractRepositoryProvider = Provider<ContractRepository>(
  (ref) => ContractRepository(dio: ref.watch(dioProvider)),
);

/// Argumentos compostos pra o provider do contrato ativo.
@immutable
class ContractQuery {
  const ContractQuery({required this.propertyId, required this.tenantId});
  final String propertyId;
  final String tenantId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContractQuery &&
          other.propertyId == propertyId &&
          other.tenantId == tenantId;

  @override
  int get hashCode => propertyId.hashCode ^ tenantId.hashCode;
}

final activeContractProvider =
    FutureProvider.family<Contract?, ContractQuery>((ref, q) {
  return ref
      .read(contractRepositoryProvider)
      .findActive(propertyId: q.propertyId, tenantId: q.tenantId);
});
