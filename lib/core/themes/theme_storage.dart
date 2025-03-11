import 'package:chatlify/core/app_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});


final themeStorageProvider = Provider<ThemeStorage>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeStorageImpl(prefs);
});


abstract class ThemeStorage {
  Future<bool> getThemeMode();

  Future<bool> setThemeMode(bool currentThemeMode);

  static Future<ThemeStorage> getInstance() async {
    final prefs = await SharedPreferences.getInstance();
    return ThemeStorageImpl(prefs);
  }
}

class ThemeStorageImpl implements ThemeStorage {
  ThemeStorageImpl(this._preferences);
  final SharedPreferences _preferences;

  @override
  Future<bool> getThemeMode() async {
    return _preferences.getBool(AppConstants.themeModeKey) ?? false;
  }

  @override
  Future<bool> setThemeMode(bool currentThemeMode) async {
    return await _preferences.setBool(
        AppConstants.themeModeKey, currentThemeMode);
  }
}