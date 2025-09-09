// lib/screens/services/line_auth_service.dart

import 'package:flutter_line_sdk/flutter_line_sdk.dart';

class LineAuthService {
  static final LineAuthService _instance = LineAuthService._internal();
  factory LineAuthService() => _instance;
  LineAuthService._internal();


  // Future<UserProfile?> loginOrSignUp() async {
  //   try {
  //     print("loginOrSignUp got invoked");
  //     final accessToken = await LineSDK.instance.currentAccessToken;
  //     print("loginOrSignUp accessToken : ${accessToken}");
  //
  //     if (accessToken != null) {
  //       print('Already logged in. Token: ${accessToken.value}');
  //       final profile = await LineSDK.instance.getProfile();
  //       return profile;
  //     }
  //
  //     print('User not logged in. Attempting login...');
  //     final result = await LineSDK.instance.login(
  //       scopes: ['profile', 'openid', 'email'],
  //     );
  //
  //     if (result.userProfile != null) {
  //       print('LINE Login successful: ${result.userProfile?.displayName}');
  //       return result.userProfile;
  //     } else {
  //       print('Login failed: No user profile returned.');
  //       return null;
  //     }
  //   } catch (e) {
  //     print('LINE Login error: $e');
  //     return null;
  //   }
  // }

  Future<UserProfile?> loginOrSignUp() async {
    try {
      print("loginOrSignUp got invoked");

      final accessToken = await LineSDK.instance.currentAccessToken;
      print("loginOrSignUp accessToken : ${accessToken?.value}");

      if (accessToken != null) {
        print('Already logged in. Token: ${accessToken.value}');
        final profile = await LineSDK.instance.getProfile();
        return profile;
      }

      print('User not logged in. Attempting login...');
      final result = await LineSDK.instance.login(scopes: ['profile', 'openid', 'email']);

      print("Login Result: $result");

      if (result.accessToken != null) {
        print('LINE Login successful! Token: ${result.accessToken?.value}');
        return result.userProfile;
      } else {
        print('Login failed: No access token returned.');
        return null;
      }
    } catch (e) {
      print('LINE Login error: $e');
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await LineSDK.instance.logout();
      print('LINE Logout successful');
    } catch (e) {
      print('LINE Logout error: $e');
      rethrow;
    }
  }

  Future<bool> verifyToken() async {
    try {
      final accessToken = await LineSDK.instance.currentAccessToken;
      if (accessToken == null) {
        print('No access token found. User is not logged in.');
        return false;
      }
      print('Access Token Found: ${accessToken.value}');
      return true;  // You can also verify the token here if needed
    } catch (e) {
      print('Token verification error: $e');
      return false;
    }
  }

  Future<String?> getAccessToken() async {
    try {
      final accessToken = await LineSDK.instance.currentAccessToken;
      print('Retrieved Access Token: ${accessToken?.value}');
      return accessToken?.value;
    } catch (e) {
      print('Error getting access token: $e');
      return null;
    }
  }

  Future<List<UserProfile>> getFriends() async {
    try {
      final accessToken = await LineSDK.instance.currentAccessToken;
      if (accessToken == null) {
        throw Exception('Not logged in');
      }

      // Fetch the user's profile as a placeholder
      final profile = await LineSDK.instance.getProfile();
      return [profile];  // Returning the user's profile as the "friend" for now.
    } catch (e) {
      print('Error fetching friends: $e');
      return [];  // Returning empty list in case of failure
    }
  }

}
