import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/dio_client.dart';
import 'secure_storage_provider.dart';

/// Configured [Dio] instance with auth, logging and error-mapping interceptors.
final dioProvider = Provider<Dio>((ref) {
  return buildDioClient(
    tokenStorage: ref.watch(secureTokenStorageProvider),
  );
});
