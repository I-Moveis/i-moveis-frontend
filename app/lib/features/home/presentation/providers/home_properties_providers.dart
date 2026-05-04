import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../search/domain/entities/property.dart';
import '../../../search/domain/usecases/search_properties_usecase.dart';
import '../../../search/presentation/providers/search_filters_provider.dart';

/// Tamanho da "fatia" mostrada em cada seção da home. Limite real do backend
/// fica a cargo do repositório (`page=1&limit=10`); o corte aqui é só visual.
const int _kHomeSectionSize = 6;

/// Seção "Destaques" — pede ao backend para ordenar por `isFeatured` e
/// filtra apenas os imóveis com a flag ligada.
final featuredHomePropertiesProvider =
    FutureProvider.autoDispose<List<Property>>((ref) async {
  final usecase = ref.watch(searchPropertiesUseCaseProvider);
  final result = await usecase.execute(
    const SearchFilters(isFeatured: true, orderBy: 'isFeatured'),
  );
  return result.properties.take(_kHomeSectionSize).toList();
});

/// Seção "Perto de você". Enquanto a home não pede permissão de localização,
/// caímos em `orderBy: createdAt` (imóveis mais recentes). Quando o toggle
/// de GPS aterrissar na home, este provider vira `setNearbySearch`.
final nearbyHomePropertiesProvider =
    FutureProvider.autoDispose<List<Property>>((ref) async {
  final usecase = ref.watch(searchPropertiesUseCaseProvider);
  final result = await usecase.execute(
    const SearchFilters(orderBy: 'createdAt'),
  );
  return result.properties.take(_kHomeSectionSize).toList();
});

/// Seção "Mais procurados" — ordena pelo campo `views` que o backend
/// incrementa a cada visualização de detalhe.
final trendingHomePropertiesProvider =
    FutureProvider.autoDispose<List<Property>>((ref) async {
  final usecase = ref.watch(searchPropertiesUseCaseProvider);
  final result = await usecase.execute(
    const SearchFilters(orderBy: 'views'),
  );
  return result.properties.take(_kHomeSectionSize).toList();
});
