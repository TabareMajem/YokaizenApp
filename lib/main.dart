/// main.dart -->

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:yokai_quiz_app/global.dart';

import 'config/firebase_config.dart';
import 'config/line_sdk_config.dart';
import 'config/revenue_cat_config.dart';
import 'services/app_state_manager.dart';
import 'services/unified_notification_service.dart';
import 'services/unity_game_service.dart';
import 'api/cache_service.dart';
import 'api/ultra_fast_api_service.dart';
import 'myapp.dart';
import 'package:get/get.dart';

// SharedPreferences? prefs;
// const String appName = "B.AI";

// Avoid initializing Firebase in the background handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message received: ${message.notification?.title}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with the improved singleton approach
  await FirebaseConfig.init();
  
  // Get FCM token - example of how to access it
  String? fcmToken = await FirebaseConfig.instance.getFCMToken();
  customPrint('Main: FCM Token for API: $fcmToken');
  
  // You can now send this token to your backend API
  // await yourApiService.sendFCMToken(fcmToken);
  
  prefs = await SharedPreferences.getInstance();
  await LineSDKConfig.init();
  await RevenueCatConfig.init();
  await dotenv.load(fileName: '.env');
  
  // Initialize cache service
  await CacheService().initialize();
  
  // Register AppStateManager early for dependency injection
  Get.put(AppStateManager(), permanent: true);
  
  // Initialize Unity Game Service
  Get.put(UnityGameService(), permanent: true);
  
  // Initialize unified notification service
  await UnifiedNotificationService().initialize();
  
  customPrint('🚀 App initialization completed - starting MyApp');
  runApp(const MyApp());
}

late SharedPreferences prefs;

