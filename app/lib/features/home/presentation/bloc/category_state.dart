part of 'category_bloc.dart';

@immutable
sealed class CategoryState {
  const CategoryState();
}

final class CategoryInitial extends CategoryState {
  const CategoryInitial();
}

final class CategoryLoading extends CategoryState {
  const CategoryLoading();
}

final class CategoryLoaded extends CategoryState {
  const CategoryLoaded({
    required this.categories,
    required this.selectedIndex,
  });

  final List<CategoryItem> categories;
  final int selectedIndex;

  CategoryLoaded copyWith({int? selectedIndex}) => CategoryLoaded(
        categories: categories,
        selectedIndex: selectedIndex ?? this.selectedIndex,
      );
}

final class CategoryError extends CategoryState {
  const CategoryError(this.message);
  final String message;
}
