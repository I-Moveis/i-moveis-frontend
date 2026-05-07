import '../../../search/data/models/property_api_model.dart';
import '../../domain/entities/favorite.dart';

/// Converte um item vindo de `GET /api/favorites` (ou `POST /api/favorites`)
/// pra [Favorite] do domínio.
///
/// O backend devolve shape:
/// ```json
/// { "userId": "...", "propertyId": "...", "createdAt": "ISO",
///   "property": { "images": [] } }
/// ```
/// A chave `property` pode não existir no POST em alguns shapes — nesse
/// caso a entidade do domínio carrega só o id.
Favorite favoriteFromApiJson(Map<String, dynamic> json) {
  final propertyJson = json['property'];
  // Dio decodifica JSON aninhado como `Map<dynamic, dynamic>` em certas
  // versões — um check `is Map<String, dynamic>` direto falha silenciosamente
  // e a property vira `null`. Precisa ser rebuilt via `.from()`.
  return Favorite(
    propertyId: (json['propertyId'] ?? '').toString(),
    createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
        DateTime.now(),
    property: propertyJson is Map
        ? propertyFromApiJson(Map<String, dynamic>.from(propertyJson))
        : null,
  );
}
