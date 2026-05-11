/// Base URL for the i-Móveis REST API. Default aponta para o backend local
/// em `http://localhost:3000/api/` (branch `hospedagem_local`). Pode ser
/// sobrescrita em build via `--dart-define=API_BASE_URL=...` para apontar
/// de volta para o backend remoto (ou outro endpoint) sem trocar de branch.
String get kApiBaseUrl {
  const envUrl = String.fromEnvironment('API_BASE_URL');
  if (envUrl.isNotEmpty) return envUrl;
  return 'http://localhost:3000/api/';
}

/// Network timeouts for the Dio client.
const Duration kApiConnectTimeout = Duration(seconds: 15);
const Duration kApiReceiveTimeout = Duration(seconds: 30);

/// Converte um path de imagem para URL absoluta. O backend guarda
/// `PropertyImage.url` como path relativo (`/uploads/<propertyId>/<file>.jpg`)
/// que é servido pelo express-static na raiz do servidor — **fora** do
/// prefixo `/api`. Essa função:
///
/// - devolve a string intacta quando já começa com `http://` ou `https://`
///   (absoluta — ex.: CDN, signed URL ou backend local em
///   `http://localhost`); o upgrade automático de HTTP→HTTPS NÃO é mais
///   aplicado, pois quebrava localhost sem certificado na branch
///   `hospedagem_local`;
/// - prepend a ORIGEM do `kApiBaseUrl` (sem o `/api`) quando começa com `/`.
///
/// `Image.network` exige URL absoluta; URL relativa falha sem mensagem
/// clara. Use este helper em todo ponto da UI que renderiza uma imagem
/// vinda do backend.
String absoluteImageUrl(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return trimmed;

  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }

  final base = kApiBaseUrl;
  final baseUri = Uri.tryParse(base);
  if (baseUri == null) return trimmed;
  // Usa o path base até /api para montar URLs de uploads (/api/uploads/...)
  final basePath = baseUri.path.endsWith('/')
      ? baseUri.path.substring(0, baseUri.path.length - 1)
      : baseUri.path;
  final origin = '${baseUri.scheme}://${baseUri.authority}$basePath';
  final normalizedPath = trimmed.startsWith('/') ? trimmed : '/$trimmed';
  return '$origin$normalizedPath';
}

/// When true, data layers return hardcoded mock data instead of hitting the
/// backend. Default is `true` on this branch so the demo works without a
/// running backend (admin login, listings, users — all mocked).
const bool kUseMockData = bool.fromEnvironment('USE_MOCK_DATA');

/// When true, auth layer uses mock (fake token/user) instead of Firebase Auth.
/// Default é `false` — o app conversa com o Firebase em dev e prod. Passa
/// `--dart-define=USE_MOCK_AUTH=true` pra pular o Firebase em builds de UI
/// sem projeto configurado.
const bool kUseMockAuth = bool.fromEnvironment('USE_MOCK_AUTH');
