import 'package:chatlify/core/themes/theme_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  final themeRepository = ref.watch(themeRepositoryProvider);
  return ThemeNotifier(themeRepository);
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final ThemeRepository themeRepository;

  ThemeNotifier(this.themeRepository) : super(ThemeMode.light);

  void initTheme(bool isDarkMode) {
    state = isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  void toggleTheme() async {
    final isDarkMode = state == ThemeMode.light;

    /// Save the theme locally
    await themeRepository.setThemeMode(isDarkMode);
    state = isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }
}
