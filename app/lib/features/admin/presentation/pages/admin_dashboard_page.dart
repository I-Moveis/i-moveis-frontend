import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/design_system.dart';
import '../../../admin_users/presentation/providers/admin_users_notifier.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../listing/presentation/providers/my_properties_notifier.dart';

/// Admin dashboard — live user/property counts aggregated client-side from
/// the list providers. Contracts/pending cards stay placeholder because
/// the backend doesn't expose those endpoints (see BACKEND_GAPS.md).
class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BrutalistPageScaffold(
      builder: (context, isDark, entrance, pulse) {
        final titleColor = BrutalistPalette.title(isDark);

        final users = ref.watch(adminUsersNotifierProvider);
        final properties = ref.watch(myPropertiesNotifierProvider);

        final userCount = users.value?.length;
        final propertyCount = properties.value?.length;

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
                          context
                              .read<AuthBloc>()
                              .add(const AuthEvent.logoutRequested());
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
                    const AppSectionHeader(title: 'Métricas'),
                    const SizedBox(height: AppSpacing.md),
                    Row(children: [
                      AppMetricCard(
                        icon: Icons.people_outline,
                        value: userCount ?? 0,
                        label: 'Usuários',
                      ),
                      const SizedBox(width: AppSpacing.md),
                      AppMetricCard(
                        icon: Icons.home_outlined,
                        value: propertyCount ?? 0,
                        label: 'Imóveis',
                      ),
                    ]),
                    const SizedBox(height: AppSpacing.md),
                    const Row(children: [
                      // Contracts & pending lack backend endpoints — show 0
                      // rather than fake numbers. Card stays visually
                      // consistent.
                      AppMetricCard(
                          icon: Icons.article_outlined,
                          value: 0,
                          label: 'Contratos'),
                      SizedBox(width: AppSpacing.md),
                      AppMetricCard(
                          icon: Icons.pending_outlined,
                          value: 0,
                          label: 'Pendentes'),
                    ]),
                    const SizedBox(height: AppSpacing.xxl),
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
