import 'package:fl_chart/fl_chart.dart' as fl;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/design_system.dart';
import '../../../listing/presentation/providers/my_properties_notifier.dart';
import '../../../search/domain/entities/property.dart';

class LandlordDashboardPage extends ConsumerWidget {
  const LandlordDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertiesAsync = ref.watch(myPropertiesNotifierProvider);

    return BrutalistPageScaffold(
      waveSpeed: 0.15,
      waveAmplitude: 0.3,
      waveCount: 3,
      builder: (context, isDark, entrance, pulse) {
        return propertiesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erro ao carregar dados: $e')),
          data: (properties) => CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _HeaderSection(isDark: isDark)),
              SliverToBoxAdapter(child: _StatsSection(isDark: isDark)),
              SliverToBoxAdapter(child: _QuickActionsSection(isDark: isDark)),
              SliverToBoxAdapter(
                child: _RentedPropertiesSection(
                  isDark: isDark,
                  properties: properties,
                ),
              ),
              SliverToBoxAdapter(child: _RecentTenantsSection(isDark: isDark)),
              SliverToBoxAdapter(child: _ChartsSection(isDark: isDark)),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        );
      },
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final bool isDark;
  const _HeaderSection({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final titleColor = isDark ? AppColors.white : AppColors.black;
    final subtitleColor = isDark ? AppColors.whiteDim : AppColors.lightTextSecondary;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bem-vindo de volta!',
                  style: AppTypography.bodyLarge.copyWith(color: subtitleColor),
                ),
                const SizedBox(height: 4),
                Text(
                  'Seu Painel',
                  style: AppTypography.headlineLarge.copyWith(color: titleColor),
                ),
              ],
            ),
          ),
          Container(
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
          ),
        ],
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  final bool isDark;
  const _StatsSection({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          const Row(
            children: [
              AppMetricCard(
                icon: Icons.visibility_outlined,
                value: 1240,
                label: 'Visitas ao perfil',
              ),
              SizedBox(width: 12),
              AppMetricCard(
                icon: Icons.group_outlined,
                value: 24,
                label: 'Inquilinos',
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              AppMetricCard(
                icon: Icons.description_outlined,
                value: 12,
                label: 'Propostas',
              ),
              SizedBox(width: 12),
              AppMetricCard(
                icon: Icons.calendar_today_outlined,
                value: 5,
                label: 'Visitas hoje',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartsSection extends StatelessWidget {
  final bool isDark;
  const _ChartsSection({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        const AppSectionHeader(title: 'Análise de Performance'),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: BrutalistBarChart(
                      isDark: isDark,
                      title: 'Locações Mensais',
                      labels: months,
                      data: const [2, 3, 5, 4, 6, 8],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: BrutalistBarChart(
                      isDark: isDark,
                      title: 'Novos Inquilinos',
                      labels: months,
                      data: const [1, 2, 4, 3, 5, 7],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              BrutalistLineChart(
                isDark: isDark,
                title: r'Receita Mensal (R$)',
                labels: months,
                valuePrefix: r'R$ ',
                points: const [
                  fl.FlSpot(0, 4500),
                  fl.FlSpot(1, 8200),
                  fl.FlSpot(2, 7800),
                  fl.FlSpot(3, 12400),
                  fl.FlSpot(4, 15600),
                  fl.FlSpot(5, 18900),
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
  final bool isDark;
  const _QuickActionsSection({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        const AppSectionHeader(title: 'Ações Rápidas'),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                onTap: () => context.push('/profile/landlord-visits'),
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
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;

  const _ActionItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
  });

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
  });

  final bool isDark;
  final List<Property> properties;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.xxl),
        AppSectionHeader(
          title: 'Imóveis Locados',
        ),
        const SizedBox(height: AppSpacing.md),
        if (properties.isEmpty)
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
  final String title;
  final String tenant;
  final String price;
  final bool isDark;

  const _PropertyTile({
    super.key,
    required this.title,
    required this.tenant,
    required this.price,
    required this.isDark,
  });

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

class _RecentTenantsSection extends StatelessWidget {
  final bool isDark;
  const _RecentTenantsSection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        const AppSectionHeader(title: 'Inquilinos Recentes'),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              _TenantItem(name: 'Carlos Mendes', property: 'Cobertura Vila Madalena', status: 'Aluguel em dia', isDark: isDark),
              const SizedBox(height: 12),
              _TenantItem(name: 'Ana Paula', property: 'Loft Industrial', status: 'Novo Contrato', isDark: isDark),
            ],
          ),
        ),
      ],
    );
  }
}

class _TenantItem extends StatelessWidget {
  final String name;
  final String property;
  final String status;
  final bool isDark;

  const _TenantItem({
    super.key,
    required this.name,
    required this.property,
    required this.status,
    required this.isDark,
  });

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
