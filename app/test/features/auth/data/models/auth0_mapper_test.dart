import 'package:app/features/auth/data/models/auth0_mapper.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

Credentials _buildCredentials({
  String? name,
  String? email,
  Map<String, dynamic>? customClaims,
  String? refreshToken,
  String sub = 'auth0|abc123',
  String? picture,
}) {
  return Credentials(
    idToken: 'id.jwt',
    accessToken: 'access.jwt',
    refreshToken: refreshToken,
    expiresAt: DateTime.utc(2026, 5, 10, 14),
    user: UserProfile(
      sub: sub,
      name: name,
      email: email,
      pictureUrl: picture != null ? Uri.parse(picture) : null,
      customClaims: customClaims,
    ),
    tokenType: 'Bearer',
  );
}

void main() {
  group('sessionFromCredentials', () {
    test('maps core fields', () {
      final session = sessionFromCredentials(_buildCredentials(
        name: 'João Silva',
        email: 'joao@example.com',
        picture: 'https://cdn/avatar.png',
        refreshToken: 'refresh.jwt',
      ));

      expect(session.accessToken, 'access.jwt');
      expect(session.refreshToken, 'refresh.jwt');
      expect(session.expiresAt, DateTime.utc(2026, 5, 10, 14));
      expect(session.user.id, 'auth0|abc123');
      expect(session.user.name, 'João Silva');
      expect(session.user.email, 'joao@example.com');
      expect(session.user.avatarUrl, 'https://cdn/avatar.png');
      expect(session.user.isOwner, false);
      expect(session.user.isAdmin, false);
    });

    test('falls back to email when name is absent', () {
      final session = sessionFromCredentials(_buildCredentials(
        email: 'joao@example.com',
      ));
      expect(session.user.name, 'joao@example.com');
    });

    test('falls back to sub when both name and email are absent', () {
      final session = sessionFromCredentials(_buildCredentials(
        sub: 'google-oauth2|999',
      ));
      expect(session.user.name, 'google-oauth2|999');
      expect(session.user.email, '');
    });

    test('persists empty refresh token when Auth0 returns null', () {
      final session =
          sessionFromCredentials(_buildCredentials(email: 'a@b.com'));
      expect(session.refreshToken, '');
    });

    test('LANDLORD role sets isOwner', () {
      final session = sessionFromCredentials(_buildCredentials(
        email: 'owner@example.com',
        customClaims: const {
          'https://alphatoca.com/roles': ['LANDLORD'],
        },
      ));
      expect(session.user.isOwner, true);
      expect(session.user.isAdmin, false);
    });

    test('ADMIN role sets isAdmin', () {
      final session = sessionFromCredentials(_buildCredentials(
        email: 'admin@example.com',
        customClaims: const {
          'https://alphatoca.com/roles': ['ADMIN'],
        },
      ));
      expect(session.user.isOwner, false);
      expect(session.user.isAdmin, true);
    });

    test('both roles set both flags', () {
      final session = sessionFromCredentials(_buildCredentials(
        email: 'super@example.com',
        customClaims: const {
          'https://alphatoca.com/roles': ['LANDLORD', 'ADMIN'],
        },
      ));
      expect(session.user.isOwner, true);
      expect(session.user.isAdmin, true);
    });

    test('unknown roles are ignored', () {
      final session = sessionFromCredentials(_buildCredentials(
        email: 'x@example.com',
        customClaims: const {
          'https://alphatoca.com/roles': ['RANDOM', 'OTHER'],
        },
      ));
      expect(session.user.isOwner, false);
      expect(session.user.isAdmin, false);
    });
  });

  group('rolesFromClaims', () {
    test('returns (false, false) when claims are null', () {
      expect(rolesFromClaims(null), (false, false));
    });

    test('returns (false, false) when roles claim is not a list', () {
      expect(
        rolesFromClaims(const {'https://alphatoca.com/roles': 'LANDLORD'}),
        (false, false),
      );
    });
  });
}
