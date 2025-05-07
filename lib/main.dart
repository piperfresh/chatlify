import 'dart:developer';

import 'package:chatlify/app.dart';
import 'package:chatlify/core/themes/theme_repository.dart';
import 'package:chatlify/core/themes/theme_storage.dart';
import 'package:chatlify/features/call/call_listener.dart';
import 'package:chatlify/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/themes/theme_notifier.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log('Handling a background message ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeStorage = await ThemeStorage.getInstance();

  final savedTheme = await themeStorage.getThemeMode();

  ///Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // await NotificationService().initialize();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // ///Set up Firebase Messaging
  // FirebaseMessaging messaging = FirebaseMessaging.instance;

  // ///Request for permission to receive notifications
  // NotificationSettings settings = await messaging.requestPermission(
  //   alert: true,
  //   badge: true,
  //   sound: true,
  // );
  //
  // /// Get Fcm Token for the device
  // String? token = await messaging.getToken();
  // log('FCM Token: $token');
  //
  // ///Handle background messages
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(ProviderScope(overrides: [
    themeProvider.overrideWith(
      (ref) =>
          ThemeNotifier(ThemeRepository(themeStorage))..initTheme(savedTheme),
    )
  ], child: ChatApp()));
}
