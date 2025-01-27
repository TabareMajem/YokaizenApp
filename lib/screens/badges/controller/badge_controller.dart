import 'dart:convert';

import 'package:yokai_quiz_app/api/database_api.dart';
import 'package:http/http.dart' as http;
import 'package:yokai_quiz_app/global.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:get/get.dart';

class BadgeController {
  static RxList<Map> badges = <Map>[
    {"icon": "icons/books.png", "name": "App Ambassador", "type": "share"},
    {"icon": "icons/books.png", "name": "App Evangelist", "type": "chat"},
    {"icon": "icons/books.png", "name": "App Promoter", "type": "showup"},
    {
      "icon": "icons/books.png",
      "name": "Mindfulness Practitioner L2",
      "type": "mentality"
    },
    {"icon": "icons/books.png", "name": " App Ambassador", "type": "share"},
    {"icon": "icons/books.png", "name": "App Evangelist", "type": "chat"},
    {"icon": "icons/books.png", "name": "App Promoter", "type": "showup"},
    {
      "icon": "icons/books.png",
      "name": "Mindfulness Practitioner L2",
      "type": "mentality"
    },
    {"icon": "icons/books.png", "name": " App Ambassador", "type": "share"},
    {"icon": "icons/books.png", "name": "App Evangelist", "type": "chat"},
    {"icon": "icons/books.png", "name": "App Promoter", "type": "showup"},
    {
      "icon": "icons/books.png",
      "name": "Mindfulness Practitioner L2",
      "type": "mentality"
    },
    {"icon": "icons/books.png", "name": " App Ambassador", "type": "share"},
    {"icon": "icons/books.png", "name": "App Evangelist", "type": "chat"},
    {"icon": "icons/books.png", "name": "App Promoter", "type": "showup"},
    {
      "icon": "icons/books.png",
      "name": "Mindfulness Practitioner L2",
      "type": "mentality"
    },
    {"icon": "icons/books.png", "name": " App Ambassador", "type": "share"},
    {"icon": "icons/books.png", "name": "App Evangelist", "type": "chat"},
    {"icon": "icons/books.png", "name": "App Promoter", "type": "showup"},
    {
      "icon": "icons/books.png",
      "name": "Mindfulness Practitioner L2",
      "type": "mentality"
    },
    {"icon": "icons/books.png", "name": " App Ambassador", "type": "share"},
    {"icon": "icons/books.png", "name": "App Evangelist", "type": "chat"},
    {"icon": "icons/books.png", "name": "App Promoter", "type": "showup"},
    {
      "icon": "icons/books.png",
      "name": "Mindfulness Practitioner L2",
      "type": "mentality"
    },
    {"icon": "icons/books.png", "name": " App Ambassador", "type": "share"},
    {"icon": "icons/books.png", "name": "App Evangelist", "type": "chat"},
    {"icon": "icons/books.png", "name": "App Promoter", "type": "showup"},
    {
      "icon": "icons/books.png",
      "name": "Mindfulness Practitioner L2",
      "type": "mentality"
    },
    {"icon": "icons/books.png", "name": " App Ambassador", "type": "share"},
    {"icon": "icons/books.png", "name": "App Evangelist", "type": "chat"},
    {"icon": "icons/books.png", "name": "App Promoter", "type": "showup"},
    {
      "icon": "icons/books.png",
      "name": "Mindfulness Practitioner L2",
      "type": "mentality"
    },
    {"icon": "icons/books.png", "name": " App Ambassador", "type": "arcs"},
    {"icon": "icons/books.png", "name": "App Evangelist", "type": "arcs"},
    {"icon": "icons/books.png", "name": "App Promoter", "type": "arcs"},
    {
      "icon": "icons/books.png",
      "name": "Mindfulness Practitioner L2",
      "type": "arcs"
    },
  ].obs;

  static Future<bool> fetchAllBadges() async {
    final headers = {
      "Content-Type": "application/json",
    };

    try {
      String url = DatabaseApi.getChallenges;

      final response = await http.get(Uri.parse(url), headers: headers);
      final jsonData = jsonDecode(response.body);

      if (jsonData["status"].toString() != "true") {
        customPrint("fetchBadges response :: ${response.body}");
        customPrint("fetchBadges message::${jsonData["message"]}");
        return false;
      } else {
        customPrint("fetchBadges::${response.body}");

        List<dynamic> badgeData = jsonData["data"];

        if (badgeData.isNotEmpty) {
          badges.clear();
          for (var badge in badgeData) {
            badges.add({
              'name': badge['badge_name'],
              'icon': badge['badge_image_path'],
              'type': badge['badge_type'],
            });
          }
          return true;
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
