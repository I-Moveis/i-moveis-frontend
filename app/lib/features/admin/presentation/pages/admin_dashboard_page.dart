import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failures.dart';
import '../../../../design_system/design_system.dart';
import '../../../admin_users/presentation/providers/admin_users_notifier.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
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
        final pendingCount = metrics?.pendingModeration ?? 0;

        final errorMessage = metricsAsync.hasError
            ? (metricsAsync.error is Failure
                ? (metricsAsync.error! as Failure).message
                : 'Erro ao carregar métricas.')
            : null;

        // Ocupação: RENTED / totalProperties vindos direto do GET /admin/metrics.
        final rentedCount = metrics?.propertiesByStatus['RENTED'] ?? 0;
        final occupancyRate = propertyCount > 0
            ? ((rentedCount / propertyCount) * 100).round()
            : 0;

        // Novos usuários (últimos 7 dias): filtro client-side sobre GET /users.
        final usersAsync = ref.watch(adminUsersNotifierProvider);
        final allUsers = usersAsync.value ?? const [];
        final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
        final newUsersCount = allUsers
            .where((u) =>
                u.createdAt != null && u.createdAt!.isAfter(sevenDaysAgo))
            .length;

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

                    // Layout: coluna esquerda (3 cards) | coluna direita (2 cards)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(children: [
                            _TappableMetricCard(
                              icon: Icons.people_outline,
                              value: userCount,
                              label: 'Usuários',
                              accentColor: accentColor,
                              cardBg: cardBg,
                              borderColor: borderColor,
                              titleColor: titleColor,
                              mutedColor: mutedColor,
                              onTap: () => context.push('/admin/users'),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _TappableMetricCard(
                              icon: Icons.home_outlined,
                              value: propertyCount,
                              label: 'Imóveis',
                              accentColor: accentColor,
                              cardBg: cardBg,
                              borderColor: borderColor,
                              titleColor: titleColor,
                              mutedColor: mutedColor,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _TappableMetricCard(
                              icon: Icons.donut_large_outlined,
                              value: occupancyRate,
                              label: 'Ocupação %',
                              accentColor: accentColor,
                              cardBg: cardBg,
                              borderColor: borderColor,
                              titleColor: titleColor,
                              mutedColor: mutedColor,
                            ),
                          ]),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(children: [
                            _NewUsersMetricCard(
                              count: newUsersCount,
                              accentColor: accentColor,
                              cardBg: cardBg,
                              borderColor: borderColor,
                              titleColor: titleColor,
                              mutedColor: mutedColor,
                              onTap: () => context.push('/admin/new-users'),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _TappableMetricCard(
                              icon: Icons.pending_outlined,
                              value: pendingCount,
                              label: 'Pendentes',
                              accentColor: accentColor,
                              cardBg: cardBg,
                              borderColor: borderColor,
                              titleColor: titleColor,
                              mutedColor: mutedColor,
                              onTap: () {
                                try {
                                  ref
                                      .read(adminModerationTabProvider
                                          .notifier)
                                      .selectPending();
                                } on Object {
                                  // provider pode não existir na primeira carga
                                }
                                context.push('/admin/listings');
                              },
                            ),
                          ]),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // ── Alertas Críticos ──────────────────────────────
                    _AlertsSection(
                      isDark: isDark,
                      accentColor: accentColor,
                      cardBg: cardBg,
                      borderColor: borderColor,
                      titleColor: titleColor,
                      mutedColor: mutedColor,
                      onReportsTap: () => context.push('/admin/reports'),
                      onContractsTap: () =>
                          context.push('/admin/contracts?filter=avencer'),
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

/// Card de Novos Usuários: ícone person_add + contagem real (client-side).
class _NewUsersMetricCard extends StatelessWidget {
  const _NewUsersMetricCard({
    required this.count,
    required this.accentColor,
    required this.cardBg,
    required this.borderColor,
    required this.titleColor,
    required this.mutedColor,
    required this.onTap,
  });

  final int count;
  final Color accentColor;
  final Color cardBg;
  final Color borderColor;
  final Color titleColor;
  final Color mutedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: borderColor),
        ),
        child: Column(children: [
          Icon(Icons.person_add_outlined,
              size: 20, color: accentColor.withValues(alpha: 0.7)),
          const SizedBox(height: AppSpacing.md),
          Text('$count',
              style: AppTypography.headlineLarge.copyWith(color: titleColor)),
          const SizedBox(height: AppSpacing.xs),
          Text('Novos',
              style: AppTypography.bodySmall.copyWith(color: mutedColor)),
        ]),
      ),
    );
  }
}

/// Card de métrica clicável genérico (usado pelo card Pendentes).
class _TappableMetricCard extends StatelessWidget {
  const _TappableMetricCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.accentColor,
    required this.cardBg,
    required this.borderColor,
    required this.titleColor,
    required this.mutedColor,
    this.onTap,
  });

  final IconData icon;
  final int value;
  final String label;
  final Color accentColor;
  final Color cardBg;
  final Color borderColor;
  final Color titleColor;
  final Color mutedColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: borderColor),
        ),
        child: Column(children: [
          Icon(icon, size: 20, color: accentColor.withValues(alpha: 0.7)),
          const SizedBox(height: AppSpacing.md),
          Text('$value',
              style: AppTypography.headlineLarge.copyWith(color: titleColor)),
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
    required this.onReportsTap,
    required this.onContractsTap,
  });

  final bool isDark;
  final Color accentColor;
  final Color cardBg;
  final Color borderColor;
  final Color titleColor;
  final Color mutedColor;
  final VoidCallback onReportsTap;
  final VoidCallback onContractsTap;

  @override
  Widget build(BuildContext context) {
    final alerts = [
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
