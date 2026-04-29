import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/design_system.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

/// Profile tab — cozy profile with grouped menu sections.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BrutalistPageScaffold(
      builder: (context, isDark, entrance, pulse) {
        final fade = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: entrance, curve: const Interval(0.1, 0.5, curve: Curves.easeOut)),
        );

        final titleColor = BrutalistPalette.title(isDark);
        final mutedColor = BrutalistPalette.muted(isDark);
        final accentColor = isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;

        return Opacity(opacity: fade.value, child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
            child: Column(children: [
              const SizedBox(height: AppSpacing.xl),

              // Avatar + info
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(shape: BoxShape.circle, color: accentColor.withValues(alpha: 0.1)),
                child: Icon(Icons.person_rounded, size: 32, color: accentColor.withValues(alpha: 0.6)),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Usuário', style: AppTypography.headlineLarge.copyWith(color: titleColor)),
              const SizedBox(height: AppSpacing.xxs),
              Text('usuario@email.com', style: AppTypography.bodyMedium.copyWith(color: mutedColor)),
              const SizedBox(height: AppSpacing.xl),
              GestureDetector(
                onTap: () => context.go('/profile/edit'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.borderFull,
                    border: Border.all(color: BrutalistPalette.surfaceBorder(isDark)),
                  ),
                  child: Text('Editar perfil', style: AppTypography.titleSmall.copyWith(color: mutedColor)),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),

              // Atividade
              const AppSectionHeader(title: 'Atividade'),
              const SizedBox(height: AppSpacing.md),
              AppMenuGroup(items: [
                AppMenuGroupItem(icon: Icons.description_outlined, label: 'Minhas propostas', onTap: () {}),
                AppMenuGroupItem(icon: Icons.calendar_today_outlined, label: 'Minhas visitas', onTap: () => context.go('/profile/my-visits')),
                AppMenuGroupItem(icon: Icons.article_outlined, label: 'Meus contratos', onTap: () {}),
              ]),

              const SizedBox(height: AppSpacing.xxl),

              // Imóveis
              const AppSectionHeader(title: 'Imóveis'),
              const SizedBox(height: AppSpacing.md),
              AppMenuGroup(items: [
                AppMenuGroupItem(icon: Icons.home_outlined, label: 'Meus imóveis', onTap: () => context.go('/profile/my-properties')),
                AppMenuGroupItem(icon: Icons.add_circle_outline, label: 'Anunciar imóvel', onTap: () => context.go('/profile/my-properties/create')),
                AppMenuGroupItem(icon: Icons.event_note_outlined, label: 'Visitas nos meus imóveis', onTap: () => context.go('/profile/landlord-visits')),
              ]),

              const SizedBox(height: AppSpacing.xxl),

              // Sistema
              const AppSectionHeader(title: 'Sistema'),
              const SizedBox(height: AppSpacing.md),
              AppMenuGroup(items: [
                AppMenuGroupItem(icon: Icons.settings_outlined, label: 'Configurações', onTap: () => context.go('/profile/settings')),
                AppMenuGroupItem(icon: Icons.support_agent_outlined, label: 'Suporte', onTap: () {}),
              ]),

              const SizedBox(height: AppSpacing.xxl),

              // Logout
              GestureDetector(
                onTap: () {
                  context.read<AuthBloc>().add(const AuthEvent.logoutRequested());
                  context.go('/login');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.06),
                    borderRadius: AppRadius.borderLg,
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.15)),
                  ),
                  child: Center(child: Text('Sair', style: AppTypography.titleSmallBold.copyWith(color: AppColors.error))),
                ),
              ),
              const SizedBox(height: AppSpacing.massive),
            ]),
          ))],
        ));
      },
    );
  }

}
