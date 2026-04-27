import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SearchViewMode {
  list,
  map,
}

/// Provider to manage the current search view mode.
class SearchViewNotifier extends Notifier<SearchViewMode> {
  @override
  SearchViewMode build() => SearchViewMode.list;
  
  void set(SearchViewMode mode) => state = mode;
  void toggle() => state = state == SearchViewMode.list ? SearchViewMode.map : SearchViewMode.list;
}

final searchViewProvider = NotifierProvider<SearchViewNotifier, SearchViewMode>(SearchViewNotifier.new);
