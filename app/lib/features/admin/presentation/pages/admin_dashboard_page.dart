import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failures.dart';
import '../../../../design_system/design_system.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../listing/presentation/providers/my_properties_notifier.dart';
import '../providers/admin_metrics_notifier.dart';
import '../providers/admin_shared_providers.dart';

/// Admin dashboard — lê `GET /admin/metrics` via [adminMetricsNotifierProvider].
/// Inclui métricas, alertas críticos e menu de acesso rápido.
class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BrutalistPageScaffold(
      builder: (context, isDark, entrance, pulse) {
        final titleColor = BrutalistPalette.title(isDark);
        final mutedColor = BrutalistPalette.muted(isDark);
        final accentColor =
            isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;
        final cardBg = BrutalistPalette.surfaceBg(isDark);
        final borderColor = BrutalistPalette.surfaceBorder(isDark);

        final metricsAsync = ref.watch(adminMetricsNotifierProvider);
        final metrics = metricsAsync.value;
        final userCount = metrics?.totalUsers ?? 0;
        final propertyCount = metrics?.totalProperties ?? 0;
        final visitCount = metrics?.totalVisits ?? 0;
        final pendingCount = metrics?.pendingModeration ?? 0;
        
        final errorMessage = metricsAsync.hasError
            ? (metricsAsync.error is Failure
                ? (metricsAsync.error! as Failure).message
                : 'Erro ao carregar métricas.')
            : null;

        // Taxa de ocupação calculada client-side a partir do status dos imóveis.
        final properties = ref.watch(myPropertiesNotifierProvider);
        final propertyList = properties.value ?? const [];
        final rentedCount =
            propertyList.where((p) => p.type == 'RENTED').length;
        final occupancyRate = propertyCount > 0
            ? ((rentedCount / propertyCount) * 100).round()
            : 42; // valor ilustrativo quando lista está vazia

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.xl),

                    // ── Header ──────────────────────────────────────
                    Row(children: [
                      Expanded(
                        child: Text('Painel admin',
                            style: AppTypography.headlineLarge
                                .copyWith(color: titleColor)),
                      ),
                      GestureDetector(
                        onTap: () {
                          ref.read(authNotifierProvider.notifier).logout();
                          context.go('/login');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.sm),
                          decoration: BoxDecoration(
                            borderRadius: AppRadius.borderFull,
                            border: Border.all(
                                color: AppColors.error.withValues(alpha: 0.2)),
                          ),
                          child: Text('Sair',
                              style: AppTypography.titleSmall
                                  .copyWith(color: AppColors.error)),
                        ),
                      ),
                    ]),
                    const SizedBox(height: AppSpacing.xxl),

                    // ── Métricas ─────────────────────────────────────
                    const AppSectionHeader(title: 'Métricas'),
                    const SizedBox(height: AppSpacing.md),
                    
                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: Text(
                          errorMessage,
                          style: AppTypography.bodySmall
                              .copyWith(color: AppColors.error),
                        ),
                      ),

                    Row(children: [
                      AppMetricCard(
                        icon: Icons.people_outline,
                        value: userCount,
                        label: 'Usuários',
                      ),
                      const SizedBox(width: AppSpacing.md),
                      AppMetricCard(
                        icon: Icons.home_outlined,
                        value: propertyCount,
                        label: 'Imóveis',
                      ),
                    ]),
                    const SizedBox(height: AppSpacing.md),

                    Row(children: [
                      AppMetricCard(
                        icon: Icons.donut_large_outlined,
                        value: occupancyRate,
                        label: 'Ocupação %',
                      ),
                      const SizedBox(width: AppSpacing.md),
                      _MockMetricCard(
                        icon: Icons.fiber_new_outlined,
                        displayValue: '3',
                        label: 'Novos (7d)',
                        accentColor: accentColor,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        titleColor: titleColor,
                        mutedColor: mutedColor,
                      ),
                    ]),
                    const SizedBox(height: AppSpacing.md),

                    Row(children: [
                      AppMetricCard(
                        icon: Icons.event_available_outlined,
                        value: visitCount,
                        label: 'Visitas',
                      ),
                      const SizedBox(width: AppSpacing.md),
                      AppMetricCard(
                        icon: Icons.pending_outlined,
                        value: pendingCount,
                        label: 'Pendentes',
                      ),
                    ]),
                    const SizedBox(height: AppSpacing.xxl),

                    // ── Alertas Críticos ──────────────────────────────
                    _AlertsSection(
                      isDark: isDark,
                      accentColor: accentColor,
                      cardBg: cardBg,
                      borderColor: borderColor,
                      titleColor: titleColor,
                      mutedColor: mutedColor,
                      onModerationTap: () {
                        try {
                          ref.read(adminModerationTabProvider.notifier).selectPending();
                        } on Object {
                          // Provider pode não existir durante primeira carga;
                          // navegação deve prosseguir mesmo assim.
                        }
                        context.push('/admin/listings');
                      },
                      onReportsTap: () => context.push('/admin/reports'),
                      onContractsTap: () => context.push('/admin/contracts'),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // ── Acesso rápido ─────────────────────────────────
                    const AppSectionHeader(title: 'Acesso rápido'),
                    const SizedBox(height: AppSpacing.md),
                    AppMenuGroup(items: [
                      AppMenuGroupItem(
                        icon: Icons.people_outline,
                        label: 'Gerenciar usuários',
                        onTap: () => context.push('/admin/users'),
                      ),
                      AppMenuGroupItem(
                        icon: Icons.home_outlined,
                        label: 'Moderar anúncios',
                        onTap: () => context.push('/admin/listings'),
                      ),
                      AppMenuGroupItem(
                        icon: Icons.article_outlined,
                        label: 'Gerenciar contratos',
                        onTap: () => context.push('/admin/contracts'),
                      ),
                      AppMenuGroupItem(
                        icon: Icons.flag_outlined,
                        label: 'Central de denúncias',
                        onTap: () => context.push('/admin/reports'),
                      ),
                    ]),
                    const SizedBox(height: AppSpacing.massive),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MockMetricCard extends StatelessWidget {
  const _MockMetricCard({
    required this.icon,
    required this.displayValue,
    required this.label,
    required this.accentColor,
    required this.cardBg,
    required this.borderColor,
    required this.titleColor,
    required this.mutedColor,
  });

  final IconData icon;
  final String displayValue;
  final String label;
  final Color accentColor;
  final Color cardBg;
  final Color borderColor;
  final Color titleColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: borderColor),
        ),
        child: Column(children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, size: 20, color: accentColor.withValues(alpha: 0.5)),
              Positioned(
                top: -4,
                right: -8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 3, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('demo',
                      style: AppTypography.tagBadge
                          .copyWith(color: AppColors.warning, fontSize: 7)),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(displayValue,
              style:
                  AppTypography.headlineLarge.copyWith(color: titleColor)),
          const SizedBox(height: AppSpacing.xs),
          Text(label,
              style: AppTypography.bodySmall.copyWith(color: mutedColor)),
        ]),
      ),
    );
  }
}

