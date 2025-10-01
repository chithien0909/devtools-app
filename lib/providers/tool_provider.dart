import 'package:devtools_plus/core/constants/tools_list.dart';
import 'package:devtools_plus/models/tool_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppSection { dashboard, settings, about }

class ToolFilterState {
  const ToolFilterState({this.category, this.query = ''});

  final ToolCategory? category;
  final String query;

  ToolFilterState copyWith({ToolCategory? category, String? query}) {
    return ToolFilterState(
      category: category ?? this.category,
      query: query ?? this.query,
    );
  }

  bool get isDefault => category == null && query.isEmpty;
}

class ToolFiltersNotifier extends StateNotifier<ToolFilterState> {
  ToolFiltersNotifier() : super(const ToolFilterState());

  void setCategory(ToolCategory? category) {
    state = state.copyWith(category: category);
  }

  void setQuery(String query) {
    state = state.copyWith(query: query);
  }

  void clear() {
    state = const ToolFilterState();
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system);

  void toggle() {
    state = switch (state) {
      ThemeMode.system => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
    };
  }

  void setMode(ThemeMode mode) {
    state = mode;
  }
}

final appSectionProvider = StateProvider<AppSection>(
  (ref) => AppSection.dashboard,
);
final toolFiltersProvider =
    StateNotifierProvider<ToolFiltersNotifier, ToolFilterState>((ref) {
      return ToolFiltersNotifier();
    });



final activeToolProvider = StateProvider<ToolModel?>((ref) => null);

final toolsProvider = Provider<List<ToolModel>>((ref) => tools);

final filteredToolsProvider = Provider<List<ToolModel>>((ref) {
  final filters = ref.watch(toolFiltersProvider);
  final all = ref.watch(toolsProvider);
  return all.where((tool) {
    final matchesCategory = filters.category == null
        ? true
        : tool.category == filters.category;
    final query = filters.query.trim().toLowerCase();
    if (query.isEmpty) {
      return matchesCategory;
    }
    final haystack = '${tool.name} ${tool.description}'.toLowerCase();
    return matchesCategory && haystack.contains(query);
  }).toList();
});
