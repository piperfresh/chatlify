import 'package:chatlify/app_life_cycle.dart';
import 'package:chatlify/core/themes/app_themes.dart';
import 'package:chatlify/core/themes/theme_notifier.dart';
import 'package:chatlify/features/auth/data/repository/firebase_auth_repository.dart';
import 'package:chatlify/features/auth/presentation/screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatApp extends ConsumerStatefulWidget {
  const ChatApp({super.key});

  @override
  ConsumerState createState() => _ChatAppState();
}

class _ChatAppState extends ConsumerState<ChatApp> {
  late AppLifecycleObserver _appLifecycleObserver;

  @override
  void initState() {
    super.initState();
    _appLifecycleObserver = AppLifecycleObserver(
      (isActive) {
        if (ref.read(authStateStreamProvider).value != null) {
          ref.read(firebaseAuthRepositoryProvider).updateOnlineStatus(isActive);
        }
      },
    );
  }

  @override
  void dispose() {
    _appLifecycleObserver.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode  = ref.watch(themeProvider);
    return ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        builder: (context, child) {
          return MaterialApp(
            themeMode: themeMode,
            debugShowCheckedModeBanner: false,
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            home: const SplashScreen(),
          );
        }
    );
  }
}
