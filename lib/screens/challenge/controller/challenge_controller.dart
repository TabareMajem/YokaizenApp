import 'dart:convert';

import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:yokai_quiz_app/api/database_api.dart';
import 'package:http/http.dart' as http;
import 'package:yokai_quiz_app/api/local_storage.dart';
import 'package:yokai_quiz_app/global.dart';
import 'package:yokai_quiz_app/main.dart';
import 'package:yokai_quiz_app/models/challenge/challenge_model.dart';
import 'package:yokai_quiz_app/models/comlaiment/complement_model.dart';
import 'package:yokai_quiz_app/screens/Authentication/controller/auth_screen_controller.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:get/get.dart';

class ChallengeController {
  static RxBool backToChallenge = false.obs;
  static Rx<ChallengeRes> getChallengeAll = ChallengeRes().obs;

  static Future<bool> getAllChallenges() async {
    final headers = {
      "Content-Type": "application/json",
      "AdminToken": '${prefs.getString(LocalStorage.token).toString()}'
    };
    final String url =
        '${DatabaseApi.getAllChallenge}';
    customPrint("getAllChallenge url :: $url");
    try {
      return await http
          .get(Uri.parse(url), headers: headers)
          .then((value) async {
        print("getAllChallenge :: ${value.body}");
        final jsonData = jsonDecode(value.body);
        if (jsonData["status"].toString() != "true") {
          // showErrorSnackBar(jsonData["message"].toString(), colorError);
          return false;
        }
        //showSnackbar("Subscription PlanPrice Details Added Successfully", colorSuccess);
        getChallengeAll(ChallengeRes.fromJson(jsonData));
        return true;
      });
    } on Exception catch (e) {
      print("getAllChallenge:: $e");
      // showSnackbar("Some unknown error has occur, try again after some time!", colorError);
      return false;
    }
  }

  static RxList<Map> challenges = <Map>[
    {
      "image": "icons/books.png",
      "heading": "Complete 2 Quizes".tr,
      "badge": "Kodama",
      "isActive": 0,
      "isCompleted": 5
    },
    {
      "image": "icons/books.png",
      "heading": "Complete 2 Quizes".tr,
      "badge": "Kodama",
      "isActive": 0,
      "isCompleted": 5
    },
    {
      "image": "icons/books.png",
      "heading": "Complete 2 Quizes".tr,
      "badge": "Kodama",
      "isActive": 0,
      "isCompleted": 5
    },
    {
      "image": "icons/books.png",
      "heading": "Complete 2 Quizes".tr,
      "badge": "Kodama",
      "isActive": 0,
      "isCompleted": 3
    },
    {
      "image": "icons/books.png",
      "heading": "Complete 2 Quizes".tr,
      "badge": "Kodama",
      "isActive": 1,
      "isCompleted": 3
    },
    {
      "image": "icons/books.png",
      "heading": "Complete 2 Quizes".tr,
      "badge": "Kodama",
      "isActive": 2,
      "isCompleted": 4
    },
    {
      "image": "icons/books.png",
      "heading": "Complete 3 Quizes".tr,
      "badge": "Kodama",
      "isActive": 1,
      "isCompleted": 3
    },
    {
      "image": "icons/books.png",
      "heading": "Complete 3 Quizes".tr,
      "badge": "Kodama",
      "isActive": 3,
      "isCompleted": 3
    },
    {
      "image": "icons/books.png",
      "heading": "Complete 3 Quizes".tr,
      "badge": "Kodama",
      "isActive": 3,
      "isCompleted": 3
    },
  ].obs;

  static RxBool isChallengeOrComplaint = true.obs;
  static RxBool isReceivedOrSent = false.obs;

  static List<ComplementData> complaints = [];

  static Future<bool> fetchChallenges() async {
    final headers = {
      "Content-Type": "application/json",
    };

    try {
      String url = DatabaseApi.getChallenges;

      final response = await http.get(Uri.parse(url), headers: headers);
      final jsonData = jsonDecode(response.body);

      String userLogs =
          "${DatabaseApi.getUserLogs}${AuthScreenController.userId}";

      if (jsonData["status"].toString() != "true") {
        customPrint("fetchAllChallenges response :: ${response.body}");
        customPrint("fetchAllChallenges message::${jsonData["message"]}");
        return false;
      } else {
        final inviteResponse =
            await http.get(Uri.parse(userLogs), headers: headers);
        final inviteJsonData = jsonDecode(inviteResponse.body);

        List<dynamic> challengesData = jsonData["data"];
        List<dynamic> inviteData = inviteJsonData["data"];
        int loginCount = inviteData[0]["login_count"] ?? 0;

        List<dynamic> filteredChallenges = challengesData.where((task) {
          return task['badge_type'] != 'invite' ||
              task['badge_type'] != 'share';
        }).toList();

        customPrint("fetchAllChallenges:::${filteredChallenges.toString()}");
        customPrint("Count::$loginCount");

        if (filteredChallenges.isNotEmpty) {
          challenges.clear();
          for (var challenge in filteredChallenges) {
            challenges.add({
              'image': challenge['badge_image_path'] ?? "",
              'badge': challenge['badge_name'] ?? "",
              'heading': challenge['name'] ?? "",
              'isCompleted': challenge['badge_step_count'] ?? 0,
              'isActive': challenge['badge_type'] == 'login' ? loginCount : 0 ?? 0,
            });
          }
        }
        return true;
      }
    } on Exception catch (e) {
      customPrint("Error :: $e");
      showErrorMessage("Failed to fetch mood data.", colorError);
      return false;
    }
  }

  static Future<bool> fetchComplaints() async {
    final headers = {
      "Content-Type": "application/json",
    };

    try {
      String url = DatabaseApi.getComplaints;

      final response = await http.get(Uri.parse(url), headers: headers);
      final jsonData = jsonDecode(response.body);

      if (jsonData["status"].toString() != "true") {
        customPrint("fetchAllComplaints response :: ${response.body}");
        customPrint("fetchAllComplaints message::${jsonData["message"]}");
        return false;
      } else {
        customPrint("fetchAllComplaints:::${jsonData.toString()}");
        ComplementRes modelResponse = ComplementRes.fromJson(jsonData);
        if (modelResponse.data.isNotEmpty) {
          complaints.addAll(modelResponse.data);
        }
        return true;
      }
    } on Exception catch (e) {
      customPrint("Error :: $e");
      showErrorMessage("Failed to fetch mood data.".tr, colorError);
      return false;
    }
  }
}
