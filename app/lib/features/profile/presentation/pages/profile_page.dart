import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/design_system.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../auth/presentation/providers/auth_state.dart';

/// Profile tab ÔÇö cozy profile with grouped menu sections.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BrutalistPageScaffold(
      builder: (context, isDark, entrance, pulse) {
        final fade = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: entrance, curve: const Interval(0.1, 0.5, curve: Curves.easeOut)),
        );

        final titleColor = BrutalistPalette.title(isDark);
        final mutedColor = BrutalistPalette.muted(isDark);
        final accentColor = isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;

        final authUser = ref.watch(authNotifierProvider).maybeWhen(
              authenticated: (user) => (
                name: user.name.isNotEmpty ? user.name : 'Usuário',
                email: user.email,
                avatarUrl: user.avatarUrl,
                isOwner: user.isOwner,
                isAdmin: user.isAdmin,
              ),
              orElse: () => null,
            );
        final displayName = authUser?.name ?? 'Usuário';
        final displayEmail = authUser?.email ?? '';
        final avatarUrl = authUser?.avatarUrl;
        final isOwner = authUser?.isOwner ?? false;

        return Opacity(opacity: fade.value, child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
            child: Column(children: [
              const SizedBox(height: AppSpacing.xl),

              // Avatar + info
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withValues(alpha: 0.1),
                  image: avatarUrl != null && avatarUrl.isNotEmpty
                      ? DecorationImage(image: NetworkImage(avatarUrl), fit: BoxFit.cover)
                      : null,
                ),
                child: avatarUrl == null || avatarUrl.isEmpty
                    ? Icon(Icons.person_rounded, size: 32, color: accentColor.withValues(alpha: 0.6))
                    : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(displayName, style: AppTypography.headlineLarge.copyWith(color: titleColor)),
              if (displayEmail.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xxs),
                Text(displayEmail, style: AppTypography.bodyMedium.copyWith(color: mutedColor)),
              ],
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

              // --- SEÇÃO DE ATIVIDADE (DINÂMICA) ---
              if (isOwner) ...[
                const AppSectionHeader(title: 'Gestão de Atividade'),
                const SizedBox(height: AppSpacing.md),
                AppMenuGroup(items: [
                  AppMenuGroupItem(
                    icon: Icons.description_outlined,
                    label: 'Propostas Recebidas',
                    onTap: () {},
                  ),
                  AppMenuGroupItem(
                    icon: Icons.calendar_today_outlined,
                    label: 'Visitas Agendadas',
                    onTap: () => context.push('/landlord-visits'),
                  ),
                  AppMenuGroupItem(
                    icon: Icons.assignment_turned_in_outlined,
                    label: 'Contratos Ativos',
                    onTap: () {},
                  ),
                ]),
                const SizedBox(height: AppSpacing.xxl),
                const AppSectionHeader(title: 'Meus Imóveis'),
                const SizedBox(height: AppSpacing.md),
                AppMenuGroup(items: [
                  AppMenuGroupItem(
                    icon: Icons.business_outlined,
                    label: 'Gerenciar Imóveis',
                    onTap: () => context.go('/my-properties'),
                  ),
                  AppMenuGroupItem(
                    icon: Icons.add_business_outlined,
                    label: 'Anunciar Novo Imóvel',
                    onTap: () => context.push('/my-properties/create'),
                  ),
                  AppMenuGroupItem(
                    icon: Icons.folder_open_outlined,
                    label: 'Documentação e IPTU',
                    onTap: () {},
                  ),
                ]),
                const SizedBox(height: AppSpacing.xxl),
                const AppSectionHeader(title: 'Financeiro'),
                const SizedBox(height: AppSpacing.md),
                AppMenuGroup(items: [
                  AppMenuGroupItem(
                    icon: Icons.payments_outlined,
                    label: 'Extrato de Repasses',
                    onTap: () {},
                  ),
                ]),
              ] else ...[
                const AppSectionHeader(title: 'Atividade'),
                const SizedBox(height: AppSpacing.md),
                AppMenuGroup(items: [
                  AppMenuGroupItem(
                    icon: Icons.description_outlined,
                    label: 'Minhas propostas',
                    onTap: () {},
                  ),
                  AppMenuGroupItem(
                    icon: Icons.calendar_today_outlined,
                    label: 'Minhas visitas',
                    onTap: () => context.go('/profile/my-visits'),
                  ),
                  AppMenuGroupItem(
                    icon: Icons.article_outlined,
                    label: 'Meus contratos',
                    onTap: () {},
                  ),
                ]),
              ],

              const SizedBox(height: AppSpacing.xxl),

              // Sistema
              const AppSectionHeader(title: 'Sistema'),
              const SizedBox(height: AppSpacing.md),
              AppMenuGroup(items: [
                AppMenuGroupItem(icon: Icons.settings_outlined, label: 'Configurações', onTap: () => context.go('/profile/settings')),
                AppMenuGroupItem(icon: Icons.support_agent_outlined, label: 'Suporte', onTap: () => context.push('/support')),
              ]),

              const SizedBox(height: AppSpacing.xxl),

              // Logout
              GestureDetector(
                onTap: () {
                  ref.read(authNotifierProvider.notifier).logout();
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
