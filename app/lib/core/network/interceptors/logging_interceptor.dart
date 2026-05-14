import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Lightweight request/response logger — debug builds only.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      debugPrint('→ ${options.method} ${options.uri}');
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      debugPrint(
        '← ${response.statusCode} ${response.requestOptions.uri}',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '✗ ${err.response?.statusCode ?? '---'} '
        '${err.requestOptions.uri} → ${err.type}',
      );
      // Log do body do erro em 4xx: o backend geralmente coloca aqui a
      // mensagem específica ("Invalid uuid", "Unknown query param", etc.)
      // que deixa óbvio o que consertar na request/seed/validação.
      final body = err.response?.data;
      if (body != null) {
        debugPrint('   body: $body');
      }
    }
    handler.next(err);
  }
}
