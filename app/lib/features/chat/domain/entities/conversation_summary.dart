import 'package:flutter/foundation.dart';

/// Resumo de uma conversa mostrada na lista `/chat`. É o shape mínimo
/// pra renderizar o card na lista de conversas; a thread completa é
/// carregada sob demanda em `/chat/:conversationId`.
///
/// Hoje o backend não expõe `GET /api/conversations` ainda — ver
/// `BACKEND_HANDOFF.md §4`. O provider cai em lista vazia quando o
/// endpoint não responde, e a UI mostra estado vazio.
@immutable
class ConversationSummary {
  const ConversationSummary({
    required this.id,
    required this.counterpartName,
    required this.lastMessage,
    required this.lastMessageAt,
    this.unread = false,
    this.counterpartAvatarUrl,
    this.linkedPropertyId,
    this.linkedTenantId,
  });

  factory ConversationSummary.fromJson(Map<String, dynamic> json) {
    // Alguns usuários demo foram criados com `name='landlord'` ou
    // `'tenant'` (igual ao role) — mostrar isso como nome do contato fica
    // confuso. Quando bater, caímos pro email ou pra um placeholder
    // genérico em vez de exibir o role literal.
    final rawName = (json['counterpartName'] ?? json['name'] ?? '').toString().trim();
    final isRoleLabel = const {'landlord', 'tenant', 'admin'}
        .contains(rawName.toLowerCase());
    final cleaned = (rawName.isEmpty || isRoleLabel)
        ? (json['counterpartEmail'] as String? ??
            json['email'] as String? ??
            'Conversa')
        : rawName;
    return ConversationSummary(
      id: (json['id'] ?? '').toString(),
      counterpartName: cleaned,
      lastMessage:
          (json['lastMessage'] ?? json['preview'] ?? '').toString(),
      lastMessageAt: DateTime.tryParse(
            (json['lastMessageAt'] ?? json['updatedAt'] ?? '').toString(),
          )?.toLocal() ??
          DateTime.now(),
      unread: json['unread'] == true || json['unreadCount'] is num &&
          (json['unreadCount'] as num) > 0,
      counterpartAvatarUrl:
          (json['counterpartAvatarUrl'] ?? json['avatarUrl']) as String?,
      linkedPropertyId: json['linkedPropertyId'] as String?,
      linkedTenantId: json['linkedTenantId'] as String?,
    );
  }

  /// ID usado em `context.push('/chat/:id')`. Quando vier do backend,
  /// é o UUID da conversa.
  final String id;

  /// Nome do outro lado da conversa — o inquilino (para landlord) ou o
  /// proprietário (para tenant). "Suporte I-Móveis" quando é chat com
  /// admin.
  final String counterpartName;

  /// Preview da última mensagem trocada — string livre.
  final String lastMessage;

  /// Timestamp da última mensagem, usado pra formatar o horário no card.
  final DateTime lastMessageAt;

  /// `true` quando há pelo menos uma mensagem não lida pelo usuário
  /// corrente. Marca o dot laranja no card.
  final bool unread;

  /// URL opcional do avatar do outro lado. Quando null, a UI mostra as
  /// iniciais do nome.
  final String? counterpartAvatarUrl;

  /// UUID do imóvel vinculado à conversa, quando o contexto é sobre um
  /// imóvel específico (landlord x interessado, landlord x inquilino).
  /// Null para chats genéricos (ex: conversa com suporte). Ver
  /// `BACKEND_HANDOFF.md §12`.
  final String? linkedPropertyId;

  /// UUID do inquilino do outro lado (do ponto de vista do landlord).
  /// Usado pra cruzar com a lista "Meus Inquilinos" e mostrar preview
  /// da última mensagem no card.
  final String? linkedTenantId;

  /// Primeiras letras do nome pro avatar circular quando não há foto.
  /// Ex: "João Silva" → "JS"; "Maria" → "MA".
  String get initials {
    final parts = counterpartName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) {
      final word = parts.first;
      return word.length == 1
          ? word.toUpperCase()
          : word.substring(0, 2).toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
