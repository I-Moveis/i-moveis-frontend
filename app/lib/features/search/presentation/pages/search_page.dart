import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../design_system/design_system.dart';

/// Search tab — cozy search with rounded inputs and warm filter chips.
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  int _selectedFilter = -1;
  static const _filters = ['Tipo', 'Quartos', 'Preço', 'Filtros'];

  @override
  Widget build(BuildContext context) {
    return BrutalistPageScaffold(
      builder: (context, isDark, entrance, pulse) {
        final fade = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: entrance, curve: const Interval(0.1, 0.5, curve: Curves.easeOut)),
        );

        final accentColor = isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;
        final mutedColor = BrutalistPalette.muted(isDark);
        final titleColor = BrutalistPalette.title(isDark);
        final faintColor = BrutalistPalette.faint(isDark);

        return Opacity(
          opacity: fade.value,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SizedBox(height: AppSpacing.xl),
                  // Header
                  Row(children: [
                    Expanded(child: Text('Buscar', style: AppTypography.headlineLarge.copyWith(color: titleColor))),
                    GestureDetector(
                      onTap: () => context.go('/search/map'),
                      child: Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: BrutalistPalette.subtleBg(isDark),
                          borderRadius: AppRadius.borderMd,
                        ),
                        child: Icon(Icons.map_outlined, size: 20, color: mutedColor),
                      ),
                    ),
                  ]),
                  const SizedBox(height: AppSpacing.xl),

                  // Search bar
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.mdLg),
                      decoration: BoxDecoration(
                        color: BrutalistPalette.surfaceBg(isDark),
                        borderRadius: AppRadius.borderXl,
                        border: Border.all(color: BrutalistPalette.surfaceBorder(isDark)),
                      ),
                      child: Row(children: [
                        Icon(Icons.search_rounded, size: 20, color: mutedColor),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(child: Text('Cidade, bairro ou endereço...', style: AppTypography.bodyLarge.copyWith(color: faintColor))),
                        Container(width: 1, height: 20, color: BrutalistPalette.dividerColor(isDark)),
                        const SizedBox(width: AppSpacing.md),
                        Icon(Icons.tune_rounded, size: 18, color: mutedColor),
                      ]),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Filter chips
                  Wrap(spacing: AppSpacing.sm, children: List.generate(_filters.length, (i) {
                    final isSelected = i == _selectedFilter;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedFilter = isSelected ? -1 : i),
                      child: AnimatedContainer(
                        duration: AppDurations.normal,
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: isSelected ? accentColor.withValues(alpha: 0.12) : BrutalistPalette.surfaceBg(isDark),
                          borderRadius: AppRadius.borderFull,
                          border: Border.all(color: isSelected ? accentColor.withValues(alpha: 0.4) : BrutalistPalette.surfaceBorder(isDark)),
                        ),
                        child: Text(_filters[i], style: AppTypography.titleSmall.copyWith(color: isSelected ? accentColor : mutedColor)),
                      ),
                    );
                  })),
                ]),
              )),

              // Empty state
              SliverFillRemaining(hasScrollBody: false, child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.search_rounded, size: 48, color: accentColor.withValues(alpha: 0.2)),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Explore imóveis', style: AppTypography.headlineMedium.copyWith(color: titleColor)),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Use os filtros para encontrar seu lar', style: AppTypography.bodyMedium.copyWith(color: mutedColor)),
                ]),
              )),
            ],
          ),
        );
      },
    );
  }
}
