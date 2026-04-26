import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/design_system.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/filter_chip_bar.dart';
import '../widgets/property_list_tile.dart';
import '../providers/search_notifier.dart';

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

    return BrutalistPageScaffold(
      builder: (context, _, entrance, pulse) {
        final fade = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: entrance, curve: const Interval(0.1, 0.5, curve: Curves.easeOut)),
        );

        final titleColor = BrutalistPalette.title(isDark);
        final searchState = ref.watch(searchNotifierProvider);

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
                            onTap: () => context.go('/search/map'),
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
                data: (properties) {
                  if (properties.isEmpty) {
                    return const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text('Nenhum imóvel encontrado.'),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                    sliver: SliverList(
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
                  );
                },
                loading: () => const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
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
                            'Erro ao carregar imóveis.',
                            style: AppTypography.titleMedium,
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
