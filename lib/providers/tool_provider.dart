import 'package:devtools_plus/core/registry/tool_registry.dart';
import 'package:devtools_plus/models/tool_model.dart';
import 'package:devtools_plus/services/preferences_service.dart';
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

final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  throw UnimplementedError('PreferencesService must be overridden');
});

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(ref.watch(preferencesServiceProvider)),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final PreferencesService _prefs;

  ThemeModeNotifier(this._prefs) : super(ThemeMode.system) {
    _loadTheme();
  }

  void _loadTheme() {
    state = _prefs.getThemeMode();
  }

  Future<void> toggle() async {
    final newMode = switch (state) {
      ThemeMode.system => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
    };
    await setMode(newMode);
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    await _prefs.setThemeMode(mode);
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

final toolsProvider = Provider<List<ToolModel>>((ref) => ToolRegistry.allAsModels());

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<String>>(
  (ref) => FavoritesNotifier(ref.watch(preferencesServiceProvider)),
);

class FavoritesNotifier extends StateNotifier<List<String>> {
  final PreferencesService _prefs;

  FavoritesNotifier(this._prefs) : super([]) {
    _loadFavorites();
  }

  void _loadFavorites() {
    state = _prefs.getFavorites();
  }

  Future<void> toggle(String toolId) async {
    if (state.contains(toolId)) {
      await _prefs.removeFavorite(toolId);
    } else {
      await _prefs.addFavorite(toolId);
    }
    _loadFavorites();
  }

  bool isFavorite(String toolId) => state.contains(toolId);
}

final recentToolsProvider = StateNotifierProvider<RecentToolsNotifier, List<String>>(
  (ref) => RecentToolsNotifier(ref.watch(preferencesServiceProvider)),
);

class RecentToolsNotifier extends StateNotifier<List<String>> {
  final PreferencesService _prefs;

  RecentToolsNotifier(this._prefs) : super([]) {
    _loadRecent();
  }

  void _loadRecent() {
    state = _prefs.getRecentTools();
  }

  Future<void> addTool(String toolId) async {
    await _prefs.addRecentTool(toolId);
    _loadRecent();
  }

  Future<void> clear() async {
    await _prefs.clearRecentTools();
    _loadRecent();
  }
}

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
