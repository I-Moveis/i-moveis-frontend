import 'package:fl_chart/fl_chart.dart' as fl;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/design_system.dart';
import '../../../listing/presentation/providers/my_properties_notifier.dart';
import '../../../notifications/presentation/providers/notifications_notifier.dart';
import '../../../search/domain/entities/property.dart';
import '../../../visits/presentation/providers/landlord_visits_notifier.dart';
import '../../domain/entities/landlord_monthly_metrics.dart';
import '../providers/landlord_metrics_provider.dart';
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
/// Toca → abre `/notifications`. Mostra um dot laranja quando há
/// notificações não lidas no cache local (populado pelo listener FCM
/// no futuro, hoje só ingest manual em dev).
class _NotificationBell extends ConsumerWidget {
  const _NotificationBell({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadNotificationsCountProvider);
    final accentColor = BrutalistPalette.accentPeach(isDark);
    return GestureDetector(
      onTap: () => context.push('/notifications'),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: BrutalistPalette.subtleBg(isDark),
          borderRadius: AppRadius.borderMd,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.notifications_outlined,
              size: 22,
              color: isDark
                  ? AppColors.whiteMuted
                  : AppColors.lightTextTertiary,
            ),
            if (unread > 0)
              Positioned(
                top: 11,
                right: 13,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Métricas do topo da dashboard. **Inquilinos** e **Visitas hoje** são
/// derivados dos providers locais (`myPropertiesNotifier` +
/// `landlordVisitsNotifier`). **Visitas ao perfil** e **Propostas
/// pendentes** vêm de `GET /api/landlord/metrics`.
class _StatsSection extends ConsumerWidget {
  const _StatsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final properties =
        ref.watch(myPropertiesNotifierProvider).asData?.value ??
            const <Property>[];
    final visits =
        ref.watch(landlordVisitsNotifierProvider).asData?.value ?? const [];
    final metrics = ref.watch(landlordMetricsProvider).asData?.value;

    // 1 imóvel RENTED conta como 1 inquilino. Aproximação: ainda não
    // temos Contract.ACTIVE persistido no backend depois do PATCH de
    // proposta (ver BACKEND_GAPS.md §14), então `currentTenant` fica
    // null e a contagem por contrato sai sempre zero. `status` é
    // atualizado pelo backend no aceite, então usamos ele como proxy
    // até o Contract ser criado de fato.
    final tenantCount =
        properties.where((p) => p.status == 'RENTED').length;

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
              AppMetricCard(
                icon: Icons.visibility_outlined,
                value: metrics?.profileViews ?? 0,
                label: 'Visitas ao perfil',
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
              AppMetricCard(
                icon: Icons.description_outlined,
                value: metrics?.proposalsPending ?? 0,
                label: 'Propostas',
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

/// Seção de análise de performance — 3 gráficos lado a lado + abaixo.
/// Consome `landlordMonthlyMetricsProvider` (`GET /api/properties/analytics/monthly`).
/// Em falha de rede, cai em 6 meses zerados pra estrutura visual ficar
/// no lugar.
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
    final metrics = async.asData?.value ??
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

/// Card horizontal na dashboard com os imóveis **efetivamente alugados**
/// do landlord. Filtra a lista por `status == 'RENTED'` e usa o
/// `currentTenant.name` real de cada imóvel (US-004). Quando o landlord
/// tem mais de 3 rented, o 4º slot vira tile "Ver mais" que navega para
/// /my-properties. Tocar num tile abre a análise do imóvel
/// (/my-properties/:id/analytics).
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
    final rented =
        properties.where((p) => p.status == 'RENTED').toList(growable: false);
    final mutedColor = BrutalistPalette.muted(isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.xxl),
        const AppSectionHeader(
          title: 'Imóveis Locados',
        ),
        const SizedBox(height: AppSpacing.md),
        if (isLoading && rented.isEmpty)
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
        else if (rented.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: BrutalistPalette.surfaceBg(isDark),
                borderRadius: AppRadius.borderLg,
                border:
                    Border.all(color: BrutalistPalette.surfaceBorder(isDark)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.home_work_outlined,
                    size: 32,
                    color: mutedColor.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Nenhum imóvel alugado ainda.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium.copyWith(
                      color: mutedColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'Seus imóveis aparecem aqui quando fecharem contrato.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySmall.copyWith(color: mutedColor),
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
              itemCount: rented.length > 3 ? 4 : rented.length,
              itemBuilder: (context, index) {
                if (index == 3 && rented.length > 3) {
                  return _SeeMoreTile(
                    count: rented.length - 3,
                    isDark: isDark,
                    onTap: () => context.go('/my-properties'),
                  );
                }

                final property = rented[index];
                final rawTenantName = property.currentTenant?.name ?? '';
                final tenantName = rawTenantName.isNotEmpty
                    ? rawTenantName
                    : 'Inquilino não identificado';
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: _PropertyTile(
                    title: property.title,
                    tenant: tenantName,
                    price: property.price,
                    isDark: isDark,
                    onTap: () =>
                        context.go('/my-properties/${property.id}/analytics'),
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
    this.onTap,
  });
  final String title;
  final String tenant;
  final String price;
  final bool isDark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            Text(
              title,
              style: AppTypography.titleSmallBold
                  .copyWith(color: BrutalistPalette.title(isDark)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'Inquilino: $tenant',
              style: AppTypography.bodySmall
                  .copyWith(color: BrutalistPalette.muted(isDark)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Text(
              price,
              style: AppTypography.titleMediumAccent
                  .copyWith(color: BrutalistPalette.accentPeach(isDark)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Inquilinos que atualmente moram nos imóveis do landlord. Derivado
/// de `myPropertiesNotifier` — um item por property com
/// `currentTenant != null`. Status textual derivado de `property.status`
/// (operacional do imóvel, não do pagamento mensal — ver
/// "Histórico Financeiro" para isso).
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
