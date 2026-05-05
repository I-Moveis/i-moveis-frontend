import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants.dart';
import '../network/dio_client.dart';
import 'firebase_auth_provider.dart';
import 'secure_storage_provider.dart';

/// Configured [Dio] instance with auth, logging and error-mapping interceptors.
///
/// In mock-auth mode the Firebase dependency is skipped so tests/UI builds
/// without Firebase configured don't trip over `FirebaseAuth.instance`.
final dioProvider = Provider<Dio>((ref) {
  return buildDioClient(
    tokenStorage: ref.watch(secureTokenStorageProvider),
    firebaseAuth: kUseMockAuth ? null : ref.watch(firebaseAuthProvider),
  );
});
