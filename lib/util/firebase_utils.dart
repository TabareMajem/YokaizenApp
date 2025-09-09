import 'package:flutter/foundation.dart';
import '../config/firebase_config.dart';

/// Utility class for Firebase-related operations
class FirebaseUtils {
  /// Private constructor to prevent instantiation
  FirebaseUtils._();
  
  /// Get the FCM token for the current device
  /// Returns null if Firebase initialization fails or if the token can't be retrieved
  static Future<String?> getFCMToken() async {
    try {
      final token = await FirebaseConfig.instance.getFCMToken();
      return token;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting FCM token: $e');
      }
      return null;
    }
  }
  
  /// Send the FCM token to your backend API
  /// Replace this with your actual API call implementation
  static Future<bool> sendTokenToBackend(String? token, {String? userId}) async {
    if (token == null) {
      if (kDebugMode) {
        print('Cannot send null FCM token to backend');
      }
      return false;
    }
    
    try {
      // TODO: Implement your API call to send the token to your backend
      // Example:
      // final response = await http.post(
      //   Uri.parse('https://your-api.com/register-device'),
      //   body: {
      //     'token': token,
      //     'user_id': userId,
      //     'platform': Platform.isIOS ? 'ios' : 'android',
      //   },
      // );
      // return response.statusCode == 200;
      
      if (kDebugMode) {
        print('FCM Token ready to be sent to backend: $token');
        print('User ID: $userId');
      }
      
      // Return true for now - replace with actual implementation
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error sending FCM token to backend: $e');
      }
      return false;
    }
  }
} 