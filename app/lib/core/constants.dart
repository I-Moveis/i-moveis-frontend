/// Base URL for the i-Móveis REST API.
///
/// TODO(infra): read from --dart-define env var (e.g. `API_BASE_URL`) so
/// dev/staging/prod builds can point to different backends without editing
/// code.
const String kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:3000/api',
);

/// Network timeouts for the Dio client.
const Duration kApiConnectTimeout = Duration(seconds: 15);
const Duration kApiReceiveTimeout = Duration(seconds: 30);

/// When true, data layers return hardcoded mock data instead of hitting the
/// backend. Default is `false` for backend testing.
const bool kUseMockData = bool.fromEnvironment(
  'USE_MOCK_DATA',
  defaultValue: false,
);

/// When true, auth layer uses mock (fake token/user) instead of Auth0.
/// Default is `true` so the app runs without Auth0 credentials while still
/// hitting the real backend for data (search, listings, etc.).
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
