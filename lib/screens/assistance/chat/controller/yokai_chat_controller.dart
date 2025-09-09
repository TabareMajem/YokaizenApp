/// yokai_chat_controller.dart

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yokai_quiz_app/api/local_storage.dart';
import 'package:yokai_quiz_app/api/node_database.dart';
import 'package:yokai_quiz_app/global.dart';
import 'package:yokai_quiz_app/main.dart';
// import 'package:yokai_quiz_app/models/chat/message_send_model.dart';
import 'package:yokai_quiz_app/screens/Authentication/controller/auth_screen_controller.dart';
import 'package:yokai_quiz_app/screens/Authentication/login_screen.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:http_parser/http_parser.dart';
import 'package:yokai_quiz_app/util/constants.dart';

import '../../../../models/chat/chat_model.dart';
import '../model/message_send_res.dart';

class YokaiChatController extends GetxController {
  static RxBool isLoading = false.obs;
  static List<Messages> messageList = [];
  AudioPlayer audioPLayer = AudioPlayer();
  String? latestVideoUrl;
  static RxString? currentVideoUrl = RxString('');

  static Future<bool> getChatMessage({BuildContext? context}) async {
    final headers = {
      // "Content-Type": "application/json",
      "Authorization":
          "Bearer ${prefs.getString(LocalStorage.tokenNode).toString()}"
    };

    print("Get Message");
    final String url =
        '${NodeDatabaseApi.getChatMessage}${prefs.getString(LocalStorage.idNode).toString()}/chats';
    customPrint("Send Message Url  :: $url");

    try {
      return await http
          .get(
        Uri.parse(url),
        headers: headers,
      )
          .then((value) async {
        print("Get Message :: ${value.body}");
        final jsonData = jsonDecode(value.body);
        if (jsonData["success"].toString() != "true") {
          if (jsonData["message"] == "Unauthorized - Invalid token") {
            showErrorMessage(
                "Your Login is expired please login again".tr, colorError);
            AuthScreenController.signOutWithFirebase().then(
              (value) {
                if (value) {
                  prefs.clear();
                  navigator?.pushAndRemoveUntil(MaterialPageRoute(
                    builder: (context) {
                      return LoginScreen();
                    },
                  ), (route) => false);
                } else {
                  return;
                }
              },
            );
          }
          return false;
        }
        ChatRes response = ChatRes.fromJson(jsonData);
        if (response.sessionData!.messages!.isNotEmpty) {
          messageList = response.sessionData!.messages!.reversed.toList();
        }
        return true;
      });
    } on Exception catch (e) {
      print("Send Message:: $e");
      // showSnackbar("Some unknown error has occur, try again after some time!", colorError);
      return false;
    }
  }

  // static Future<bool> sendMessage(
  //     {BuildContext? context, String? message}) async {
  //   final headers = {
  //     "Content-Type": "application/json",
  //     "Authorization": "Bearer ${prefs.getString(LocalStorage.tokenNode).toString()}",
  //   };
  //
  //   customPrint("sendMessage got invoked headers : $headers");
  //
  //   final String url = NodeDatabaseApi.sendMessage;
  //   customPrint("sendMessage Url :: $url selectedYokai : ${constants.selectedYokai}");
  //   String selectedYokai = "";
  //   if(constants.selectedYokai == "tanuki") {
  //     selectedYokai = "TANUKI";
  //   } else if(constants.selectedYokai == "water") {
  //     selectedYokai = "WATER_SPIRIT";
  //   } else if(constants.selectedYokai == "purple") {
  //     selectedYokai = "COMFORT_CHARACTER";
  //   } if(constants.selectedYokai == "spirit") {
  //     selectedYokai = "FOREST_SPIRIT";
  //   }
  //
  //   customPrint("sendMessage yokai selected : $selectedYokai");
  //
  //   var payload = {
  //     "message": message,
  //     "selectedYokai" : selectedYokai,
  //   };
  //   customPrint("sendMessage payload : $payload");
  //   try {
  //     return await http
  //         .post(
  //       Uri.parse(url),
  //       body: jsonEncode(payload),
  //       headers: headers,
  //     )
  //         .then((value) async {
  //       print("send Message :: ${value.body}");
  //       final jsonData = jsonDecode(value.body);
  //       if (jsonData["success"].toString() != "true") {
  //         if (jsonData["message"] == "Unauthorized - Invalid token") {
  //           showErrorMessage(
  //               "Your Login is expired please login again".tr, colorError);
  //           AuthScreenController.signOutWithFirebase().then(
  //             (value) {
  //               if (value) {
  //                 prefs.clear();
  //                 navigator?.pushAndRemoveUntil(MaterialPageRoute(
  //                   builder: (context) {
  //                     return LoginScreen();
  //                   },
  //                 ), (route) => false);
  //               } else {
  //                 return;
  //               }
  //             },
  //           );
  //         }
  //         return false;
  //       }
  //       MessageSendRes response = MessageSendRes.fromJson(jsonData);
  //       YokaiChatController.messageList[0].isMessageSend = false;
  //       YokaiChatController.messageList.insert(
  //           0,
  //           Messages(
  //               role: "yokai",
  //               content: response.response,
  //               messageId: YokaiChatController.messageList.length + 1,
  //               sentAt: DateTime.now().toString(),
  //               isProcessed: false));
  //       YokaiChatController.messageList[0].role = "yokai";
  //       YokaiChatController.messageList[0].content = response.response;
  //       YokaiChatController.messageList[0].messageId =
  //           (YokaiChatController.messageList.length + 1).toString();
  //       YokaiChatController.messageList[0].sentAt = DateTime.now().toString();
  //       YokaiChatController.messageList[0].isMessageSend = false;
  //       return true;
  //     });
  //   } on Exception catch (e) {
  //     print("Send Message:: $e");
  //     // showSnackbar("Some unknown error has occur, try again after some time!", colorError);
  //     return false;
  //   }
  // }


