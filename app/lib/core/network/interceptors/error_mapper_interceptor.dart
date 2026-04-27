import 'package:dio/dio.dart';

import '../network_exception.dart';

/// Converts [DioException] into a transport-agnostic [NetworkException] so
/// upper layers do not depend on Dio.
class ErrorMapperInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final mapped = DioException(
      requestOptions: err.requestOptions,
      type: err.type,
      response: err.response,
      error: _toNetworkException(err),
      stackTrace: err.stackTrace,
    );
    handler.next(mapped);
  }

  NetworkException _toNetworkException(DioException err) {
    final status = err.response?.statusCode;
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(
          kind: NetworkErrorKind.timeout,
          message: 'A requisição demorou demais.',
        );
      case DioExceptionType.connectionError:
        return const NetworkException(
          kind: NetworkErrorKind.noConnection,
          message: 'Sem conexão com o servidor.',
        );
      case DioExceptionType.cancel:
        return const NetworkException(
          kind: NetworkErrorKind.cancelled,
          message: 'Requisição cancelada.',
        );
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return NetworkException(
          kind: NetworkErrorKind.unknown,
          message: err.message ?? 'Erro desconhecido.',
        );
      case DioExceptionType.badResponse:
        return NetworkException(
          kind: _kindFromStatus(status),
          message: _messageFromResponse(err.response) ??
              'Erro ${status ?? '---'}.',
          statusCode: status,
        );
    }
  }

  NetworkErrorKind _kindFromStatus(int? status) {
    if (status == null) return NetworkErrorKind.unknown;
    if (status == 400) return NetworkErrorKind.badRequest;
    if (status == 401) return NetworkErrorKind.unauthorized;
    if (status == 403) return NetworkErrorKind.forbidden;
    if (status == 404) return NetworkErrorKind.notFound;
    if (status == 409) return NetworkErrorKind.conflict;
    if (status >= 500) return NetworkErrorKind.serverError;
    return NetworkErrorKind.unknown;
  }

  String? _messageFromResponse(Response<dynamic>? response) {
    final data = response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    return null;
  }
}
