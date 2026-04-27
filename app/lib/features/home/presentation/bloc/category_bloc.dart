import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryItem {
  const CategoryItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

const _kDefaultCategories = [
  CategoryItem(icon: Icons.apartment_rounded, label: 'Apê'),
  CategoryItem(icon: Icons.house_rounded, label: 'Casa'),
  CategoryItem(icon: Icons.single_bed_rounded, label: 'Kitnet'),
  CategoryItem(icon: Icons.business_rounded, label: 'Studio'),
  CategoryItem(icon: Icons.pets_rounded, label: 'Pet friendly'),
  CategoryItem(icon: Icons.weekend_rounded, label: 'Mobiliado'),
];

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  CategoryBloc() : super(const CategoryInitial()) {
    on<LoadCategories>(_onLoad);
    on<SelectCategory>(_onSelect);
  }

  Future<void> _onLoad(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategoryLoading());
    await Future<void>.delayed(const Duration(milliseconds: 300));
    emit(const CategoryLoaded(
      categories: _kDefaultCategories,
      selectedIndex: 0,
    ));
  }

  void _onSelect(
    SelectCategory event,
    Emitter<CategoryState> emit,
  ) {
    final current = state;
    if (current is CategoryLoaded) {
      emit(current.copyWith(selectedIndex: event.index));
    }
  }
}
