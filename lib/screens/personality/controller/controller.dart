import 'dart:convert';

import 'package:get/get.dart';
import 'package:yokai_quiz_app/api/database_api.dart';
import 'package:yokai_quiz_app/global.dart';
import 'package:yokai_quiz_app/models/assessment_model.dart';
import 'package:yokai_quiz_app/screens/Authentication/controller/auth_screen_controller.dart';
import 'package:http/http.dart' as http;

class PersonalityController {
  static RxBool isLoading = false.obs;
  static RxList<AssessmentResult> personalityResultList =
      <AssessmentResult>[].obs;

  static Future<bool> fetchAssignmentResultUserId() async {
    final headers = {
      "Content-Type": "application/json",
    };

    try {
      await AuthScreenController.fetchData();
      int userId = AuthScreenController.getProfileModel.value.user?.userId ?? 1;

      String url = "${DatabaseApi.getPersonalityResult}/$userId";

      final response = await http.get(Uri.parse(url), headers: headers);
      final jsonData = jsonDecode(response.body);

      if (jsonData == null) {
        customPrint(
            "assessment result by user id response :: ${response.body}");
        customPrint("assessment result by user id::$jsonData");
        return false;
      } else {
        customPrint("assessment result by user id::${response.body}");

        List<dynamic> moods = jsonData;
        personalityResultList.clear();

        for (var mood in moods) {
          personalityResultList.add(
            AssessmentResult.fromJson(mood),
          );
        }
        return true;
      }
    } on Exception catch (e) {
      customPrint("Error :: $e");
      // showErrorMessage("Failed to fetch mood data.".tr, colorError);
      return false;
    }
  }
}
