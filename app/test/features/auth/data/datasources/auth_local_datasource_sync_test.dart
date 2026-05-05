import 'dart:convert';

import 'package:app/core/storage/secure_token_storage.dart';
import 'package:app/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:app/features/auth/data/models/auth_session_model.dart';
import 'package:app/features/auth/data/models/auth_user_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  setUpAll(() {
    registerFallbackValue(RequestOptions(path: '/'));
  });

  late AuthLocalDataSourceImpl sut;
  late SharedPreferences prefs;
  late SecureTokenStorage storage;

  setUp(() async {
    // Mock the secure storage platform channel so FlutterSecureStorage
    // writes land somewhere addressable in tests.
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues(const {});
    prefs = await SharedPreferences.getInstance();
    storage = const SecureTokenStorage(FlutterSecureStorage());
    sut = AuthLocalDataSourceImpl(prefs: prefs, tokenStorage: storage);
  });

  AuthSessionModel seedSession() {
    return const AuthSessionModel(
      user: AuthUserModel(
        id: 'firebase-uid-abc123',
        name: 'João Silva',
        email: 'joao@example.com',
        avatarUrl: 'https://cdn/avatar.png',
      ),
      accessToken: 'access.jwt',
      refreshToken: 'refresh.jwt',
    );
  }

  Response<Map<String, dynamic>> meResponse({
    String id = 'backend-uuid-1',
    String role = 'TENANT',
    String? name = 'João da Silva (backend)',
    String? phoneNumber = '+5511999999999',
  }) {
    return Response<Map<String, dynamic>>(
      requestOptions: RequestOptions(path: '/users/me'),
      statusCode: 200,
      data: {
        'id': id,
        'name': name,
        'phoneNumber': phoneNumber,
        'role': role,
      },
    );
  }

  group('syncFromBackend', () {
    test('rewrites cached user id with backend UUID', () async {
      await sut.saveSession(seedSession());
      final dio = _MockDio();
      when(() => dio.get<Map<String, dynamic>>(any()))
          .thenAnswer((_) async => meResponse());

      await sut.syncFromBackend(dio);

      final cached = await sut.readCachedUser();
      expect(cached?.id, 'backend-uuid-1');
      expect(await storage.readUserId(), 'backend-uuid-1');
    });

    test('merges backend phone and role into cached profile', () async {
      await sut.saveSession(seedSession());
      final dio = _MockDio();
      when(() => dio.get<Map<String, dynamic>>(any()))
          .thenAnswer((_) async => meResponse(role: 'LANDLORD'));

      await sut.syncFromBackend(dio);

      final cached = await sut.readCachedUser();
      expect(cached?.phone, '+5511999999999');
      expect(cached?.isOwner, true);
      expect(cached?.isAdmin, false);
      // Firebase-provided fields stay when backend omits them.
      expect(cached?.email, 'joao@example.com');
      expect(cached?.avatarUrl, 'https://cdn/avatar.png');
    });

    test('ADMIN role is reflected in cached user', () async {
      await sut.saveSession(seedSession());
      final dio = _MockDio();
      when(() => dio.get<Map<String, dynamic>>(any()))
          .thenAnswer((_) async => meResponse(role: 'ADMIN'));

      await sut.syncFromBackend(dio);

      expect((await sut.readCachedUser())?.isAdmin, true);
    });

    test('swallows DioException and keeps cached user intact', () async {
      await sut.saveSession(seedSession());
      final dio = _MockDio();
      when(() => dio.get<Map<String, dynamic>>(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/users/me'),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      await sut.syncFromBackend(dio); // must not throw

      final cached = await sut.readCachedUser();
      expect(cached?.id, 'firebase-uid-abc123'); // untouched
    });

    test('skips when backend response is missing an id', () async {
      await sut.saveSession(seedSession());
      final dio = _MockDio();
      when(() => dio.get<Map<String, dynamic>>(any())).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: '/users/me'),
          statusCode: 200,
          data: const {'name': 'only-name'},
        ),
      );

      await sut.syncFromBackend(dio);

      expect((await sut.readCachedUser())?.id, 'firebase-uid-abc123');
      expect(await storage.readUserId(), 'firebase-uid-abc123');
    });

    test('no-op when there is no access token stored yet', () async {
      // Without saveSession running first, storage has no access token,
      // so we skip rewriting the userId to avoid clobbering a non-session.
      final dio = _MockDio();
      when(() => dio.get<Map<String, dynamic>>(any()))
          .thenAnswer((_) async => meResponse());

      await sut.syncFromBackend(dio);

      expect(await storage.readUserId(), isNull);
    });

    test('requires valid JSON shape — non-map response ignored', () async {
      await sut.saveSession(seedSession());
      // Dio with non-map data would normally be a different type arg; here
      // we simulate by returning a response whose data is null.
      final dio = _MockDio();
      when(() => dio.get<Map<String, dynamic>>(any())).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: '/users/me'),
          statusCode: 200,
        ),
      );

      await sut.syncFromBackend(dio);

      expect((await sut.readCachedUser())?.id, 'firebase-uid-abc123');
    });

    test('target path is /users/me', () async {
      await sut.saveSession(seedSession());
      final dio = _MockDio();
      when(() => dio.get<Map<String, dynamic>>(any()))
          .thenAnswer((_) async => meResponse());

      await sut.syncFromBackend(dio);

      verify(() => dio.get<Map<String, dynamic>>('/users/me')).called(1);
    });
  });

  test('saveSession still keeps json round-trip working', () async {
    await sut.saveSession(seedSession());
    final raw = prefs.getString('auth.cached_user');
    expect(raw, isNotNull);
    expect(jsonDecode(raw!), isA<Map<String, dynamic>>());
  });
}
