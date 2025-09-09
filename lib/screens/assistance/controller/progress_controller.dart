// lib/screens/assistance/controller/progress_controller.dart

import 'dart:convert';
import 'package:get/get.dart';
import 'package:yokai_quiz_app/api/local_storage.dart';
import 'package:yokai_quiz_app/api/node_database.dart';
import 'package:yokai_quiz_app/global.dart';
import 'package:yokai_quiz_app/main.dart';
import 'package:http/http.dart' as http;
import 'package:yokai_quiz_app/screens/assistance/model/progress_response.dart';

import '../../../util/constants.dart';

class ProgressController {
  static RxBool isExerciseLoading = false.obs;

  static Rx<ProgressResponse> progressData = ProgressResponse().obs;

  static Future<bool> getAllProgress() async {
    customPrint("getAllProgress got invoked");
    try {
      final headers = {
        "Content-Type": "application/json",
        "Authorization":
        "Bearer ${prefs.getString(LocalStorage.tokenNode).toString()}",
        "accept-language" : constants.deviceLanguage ?? "en"
      };
      final String url = NodeDatabaseApi.getAllProgress;
      customPrint("getAllProgress url :: $url");
      print(headers);

      final response = await http.get(Uri.parse(url), headers: headers);
      customPrint("getAllProgress :: ${response.body}");

      final jsonData = jsonDecode(response.body);
      customPrint("this is jsonData : $jsonData");

      try {
        progressData(ProgressResponse.fromJson(jsonData));
        customPrint("Progress data parsed successfully");
        return true;
      } catch (e) {
        customPrint("Error parsing progress data: $e");
        return false;
      }
    } catch (e) {
      customPrint("Error in getAllProgress: $e");
      return false;
    }
  }

  // static Future<bool> getAllProgress() async {
  //   customPrint("getAllProgress got invoked");
  //   customPrint(prefs.getString(LocalStorage.tokenNode).toString());
  //   final headers = {
  //     "Content-Type": "application/json",
  //     "Authorization":
  //     "Bearer ${prefs.getString(LocalStorage.tokenNode).toString()}"
  //   };
  //   // var userId = prefs.getString(LocalStorage.idNode).toString();
  //   final String url = NodeDatabaseApi.getAllProgress;
  //   customPrint("getAllProgress url :: $url");
  //   print(headers);
  //   try {
  //     return await http
  //         .get(Uri.parse(url), headers: headers)
  //         .then((value) async {
  //       customPrint("getAllProgress :: ${value.body}");
  //       final jsonData = jsonDecode(value.body);
  //       customPrint("this is jsonData : $jsonData");
  //       progressData(ProgressResponse.fromJson(jsonData));
  //       customPrint("Done done without error");
  //       return true;
  //     });
  //   } on Exception catch (e) {
  //     print("getAllExcessive:: $e");
  //
  //     return false;
  //   }
  // }
}
