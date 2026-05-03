import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/design_system.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

/// Profile tab — switches between Tenant and Landlord profile menus.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        final (displayName, displayEmail, avatarUrl, isOwner) = state.maybeWhen(
          authenticated: (user) => (
            user.name.isNotEmpty ? user.name : 'Usuário',
            user.email,
            user.avatarUrl,
            user.isOwner,
          ),
          orElse: () => ('Usuário', '', null, false),
        );

        return BrutalistPageScaffold(
          builder: (context, _, entrance, pulse) {
            final fade = Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(parent: entrance, curve: const Interval(0.1, 0.5, curve: Curves.easeOut)),
            );

            final titleColor = BrutalistPalette.title(isDark);
            final mutedColor = BrutalistPalette.muted(isDark);
            final accentColor = isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;

            return Opacity(
              opacity: fade.value,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                      child: Column(
                        children: [
                          const SizedBox(height: AppSpacing.xl),

                          // Avatar + info
                          Container(
                            width: 72,
                            height: 72,
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
                              child: Text(
                                isOwner ? 'Editar Painel' : 'Editar perfil',
                                style: AppTypography.titleSmall.copyWith(color: mutedColor),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxxl),

                          if (isOwner)
                            _buildLandlordMenu(context, isDark)
                          else
                            _buildTenantMenu(context, isDark),

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
                              child: Center(
                                child: Text(
                                  'Sair da Conta',
                                  style: AppTypography.titleSmallBold.copyWith(color: AppColors.error),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.massive),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTenantMenu(BuildContext context, bool isDark) {
    return Column(
      children: [
        const AppSectionHeader(title: 'Atividade'),
        const SizedBox(height: AppSpacing.md),
        AppMenuGroup(items: [
          AppMenuGroupItem(icon: Icons.description_outlined, label: 'Minhas propostas', onTap: () {}),
          AppMenuGroupItem(icon: Icons.calendar_today_outlined, label: 'Minhas visitas', onTap: () => context.go('/profile/my-visits')),
          AppMenuGroupItem(icon: Icons.article_outlined, label: 'Meus contratos', onTap: () {}),
        ]),
        const SizedBox(height: AppSpacing.xxl),
        const AppSectionHeader(title: 'Imóveis'),
        const SizedBox(height: AppSpacing.md),
        AppMenuGroup(items: [
          AppMenuGroupItem(icon: Icons.home_outlined, label: 'Meus imóveis', onTap: () => context.go('/profile/my-properties')),
          AppMenuGroupItem(icon: Icons.add_circle_outline, label: 'Anunciar imóvel', onTap: () => context.go('/profile/my-properties/create')),
          AppMenuGroupItem(icon: Icons.event_note_outlined, label: 'Visitas nos meus imóveis', onTap: () => context.go('/profile/landlord-visits')),
        ]),
        const SizedBox(height: AppSpacing.xxl),
        const AppSectionHeader(title: 'Sistema'),
        const SizedBox(height: AppSpacing.md),
        AppMenuGroup(items: [
          AppMenuGroupItem(icon: Icons.settings_outlined, label: 'Configurações', onTap: () => context.go('/profile/settings')),
          AppMenuGroupItem(icon: Icons.support_agent_outlined, label: 'Suporte', onTap: () {}),
        ]),
      ],
    );
  }

  Widget _buildLandlordMenu(BuildContext context, bool isDark) {
    return Column(
      children: [
        const AppSectionHeader(title: 'Gestão de Atividade'),
        const SizedBox(height: AppSpacing.md),
        AppMenuGroup(items: [
          AppMenuGroupItem(icon: Icons.analytics_outlined, label: 'Propostas Recebidas', onTap: () => context.go('/profile/my-properties/analytics')),
          AppMenuGroupItem(icon: Icons.event_note_rounded, label: 'Visitas Agendadas', onTap: () => context.go('/profile/landlord-visits')),
          // Contratos Ativos leads to the same properties tab but filtered (conceptually)
          AppMenuGroupItem(icon: Icons.assignment_turned_in_outlined, label: 'Contratos Ativos', onTap: () => context.go('/favorites')),
        ]),
        const SizedBox(height: AppSpacing.xxl),
        const AppSectionHeader(title: 'Meus Imóveis'),
        const SizedBox(height: AppSpacing.md),
        AppMenuGroup(items: [
          // Redirect to the bottom nav tab "Imóveis" (which is the favorites branch for landlords)
          AppMenuGroupItem(icon: Icons.business_rounded, label: 'Gerenciar Imóveis', onTap: () => context.go('/favorites')),
          AppMenuGroupItem(icon: Icons.add_business_rounded, label: 'Anunciar Novo Imóvel', onTap: () => context.go('/profile/my-properties/create')),
          AppMenuGroupItem(icon: Icons.folder_open_rounded, label: 'Documentação e IPTU', onTap: () {}),
        ]),
        const SizedBox(height: AppSpacing.xxl),
        const AppSectionHeader(title: 'Financeiro'),
        const SizedBox(height: AppSpacing.md),
        AppMenuGroup(items: [
          AppMenuGroupItem(icon: Icons.account_balance_wallet_outlined, label: 'Extrato de Repasses', onTap: () {}),
          AppMenuGroupItem(icon: Icons.trending_up_rounded, label: 'Relatórios de Rendimentos', onTap: () {}),
          AppMenuGroupItem(icon: Icons.qr_code_2_rounded, label: 'Configurar Chaves PIX', onTap: () {}),
        ]),
        const SizedBox(height: AppSpacing.xxl),
        const AppSectionHeader(title: 'Sistema'),
        const SizedBox(height: AppSpacing.md),
        AppMenuGroup(items: [
          AppMenuGroupItem(icon: Icons.manage_accounts_outlined, label: 'Configurações da Conta', onTap: () => context.go('/profile/settings')),
          AppMenuGroupItem(icon: Icons.help_outline_rounded, label: 'Central de Ajuda', onTap: () {}),
          AppMenuGroupItem(icon: Icons.support_agent_outlined, label: 'Suporte Prioritário', onTap: () {}),
        ]),
      ],
    );
  }
}
