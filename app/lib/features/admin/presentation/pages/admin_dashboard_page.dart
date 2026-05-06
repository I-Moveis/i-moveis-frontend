import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failures.dart';
import '../../../../design_system/design_system.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../providers/admin_metrics_notifier.dart';

/// Admin dashboard ÔÇö l├¬ `GET /admin/metrics` via [adminMetricsNotifierProvider].
class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BrutalistPageScaffold(
      builder: (context, isDark, entrance, pulse) {
        final titleColor = BrutalistPalette.title(isDark);

        final metricsAsync = ref.watch(adminMetricsNotifierProvider);
        final metrics = metricsAsync.value;
        final userCount = metrics?.totalUsers;
        final propertyCount = metrics?.totalProperties;
        final visitCount = metrics?.totalVisits;
        final pendingCount = metrics?.pendingModeration;
        final errorMessage = metricsAsync.hasError
            ? (metricsAsync.error is Failure
                ? (metricsAsync.error! as Failure).message
                : 'Erro ao carregar m├®tricas.')
            : null;

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
                                color:
                                    AppColors.error.withValues(alpha: 0.2)),
                          ),
                          child: Text('Sair',
                              style: AppTypography.titleSmall
                                  .copyWith(color: AppColors.error)),
                        ),
                      ),
                    ]),
                    const SizedBox(height: AppSpacing.xxl),
                    const AppSectionHeader(title: 'M├®tricas'),
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
                        value: userCount ?? 0,
                        label: 'Usu├írios',
                      ),
                      const SizedBox(width: AppSpacing.md),
                      AppMetricCard(
                        icon: Icons.home_outlined,
                        value: propertyCount ?? 0,
                        label: 'Im├│veis',
                      ),
                    ]),
                    const SizedBox(height: AppSpacing.md),
                    Row(children: [
                      AppMetricCard(
                        icon: Icons.event_available_outlined,
                        value: visitCount ?? 0,
                        label: 'Visitas',
                      ),
                      const SizedBox(width: AppSpacing.md),
                      AppMetricCard(
                        icon: Icons.pending_outlined,
                        value: pendingCount ?? 0,
                        label: 'Pendentes',
                      ),
                    ]),
                    const SizedBox(height: AppSpacing.xxl),
                    const AppSectionHeader(title: 'Acesso r├ípido'),
                    const SizedBox(height: AppSpacing.md),
                    AppMenuGroup(items: [
                      AppMenuGroupItem(
                        icon: Icons.people_outline,
                        label: 'Gerenciar usu├írios',
                        onTap: () => context.push('/admin/users'),
                      ),
                      AppMenuGroupItem(
                        icon: Icons.home_outlined,
                        label: 'Moderar an├║ncios',
                        onTap: () => context.push('/admin/listings'),
                      ),
                      AppMenuGroupItem(
                        icon: Icons.article_outlined,
                        label: 'Gerenciar contratos',
                        onTap: () => context.push('/admin/contracts'),
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