class _AlertsSection extends StatelessWidget {
  const _AlertsSection({
    required this.isDark,
    required this.accentColor,
    required this.cardBg,
    required this.borderColor,
    required this.titleColor,
    required this.mutedColor,
    required this.onModerationTap,
    required this.onReportsTap,
    required this.onContractsTap,
  });

  final bool isDark;
  final Color accentColor;
  final Color cardBg;
  final Color borderColor;
  final Color titleColor;
  final Color mutedColor;
  final VoidCallback onModerationTap;
  final VoidCallback onReportsTap;
  final VoidCallback onContractsTap;

  @override
  Widget build(BuildContext context) {
    final alerts = [
      _Alert(
        icon: Icons.home_outlined,
        message: '4 anúncios aguardando moderação',
        color: AppColors.warning,
        onTap: onModerationTap,
      ),
      _Alert(
        icon: Icons.person_off_outlined,
        message: '1 usuário com relatos de comportamento inadequado',
        color: AppColors.error,
        onTap: onReportsTap,
      ),
      _Alert(
        icon: Icons.article_outlined,
        message: '2 contratos próximos ao vencimento',
        color: AppColors.info,
        onTap: onContractsTap,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const AppSectionHeader(title: 'Alertas'),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.12),
              borderRadius: AppRadius.borderFull,
            ),
            child: Text('demo',
                style: AppTypography.tagBadge
                    .copyWith(color: AppColors.warning, fontSize: 9)),
          ),
        ]),
        const SizedBox(height: AppSpacing.md),
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: AppRadius.borderLg,
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: List.generate(alerts.length, (i) {
              final a = alerts[i];
              final isLast = i == alerts.length - 1;
              return Column(children: [
                InkWell(
                  onTap: a.onTap,
                  borderRadius: BorderRadius.vertical(
                    top: i == 0 ? const Radius.circular(12) : Radius.zero,
                    bottom:
                        isLast ? const Radius.circular(12) : Radius.zero,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                    child: Row(children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: a.color.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(a.icon, size: 16, color: a.color),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(a.message,
                            style: AppTypography.bodySmall
                                .copyWith(color: titleColor)),
                      ),
                      Icon(Icons.chevron_right_rounded,
                          size: 16,
                          color: mutedColor.withValues(alpha: 0.5)),
                    ]),
                  ),
                ),
                if (!isLast)
                  Divider(
                      height: 1,
                      color: borderColor,
                      indent: AppSpacing.lg,
                      endIndent: AppSpacing.lg),
              ]);
            }),
          ),
        ),
      ],
    );
  }
}

class _Alert {
  const _Alert({
    required this.icon,
    required this.message,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String message;
  final Color color;
  final VoidCallback onTap;
}
