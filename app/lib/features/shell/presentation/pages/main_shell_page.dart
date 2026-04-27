import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../design_system/design_system.dart';
import '../../../search/presentation/providers/search_notifier.dart';

/// Main shell with fixed bottom navigation bar.
class MainShellPage extends ConsumerWidget {
  const MainShellPage({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const _icons = [
    Icons.home_rounded,
    Icons.search_rounded,
    Icons.favorite_rounded,
    Icons.chat_bubble_rounded,
    Icons.person_rounded,
  ];

  static const _labels = ['Home', 'Busca', 'Salvos', 'Chat', 'Perfil'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              children: List.generate(_icons.length, (i) {
                final isActive = i == navigationShell.currentIndex;
                return Expanded(
                  child: _NavItem(
                    icon: _icons[i],
                    label: _labels[i],
                    isActive: isActive,
                    isDark: isDark,
                    onTap: () {
                      // If tapping the search icon (index 1) while already active, trigger scroll to top
                      if (isActive && i == 1) {
                        ref.read(searchScrollTriggerProvider.notifier).trigger();
                      }
                      
                      navigationShell.goBranch(
                        i,
                        initialLocation: i == navigationShell.currentIndex,
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
    final activeColor =
        isDark ? BrutalistPalette.warmPeach : BrutalistPalette.deepOrange;
    final inactiveColor =
        isDark ? AppColors.whiteFaint : AppColors.lightTextDisabled;
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
