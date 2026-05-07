import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoryItem {
  const CategoryItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

const kHomeCategories = <CategoryItem>[
  CategoryItem(icon: Icons.apartment_rounded, label: 'Apê'),
  CategoryItem(icon: Icons.house_rounded, label: 'Casa'),
  CategoryItem(icon: Icons.single_bed_rounded, label: 'Kitnet'),
  CategoryItem(icon: Icons.business_rounded, label: 'Studio'),
  CategoryItem(icon: Icons.pets_rounded, label: 'Pet friendly'),
  CategoryItem(icon: Icons.weekend_rounded, label: 'Mobiliado'),
];

class SelectedCategoryNotifier extends Notifier<int> {
  @override
  int build() => 0;

  // Imperative method to match the convention used by other notifiers in the
  // codebase (see search_view_provider.dart / map_providers.dart).
  // ignore: use_setters_to_change_properties
  void set(int index) => state = index;
}

final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, int>(
  SelectedCategoryNotifier.new,
);
