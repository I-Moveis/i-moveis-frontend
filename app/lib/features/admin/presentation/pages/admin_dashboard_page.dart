import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/design_system.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

/// Admin dashboard — cozy metrics and quick access.
class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BrutalistPageScaffold(
      builder: (context, isDark, entrance, pulse) {
        final fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: entrance, curve: const Interval(0.1, 0.5, curve: Curves.easeOut)));
        final titleColor = BrutalistPalette.title(isDark);

        return Opacity(opacity: fade.value, child: CustomScrollView(physics: const BouncingScrollPhysics(), slivers: [
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: AppSpacing.xl),
            Row(children: [
              Expanded(child: Text('Painel admin', style: AppTypography.headlineLarge.copyWith(color: titleColor))),
              GestureDetector(
                onTap: () {
                  context.read<AuthBloc>().add(const AuthEvent.logoutRequested());
                  context.go('/login');
                },
                child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                decoration: BoxDecoration(borderRadius: AppRadius.borderFull, border: Border.all(color: AppColors.error.withValues(alpha: 0.2))),
                child: Text('Sair', style: AppTypography.titleSmall.copyWith(color: AppColors.error)),
              )),
            ]),
            const SizedBox(height: AppSpacing.xxl),

            // Metrics
            const AppSectionHeader(title: 'Métricas'),
            const SizedBox(height: AppSpacing.md),
            const Row(children: [
              AppMetricCard(icon: Icons.people_outline, value: 1234, label: 'Usuários'),
              SizedBox(width: AppSpacing.md),
              AppMetricCard(icon: Icons.home_outlined, value: 567, label: 'Imóveis'),
            ]),
            const SizedBox(height: AppSpacing.md),
            const Row(children: [
              AppMetricCard(icon: Icons.article_outlined, value: 89, label: 'Contratos'),
              SizedBox(width: AppSpacing.md),
              AppMetricCard(icon: Icons.pending_outlined, value: 12, label: 'Pendentes'),
            ]),

            const SizedBox(height: AppSpacing.xxl),

            // Quick access
            const AppSectionHeader(title: 'Acesso rápido'),
            const SizedBox(height: AppSpacing.md),
            AppMenuGroup(items: [
              AppMenuGroupItem(icon: Icons.people_outline, label: 'Gerenciar usuários', onTap: () => context.push('/admin/users')),
              AppMenuGroupItem(icon: Icons.home_outlined, label: 'Moderar anúncios', onTap: () => context.push('/admin/listings')),
              AppMenuGroupItem(icon: Icons.article_outlined, label: 'Gerenciar contratos', onTap: () => context.push('/admin/contracts')),
            ]),
            const SizedBox(height: AppSpacing.massive),
          ]))),
        ]));
      },
    );
  }

}
