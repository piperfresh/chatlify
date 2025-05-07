import 'dart:convert';
import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/auth/data/repository/firebase_auth_repository.dart';
import 'features/chat/data/repositories/firebase_chat_repository.dart';
import 'features/chat/presentation/screens/chat_screen.dart';

// Top-level function for handling background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized
  await Firebase.initializeApp();
  log('Background message received: ${message.messageId}');
  log('Background message data: ${message.data}');
}

// Provider to track current chat ID
final currentChatIdProvider = StateProvider<String?>((ref) => null);

// Provider for notification service
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref);
});

class NotificationService {
  final Ref _ref;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  String? _initialNotificationPayload;
  bool _isInitialized = false;

  NotificationService(this._ref);

  // Getter to check if service is initialized
  bool get isInitialized => _isInitialized;

  // Initialize the notification service
  Future<void> initialize(BuildContext context) async {
    if (_isInitialized) return;

    await _setupLocalNotifications();
    await _setupFirebaseMessaging();

    // Process initial notification if any
    if (_initialNotificationPayload != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleNotificationTap(_initialNotificationPayload, context);
      });
    }

    _isInitialized = true;
  }

  Future<void> _setupLocalNotifications() async {
    log('Setting up local notifications');

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Channel',
      description: 'This channel is used for important notifications',
      importance: Importance.high,
    );


    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);


    // iOS settings
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    // Initialize the plugin
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize with callback for handling notification taps
    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {

      },
    );

    // Check if app was opened from a notification
    final NotificationAppLaunchDetails? launchDetails =
        await _localNotifications.getNotificationAppLaunchDetails();


    if (launchDetails?.didNotificationLaunchApp == true) {
      _initialNotificationPayload =
          launchDetails?.notificationResponse?.payload;
      log('App launched from notification with payload: $_initialNotificationPayload');
    }
  }

  // Set up Firebase Cloud Messaging
  Future<void> _setupFirebaseMessaging() async {
    log('Setting up Firebase messaging');

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permissions
    await _requestNotificationPermissions();

    // Get and store FCM token
    await _updateFcmToken();


    // Handle token refreshes
    FirebaseMessaging.instance.onTokenRefresh.listen(_onTokenRefresh);

    // Handle initial message (app opened from terminated state)
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      log('App opened from terminated state with message: ${initialMessage.messageId}');

    }

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Listen for when the app is opened from background state
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
  }

  // Request notification permissions
  Future<void> _requestNotificationPermissions() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    log('User notification permission status: ${settings.authorizationStatus}');

    // For iOS, register for remote notifications
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // Handle token updates
  Future<void> _updateFcmToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      log('FCM Token: $token');
      // Save token to user profile if authenticated
      if (_ref.read(authStateStreamProvider).value != null) {
        await _ref.read(firebaseAuthRepositoryProvider).updateFcmToken(token);
      }
    }
  }

  // Handle token refresh
  void _onTokenRefresh(String newToken) {
    log('FCM Token refreshed: $newToken');
    if (_ref.read(authStateStreamProvider).value != null) {
      _ref.read(firebaseAuthRepositoryProvider).updateFcmToken(newToken);
    }
  }

  // Handle foreground messages
  void _onForegroundMessage(RemoteMessage message) {
    log('Foreground message received: ${message.messageId}');
    log('Message data: ${message.data}');

    if (message.notification != null) {
      log('Message contains notification: ${message.notification?.body}');
      _showForegroundNotification(message);
    }
  }

  // Handle when app is opened from background via notification
  void _onMessageOpenedApp(RemoteMessage message) {
    log('App opened from background state with message: ${message.messageId}');

  }

  /// Show a notification while the app is in foreground
  void _showForegroundNotification(RemoteMessage message) {
    log('Showing foreground notification');
    log('Notification data: ${message.data}');
    // Don't show notification if user is already in the relevant chat
    if (message.data.containsKey('chatId')) {
      print('Chat ID found in message data');
      String chatId = message.data['chatId'];

      // Check if user is currently in this chat
      if (_ref.read(currentChatIdProvider) == chatId) {
        log('User is already in the chat screen, skipping notification');
        return;
      }
    }

    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Channel',
            channelDescription:
                'This channel is used for important notifications',
            importance: Importance.high,
            priority: Priority.high,
            icon: android?.smallIcon,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  // Handle notification tap with context
  void handleNotificationTap(String? payload, BuildContext context) {
    _handleNotificationTap(payload, context);
  }

  // Process notification payload and navigate
  void _handleNotificationTap(String? payload, BuildContext context) {
    if (payload != null) {
      try {
        final Map<String, dynamic> data = jsonDecode(payload);
        log('Processing notification payload: $data');

        // Navigate to chat if it's a chat notification
        if (data['type'] == 'chat' && data['chatId'] != null) {
          _navigateToChatScreen(data['chatId'], context);
        }
      } catch (e) {
        log('Error parsing notification payload: $e');
      }
    }
  }

  // Navigate to the appropriate chat screen
  Future<void> _navigateToChatScreen(
      String chatId, BuildContext context) async {
    try {
      final currentUser =
          await _ref.read(firebaseAuthRepositoryProvider).getCurrentUser();

      if (currentUser == null) return;

      // Get the chat details
      final chatDetails = await _ref
          .read(firebaseChatRepositoryProvider)
          .getChatDetails(chatId);

      if (chatDetails != null) {
        // Find the other participant ID
        String otherUserId =
            chatDetails.participantIds.firstWhere((id) => id != currentUser.id);

        // Get the user details
        final otherUser = await _ref
            .read(firebaseChatRepositoryProvider)
            .getUserById(otherUserId);

        if (otherUser != null && context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                chatId: chatId,
                otherUser: otherUser,
              ),
            ),
            (route) => route.isFirst,
          );
        }
      }
    } catch (e) {
      log('Error navigating to chat: $e');
    }
  }

  // Process any messages that caused the app to open from terminated state
  Future<void> processInitialMessage(BuildContext context) async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      log('Processing initial message: ${initialMessage.messageId}');

      if (initialMessage.data.containsKey('type') &&
          initialMessage.data['type'] == 'chat' &&
          initialMessage.data.containsKey('chatId')) {
        _navigateToChatScreen(initialMessage.data['chatId'], context);
      }
    }
  }
}

