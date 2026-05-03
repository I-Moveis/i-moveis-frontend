import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../design_system/design_system.dart';

class LandlordDashboardPage extends StatelessWidget {
  const LandlordDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BrutalistPageScaffold(
      waveSpeed: 0.15,
      waveAmplitude: 0.3,
      waveCount: 3,
      builder: (context, isDark, entrance, pulse) {
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _HeaderSection(isDark: isDark)),
            SliverToBoxAdapter(child: _StatsSection(isDark: isDark)),
            SliverToBoxAdapter(child: _QuickActionsSection(isDark: isDark)),
            SliverToBoxAdapter(child: _RentedPropertiesSection(isDark: isDark)),
            SliverToBoxAdapter(child: _RecentTenantsSection(isDark: isDark)),
            SliverToBoxAdapter(child: _ChartsSection(isDark: isDark)),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        );
      },
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final bool isDark;
  const _HeaderSection({super.key, required this.isDark});

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
  const _StatsSection({super.key, required this.isDark});

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
  const _ChartsSection({super.key, required this.isDark});

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
                  FlSpot(0, 4500),
                  FlSpot(1, 8200),
                  FlSpot(2, 7800),
                  FlSpot(3, 12400),
                  FlSpot(4, 15600),
                  FlSpot(5, 18900),
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
  const _QuickActionsSection({super.key, required this.isDark});

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
                onTap: () => context.push('/profile/my-properties/create'),
                isDark: isDark,
              ),
              _ActionItem(
                icon: Icons.business_rounded,
                label: 'Gerenciar',
                onTap: () => context.go('/favorites'),
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
  final bool isDark;
  const _RentedPropertiesSection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        const AppSectionHeader(title: 'Imóveis Locados', action: 'Ver todos'),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            children: [
              _PropertyTile(
                title: 'Apartamento Jardins',
                tenant: 'João Silva',
                price: r'R$ 4.500',
                isDark: isDark,
              ),
              const SizedBox(width: 12),
              _PropertyTile(
                title: 'Studio Pinheiros',
                tenant: 'Maria Oliveira',
                price: r'R$ 2.800',
                isDark: isDark,
              ),
            ],
          ),
        ),
      ],
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
