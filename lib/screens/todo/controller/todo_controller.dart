import 'dart:convert';
import 'package:yokai_quiz_app/api/database_api.dart';
import 'package:yokai_quiz_app/global.dart';
import 'package:yokai_quiz_app/screens/Authentication/controller/auth_screen_controller.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class TodoController {
  static RxList<Map> todoList = <Map>[
    {
      "id": 1,
      "title": "Share App with 5 friends".tr,
      "badge": "Tengu’s Apprentice",
      "isCompleted": 5,
      "isActive": 0,
      "type": "share"
    },
    {
      "id": 1,
      "title": "Share App with 10 friends".tr,
      "badge": "Tengu’s Disciple",
      "isCompleted": 10,
      "isActive": 0,
      "type": "share"
    },
    {
      "id": 1,
      "title": "Share App with 20 friends".tr,
      "badge": "Tengu’s Master",
      "isCompleted": 20,
      "isActive": 0,
      "type": "share"
    },
    {
      "id": 1,
      "title": "Share App with 50 friends".tr,
      "badge": "Yokai",
      "isCompleted": 50,
      "isActive": 0,
      "type": "share"
    },
    {
      "id": 1,
      "title": "Invite 1 friend to join challenge".tr,
      "badge": "Yokai",
      "isCompleted": 1,
      "isActive": 0,
      "type": "invite"
    },
    {
      "id": 1,
      "title": "Invite 10 friend to join challenge".tr,
      "badge": "Yokai",
      "isCompleted": 10,
      "isActive": 0,
      "type": "invite"
    },
  ].obs;

  static Future<bool> fetchTodoData() async {
    final headers = {
      "Content-Type": "application/json",
    };

    try {
      String url = DatabaseApi.getChallenges;
      final response = await http.get(Uri.parse(url), headers: headers);
      final jsonData = jsonDecode(response.body);

      String userLogs =
          "${DatabaseApi.getUserLogs}${AuthScreenController.userId}";
      final inviteResponse =
          await http.get(Uri.parse(userLogs), headers: headers);
      final inviteJsonData = jsonDecode(inviteResponse.body);

      if (jsonData["status"].toString() != "true" ||
          inviteJsonData["status"].toString() != "true") {
        customPrint("fetchingTasks response :: ${response.body}");
        customPrint("fetchingTasks message::${jsonData["message"]}");
        customPrint("fetchingTasks message::${inviteJsonData["message"]}");
        return false;
      } else {
        customPrint("fetchingTasks::${response.body}");
        customPrint("fetchingTasks::${inviteResponse.body}");

        List<dynamic> tasks = jsonData["data"];
        List<dynamic> inviteTasks = inviteJsonData["data"];

        List<dynamic> filteredTasks = tasks.where((task) {
          return task['badge_type'] == 'invite' ||
              task['badge_type'] == 'share';
        }).toList();

        if (filteredTasks.isNotEmpty) {
          todoList.clear();
          for (var task in filteredTasks) {
            todoList.add({
              'id': task['id'],
              'badge': task['badge_name'],
              'title': task['name'],
              'isCompleted': task['badge_step_count'],
              'isActive': 0,
              'type': task['badge_type'],
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
}
