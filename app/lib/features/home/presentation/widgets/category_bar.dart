import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../design_system/design_system.dart';
import '../bloc/category_bloc.dart';

class CategoryBar extends StatelessWidget {
  const CategoryBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is CategoryLoading) {
          return const SizedBox(
            height: 44,
            child: Center(child: LinearProgressIndicator()),
          );
        }
        if (state is CategoryError) {
          return const SizedBox(height: 44);
        }
        if (state is CategoryLoaded) {
          return SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
              ),
              itemCount: state.categories.length,
              itemBuilder: (context, i) {
                final cat = state.categories[i];
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: AppChip(
                    label: cat.label,
                    icon: cat.icon,
                    isSelected: i == state.selectedIndex,
                    onTap: () => context
                        .read<CategoryBloc>()
                        .add(SelectCategory(i)),
                  ),
                );
              },
            ),
          );
        }
        return const SizedBox(height: 44);
      },
    );
  }
}
