import 'dart:convert';

import 'package:get/get.dart';
import 'package:yokai_quiz_app/api/local_storage.dart';
import 'package:yokai_quiz_app/api/node_database.dart';
import 'package:yokai_quiz_app/global.dart';
import 'package:yokai_quiz_app/main.dart';
import 'package:http/http.dart' as http;
import 'package:yokai_quiz_app/models/exercise/Exercise_model.dart';
import 'package:yokai_quiz_app/screens/assistance/model/progress_response.dart';
import 'package:yokai_quiz_app/util/colors.dart';

class ExercisesController {
  static RxBool isExerciseLoading = false.obs;

  static Rx<ExercisesRes> getChallengeAll = ExercisesRes().obs;

  static Future<bool> getAllExercise() async {
    print(prefs.getString(LocalStorage.tokenNode).toString());
    final headers = {
      "Content-Type": "application/json",
      "Authorization":
          "Bearer ${prefs.getString(LocalStorage.tokenNode).toString()}"
    };
    // var userId = prefs.getString(LocalStorage.idNode).toString();
    final String url = '${NodeDatabaseApi.getAllExercise}';
    customPrint("getAllExcessive url :: $url");
    print(headers);
    try {
      return await http
          .get(Uri.parse(url), headers: headers)
          .then((value) async {
        print("getAllExcessive :: ${value.body}");
        final jsonData = jsonDecode(value.body);
        // if (jsonData["status"].toString() != "true") {
        //   // showErrorMessage(jsonData["message"].toString(), colorError);
        //   return false;
        // }
        //showSnackbar("Subscription PlanPrice Details Added Successfully", colorSuccess);
        getChallengeAll(ExercisesRes.fromJson(jsonData));
        return true;
      });
    } on Exception catch (e) {
      print("getAllExcessive:: $e");

      return false;
    }
  }
}
