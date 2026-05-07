import 'package:fl_chart/fl_chart.dart' as fl;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/design_system.dart';
import '../../../listing/presentation/providers/my_properties_notifier.dart';
import '../../../search/domain/entities/property.dart';
import '../../../visits/presentation/providers/landlord_visits_notifier.dart';
import '../../domain/entities/landlord_monthly_metrics.dart';
import '../providers/landlord_monthly_metrics_provider.dart';

class LandlordDashboardPage extends ConsumerWidget {
  const LandlordDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertiesAsync = ref.watch(myPropertiesNotifierProvider);
    // A lista de imóveis só alimenta a seção "Imóveis Locados". Se o endpoint
    // estiver fora (timeout/500/filtro landlordId não implementado), a
    // dashboard continua renderizando — a seção cai num estado vazio. Nunca
    // derrubar a tela inteira por causa de um fetch secundário.
    final properties = propertiesAsync.asData?.value ?? const <Property>[];

    return BrutalistPageScaffold(
      waveSpeed: 0.15,
      waveAmplitude: 0.3,
      waveCount: 3,
      builder: (context, isDark, entrance, pulse) {
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: BrutalistPageHeader(
                title: 'Seu Painel',
                subtitle: 'Bem-vindo de volta!',
                trailing: _NotificationBell(isDark: isDark),
              ),
            ),
            const SliverToBoxAdapter(child: _StatsSection()),
            SliverToBoxAdapter(child: _QuickActionsSection(isDark: isDark)),
            SliverToBoxAdapter(
              child: _RentedPropertiesSection(
                isDark: isDark,
                properties: properties,
                isLoading: propertiesAsync.isLoading,
              ),
            ),
            const SliverToBoxAdapter(child: _RecentTenantsSection()),
            const SliverToBoxAdapter(child: _ChartsSection()),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        );
      },
    );
  }
}

/// Sino de notificações exibido no canto direito do header do dashboard.
/// Hoje é read-only (sem handler) — fica plumbed pra ligar no futuro
/// quando houver central de notificações.
class _NotificationBell extends StatelessWidget {
  const _NotificationBell({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: BrutalistPalette.subtleBg(isDark),
        borderRadius: AppRadius.borderMd,
      ),
      child: Icon(
        Icons.notifications_outlined,
        size: 22,
        color: isDark ? AppColors.whiteMuted : AppColors.lightTextTertiary,
      ),
    );
  }
}

/// Métricas do topo da dashboard. **Inquilinos** e **Visitas hoje** são
/// derivados dos providers que já existem (`myPropertiesNotifier` +
/// `landlordVisitsNotifier`). **Visitas ao perfil** e **Propostas** ainda
/// não têm endpoint no backend — renderizam `—` com tooltip explicando.
/// Ver `BACKEND_HANDOFF.md §11`.
class _StatsSection extends ConsumerWidget {
  const _StatsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final properties =
        ref.watch(myPropertiesNotifierProvider).asData?.value ??
            const <Property>[];
    final visits =
        ref.watch(landlordVisitsNotifierProvider).asData?.value ?? const [];

    // Conta inquilinos com contrato ativo — 1 por property.currentTenant
    // não-nulo. Se o mesmo tenant aluga 2 imóveis, conta 2 (cada imóvel
    // é uma unidade de gestão pro landlord).
    final tenantCount =
        properties.where((p) => p.currentTenant != null).length;

