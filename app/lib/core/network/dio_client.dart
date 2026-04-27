import 'package:dio/dio.dart';

import '../constants.dart';
import '../storage/secure_token_storage.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_mapper_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

/// Builds the Dio instance with base options and the standard interceptor
/// stack used by the app. Intended to be called from a Riverpod provider.
Dio buildDioClient({required SecureTokenStorage tokenStorage}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: kApiBaseUrl,
      connectTimeout: kApiConnectTimeout,
      receiveTimeout: kApiReceiveTimeout,
      contentType: Headers.jsonContentType,
    ),
  )..interceptors.addAll([
      AuthInterceptor(tokenStorage),
      LoggingInterceptor(),
      ErrorMapperInterceptor(),
    ]);

  return dio;
}
