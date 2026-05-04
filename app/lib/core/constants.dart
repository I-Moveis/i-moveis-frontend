/// Base URL for the i-Móveis REST API. Sobrescrito por `--dart-define=API_BASE_URL=...`
/// em builds de staging/prod.
const String kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:3000/api',
);

/// Network timeouts for the Dio client.
const Duration kApiConnectTimeout = Duration(seconds: 15);
const Duration kApiReceiveTimeout = Duration(seconds: 30);

/// When true, data layers return hardcoded mock data instead of hitting the
/// backend. Default is `false` for backend testing.
const bool kUseMockData = bool.fromEnvironment('USE_MOCK_DATA');

/// When true, auth layer uses mock (fake token/user) instead of Firebase Auth.
/// Default é `false` — o app conversa com o Firebase em dev e prod. Passa
/// `--dart-define=USE_MOCK_AUTH=true` pra pular o Firebase em builds de UI
/// sem projeto configurado.
const bool kUseMockAuth = bool.fromEnvironment('USE_MOCK_AUTH');
