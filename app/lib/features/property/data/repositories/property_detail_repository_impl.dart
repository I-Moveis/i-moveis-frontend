import 'package:app/core/error/failures.dart';
import 'package:app/core/network/network_exception.dart';
import 'package:dio/dio.dart';

import '../../../search/data/models/property_api_model.dart';
import '../../../search/domain/entities/property.dart';
import '../../domain/repositories/property_detail_repository.dart';
import '../mock_property_datasource.dart';

/// Single implementation with a flag toggle. When `useMock` is true, resolves
/// the detail from the in-memory `kMockProperties` list; otherwise calls
/// `GET /api/properties/:id` via [Dio] and maps the response.
class PropertyDetailRepositoryImpl implements PropertyDetailRepository {
  PropertyDetailRepositoryImpl({
    required this.dio,
    required this.useMock,
  });

  final Dio dio;
  final bool useMock;

  @override
  Future<Property> getById(String id) async {
    if (useMock) {
      return _getFromMock(id);
    }
    return _getFromApi(id);
  }

  Future<Property> _getFromMock(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final match = kMockProperties.where((p) => p.id == id).toList();
    if (match.isEmpty) {
      throw const ServerFailure('Imóvel não encontrado');
    }
    return match.first;
  }

  Future<Property> _getFromApi(String id) async {
    try {
      final response = await dio.get<Map<String, dynamic>>('/properties/$id');
      final body = response.data ?? const <String, dynamic>{};
      return propertyFromApiJson(body);
    } on DioException catch (e) {
      final netErr = e.error;
      if (netErr is NetworkException) {
        switch (netErr.kind) {
          case NetworkErrorKind.notFound:
            throw const ServerFailure('Imóvel não encontrado');
          case NetworkErrorKind.noConnection:
          case NetworkErrorKind.timeout:
            throw const NetworkFailure();
          case NetworkErrorKind.badRequest:
          case NetworkErrorKind.unauthorized:
          case NetworkErrorKind.forbidden:
          case NetworkErrorKind.conflict:
          case NetworkErrorKind.serverError:
          case NetworkErrorKind.cancelled:
          case NetworkErrorKind.unknown:
            throw const ServerFailure();
        }
      }
      throw const ServerFailure();
    }
  }
}
