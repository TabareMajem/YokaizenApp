import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:yokai_quiz_app/api/database_api.dart';
import 'package:yokai_quiz_app/api/local_storage.dart';
import 'package:yokai_quiz_app/global.dart';
import 'package:yokai_quiz_app/main.dart';
import 'package:yokai_quiz_app/models/get_all_characters.dart';
import 'package:yokai_quiz_app/models/get_characters_by_id.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/constants.dart';

import '../../../models/get_chat_from_api.dart';
import '../../../models/get_unlock_all_charecters.dart';
import '../view/messaging_page.dart';

class ChatController {
  static RxBool backToCharacters = false.obs;
  static RxBool backToCharactersForCharactersDetails = false.obs;
  static final TextEditingController charactersSearch = TextEditingController();

  static RxBool isBrowseOrChats = true.obs;
  static RxBool isChatAnimation = false.obs;

  static RxList chDetails = [].obs;

  ///messaging
  static RxBool isLoading = true.obs;
  static bool apiCall = true;
  static ScrollController scrollController = ScrollController();

// bool _isGeneratingMessage = false;
  static final List<String> reasons = <String>[
    "Select".tr,
    "Spam".tr,
    "Illegal Activity".tr,
    "Harassment".tr,
    "Threat".tr,
    "Fraud / Scam".tr,
    "Misinformation".tr,
    "Other".tr,
  ];
  static String selectedReasons = "Select".tr;
  static List<Message> messages = [];
  static final TextEditingController textEditingController =
      TextEditingController();
  static int data = 1;
  static Timer? timer;

