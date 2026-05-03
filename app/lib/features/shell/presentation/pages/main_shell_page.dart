import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../design_system/design_system.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../search/presentation/providers/search_notifier.dart';

/// Main shell with fixed bottom navigation bar.
class MainShellPage extends ConsumerWidget {
  const MainShellPage({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isOwner = state.maybeWhen(
          authenticated: (user) => user.isOwner,
          orElse: () => false,
        );

        // Define the tab configuration based on role.
        // We map tab index (i) to branch index (b).
        final List<({IconData icon, String label, int branchIndex})> tabs;

        if (isOwner) {
          tabs = [
            (icon: Icons.home_rounded, label: 'Dashboard', branchIndex: 0),
            (icon: Icons.group_rounded, label: 'Inquilinos', branchIndex: 1), 
            (icon: Icons.business_rounded, label: 'Imóveis', branchIndex: 2), 
            (icon: Icons.chat_bubble_rounded, label: 'Chat', branchIndex: 3),
            (icon: Icons.person_rounded, label: 'Perfil', branchIndex: 4),
          ];
        } else {
          tabs = [
            (icon: Icons.home_rounded, label: 'Home', branchIndex: 0),
            (icon: Icons.search_rounded, label: 'Busca', branchIndex: 1),
            (icon: Icons.favorite_rounded, label: 'Salvos', branchIndex: 2),
            (icon: Icons.chat_bubble_rounded, label: 'Chat', branchIndex: 3),
            (icon: Icons.person_rounded, label: 'Perfil', branchIndex: 4),
          ];
        }

        // Find which tab is active based on the current branch index.
        final activeTabIndex = tabs.indexWhere((t) => t.branchIndex == navigationShell.currentIndex);

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: navigationShell,
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.blackLight : AppColors.white,
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? BrutalistPalette.warmBrown.withValues(alpha: 0.15)
                      : BrutalistPalette.deepOrange.withValues(alpha: 0.08),
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.xs),
                child: Row(
                  children: List.generate(tabs.length, (i) {
                    final tab = tabs[i];
                    final isActive = i == activeTabIndex;
                    
                    return Expanded(
                      child: _NavItem(
                        icon: tab.icon,
                        label: tab.label,
                        isActive: isActive,
                        isDark: isDark,
                        onTap: () {
                          // If tapping the search branch while already active, trigger scroll to top
                          if (isActive && tab.branchIndex == 1) {
                            ref.read(searchScrollTriggerProvider.notifier).trigger();
                          }

                          navigationShell.goBranch(
                            tab.branchIndex,
                            initialLocation: tab.branchIndex == navigationShell.currentIndex,
                          );
                        },
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeColor = isDark ? BrutalistPalette.warmPeach : BrutalistPalette.deepOrange;
    final inactiveColor = isDark ? AppColors.whiteFaint : AppColors.lightTextDisabled;
    final pillColor = isDark
        ? BrutalistPalette.warmOrange.withValues(alpha: 0.15)
        : BrutalistPalette.deepOrange.withValues(alpha: 0.10);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pill indicator behind icon
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: isActive ? AppSpacing.lg : AppSpacing.md,
              vertical: isActive ? AppSpacing.xsSm : AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: isActive ? pillColor : Colors.transparent,
              borderRadius: AppRadius.borderPill,
            ),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              child: Icon(
                icon,
                color: isActive ? activeColor : inactiveColor,
                size: isActive ? 24 : 22,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          // Label
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            style: (isActive ? AppTypography.navLabelActive : AppTypography.navLabelInactive).copyWith(
              color: isActive ? activeColor : inactiveColor,
            ),
            child: Text(label),
          ),
        ],
      ),
    );
  }
}
