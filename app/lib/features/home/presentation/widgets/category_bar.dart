import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../design_system/design_system.dart';
import '../providers/category_provider.dart';

class CategoryBar extends ConsumerWidget {
  const CategoryBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedCategoryProvider);

    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
        ),
        itemCount: kHomeCategories.length,
        itemBuilder: (context, i) {
          final cat = kHomeCategories[i];
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: AppChip(
              label: cat.label,
              icon: cat.icon,
              isSelected: i == selectedIndex,
              onTap: () =>
                  ref.read(selectedCategoryProvider.notifier).set(i),
            ),
          );
        },
      ),
    );
  }
}
