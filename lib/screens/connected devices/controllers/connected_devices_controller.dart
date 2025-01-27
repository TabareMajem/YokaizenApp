import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:intl/intl.dart';
import 'package:yokai_quiz_app/api/database_api.dart';
import 'package:yokai_quiz_app/global.dart';
import 'package:yokai_quiz_app/screens/Authentication/controller/auth_screen_controller.dart';
import 'package:yokai_quiz_app/util/colors.dart';

class ConnectedDevicesController {
  static RxList<Map> connectectedDevices = <Map>[].obs;

  static Future<bool> getAllUserDevices() async {
    final headers = {
      "Content-Type": "application/json",
    };
    final String url =
        "${DatabaseApi.getDeviceByUserId}/${AuthScreenController.userId}";
    customPrint("getDEvicesbyUerId url :: $url");
    try {
      return await http
          .get(Uri.parse(url), headers: headers)
          .then((value) async {
        customPrint("recordDevinceInfo :: ${value.body}");
        final jsonData = jsonDecode(value.body);
        if (jsonData["status"].toString() != "true") {
          customPrint("recordDevinceInfo response :: ${value.body}");
          showErrorMessage(jsonData["message"].toString(), colorError);
          return false;
        }
        List<dynamic> deviceInfo = jsonData["data"];

        if (deviceInfo.isNotEmpty) {
          connectectedDevices.clear();
          for (var device in deviceInfo) {
            DateTime created = DateTime.parse(device["login_time"]);
            String createdDate = DateFormat('dd-MM-yyyy').format(created);
            connectectedDevices.add({
              "id": device['device_id'],
              "icon": "icons/phone.png",
              "name": device["device_name"],
              'connectedAt': createdDate,
            });
          }
        }

        customPrint("recordDevinceInfo :: ${value.body}");
        return true;
      });
    } on Exception catch (e) {
      customPrint(e);
      return false;
    }
  }

  static Future<bool> deleteDevice(String id) async {
    final headers = {
      "Content-Type": "application/json",
    };
    final String url = "${DatabaseApi.deleteDevice}/$id";
    customPrint("deleteDevice url :: $url");
    try {
      return await http
          .delete(Uri.parse(url), headers: headers)
          .then((value) async {
        customPrint("deleteDevice response :: ${value.body}");
        final jsonData = jsonDecode(value.body);
        if (jsonData["status"].toString() == "true") {
          showSucessMessage(jsonData["message"].toString(), colorSuccess);
          return true;
        } else {
          showErrorMessage(jsonData["message"].toString(), colorError);
          return false;
        }
      });
    } on Exception catch (e) {
      customPrint(e);
      return false;
    }
  }
}
