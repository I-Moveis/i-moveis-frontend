/// Origem de uma visita: agendada manualmente pelo usuário (app/web) ou
/// automaticamente por um agente de IA (ex: bot do WhatsApp que processa
/// mensagem do inquilino e cria a visita sem intervenção humana). Vem
/// como enum `VisitSource { MANUAL, AI }` no response de `GET /api/visits*`.
enum VisitSource {
  manual,
  ai;

  /// Converte o valor do backend (`'MANUAL' | 'AI'`) no enum. Qualquer valor
  /// desconhecido ou ausente cai em [VisitSource.manual] — default seguro,
  /// já que é o caso mais comum e evita que bugs de parsing inflacionem a
  /// contagem de visitas da IA.
  static VisitSource fromApi(String? raw) {
    switch (raw) {
      case 'AI':
        return VisitSource.ai;
      case 'MANUAL':
      default:
        return VisitSource.manual;
    }
  }

  String toApi() {
    switch (this) {
      case VisitSource.ai:
        return 'AI';
      case VisitSource.manual:
        return 'MANUAL';
    }
  }
}
