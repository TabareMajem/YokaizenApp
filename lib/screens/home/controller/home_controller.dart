import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:yokai_quiz_app/screens/Authentication/controller/auth_screen_controller.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import '../../../api/database_api.dart';
import '../../../api/local_storage.dart';
import '../../../global.dart';
import '../../../main.dart';
import '../../../models/get_last_read_chapter.dart';

class HomeController {

  static RxDouble progress = 4.0.obs;
  static RxBool backToHome = false.obs;
  static RxBool backToHomeChapter = false.obs;
  static RxBool backToHomeFromCharactersDetails = false.obs;

  static Rx<GetLastReadChapter> getLastReadChapterModel =
      GetLastReadChapter().obs;
  static Future<bool> getLastReadChapter() async {
    final headers = {
      "Content-Type": "application/json",
      "UserToken": '${prefs.getString(LocalStorage.token).toString()}'
    };
    final String url = '${DatabaseApi.getLastReadChapter}';
    customPrint("getLastReadChapter url :: $url");
    try {
      return await http
          .get(Uri.parse(url), headers: headers)
          .then((value) async {
        print("getLastReadChapter :: ${value.body}");
        final jsonData = jsonDecode(value.body);
        if (jsonData["status"].toString() != "true") {
          // showErrorMessage(jsonData["message"].toString(), colorError);
          return false;
        }
        getLastReadChapterModel(getLastReadChapterFromJson(value.body));
        return true;
      });
    } on Exception catch (e) {
      print("getLastReadChapter:: $e");
      return false;
    }
  }

  static Future<bool> incrementUserLog() async {
    final headers = {
      "Content-Type": "application/json",
    };
    final String url = DatabaseApi.incrementUserLog;
    customPrint("incrementUserLog url :: $url");
    try {
      return await http
          .post(Uri.parse(url),
              body: jsonEncode({"user_id": AuthScreenController.userId}),
              headers: headers)
          .then((value) async {
        customPrint("incrementUserLog :: ${value.body}");
        final jsonData = jsonDecode(value.body);
        if (jsonData["status"].toString() != "true") {
          showErrorMessage(jsonData["message"].toString(), colorError);
          return false;
        }
        return true;
      });
    } on Exception catch (e) {
      customPrint(e);
      return false;
    }
  }

  static Future<bool> recordDevice(
      String deviceId, String deviceName, String ipAddress) async {
    final headers = {
      "Content-Type": "application/json",
    };
    final String url = DatabaseApi.recordDevice;
    customPrint("incrementUserLog url :: $url");
    try {
      return await http
          .post(Uri.parse(url),
              body: jsonEncode(
                {
                  "user_id": AuthScreenController.userId,
                  "device_name": deviceName,
                  "device_id": deviceId,
                  "ip_address": ipAddress,
                },
              ),
              headers: headers)
          .then((value) async {
        customPrint("recordDevinceInfo :: ${value.body}");
        final jsonData = jsonDecode(value.body);
        if (jsonData["status"].toString() != "true") {
          customPrint("recordDevinceInfo response :: ${value.body}");
          showErrorMessage(jsonData["message"].toString(), colorError);
          return false;
        }
        customPrint("recordDevinceInfo :: ${value.body}");
        return true;
      });
    } on Exception catch (e) {
      customPrint(e);
      return false;
    }
  }
}
