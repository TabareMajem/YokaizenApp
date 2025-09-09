// badge_controller.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:yokai_quiz_app/api/database_api.dart';
import 'package:http/http.dart' as http;
import 'package:yokai_quiz_app/global.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:get/get.dart';
import '../../../api/local_storage.dart';
import '../../../main.dart';
import '../model/badge_response.dart';

class BadgeController extends GetxController {
  static final RxList<BadgeResponse> badges = <BadgeResponse>[].obs;

  // static Future<bool> fetchAllBadges() async {
  //   customPrint("fetchAllBadges got invoked");
  //   final token = prefs.getString(LocalStorage.token);
  //
  //   if (token == null || token.isEmpty) {
  //     customPrint("Token is null or empty");
  //     return false;
  //   }
  //
  //   final headers = {
  //     "accept": "application/json",
  //     "UserToken": token,
  //   };
  //   customPrint("fetchAllBadges headers: $headers");
  //
  //   try {
  //     String url = DatabaseApi.getAllBadges;
  //     customPrint("Full URL being called: ${Uri.parse(url)}");
  //
  //     final response = await http.get(
  //         Uri.parse(url),
  //         headers: headers
  //     ).timeout(
  //       const Duration(seconds: 30),
  //       onTimeout: () {
  //         customPrint("Request timed out");
  //         throw TimeoutException('Request timed out');
  //       },
  //     );
  //
  //     customPrint("Response status code: ${response.statusCode}");
  //
  //     if (response.statusCode != 200) {
  //       customPrint("Error status code: ${response.statusCode}");
  //       customPrint("Error response body: ${response.body}");
  //       return false;
  //     }
  //
  //     if (response.body.isEmpty) {
  //       customPrint("Response body is empty");
  //       return false;
  //     }
  //
  //     final jsonData = jsonDecode(response.body);
  //     customPrint("fetchAllBadges jsonData: $jsonData");
  //
  //     if (jsonData["status"].toString() != "true") {
  //       customPrint("Error message: ${jsonData["message"]}");
  //       return false;
  //     }
  //
  //     List<dynamic> badgeData = jsonData["data"];
  //     customPrint("Number of badges received: ${badgeData.length}");
  //
  //     if (badgeData.isNotEmpty) {
  //       badges.clear();
  //       // Convert each map to BadgeResponse object
  //       final badgeList = badgeData.map((badge) => BadgeResponse.fromJson(badge as Map<String, dynamic>)).toList();
  //       badges.addAll(badgeList);
  //       customPrint("Successfully processed ${badges.length} badges");
  //       return true;
  //     }
  //
  //     return true;
  //
  //   } on SocketException catch (e) {
  //     customPrint("Network error: $e");
  //     showErrorMessage("Please check your internet connection".tr, colorError);
  //     return false;
  //
  //   } on TimeoutException catch (e) {
  //     customPrint("Timeout error: $e");
  //     showErrorMessage("Request timed out".tr, colorError);
  //     return false;
  //
  //   } on FormatException catch (e) {
  //     customPrint("Data format error: $e");
  //     showErrorMessage("Invalid data format received".tr, colorError);
  //     return false;
  //
  //   } catch (e) {
  //     customPrint("Unexpected error: $e");
  //     showErrorMessage("Failed to fetch badges.".tr, colorError);
  //     return false;
  //   }
  // }

  static Future<bool> fetchAllBadges() async {
    customPrint("fetchAllBadges got invoked");
    final token = prefs.getString(LocalStorage.token);

    if (token == null || token.isEmpty) {
      customPrint("Token is null or empty");
      return false;
    }

    final headers = {
      "accept": "application/json",
      "UserToken": token,
    };
    customPrint("fetchAllBadges headers: $headers");

    try {
      String url = DatabaseApi.getAllBadges;
      customPrint("Full URL being called: ${Uri.parse(url)}");

      final response = await http.get(
          Uri.parse(url),
          headers: headers
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          customPrint("Request timed out");
          throw TimeoutException('Request timed out');
        },
      );

      customPrint("Response status code: ${response.statusCode}");

      if (response.statusCode != 200) {
        customPrint("Error status code: ${response.statusCode}");
        customPrint("Error response body: ${response.body}");
        return false;
      }

      if (response.body.isEmpty) {
        customPrint("Response body is empty");
        return false;
      }

      final jsonData = jsonDecode(response.body);
      customPrint("fetchAllBadges jsonData: $jsonData");

      if (jsonData["status"].toString() != "true") {
        customPrint("Error message: ${jsonData["message"]}");
        return false;
      }

      List<dynamic> badgeData = jsonData["data"];
      customPrint("Number of badges received: ${badgeData.length}");

      if (badgeData.isNotEmpty) {
        badges.clear();
        // Convert each map to BadgeResponse object and explicitly cast the list
        final List<BadgeResponse> badgeList = badgeData
            .map((badge) => BadgeResponse.fromJson(badge as Map<String, dynamic>))
            .toList();
        badges.assignAll(badgeList); // Use assignAll instead of addAll
        customPrint("Successfully processed ${badges.length} badges");
        return true;
      }

      return true;

    } catch (e) {
      customPrint("Unexpected error: $e");
      showErrorMessage("Failed to fetch badges.".tr, colorError);
      return false;
    }
  }


}