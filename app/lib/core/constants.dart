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
/// backend. Default is `true` on this branch so the demo works without a
/// running backend (admin login, listings, users — all mocked).
const bool kUseMockData = bool.fromEnvironment(
  'USE_MOCK_DATA',
  defaultValue: true,
);

/// When true, auth layer uses mock (fake token/user) instead of Firebase Auth.
/// Default é `false` — o app conversa com o Firebase em dev e prod. Passa
/// `--dart-define=USE_MOCK_AUTH=true` pra pular o Firebase em builds de UI
/// sem projeto configurado.
const bool kUseMockAuth = bool.fromEnvironment(
  'USE_MOCK_AUTH',
  defaultValue: true,
);

// Auth0 configuration — all three are required when `kUseMockData` is false.
// Pass via --dart-define at build time. The native callback schemes in
// AndroidManifest.xml and Info.plist must match the applicationId/bundleId.
const String kAuth0Domain = String.fromEnvironment('AUTH0_DOMAIN');
const String kAuth0ClientId = String.fromEnvironment('AUTH0_CLIENT_ID');
const String kAuth0Audience = String.fromEnvironment('AUTH0_AUDIENCE');

/// True when the three Auth0 vars were provided at build time.
bool get kAuth0Configured =>
    kAuth0Domain.isNotEmpty &&
    kAuth0ClientId.isNotEmpty &&
    kAuth0Audience.isNotEmpty;

/// Custom claim namespace the backend uses to expose the user's role.
/// Documented in `01_VISAO_GERAL_API.md` / `02_MODELS_E_ENUMS.md`.
const String kAuth0RolesClaim = 'https://alphatoca.com/roles';
