import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../design_system/design_system.dart';
import '../../../../listing/presentation/providers/my_properties_notifier.dart';
import '../../../../rentals/data/contract_repository.dart';
import '../../../../search/domain/entities/property.dart';

/// "Extrato de Repasses" — visão financeira do landlord. Soma o
/// aluguel mensal de cada contrato ativo e mostra como uma linha no
/// extrato. Quando o backend expor um endpoint de pagamentos
/// processados, plugamos no GET correspondente; por enquanto a
/// estimativa vem dos contratos ativos.
class PayoutsStatementPage extends ConsumerWidget {
  const PayoutsStatementPage({super.key});

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
                  title: 'Extrato de Repasses',
                  subtitle: 'Aluguéis ativos dos seus imóveis',
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
                    error: (_, __) => _Empty(
                      isDark: isDark,
                      titleColor: titleColor,
                      mutedColor: mutedColor,
                    ),
                    data: (properties) {
                      final rented = properties
                          .where((p) => p.currentTenant != null)
                          .toList();
                      if (rented.isEmpty) {
                        return _Empty(
                          isDark: isDark,
                          titleColor: titleColor,
                          mutedColor: mutedColor,
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          children: [
                            _Summary(
                              properties: rented,
                              isDark: isDark,
                              titleColor: titleColor,
                              mutedColor: mutedColor,
                              accentColor: accentColor,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            for (final p in rented) ...[
                              _PayoutRow(
                                property: p,
                                isDark: isDark,
                                titleColor: titleColor,
                                mutedColor: mutedColor,
                                accentColor: accentColor,
                              ),
                              const SizedBox(height: AppSpacing.sm),
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

class _Summary extends ConsumerWidget {
  const _Summary({
    required this.properties,
    required this.isDark,
    required this.titleColor,
    required this.mutedColor,
    required this.accentColor,
  });

  final List<Property> properties;
  final bool isDark;
  final Color titleColor;
  final Color mutedColor;
  final Color accentColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var total = 0.0;
    for (final p in properties) {
      final t = p.currentTenant;
      if (t == null) continue;
      final contract = ref
          .watch(
            activeContractProvider(
                ContractQuery(propertyId: p.id, tenantId: t.id)),
          )
          .asData
          ?.value;
      if (contract != null) total += contract.monthlyRent;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: BrutalistPalette.surfaceBg(isDark),
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: BrutalistPalette.surfaceBorder(isDark)),
      ),
      child: Row(
        children: [
          Icon(Icons.account_balance_wallet_outlined,
              color: accentColor, size: 28),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Receita mensal estimada',
                    style: AppTypography.bodySmall.copyWith(color: mutedColor)),
                Text(_formatBrl(total),
                    style: AppTypography.headlineMedium
                        .copyWith(color: accentColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PayoutRow extends ConsumerWidget {
  const _PayoutRow({
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
    final contract = ref
        .watch(
          activeContractProvider(
            ContractQuery(propertyId: property.id, tenantId: tenant.id),
          ),
        )
        .asData
        ?.value;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: BrutalistPalette.surfaceBg(isDark),
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: BrutalistPalette.surfaceBorder(isDark)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(property.title,
                    style: AppTypography.titleSmallBold
                        .copyWith(color: titleColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(tenant.name,
                    style:
                        AppTypography.bodySmall.copyWith(color: mutedColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Text(
            contract != null
                ? _formatBrl(contract.monthlyRent)
                : 'Sem contrato',
            style: AppTypography.titleSmallBold.copyWith(
              color: contract != null ? accentColor : mutedColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({
    required this.isDark,
    required this.titleColor,
    required this.mutedColor,
  });
  final bool isDark;
  final Color titleColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_balance_wallet_outlined,
                size: 48, color: mutedColor.withValues(alpha: 0.4)),
            const SizedBox(height: AppSpacing.md),
            Text('Nenhum aluguel ativo',
                style:
                    AppTypography.headlineSmall.copyWith(color: titleColor)),
            const SizedBox(height: AppSpacing.xs),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Text(
                'Quando um inquilino assinar um contrato, o repasse mensal aparece aqui.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(color: mutedColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatBrl(double value) {
  final fixed = value.toStringAsFixed(2);
  final parts = fixed.split('.');
  final intPart = parts[0];
  final decPart = parts.length > 1 ? parts[1] : '00';
  final buf = StringBuffer();
  for (var i = 0; i < intPart.length; i++) {
    if (i > 0 && (intPart.length - i) % 3 == 0) buf.write('.');
    buf.write(intPart[i]);
  }
  return 'R\$ $buf,$decPart';
}
