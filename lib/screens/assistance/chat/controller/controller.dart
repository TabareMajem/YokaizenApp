import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

import 'package:yokai_quiz_app/api/local_storage.dart';
import 'package:yokai_quiz_app/api/node_database.dart';
import 'package:yokai_quiz_app/global.dart';
import 'package:yokai_quiz_app/main.dart';
import 'package:yokai_quiz_app/models/chat/chat_model.dart';
import 'package:yokai_quiz_app/models/chat/message_send_model.dart';
import 'package:yokai_quiz_app/screens/Authentication/controller/auth_screen_controller.dart';
import 'package:yokai_quiz_app/screens/Authentication/login_screen.dart';
import 'package:yokai_quiz_app/util/colors.dart';

class YokaiChatController {
  static RxBool isLoading = false.obs;
  static List<Messages> messageList = [];

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

  static Future<bool> sendMessage(
      {BuildContext? context, String? message}) async {
    final headers = {
      "Content-Type": "application/json",
      "Authorization":
          "Bearer ${prefs.getString(LocalStorage.tokenNode).toString()}"
    };

    print("sendMessage Message");
    final String url =
        '${NodeDatabaseApi.sendMessage}${prefs.getString(LocalStorage.tokenNode).toString()}';
    customPrint("send Message Url  :: $url");
    var param = {"message": message};
    print(param);
    try {
      return await http
          .post(
        Uri.parse(url),
        body: jsonEncode(param),
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
        MessageSendRes response = MessageSendRes.fromJson(jsonData);
        YokaiChatController.messageList[0].isMessageSend = false;
        YokaiChatController.messageList.insert(
            0,
            Messages(
                role: "yokai",
                content: response.response,
                messageId: YokaiChatController.messageList.length + 1,
                sentAt: DateTime.now().toString(),
                isProcessed: false));
        YokaiChatController.messageList[0].role = "yokai";
        YokaiChatController.messageList[0].content = response.response;
        YokaiChatController.messageList[0].messageId =
            (YokaiChatController.messageList.length + 1).toString();
        YokaiChatController.messageList[0].sentAt = DateTime.now().toString();
        YokaiChatController.messageList[0].isMessageSend = false;
        return true;
      });
    } on Exception catch (e) {
      print("Send Message:: $e");
      // showSnackbar("Some unknown error has occur, try again after some time!", colorError);
      return false;
    }
  }
}
