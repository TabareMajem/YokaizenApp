import 'dart:io';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:yokai_quiz_app/global.dart';
import 'package:yokai_quiz_app/api/database_api.dart';
import 'package:http/http.dart' as http;

import '../api/local_storage.dart';
import '../main.dart';
import '../screens/Authentication/controller/auth_screen_controller.dart';
import '../util/constants.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  
  // Channel ID for Android notifications
  static const String _channelId = 'yokaizen_notifications';
  static const String _channelName = 'YokaiZen Notifications';
  static const String _channelDescription = 'Notifications from YokaiZen app';

  // Initialize notification settings
  Future<void> initialize() async {
    // Request permission for iOS
    if (Platform.isIOS) {
      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    // Configure local notifications
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationTap(response.payload);
      },
    );

    // Create Android notification channel
    if (Platform.isAndroid) {
      await _createAndroidNotificationChannel();
    }

    // Get FCM token
    String? token = await _firebaseMessaging.getToken();
    customPrint('FCM Token: $token');
    
    // Save token to your backend
    if (token != null) {
      // await _saveTokenToBackend(token);
    }

    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      customPrint('FCM Token refreshed: $newToken');
      // _saveTokenToBackend(newToken);
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle when user taps on notification that opened the app
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      customPrint('Notification opened app: ${message.data}');
      _handleNotificationTap(message.data.toString());
    });

    // Check if app was opened from a notification
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      customPrint('App opened from notification: ${initialMessage.data}');
      _handleNotificationTap(initialMessage.data.toString());
    }
  }

  // Create notification channel for Android
  Future<void> _createAndroidNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    customPrint('Foreground message received: ${message.notification?.title}');
    
    // Show local notification
    if (message.notification != null) {
      await _showLocalNotification(
        id: message.hashCode,
        title: message.notification!.title ?? 'YokaiZen',
        body: message.notification!.body ?? '',
        payload: message.data.toString(),
      );
    }
  }

  // Show local notification
  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    AndroidNotificationDetails androidDetails = const AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    DarwinNotificationDetails iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Handle notification tap
  void _handleNotificationTap(String? payload) {
    if (payload != null) {
      customPrint('Notification tapped with payload: $payload');
      
      // Parse payload and navigate to appropriate screen
      // This is where you would add your navigation logic based on the notification type
      // Example:
      // if (payload.contains('quiz')) {
      //   Get.toNamed('/quiz-details', arguments: {'id': extractQuizId(payload)});
      // }
    }
  }

  /// this is portion is commented once the api for this is updated then need to uncomment this
  // Save FCM token to backend
  // Future<void> _saveTokenToBackend(String token) async {
  //   try {
  //     // Get user ID from AuthScreenController if available
  //     int? userId;
  //     try {
  //       userId = AuthScreenController.getProfileModel.value.user?.userId;
  //     } catch (e) {
  //       customPrint('Error getting user ID: $e');
  //     }
  //
  //     if (userId != null) {
  //       // Construct API endpoint
  //       final url = Uri.parse('${DatabaseApi.baseUrl}/users/update-device-token');
  //
  //       // Prepare headers
  //       final headers = {
  //         "Content-Type": "application/json",
  //         "UserToken": prefs.getString(LocalStorage.token).toString(),
  //         "Accept-Language": constants.deviceLanguage,
  //       };
  //
  //       // Prepare body
  //       final body = json.encode({
  //         'user_id': userId,
  //         'device_token': token,
  //         'device_type': Platform.isAndroid ? 'android' : 'ios',
  //       });
  //
  //       // Make API call
  //       final response = await http.post(
  //         url,
  //         headers: headers,
  //         body: body,
  //       );
  //
  //       if (response.statusCode == 200 || response.statusCode == 201) {
  //         customPrint('Device token saved successfully');
  //       } else {
  //         customPrint('Failed to save device token: ${response.statusCode} - ${response.body}');
  //       }
  //     } else {
  //       customPrint('User ID not available, token not saved to backend');
  //     }
  //   } catch (e) {
  //     customPrint('Error saving token to backend: $e');
  //   }
  // }

  /// till here ------------------------------

  // Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    customPrint('Subscribed to topic: $topic');
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    customPrint('Unsubscribed from topic: $topic');
  }
} 