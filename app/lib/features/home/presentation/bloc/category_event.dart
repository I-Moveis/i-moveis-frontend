part of 'category_bloc.dart';

@immutable
sealed class CategoryEvent {
  const CategoryEvent();
}

final class SelectCategory extends CategoryEvent {
  const SelectCategory(this.index);
  final int index;
}

final class LoadCategories extends CategoryEvent {
  const LoadCategories();
}
