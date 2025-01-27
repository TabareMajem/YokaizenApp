import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:yokai_quiz_app/api/database_api.dart';
import 'package:yokai_quiz_app/global.dart';
import 'package:yokai_quiz_app/screens/Authentication/controller/auth_screen_controller.dart';
import 'package:yokai_quiz_app/util/colors.dart';

class MoodController extends GetxController {
  static RxBool isLoading = false.obs;
  static RxInt idController = 1.obs;
  static RxList<Map> moodList = <Map>[].obs;
  static RxList<Map> moodSummeryList = <Map>[].obs;

  static Rx<String> todayDateWithDay = _getTodayDateWithDay().obs;

  static String _getTodayDateWithDay() {
    DateTime now = DateTime.now();
    return DateFormat('EEE, d MMM').format(now);
  }

  static Future<bool> addOrUpdateMood(BuildContext context, body) async {
    final headers = {
      "Content-Type": "application/json",
      "accept": "application/json",
    };
    String url = DatabaseApi.createOrUpdateMood;

    try {
      return await http
          .post(Uri.parse(url), body: jsonEncode(body), headers: headers)
          .then((value) async {
        print(value.body);
        final jsonData = jsonDecode(value.body);

        if (jsonData["status"].toString() != "true") {
          showErrorMessage(jsonData.toString(), colorError);
          customPrint("createActivity response :: ${value.body}");
          customPrint("createActivity message::${jsonData["message"]}");
          return false;
        } else {
          // showSucessMessage(jsonData["message"], colorSuccess);
        }
        customPrint("createActivity::${value.body}");
        return true;
      });
    } on Exception catch (e) {
      customPrint("Error :: $e");
      return false;
    }
  }

  static Future<bool> fetchGifsByUserId() async {
    final headers = {
      "Content-Type": "application/json",
    };

    try {
      await AuthScreenController.fetchData();
      int userId = AuthScreenController.getProfileModel.value.user?.userId ?? 1;

      String url = "${DatabaseApi.getMoodByUserId}/$userId";

      final response = await http.get(Uri.parse(url), headers: headers);
      final jsonData = jsonDecode(response.body);

      if (jsonData["status"].toString() != "true") {
        customPrint("fetchGifsByUserId response :: ${response.body}");
        customPrint("fetchGifsByUserId message::${jsonData["message"]}");
        return false;
      } else {
        customPrint("fetchGifsByUserId::${response.body}");

        List<dynamic> moods = jsonData["data"];
        moodList.clear();

        for (var mood in moods) {
          moodList.add({
            'mood_level': mood['mood_level'],
            'mood_gif': mood['mood_gif'],
            'date': mood['date'],
          });
        }
        return true;
      }
    } on Exception catch (e) {
      customPrint("Error :: $e");
      showErrorMessage("Failed to fetch mood data.".tr, colorError);
      return false;
    }
  }

  static Future<bool> fetchMoodSummeryByUserId() async {
    final headers = {
      "Content-Type": "application/json",
    };

    try {
      await AuthScreenController.fetchData();
      int userId = AuthScreenController.getProfileModel.value.user?.userId ?? 1;

      String url =
          "${DatabaseApi.getMoodSummeryByUserId}?user_id=$userId&days=8";

      final response = await http.get(Uri.parse(url), headers: headers);
      final jsonData = jsonDecode(response.body);

      if (jsonData["status"].toString() != "true") {
        customPrint("fetchGifsByUserId response :: ${response.body}");
        customPrint("fetchGifsByUserId message::${jsonData["message"]}");
        return false;
      } else {
        customPrint("fetchGifsByUserId::${response.body}");

        List<dynamic> moods = jsonData["data"];
        moodSummeryList.clear();

        for (var mood in moods) {
          moodSummeryList.add({
            'mood_level': mood['average_mood_level'],
            'date': mood['date'],
          });
        }
        print(moodSummeryList);
        return true;
      }
    } on Exception catch (e) {
      customPrint("Error :: $e");
      showErrorMessage("Failed to fetch mood summery.", colorError);
      return false;
    }
  }
}