    // Visitas agendadas pra hoje (00:00–23:59 no timezone local).
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final tomorrowStart = todayStart.add(const Duration(days: 1));
    final visitsToday = visits.where((v) {
      return v.scheduledAt.isAfter(todayStart) &&
          v.scheduledAt.isBefore(tomorrowStart);
    }).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              const _PendingMetricCard(
                icon: Icons.visibility_outlined,
                label: 'Visitas ao perfil',
                tooltip:
                    'Métrica ainda não disponível — backend em expansão.',
              ),
              const SizedBox(width: 12),
              AppMetricCard(
                icon: Icons.group_outlined,
                value: tenantCount,
                label: 'Inquilinos',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const _PendingMetricCard(
                icon: Icons.description_outlined,
                label: 'Propostas',
                tooltip:
                    'Métrica ainda não disponível — backend em expansão.',
              ),
              const SizedBox(width: 12),
              AppMetricCard(
                icon: Icons.calendar_today_outlined,
                value: visitsToday,
                label: 'Visitas hoje',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Card visualmente idêntico ao [AppMetricCard] mas exibe `—` no lugar
/// do número. Usado quando a métrica depende de endpoint que ainda não
/// existe no backend. Hover mostra tooltip explicativo.
class _PendingMetricCard extends StatelessWidget {
  const _PendingMetricCard({
    required this.icon,
    required this.label,
    required this.tooltip,
  });

  final IconData icon;
  final String label;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = BrutalistPalette.title(isDark);
    final mutedColor = BrutalistPalette.muted(isDark);
    final accentColor = BrutalistPalette.accentOrange(isDark);

    return Expanded(
      child: Tooltip(
        message: tooltip,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: BrutalistPalette.surfaceBg(isDark),
            borderRadius: AppRadius.borderLg,
            border: Border.all(color: BrutalistPalette.surfaceBorder(isDark)),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: accentColor.withValues(alpha: 0.5)),
              const SizedBox(height: AppSpacing.md),
              Text(
                '—',
                style: AppTypography.headlineLarge.copyWith(
                  color: titleColor.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(color: mutedColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Seção de análise de performance — 3 gráficos lado a lado + abaixo.
/// Consome `landlordMonthlyMetricsProvider`, que tenta o endpoint do
/// backend e cai em 6 meses zerados quando ele não existe ainda (ver
/// BACKEND_HANDOFF.md §11). Assim a estrutura visual fica no lugar,
/// os eixos ficam visíveis, e quando o endpoint subir, os valores
/// populam sozinhos.
class _ChartsSection extends ConsumerWidget {
  const _ChartsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final async = ref.watch(landlordMonthlyMetricsProvider);
    // Enquanto carrega, usa o fallback zerado — evita flash de loading
    // e mantém a tela estável. O provider já devolve esse mesmo
    // fallback quando o backend não responde, então o pior caso é
    // simplesmente "6 meses com zero".
    final LandlordMonthlyMetrics metrics = async.asData?.value ??
        LandlordMonthlyMetrics.emptyLast();
    final labels = metrics.shortMonthLabels;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        const AppSectionHeader(title: 'Análise de Performance'),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Evolução dos seus aluguéis nos últimos 6 meses: imóveis '
            'ocupados, inquilinos novos e receita arrecadada.',
            style: AppTypography.bodySmall.copyWith(
              color: BrutalistPalette.muted(isDark),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: BrutalistBarChart(
                      isDark: isDark,
                      title: 'Imóveis Alugados',
                      labels: labels,
                      data: metrics.rentals
                          .map((v) => v.toDouble())
                          .toList(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: BrutalistBarChart(
                      isDark: isDark,
                      title: 'Novos Inquilinos',
                      labels: labels,
                      data: metrics.newTenants
                          .map((v) => v.toDouble())
                          .toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              BrutalistLineChart(
                isDark: isDark,
                title: r'Receita Mensal (R$)',
                labels: labels,
                valuePrefix: r'R$ ',
                points: [
                  for (var i = 0; i < metrics.monthlyRevenue.length; i++)
                    fl.FlSpot(i.toDouble(), metrics.monthlyRevenue[i]),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        const AppSectionHeader(title: 'Ações Rápidas'),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _ActionItem(
                icon: Icons.add_business_rounded,
                label: 'Novo Imóvel',
                onTap: () => context.push('/my-properties/create'),
                isDark: isDark,
              ),
              _ActionItem(
                icon: Icons.business_rounded,
                label: 'Gerenciar',
                onTap: () => context.push('/management-dossier'),
                isDark: isDark,
              ),
              _ActionItem(
                icon: Icons.event_note_rounded,
                label: 'Visitas',
                onTap: () => context.push('/landlord-visits'),
                isDark: isDark,
              ),
              _ActionItem(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Mensagens',
                onTap: () => context.go('/chat'),
                isDark: isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionItem extends StatelessWidget {

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (MediaQuery.of(context).size.width - 52) / 2,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: BrutalistPalette.subtleBg(isDark),
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: BrutalistPalette.surfaceBorder(isDark)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: BrutalistPalette.accentOrange(isDark)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: AppTypography.titleSmallBold.copyWith(
                  color: isDark ? AppColors.white : AppColors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RentedPropertiesSection extends StatelessWidget {
  const _RentedPropertiesSection({
    required this.isDark,
    required this.properties,
    this.isLoading = false,
  });

  final bool isDark;
  final List<Property> properties;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.xxl),
        const AppSectionHeader(
          title: 'Imóveis Locados',
        ),
        const SizedBox(height: AppSpacing.md),
        if (isLoading && properties.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
              vertical: AppSpacing.md,
            ),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else if (properties.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
            child: Text(
              'Nenhum imóvel locado.',
              style: AppTypography.bodyMedium.copyWith(color: BrutalistPalette.muted(isDark)),
            ),
          )
        else
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
              itemCount: properties.length > 3 ? 4 : properties.length,
              itemBuilder: (context, index) {
                if (index == 3 && properties.length > 3) {
                  return _SeeMoreTile(
                    count: properties.length - 3,
                    isDark: isDark,
                    onTap: () => context.go('/my-properties'),
                  );
                }

                final property = properties[index];
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: _PropertyTile(
                    title: property.title,
                    tenant: 'Inquilino ${index + 1}',
                    price: property.price,
                    isDark: isDark,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _SeeMoreTile extends StatelessWidget {
  const _SeeMoreTile({
    required this.count,
    required this.isDark,
    required this.onTap,
  });

  final int count;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: AppSpacing.md),
        decoration: BoxDecoration(
          color: BrutalistPalette.subtleBg(isDark),
          borderRadius: AppRadius.borderMd,
          border: Border.all(
            color: BrutalistPalette.surfaceBorder(isDark),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline_rounded,
              color: BrutalistPalette.accentPeach(isDark),
              size: 32,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Ver mais',
              style: AppTypography.labelSmall.copyWith(
                color: BrutalistPalette.muted(isDark),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$count',
              style: AppTypography.titleMedium.copyWith(
                color: BrutalistPalette.title(isDark),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PropertyTile extends StatelessWidget {

  const _PropertyTile({
    required this.title,
    required this.tenant,
    required this.price,
    required this.isDark,
  });
  final String title;
  final String tenant;
  final String price;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BrutalistPalette.surfaceBg(isDark),
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: BrutalistPalette.surfaceBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.titleSmallBold.copyWith(color: BrutalistPalette.title(isDark)), maxLines: 1),
          const SizedBox(height: 4),
          Text('Inquilino: $tenant', style: AppTypography.bodySmall.copyWith(color: BrutalistPalette.muted(isDark))),
          const Spacer(),
          Text(price, style: AppTypography.titleMediumAccent.copyWith(color: BrutalistPalette.accentPeach(isDark))),
        ],
      ),
    );
  }
}

/// Inquilinos que atualmente moram nos imóveis do landlord. Derivado
/// de `myPropertiesNotifier` — um item por property que tem
/// `currentTenant != null`. Sem inquilinos reais cadastrados (estado
/// inicial ou backend ainda sem devolver `currentTenant`), renderiza
/// um estado vazio.
///
/// Status textual (Aluguel em dia / Em negociação / etc.) é **derivado**
/// de `property.status` — não é o status real de pagamento mensal,
/// que depende de endpoint que ainda não existe (`BACKEND_HANDOFF.md §3`).
class _RecentTenantsSection extends ConsumerWidget {
  const _RecentTenantsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final properties =
        ref.watch(myPropertiesNotifierProvider).asData?.value ??
            const <Property>[];

    // Mostra só os imóveis com inquilino vinculado, os 5 mais recentes.
    // Sem campo `contractStartedAt`, mantemos a ordem de `myProperties`
    // (que vem do backend — geralmente por createdAt DESC).
    final withTenant = properties
        .where((p) => p.currentTenant != null)
        .take(5)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        const AppSectionHeader(title: 'Inquilinos Recentes'),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: withTenant.isEmpty
              ? _EmptyTenants(isDark: isDark)
              : Column(
                  children: [
                    for (int i = 0; i < withTenant.length; i++) ...[
                      _TenantItem(
                        name: withTenant[i].currentTenant!.name,
                        property: withTenant[i].title,
                        status: _statusLabel(withTenant[i].status),
                        isDark: isDark,
                      ),
                      if (i < withTenant.length - 1)
                        const SizedBox(height: 12),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  static String _statusLabel(String? propertyStatus) {
    switch (propertyStatus) {
      case 'RENTED':
        return 'Aluguel ativo';
      case 'NEGOTIATING':
        return 'Em negociação';
      case 'AVAILABLE':
      default:
        return 'Aluguel ativo';
    }
  }
}

class _EmptyTenants extends StatelessWidget {
  const _EmptyTenants({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final muted = BrutalistPalette.muted(isDark);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: BrutalistPalette.subtleBg(isDark),
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: BrutalistPalette.surfaceBorder(isDark)),
      ),
      child: Row(
        children: [
          Icon(Icons.people_outline_rounded, color: muted),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Nenhum inquilino ativo nos seus imóveis ainda.',
              style: AppTypography.bodyMedium.copyWith(color: muted),
            ),
          ),
        ],
      ),
    );
  }
}

class _TenantItem extends StatelessWidget {

  const _TenantItem({
    required this.name,
    required this.property,
    required this.status,
    required this.isDark,
  });
  final String name;
  final String property;
  final String status;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BrutalistPalette.surfaceBg(isDark),
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: BrutalistPalette.surfaceBorder(isDark)),
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: BrutalistPalette.subtleBg(isDark), child: Icon(Icons.person_rounded, color: BrutalistPalette.muted(isDark))),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTypography.titleSmallBold.copyWith(color: BrutalistPalette.title(isDark))),
                Text(property, style: AppTypography.bodySmall.copyWith(color: BrutalistPalette.muted(isDark))),
              ],
            ),
          ),
          Text(status, style: AppTypography.bodySmall.copyWith(color: BrutalistPalette.accentOrange(isDark), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
