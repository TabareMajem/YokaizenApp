import 'dart:convert';

import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:yokai_quiz_app/api/database_api.dart';
import 'package:yokai_quiz_app/global.dart';
import 'package:yokai_quiz_app/screens/profile/controller/profile_controller.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:http/http.dart' as http;

class ReferAndEarnController {
  static RxString referralCode = "".obs;
  static Future<bool> createReferralCode() async {
    final headers = {
      "Content-Type": "application/json",
    };

    try {
      String url =
          "${DatabaseApi.createReferalCode}${ProfileController.userId.value}";

      customPrint(url);
      final response = await http.post(Uri.parse(url), headers: headers);
      final jsonData = jsonDecode(response.body);

      if (jsonData["status"].toString() != "true") {
        customPrint("creatingReferralCode response :: ${response.body}");
        customPrint("creatingReferralCode message::${jsonData["message"]}");
        return false;
      } else {
        customPrint("creatingReferralCode::${response.body}");

        referralCode.value = jsonData["data"]["referral_code"].toString();

        print(referralCode);

        return true;
      }
    } on Exception catch (e) {
      customPrint("Error :: $e");
      showErrorMessage("Failed to fetch mood data.", colorError);
      return false;
    }
  }
}
