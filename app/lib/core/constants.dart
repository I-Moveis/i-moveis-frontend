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
