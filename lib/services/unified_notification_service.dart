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

class UnifiedNotificationService {
  static final UnifiedNotificationService _instance = UnifiedNotificationService._internal();
  factory UnifiedNotificationService() => _instance;
  UnifiedNotificationService._internal();

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

    // Get FCM token - only on Android or when APNS token is available on iOS
    try {
      if (Platform.isAndroid) {
        String? token = await _firebaseMessaging.getToken();
        customPrint('FCM Token: $token');
        
        // Save token to your backend
        if (token != null) {
          // await _saveTokenToBackend(token);
        }
      } else if (Platform.isIOS) {
        // On iOS, wait for APNS token to be available
        _firebaseMessaging.onTokenRefresh.listen((newToken) {
          customPrint('FCM Token refreshed: $newToken');
          // _saveTokenToBackend(newToken);
        });
      }
    } catch (e) {
      customPrint('Error getting FCM token: $e');
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
    
    // Send to ring if connected
    // await _sendToRing(message); // Removed ring functionality
  }

  // Send notification to ring
  // Future<void> _sendToRing(RemoteMessage message) async { // Removed ring functionality
  //   try {
  //     if (!_ringService.isConnected) {
  //       customPrint('Ring not connected, skipping ring notification');
  //       return;
  //     }

  //     final notificationType = _determineNotificationType(message);
  //     final ringMessage = message.notification?.body ?? message.data['message'] ?? 'New notification';
      
  //     await _ringService.sendNotification(
  //       type: notificationType,
  //       message: ringMessage,
  //       title: message.notification?.title ?? 'YokaiZen',
  //       duration: 5000,
  //     );
      
  //     customPrint('Notification sent to ring successfully');
  //   } catch (e) {
  //     customPrint('Error sending notification to ring: $e');
  //   }
  // }

  // Determine notification type from message data
  // String _determineNotificationType(RemoteMessage message) { // Removed ring functionality
  //   final data = message.data;
    
  //   if (data.containsKey('type')) {
  //     switch (data['type']) {
  //       case 'health_reminder':
  //         return 'healthReminder';
  //       case 'workout_reminder':
  //         return 'workoutReminder';
  //       case 'medication_reminder':
  //         return 'medicationReminder';
  //       default:
  //         return 'custom';
  //     }
  //   }
    
  //   // Fallback based on message content
  //   final body = message.notification?.body?.toLowerCase() ?? '';
  //   if (body.contains('workout') || body.contains('exercise')) {
  //     return 'workoutReminder';
  //   } else if (body.contains('medication') || body.contains('pill')) {
  //     return 'medicationReminder';
  //   } else if (body.contains('health') || body.contains('wellness')) {
  //     return 'healthReminder';
  //   }
    
  //   return 'custom';
  // }

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

  // Send custom notification to ring
  // Future<bool> sendCustomNotification({ // Removed ring functionality
  //   required String title,
  //   required String message,
  //   required String type,
  //   int? duration,
  //   bool sendToRing = false,
  // }) async {
  //   try {
  //     customPrint('Sending custom notification: $message');
      
  //     // Show local notification
  //     await _flutterLocalNotificationsPlugin.show(
  //       DateTime.now().millisecondsSinceEpoch.remainder(100000),
  //       title,
  //       message,
  //       const NotificationDetails(
  //         android: AndroidNotificationDetails(
  //           _channelId,
  //           _channelName,
  //           channelDescription: _channelDescription,
  //           importance: Importance.high,
  //           priority: Priority.high,
  //         ),
  //       ),
  //     );

  //     // Send to ring if requested
  //     if (sendToRing) {
  //       await _ringService.sendNotification(
  //         type: type,
  //         message: message,
  //         title: title,
  //         duration: duration ?? 5000,
  //       );
  //     }

  //     return true;
  //   } catch (e) {
  //     customPrint('Error sending custom notification: $e');
  //     return false;
  //   }
  // }

  // Send health reminder to ring
  // Future<bool> sendHealthReminder({ // Removed ring functionality
  //   required String message,
  //   String title = 'Health Reminder',
  //   int duration = 5000,
  // }) async {
  //   return await sendCustomNotification(
  //     title: title,
  //     message: message,
  //     type: 'healthReminder',
  //     duration: duration,
  //     sendToRing: true,
  //   );
  // }

  // Send workout reminder to ring
  // Future<bool> sendWorkoutReminder({ // Removed ring functionality
  //   required String message,
  //   String title = 'Workout Reminder',
  //   int duration = 5000,
  // }) async {
  //   return await sendCustomNotification(
  //     title: title,
  //     message: message,
  //     type: 'workoutReminder',
  //     duration: duration,
  //     sendToRing: true,
  //   );
  // }

  // Send medication reminder to ring
  // Future<bool> sendMedicationReminder({ // Removed ring functionality
  //   required String message,
  //   String title = 'Medication Reminder',
  //   int duration = 5000,
  // }) async {
  //   return await sendCustomNotification(
  //     title: title,
  //     message: message,
  //     type: 'medicationReminder',
  //     duration: duration,
  //     sendToRing: true,
  //   );
  // }

  // Get ring connection state
  // dynamic get ringConnectionState => _ringService.connectionState; // Removed ring functionality
  // bool get isRingConnected => _ringService.isConnected; // Removed ring functionality
  // String? get connectedRingDevice => _ringService.connectedDeviceName; // Removed ring functionality

  // Ring connection state stream
  // Stream get ringConnectionStateStream => _ringService.connectionStateStream; // Removed ring functionality

  // Health data stream from ring
  // Stream<Map<String, dynamic>> get healthDataStream => _ringService.healthDataStream.cast<Map<String, dynamic>>(); // Removed ring functionality

  // Ring notification stream
  // Stream<String> get ringNotificationStream => _ringService.notificationStream.cast<String>(); // Removed ring functionality

  // Ring service methods
  // Future<List<Map<String, dynamic>>> startRingScan() => _ringService.startScan(); // Removed ring functionality
  // Future<void> stopRingScan() => _ringService.stopScan(); // Removed ring functionality
  // Future<bool> connectToRing(String deviceId, {String? deviceName}) => 
  //     _ringService.connectToDevice(deviceId, deviceName: deviceName); // Removed ring functionality
  // Future<bool> disconnectFromRing() => _ringService.disconnect(); // Removed ring functionality
  // Future<int?> getRingBatteryLevel() => _ringService.getBatteryLevel(); // Removed ring functionality
  // Future<String?> getRingFirmwareVersion() => _ringService.getFirmwareVersion(); // Removed ring functionality
  // Future<Map<String, dynamic>?> getRingHealthData() => _ringService.getHealthData(); // Removed ring functionality
  // Future<bool> setRingTime() => _ringService.setDeviceTime(); // Removed ring functionality
  // Future<bool> findPhoneWithRing() => _ringService.findPhone(); // Removed ring functionality

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

  // Dispose resources
  void dispose() {
    // _ringService.dispose(); // Removed ring functionality
  }
} 