import 'dart:convert';

import 'package:get/get.dart';
import 'package:yokai_quiz_app/api/database_api.dart';
import 'package:yokai_quiz_app/global.dart';
import 'package:yokai_quiz_app/models/assessment_model.dart';
import 'package:yokai_quiz_app/screens/Authentication/controller/auth_screen_controller.dart';
import 'package:http/http.dart' as http;

import '../../../api/local_storage.dart';
import '../../../main.dart';
import '../../../util/constants.dart';

class PersonalityController {
  static RxBool isLoading = true.obs;
  static RxList<AssessmentResult> personalityResultList =
      <AssessmentResult>[].obs;

  // New property to store assessment averages data
  static Rx<Map<String, dynamic>> assessmentAverages = Rx<Map<String, dynamic>>({});

  static Future<bool> fetchAssignmentResultUserId() async {
    final headers = {
      "Content-Type": "application/json",
      "Accept-Language" : constants.deviceLanguage,
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

  // New method to fetch assessment averages
  static Future<bool> fetchAssessmentAverages() async {
    isLoading(true);
    
    try {
      final userId = AuthScreenController.getProfileModel.value.user?.userId ?? 1;
      
      final headers = {
        "Content-Type": "application/json",
        "accept": "application/json",
        "Accept-Language": constants.deviceLanguage,
        "UserToken": prefs.getString(LocalStorage.token).toString(),
      };
      
      final url = Uri.parse('${DatabaseApi.getPersonalityResult}/$userId');
      customPrint("fetchAssessmentAverages url :: $url");
      
      final response = await http.get(url, headers: headers);
      final result = utf8.decode(response.bodyBytes, allowMalformed: true);
      customPrint("fetchAssessmentAverages response :: $result");
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(result);
        assessmentAverages.value = jsonData;
        isLoading(false);
        return true;
      } else {
        customPrint("fetchAssessmentAverages error :: ${response.statusCode}");
        isLoading(false);
        return false;
      }
    } catch (e) {
      customPrint("fetchAssessmentAverages exception :: $e");
      isLoading(false);
      return false;
    }
  }
}
