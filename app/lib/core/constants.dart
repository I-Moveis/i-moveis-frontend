/// Base URL for the i-Móveis REST API. Pode ser sobrescrita em build local
/// via `--dart-define=API_BASE_URL=http://localhost:3000/api`.
String get kApiBaseUrl {
  const envUrl = String.fromEnvironment('API_BASE_URL');
  if (envUrl.isNotEmpty) return envUrl;
  return 'https://lab.alphaedtech.org.br/server01/api';
}

/// Network timeouts for the Dio client.
const Duration kApiConnectTimeout = Duration(seconds: 15);
const Duration kApiReceiveTimeout = Duration(seconds: 30);

/// When true, data layers return hardcoded mock data instead of hitting the
/// backend. Default is `true` on this branch so the demo works without a
/// running backend (admin login, listings, users — all mocked).
const bool kUseMockData = bool.fromEnvironment(
  'USE_MOCK_DATA',
);

/// When true, auth layer uses mock (fake token/user) instead of Firebase Auth.
/// Default é `false` — o app conversa com o Firebase em dev e prod. Passa
/// `--dart-define=USE_MOCK_AUTH=true` pra pular o Firebase em builds de UI
/// sem projeto configurado.
const bool kUseMockAuth = bool.fromEnvironment(
  'USE_MOCK_AUTH',
);
