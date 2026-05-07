import '../entities/favorite.dart';

/// Contrato de alto nível pra persistência de favoritos do usuário logado.
/// Implementações mapeiam erros de transporte pra Failures.
abstract class FavoriteRepository {
  /// Lista todos os favoritos do usuário autenticado, com `property`
  /// aninhado (quando o backend dá join).
  Future<List<Favorite>> list();

  /// Adiciona o imóvel aos favoritos. Idempotente — o backend usa upsert,
  /// então chamar duas vezes com o mesmo id não gera duplicata.
  Future<Favorite> add(String propertyId);

  /// Remove o imóvel dos favoritos. Silencioso quando o imóvel já não
  /// estava favoritado (implementação deve tratar 404 como sucesso).
  Future<void> remove(String propertyId);

  /// Confirma se um imóvel específico está favoritado. Útil na tela de
  /// detalhes pra pintar o coração certo antes de `list()` resolver.
  Future<bool> check(String propertyId);
}
