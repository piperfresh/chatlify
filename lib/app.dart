import 'package:chatlify/app_life_cycle.dart';
import 'package:chatlify/core/themes/app_themes.dart';
import 'package:chatlify/core/themes/theme_notifier.dart';
import 'package:chatlify/features/auth/data/repository/firebase_auth_repository.dart';
import 'package:chatlify/features/auth/presentation/screen/splash_screen.dart';
import 'package:chatlify/features/call/call_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'notification_service.dart';


class ChatApp extends ConsumerStatefulWidget {
  const ChatApp({super.key});

  @override
  ConsumerState createState() => _ChatAppState();
}

class _ChatAppState extends ConsumerState<ChatApp> with WidgetsBindingObserver {
  late AppLifecycleObserver _appLifecycleObserver;

  @override
  void initState() {
    super.initState();

    // Initialize app lifecycle observer
    _appLifecycleObserver = AppLifecycleObserver(
      (isActive) {
        if (ref.read(authStateStreamProvider).value != null) {
          ref.read(firebaseAuthRepositoryProvider).updateOnlineStatus(isActive);
        }
      },
    );

    // Add this to intercept notification interactions
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize notification service after dependencies are available
    _initializeNotificationService();
  }

  Future<void> _initializeNotificationService() async {
    // Initialize the notification service with context
    await ref.read(notificationServiceProvider).initialize(context);

    // Process any initial message that might have launched the app
    await ref.read(notificationServiceProvider).processInitialMessage(context);
  }

  @override
  void dispose() {
    _appLifecycleObserver.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    return ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        builder: (context, child) {
          return MaterialApp(
            themeMode: themeMode,
            debugShowCheckedModeBanner: false,
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            home: const CallListener(child: SplashScreen()),
            navigatorKey: GlobalNavigator
                .key, // Add a global navigator key for notifications
          );
        }
    );
  }
}

// Create a global navigator key for accessing context from anywhere
class GlobalNavigator {
  static final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();
}
