import 'package:chatlify/core/themes/app_themes.dart';
import 'package:chatlify/core/themes/theme_notifier.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatApp extends ConsumerWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode  = ref.watch(themeProvider);
    return MaterialApp(
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
