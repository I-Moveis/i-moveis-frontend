import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SearchViewMode {
  list,
  map,
}

/// Provider to manage the current search view mode.
class SearchViewNotifier extends Notifier<SearchViewMode> {
  // Intentionally a method (not a setter) to match the imperative style used
  // by the other map/search notifiers in this feature.
  // ignore: use_setters_to_change_properties
  void set(SearchViewMode mode) => state = mode;

  @override
  SearchViewMode build() => SearchViewMode.list;

  void toggle() => state =
      state == SearchViewMode.list ? SearchViewMode.map : SearchViewMode.list;
}

final searchViewProvider = NotifierProvider<SearchViewNotifier, SearchViewMode>(SearchViewNotifier.new);
