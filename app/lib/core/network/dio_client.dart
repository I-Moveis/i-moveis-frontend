import 'package:dio/dio.dart';

/// HTTP client configuration using Dio.
/// This file centralizes API configuration and interceptors.
class DioClient {
  static const String _baseUrl = 'https://api.imoveis.local'; // TODO: Update with actual API URL

  static final Dio _instance = _initDio();

  static Dio _initDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        contentType: Headers.jsonContentType,
      ),
    );

    // Add interceptors here
    // dio.interceptors.add(AuthInterceptor());

    return dio;
  }

  static Dio get httpClient => _instance;
}
