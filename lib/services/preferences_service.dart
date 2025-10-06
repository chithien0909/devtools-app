import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _themeModeKey = 'theme_mode';
  static const String _favoritesKey = 'favorites';
  static const String _recentToolsKey = 'recent_tools';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  ThemeMode getThemeMode() {
    final value = _prefs?.getString(_themeModeKey);
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    String value;
    switch (mode) {
      case ThemeMode.light:
        value = 'light';
        break;
      case ThemeMode.dark:
        value = 'dark';
        break;
      case ThemeMode.system:
        value = 'system';
        break;
    }
    await _prefs?.setString(_themeModeKey, value);
  }

  List<String> getFavorites() {
    return _prefs?.getStringList(_favoritesKey) ?? [];
  }

  Future<void> addFavorite(String toolId) async {
    final favorites = getFavorites();
    if (!favorites.contains(toolId)) {
      favorites.add(toolId);
      await _prefs?.setStringList(_favoritesKey, favorites);
    }
  }

  Future<void> removeFavorite(String toolId) async {
    final favorites = getFavorites();
    favorites.remove(toolId);
    await _prefs?.setStringList(_favoritesKey, favorites);
  }

  bool isFavorite(String toolId) {
    return getFavorites().contains(toolId);
  }

  List<String> getRecentTools() {
    return _prefs?.getStringList(_recentToolsKey) ?? [];
  }

  Future<void> addRecentTool(String toolId) async {
    final recent = getRecentTools();
    recent.remove(toolId);
    recent.insert(0, toolId);
    
    if (recent.length > 10) {
      recent.removeRange(10, recent.length);
    }
    
    await _prefs?.setStringList(_recentToolsKey, recent);
  }

  Future<void> clearRecentTools() async {
    await _prefs?.remove(_recentToolsKey);
  }
}
