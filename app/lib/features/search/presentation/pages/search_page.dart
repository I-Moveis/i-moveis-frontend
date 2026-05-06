import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design_system/design_system.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../../../profile/presentation/pages/tenants_page.dart';
import '../../presentation/providers/search_filters_provider.dart';
import '../../presentation/providers/search_notifier.dart';
import '../../presentation/widgets/filter_chip_bar.dart';
import '../../presentation/widgets/property_list_tile.dart';
import '../../presentation/widgets/search_bar_widget.dart';

/// Search tab — cozy search with rounded inputs and warm filter chips.
/// Switches to TenantsPage if the user is an owner.
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key, this.initialFilters});

  /// Filtros pré-aplicados (ex: vindos de um deep link do bot WhatsApp).
  /// Quando não nulo, substitui os filtros persistidos e re-dispara a busca.
  final SearchFilters? initialFilters;

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

    final incoming = widget.initialFilters;
    if (incoming != null) {
      // Aplica depois do primeiro frame para garantir que os providers já
      // foram construídos — `build()` do Notifier roda antes do `initState`
      // do widget que o consome, mas mutar state aqui mesmo ainda dispararia
      // rebuild durante o próprio initState.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(searchFiltersProvider.notifier).applyAll(incoming);
      });
    }
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
    final isOwner = ref.watch(authNotifierProvider).maybeWhen(
      authenticated: (user) => user.isOwner,
      orElse: () => false,
    );

    if (isOwner) {
      return const TenantsPage();
    }

    return _buildTenantSearch(context);
  }

  Widget _buildTenantSearch(BuildContext context) {
    final searchStateAsync = ref.watch(searchNotifierProvider);

    return BrutalistPageScaffold(
      builder: (context, isDark, entrance, pulse) {
        final fade = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: entrance, curve: const Interval(0.1, 0.5, curve: Curves.easeOut)),
        );

        final titleColor = BrutalistPalette.title(isDark);

        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: _showScrollToTop
              ? FloatingActionButton(
                  onPressed: _scrollToTop,
                  backgroundColor: BrutalistPalette.accentOrange(isDark),
                  child: const Icon(Icons.arrow_upward_rounded, color: Colors.white),
                )
              : null,
          body: Opacity(
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Buscar', style: AppTypography.headlineLarge.copyWith(color: titleColor)),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        const SearchBarWidget(),
                        const SizedBox(height: AppSpacing.xxl),
                        const FilterChipBar(),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ),
                searchStateAsync.when(
                  data: (state) {
                    if (state.properties.isEmpty) {
                      return const SliverFillRemaining(
                        child: Center(child: Text('Nenhum imóvel encontrado.')),
                      );
                    }
                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final property = state.properties[index];
                            return PropertyListTile(property: property);
                          },
                          childCount: state.properties.length,
                        ),
                      ),
                    );
                  },
                  loading: () => const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, stack) => SliverFillRemaining(
                    child: Center(child: Text('Erro ao carregar imóveis: $err')),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.massive)),
              ],
            ),
          ),
        );
      },
    );
  }
}
