import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:yokai_quiz_app/firebase_options.dart';
import 'package:yokai_quiz_app/services/notification_service.dart';

/// A singleton class to handle Firebase configuration and initialization
class FirebaseConfig {
  /// Private constructor
  FirebaseConfig._();

  /// Singleton instance
  static final FirebaseConfig _instance = FirebaseConfig._();

  /// Get the singleton instance
  static FirebaseConfig get instance => _instance;

  /// Flag to track initialization
  bool _initialized = false;

  /// Variable to store FCM token
  String? _fcmToken;

  /// Get the FCM token - returns null if Firebase is not initialized
  String? get fcmToken => _fcmToken;

  /// Initialize Firebase and related services
  static Future<void> init() async {
    await instance._initFirebase();
  }

  /// Private initialization method
  Future<void> _initFirebase() async {
    // Only initialize once
    if (_initialized) {
      if (kDebugMode) {
        print('Firebase already initialized by this instance, skipping');
      }
      return;
    }

    try {
      // Try to get existing app first
      FirebaseApp? app;
      
      try {
        // See if default app already exists (initialized elsewhere)
        app = Firebase.app();
        if (kDebugMode) {
          print('Found existing Firebase app, using it');
        }
      } catch (e) {
        // No app exists, initialize it
        try {
          if (kDebugMode) {
            print('No existing Firebase app found, initializing new one');
          }
          app = await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );
          if (kDebugMode) {
            print('Firebase successfully initialized');
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error initializing Firebase: $e');
          }
          
          // As a last resort, try to get the default app again
          // This handles race conditions where another part of the app initialized Firebase
          // between our check and our attempt to initialize
          try {
            app = Firebase.app();
            if (kDebugMode) {
              print('Firebase was initialized by another process, using existing app');
            }
          } catch (e) {
            // If this fails too, we really can't recover
            if (kDebugMode) {
              print('Fatal error: Could not get Firebase app: $e');
            }
            rethrow;
          }
        }
      }
      
      // Mark as initialized
      _initialized = true;
      
      // Set up background message handler for Firebase Cloud Messaging
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      
      // Initialize notification service
      await NotificationService().initialize();

      // Get FCM token
      await _fetchFCMToken();
      
    } catch (e) {
      if (kDebugMode) {
        print('Critical Firebase initialization error: $e');
      }
    }
  }
  
  /// Fetch the FCM token
  Future<String?> _fetchFCMToken() async {
    try {
      _fcmToken = await FirebaseMessaging.instance.getToken();
      if (kDebugMode) {
        print('FCM Token: $_fcmToken');
      }
      
      // Set up token refresh listener
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        if (kDebugMode) {
          print('FCM Token refreshed: $newToken');
        }
        // You can add your logic to send the new token to your backend here
      });
      
      return _fcmToken;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching FCM token: $e');
      }
      return null;
    }
  }
  
  /// Get the FCM token, initializing Firebase if needed
  Future<String?> getFCMToken() async {
    if (!_initialized) {
      await _initFirebase();
    }
    
    if (_fcmToken == null) {
      return await _fetchFCMToken();
    }
    
    return _fcmToken;
  }
}

/// Background message handler for Firebase Cloud Messaging
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background handler should not initialize Firebase
  if (kDebugMode) {
    print('Background message received: ${message.notification?.title}');
  }
}