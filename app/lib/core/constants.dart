/// Base URL for the i-Móveis REST API. Pode ser sobrescrita em build local
/// via `--dart-define=API_BASE_URL=http://localhost:3000/api`.
String get kApiBaseUrl {
  const envUrl = String.fromEnvironment('API_BASE_URL');
  if (envUrl.isNotEmpty) return envUrl;
  return 'https://lab.alphaedtech.org.br/server01/api/';
}

/// Network timeouts for the Dio client.
const Duration kApiConnectTimeout = Duration(seconds: 15);
const Duration kApiReceiveTimeout = Duration(seconds: 30);

/// Converte um path de imagem para URL absoluta. O backend serve fotos
/// em `<API_ROOT>/uploads/<propertyId>/<file>.jpg` (express-static
/// montado em `/api/uploads` — incluso no path do `kApiBaseUrl`):
///
/// - se a string já começa com `http://`/`https://` (CDN ou signed URL),
///   devolve intacta (forçando https quando vier http);
/// - se começa com `/`, prepend a `origin + basePath` do `kApiBaseUrl`
///   pra montar a URL absoluta correta.
///
/// `Image.network` exige URL absoluta; URL relativa falha sem mensagem
/// clara. Use este helper em todo ponto da UI que renderiza uma imagem
/// vinda do backend.
String absoluteImageUrl(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return trimmed;

  // Força HTTPS se a URL já for absoluta mas usar HTTP. Isso corrige casos
  // onde o backend devolve URLs absolutas via protocolo inseguro.
  if (trimmed.startsWith('http://')) {
    return trimmed.replaceFirst('http://', 'https://');
  }

  if (trimmed.startsWith('https://')) {
    return trimmed;
  }

  final base = kApiBaseUrl;
  final baseUri = Uri.tryParse(base);
  if (baseUri == null) return trimmed;
  // Uploads são servidos pelo express-static na raiz do servidor, FORA do
  // prefixo /api. Removemos o segmento final /api (e variantes /api/vN) do
  // path base para que /uploads/... resolva corretamente.
  var basePath = baseUri.path;
  if (basePath.endsWith('/')) {
    basePath = basePath.substring(0, basePath.length - 1);
  }
  basePath = basePath.replaceFirst(RegExp(r'/api(/v\d+)?$'), '');
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
