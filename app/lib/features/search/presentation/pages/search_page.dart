import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failures.dart';
import '../../../../design_system/design_system.dart';
import '../providers/search_filters_provider.dart';
import '../providers/search_notifier.dart';
import '../widgets/brutalist_shimmer.dart';
import '../widgets/filter_chip_bar.dart';
import '../widgets/property_list_tile.dart';
import '../widgets/search_bar_widget.dart';

/// Search tab — cozy search with rounded inputs and warm filter chips.
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final show = _scrollController.offset > 400;
    if (show != _showScrollToTop) {
      setState(() {
        _showScrollToTop = show;
      });
    }

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(searchNotifierProvider.notifier).loadNextPage();
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutQuart,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Listen for scroll to top triggers from bottom nav bar
    ref.listen<int>(searchScrollTriggerProvider, (previous, next) {
      if (next > 0) {
        _scrollToTop();
      }
    });

    final titleColor = BrutalistPalette.title(isDark);
    final searchState = ref.watch(searchNotifierProvider);

    return BrutalistPageScaffold(
      builder: (context, _, entrance, pulse) {
        final fade = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: entrance, curve: const Interval(0.1, 0.5, curve: Curves.easeOut)),
        );

        return Opacity(
          opacity: fade.value,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.xl),
                      // Header
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Buscar',
                              style: AppTypography.headlineLarge.copyWith(color: titleColor),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.push('/search/map'),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: BrutalistPalette.subtleBg(isDark),
                                borderRadius: AppRadius.borderMd,
                              ),
                              child: Icon(
                                Icons.map_outlined,
                                size: 20,
                                color: BrutalistPalette.muted(isDark),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Search bar
                      const SearchBarWidget(),

                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),

              // Filter chips
              const SliverToBoxAdapter(
                child: FilterChipBar(),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.xxxl),
              ),

              // Property list or Error/Loading
              searchState.when(
                data: (state) {
                  final properties = state.properties;
                  if (properties.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Nenhum resultado encontrado',
                              style: AppTypography.titleMedium.copyWith(color: titleColor),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AppButton(
                              label: 'Limpar Filtros',
                              onPressed: () => ref.read(searchFiltersProvider.notifier).clearFilters(),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                    sliver: SliverMainAxisGroup(
                      slivers: [
                        if (state.isOffline)
                          SliverToBoxAdapter(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: AppSpacing.md),
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs, horizontal: AppSpacing.md),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.error.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.05),
                                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                                borderRadius: AppRadius.borderSm,
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.cloud_off_rounded, size: 14, color: AppColors.error),
                                  const SizedBox(width: AppSpacing.sm),
                                  Text(
                                    'Modo Offline — Resultados podem estar desatualizados',
                                    style: AppTypography.labelSmall.copyWith(color: AppColors.error),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index < properties.length) {
                            final property = properties[index];
                            return PropertyListTile(
                              property: property,
                              onTap: () => context.push('/property/${property.id}'),
                            );
                          } else {
                            // Pagination loading indicator
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange,
                                ),
                              ),
                            );
                          }
                        },
                        childCount: properties.length + (searchState.isLoading ? 1 : 0),
                      ),
                    ),
                  ],
                ),
              );
                },
                loading: () => const SliverToBoxAdapter(
                  child: BrutalistShimmer(),
                ),
                error: (error, stack) => SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            error is Failure ? error.message : 'Erro ao carregar imóveis.',
                            style: AppTypography.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppButton(
                            label: 'Tentar novamente',
                            onPressed: () => ref.read(searchNotifierProvider.notifier).search(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            ],
          ),
        );
      },
      floatingActionButton: _showScrollToTop
          ? FloatingActionButton(
              onPressed: _scrollToTop,
              backgroundColor: BrutalistPalette.warmBrown.withValues(alpha: 0.9),
              elevation: 4,
              shape: const CircleBorder(),
              child: Icon(
                Icons.keyboard_arrow_up_rounded,
                color: BrutalistPalette.accentAmber(isDark),
                size: 32,
              ),
            )
          : null,
    );
  }
}
