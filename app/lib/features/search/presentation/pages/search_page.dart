import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/design_system.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/filter_chip_bar.dart';


import '../widgets/property_carousel_card.dart';
import '../providers/map_providers.dart';

/// Search tab — cozy search with rounded inputs and warm filter chips.
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {

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
        final properties = ref.watch(mockPropertiesProvider);


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
                  const SearchBarWidget(),

                  const SizedBox(height: AppSpacing.xl),
                ]),
              )),

              // Filter chips
              const SliverToBoxAdapter(
                child: FilterChipBar(),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.xxxl),
              ),

              // Property list
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final property = properties[index];
                      return PropertyCarouselCard(
                        property: property,
                        onTap: () => context.push('/property/${property.id}'),
                      );
                    },
                    childCount: properties.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        );
      },
    );
  }
}
