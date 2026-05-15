import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/design_system.dart';
import '../../../listing/presentation/providers/my_properties_notifier.dart';
import '../../../search/domain/entities/property.dart';
import '../../data/contract_repository.dart';
import 'my_contracts_page.dart';

/// Lista os contratos ATIVOS dos imóveis do landlord. Cruza:
/// - `myPropertiesNotifierProvider` — uma linha por imóvel com inquilino
///   atual
/// - `activeContractProvider(propertyId, tenantId)` — busca o contrato
///   ativo individualmente (mesmo padrão de `tenants_page.dart`)
class ActiveContractsPage extends ConsumerWidget {
  const ActiveContractsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propsAsync = ref.watch(myPropertiesNotifierProvider);

    return BrutalistPageScaffold(
      builder: (context, isDark, entrance, pulse) {
        final fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
          parent: entrance,
          curve: const Interval(0.1, 0.5, curve: Curves.easeOut),
        ));
        final titleColor = BrutalistPalette.title(isDark);
        final mutedColor = BrutalistPalette.muted(isDark);
        final accentColor =
            isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;

        return Opacity(
          opacity: fade.value,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: BrutalistPageHeader(
                  title: 'Contratos Ativos',
                  subtitle: 'Aluguéis em vigor nos seus imóveis',
                  onBack: () => context.pop(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal),
                  child: propsAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(AppSpacing.xxxl),
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    error: (_, __) => ContractsEmpty(
                      isDark: isDark,
                      titleColor: titleColor,
                      mutedColor: mutedColor,
                      message: 'Não foi possível carregar os contratos.',
                    ),
                    data: (properties) {
                      final rented = properties
                          .where((p) => p.currentTenant != null)
                          .toList();
                      if (rented.isEmpty) {
                        return ContractsEmpty(
                          isDark: isDark,
                          titleColor: titleColor,
                          mutedColor: mutedColor,
                          message:
                              'Quando você tiver inquilinos com contrato ativo, '
                              'eles aparecem aqui.',
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          children: [
                            for (final p in rented) ...[
                              _LandlordContractCard(
                                property: p,
                                isDark: isDark,
                                titleColor: titleColor,
                                mutedColor: mutedColor,
                                accentColor: accentColor,
                              ),
                              const SizedBox(height: AppSpacing.md),
                            ],
                            const SizedBox(height: AppSpacing.massive),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LandlordContractCard extends ConsumerWidget {
  const _LandlordContractCard({
    required this.property,
    required this.isDark,
    required this.titleColor,
    required this.mutedColor,
    required this.accentColor,
  });

  final Property property;
  final bool isDark;
  final Color titleColor;
  final Color mutedColor;
  final Color accentColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenant = property.currentTenant!;
    final contractAsync = ref.watch(
      activeContractProvider(
        ContractQuery(propertyId: property.id, tenantId: tenant.id),
      ),
    );

    final contract = contractAsync.asData?.value;

    // Monta o `raw` no shape esperado pelo ContractCard (mesmo formato
    // que o backend devolve em /tenants/:id/contracts).
    final raw = <String, dynamic>{
      'id': contract?.id ?? '',
      'startDate': contract?.startDate.toIso8601String(),
      'endDate': contract?.endDate.toIso8601String(),
      'monthlyRent': contract?.monthlyRent ?? 0,
      'status': contract != null ? 'ACTIVE' : 'PENDING',
      'property': {
        'id': property.id,
        'title': property.title,
        'address': property.address,
      },
      'tenant': {
        'id': tenant.id,
        'name': tenant.name,
      },
    };

    return ContractCard(
      raw: raw,
      isDark: isDark,
      titleColor: titleColor,
      mutedColor: mutedColor,
      accentColor: accentColor,
      showLandlord: false,
      showTenant: true,
    );
  }
}