  static Future<void> scrollListener() async {
    if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent &&
        scrollController.position.userScrollDirection ==
            ScrollDirection.reverse) {
      if (apiCall) {
        // setState(() {
        apiCall = false;
        isLoading(true);
        // });
        data = data + 1;
        // await getgroupChatById(context, widget.groupId, data).then((value) {
        // messagesData(getGroupChatByGroupId.value.data);
        // });
        // filteredMessages.addAll(messagesData);

        // messagesData.clear();
        // setState(() {
        apiCall = true;
        isLoading(false);
        // });
      }
    }
  }

  static double calculatePercentage(double part, double? total) {
    if (total == null || total == 0) {
      return 0; // or throw an exception, depending on your use case
    }
    return (part / total) * 100;
  }

  static Rx<GetAllCharacters> getAllCharactersModel = GetAllCharacters().obs;

  static Future<bool> getAllCharacters(String search) async {
    final headers = {
      "Content-Type": "application/json",
      "UserToken": prefs.getString(LocalStorage.token).toString(),
      "Accept-Language" : constants.deviceLanguage,
    };
    print("character");
    final String url = '${DatabaseApi.getAllCharacters}$search';
    customPrint("getAllCharacters url :: $url");
    try {
      return await http
          .get(Uri.parse(url), headers: headers)
          .then((value) async {
        final result = utf8.decode(value.bodyBytes, allowMalformed: true);
        print("getAllCharacters :: ${result}");
        final jsonData = jsonDecode(result);
        if (jsonData["status"].toString() != "true") {
          showErrorMessage(jsonData["message"].toString(), colorError);
          return false;
        }
        print("bhati saad");
        print(value.body);
        //showSnackbar("Subscription PlanPrice Details Added Successfully", colorSuccess);
        getAllCharactersModel(getAllCharactersFromJson(result));
        return true;
      });
    } on Exception catch (e) {
      print("getAllCharacters:: $e");
      // showSnackbar("Some unknown error has occur, try again after some time!", colorError);
      return false;
    }
  }

  static Rx<GetCharactersById> getCharactersByIdModel = GetCharactersById().obs;
  static Future<bool> getCharactersById(String id) async {
    final headers = {
      "Content-Type": "application/json",
      "UserToken": prefs.getString(LocalStorage.token).toString(),
      "Accept-Language" : constants.deviceLanguage,
    };
    final String url = '${DatabaseApi.getCharactersById}$id';
    customPrint("getCharactersById url :: $url");
    try {
      return await http
          .get(Uri.parse(url), headers: headers)
          .then((value) async {
        // final result = utf8.decode(value.bodyBytes, allowMalformed: true);
        print("getCharactersById :: ${value.body}");
        final jsonData = jsonDecode(value.body);
        if (jsonData["status"].toString() != "true") {
          showErrorMessage(jsonData["message"].toString(), colorError);
          return false;
        }
        //showSnackbar("Subscription PlanPrice Details Added Successfully", colorSuccess);
        getCharactersByIdModel(getCharactersByIdFromJson(value.body));
        return true;
      });
    } on Exception catch (e) {
      print("getCharactersById:: $e");
      // showSnackbar("Some unknown error has occur, try again after some time!", colorError);
      return false;
    }
  }

  static Rx<GetUnlockAllCharacters> getUnlockCharactersModel =
      GetUnlockAllCharacters().obs;
  static Future<bool> getUnlockCharacters(String search) async {
    final headers = {
      "Content-Type": "application/json",
      "UserToken": prefs.getString(LocalStorage.token).toString()
    };
    final String url = '${DatabaseApi.getAllUnlockCharacters}$search';
    customPrint("getAllUnlockCharacters url :: $url");
    try {
      return await http
          .get(Uri.parse(url), headers: headers)
          .then((value) async {
        print("getAllUnlockCharacters :: ${value.body}");
        final jsonData = jsonDecode(value.body);
        if (jsonData["status"].toString() != "true") {
          showErrorMessage(jsonData["message"].toString(), colorError);
          return false;
        }
        //showSnackbar("Subscription PlanPrice Details Added Successfully", colorSuccess);
        getUnlockCharactersModel(getUnlockAllCharactersFromJson(value.body));
        return true;
      });
    } on Exception catch (e) {
      print("getAllUnlockCharacters:: $e");
      // showSnackbar("Some unknown error has occur, try again after some time!", colorError);
      return false;
    }
  }

  static Future<bool> sendChatToApi(BuildContext context, body) async {
    final String url = DatabaseApi.sendChatToApi;
    final headers = {
      "Content-Type": "application/json",
      "UserToken": prefs.getString(LocalStorage.token).toString()
    };
    customPrint("sendChatToApi Url::$url");
    customPrint("sendChatToApi body::${jsonEncode(body)}");
    try {
      return await http
          .post(
        Uri.parse(url),
        body: jsonEncode(body),
        headers: headers,
      )
          .then((value) async {
        final jsonData = jsonDecode(value.body);
        customPrint("sendChatToApi response :: ${value.body}");
        
        if (jsonData["status"].toString() != "true") {
          // Handle null message safely
          String errorMessage = "Unknown error occurred";
          if (jsonData["message"] != null) {
            errorMessage = jsonData["message"].toString();
          }
          showErrorMessage(errorMessage, colorError);
          customPrint("sendChatToApi error message:: $errorMessage");
          return false;
        } else {
          // Success case - handle null message safely
          String successMessage = "Chat sent successfully";
          if (jsonData["message"] != null) {
            successMessage = jsonData["message"].toString();
          }
          customPrint("sendChatToApi success:: $successMessage");
          // showSucessMessage(successMessage, colorSuccess);
        }
        return true;
      });
    } on Exception catch (e) {
      customPrint("sendChatToApi Error :: $e");
      // showSnackbar(
      //     context,
      //     "Some unknown error has occur, try again after some time",
      //     colorError);
      return false;
    }
  }

  static Rx<GetChatFromApiByCharacterId> getChatFromApiModel =
      GetChatFromApiByCharacterId().obs;

  static Future<bool> getChatFromApi(String id, String page) async {
    final headers = {
      "Content-Type": "application/json",
      "UserToken": prefs.getString(LocalStorage.token).toString()
    };
    final String url = '${DatabaseApi.getChatFromApi}$id&page_number=$page';
    customPrint("getChatFromApi url :: $url");
    try {
      return await http
          .get(Uri.parse(url), headers: headers)
          .then((value) async {
        print("getChatFromApi :: ${value.statusCode}");
        final jsonData = jsonDecode(value.body);
        customPrint("getChatFromApi jsonData : ${jsonData['status']}");
        if (jsonData["status"].toString() != "true") {
          showErrorMessage(jsonData["message"].toString(), colorError);
          return false;
        }
        //showSnackbar("Subscription PlanPrice Details Added Successfully", colorSuccess);
        getChatFromApiModel(getChatFromApiByCharacterIdFromJson(value.body));
        customPrint("This is character summary value : ${getChatFromApiModel}");
        return true;
      });
    } on Exception catch (e) {
      print("getChatFromApi:: $e");
      // showSnackbar("Some unknown error has occur, try again after some time!", colorError);
      return false;
    }
  }

  static Future<bool> updateCharacterSummary(BuildContext context, body) async {
    final String url = "${DatabaseApi.updateCharacterSummary}";
    final headers = {
      "accept": "application/json",
      "Content-Type": "application/json",
      "UserToken": '${prefs.getString(LocalStorage.token).toString()}'
    };
    customPrint("updateCharacterSummary Url::$url");
    customPrint("updateCharacterSummary body::${jsonEncode(body)}");
    try {
      return await http
          .post(
        Uri.parse(url),
        body: jsonEncode(body),
        headers: headers,
      )
          .then((value) async {
        final jsonData = jsonDecode(value.body);
        if (jsonData["status"].toString() != "true") {
          // showErrorMessage(jsonData["message"], colorError);
          customPrint("updateCharacterSummary response :: ${value.body}");
          customPrint("updateCharacterSummary message::${jsonData["message"]}");
          return false;
        } else {
          // showSucessMessage(jsonData["message"], colorSuccess);
        }
        customPrint("updateCharacterSummary::${value.body}");
        return true;
      });
    } on Exception catch (e) {
      customPrint("Error :: $e");
      // showSnackbar(
      //     context,
      //     "Some unknown error has occur, try again after some time",
      //     colorError);
      return false;
    }
  }
}
