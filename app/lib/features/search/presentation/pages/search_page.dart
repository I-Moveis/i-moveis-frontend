import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/design_system.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../presentation/widgets/search_bar_widget.dart';
import '../../presentation/widgets/filter_chip_bar.dart';
import '../../presentation/widgets/property_list_tile.dart';
import '../../../profile/presentation/pages/tenants_page.dart';
import '../../presentation/providers/search_notifier.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isOwner = state.maybeWhen(
          authenticated: (user) => user.isOwner,
          orElse: () => false,
        );

        if (isOwner) {
          return const TenantsPage();
        }

        return const _TenantSearchContent();
      },
    );
  }
}

class _TenantSearchContent extends ConsumerWidget {
  const _TenantSearchContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchStateAsync = ref.watch(searchNotifierProvider);

    return BrutalistPageScaffold(
      builder: (context, isDark, entrance, pulse) {
        final fade = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: entrance, curve: const Interval(0.1, 0.5, curve: Curves.easeOut)),
        );

        final titleColor = BrutalistPalette.title(isDark);

        return Opacity(
          opacity: fade.value,
          child: CustomScrollView(
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
        );
      },
    );
  }
}
