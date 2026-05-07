import 'package:flutter/foundation.dart';

import '../../../search/domain/entities/property.dart';

/// Item de favoritos como o backend retorna em `GET /api/favorites`.
/// O servidor envia o `property` aninhado (com a imagem de capa), então
/// a UI consegue listar os salvos numa única request sem cair em N+1
/// chamadas ao endpoint de detalhe.
@immutable
class Favorite {
  const Favorite({
    required this.propertyId,
    required this.createdAt,
    this.property,
  });

  final String propertyId;
  final DateTime createdAt;

  /// Pode vir `null` em cenários onde o backend omite a join (ex: `POST`
  /// retorna o favorite mas a UI só precisa do id pra atualizar estado).
  final Property? property;
}