  static Future<dynamic> sendMessage({BuildContext? context, String? message}) async {
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${prefs.getString(LocalStorage.tokenNode).toString()}",
    };

    customPrint("sendMessage got invoked headers : $headers");

    final String url = NodeDatabaseApi.sendMessage;
    customPrint("sendMessage Url :: $url selectedYokai : ${constants.selectedYokai}");
    String selectedYokai = "";
    if(constants.selectedYokai == "tanuki") {
      selectedYokai = "TANUKI";
    } else if(constants.selectedYokai == "water") {
      selectedYokai = "WATER_SPIRIT";
    } else if(constants.selectedYokai == "purple") {
      selectedYokai = "COMFORT_CHARACTER";
    } if(constants.selectedYokai == "spirit") {
      selectedYokai = "FOREST_SPIRIT";
    }

    customPrint("sendMessage yokai selected : $selectedYokai");

    var payload = {
      "message": message,
      "selectedYokai" : selectedYokai,
    };
    customPrint("sendMessage payload : $payload");
    try {
      return await http
          .post(
        Uri.parse(url),
        body: jsonEncode(payload),
        headers: headers,
      )
          .then((value) async {
        print("send Message :: ${value.body}");
        final jsonData = jsonDecode(value.body);
        if (jsonData["success"].toString() != "true") {
          if (jsonData["message"] == "Unauthorized - Invalid token") {
            showErrorMessage(
                "Your Login is expired please login again".tr, colorError);
            AuthScreenController.signOutWithFirebase().then(
                  (value) {
                if (value) {
                  prefs.clear();
                  navigator?.pushAndRemoveUntil(MaterialPageRoute(
                    builder: (context) {
                      return LoginScreen();
                    },
                  ), (route) => false);
                } else {
                  return;
                }
              },
            );
          }
          return false;
        }

        // Store the response for returning later
        dynamic responseData = jsonData;

        // Parse response
        MessageSendRes response = MessageSendRes.fromJson(jsonData);

        // Check if there's a video URL in the response
        if (response.video != null && response.video!.url.isNotEmpty) {
          currentVideoUrl?.value = response.video!.url;
        }

        // Update the message list
        YokaiChatController.messageList[0].isMessageSend = false;
        YokaiChatController.messageList.insert(
            0,
            Messages(
                role: "yokai",
                content: response.response,
                messageId: YokaiChatController.messageList.length + 1,
                sentAt: DateTime.now().toString(),
                // videoUrl: response.video?.url,
                isProcessed: false));

        YokaiChatController.messageList[0].role = "yokai";
        YokaiChatController.messageList[0].content = response.response;
        YokaiChatController.messageList[0].messageId =
            (YokaiChatController.messageList.length + 1).toString();
        YokaiChatController.messageList[0].sentAt = DateTime.now().toString();
        YokaiChatController.messageList[0].isMessageSend = false;

        // Return the full response data so the UI can extract the video URL
        return responseData;
      });
    } on Exception catch (e) {
      print("Send Message:: $e");
      return false;
    }
  }

  static Future<File?> sendVoice({BuildContext? context, XFile? audio, String? voice}) async {
    try {
      if (!await audio!.path.isNotEmpty) return null;
      XFile audioToSend = audio;

      String finalUrl = "${NodeDatabaseApi.voiceToVoice}?voice=$voice";

      String selectedYokai = "";
      if(constants.selectedYokai == "tanuki") {
        selectedYokai = "TANUKI";
      } else if(constants.selectedYokai == "water") {
        selectedYokai = "WATER_SPIRIT";
      } else if(constants.selectedYokai == "purple") {
        selectedYokai = "COMFORT_CHARACTER";
      } if(constants.selectedYokai == "spirit") {
        selectedYokai = "FOREST_SPIRIT";
      }

      customPrint("sendVoice finalUrl :: $finalUrl yokai selected : $selectedYokai");

      var request = http.MultipartRequest(
          'POST',
          Uri.parse(finalUrl)
      );

      request.headers.addAll({
        "Authorization": "Bearer ${prefs.getString(LocalStorage.tokenNode)}",
      });

      request.fields['selectedYokai'] = selectedYokai;

      request.files.add(await http.MultipartFile.fromPath(
        'audio', audioToSend.path,
        contentType: MediaType('audio', 'x-m4a'),
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      customPrint('sendVoice response received response statusCode: ${response.statusCode}');
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final tempPath = '${tempDir.path}/response_${DateTime.now().millisecondsSinceEpoch}.mp3';
        final audioFile = File(tempPath);
        await audioFile.writeAsBytes(response.bodyBytes);
        return audioFile;
      }
      return null;
    } catch (e, s) {
      customPrint("SendVoice error: $e\n$s");
      return null;
    }
  }

  void handleApiResponse(Map<String, dynamic> response) {
    if (response['video'] != null && response['video']['url'] != null) {
      latestVideoUrl = response['video']['url'];
      update();
    }
  }
}
