import 'dart:async';
import 'dart:convert';
import 'dart:developer' as d;
import 'dart:math';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:yokai_quiz_app/util/const.dart';

import '../../../Widgets/progressHud.dart';
import '../../../api/database_api.dart';
import '../../../global.dart';
import '../../../util/colors.dart';
import '../controller/chat_controller.dart';
import 'package:get/get.dart';

class MessagingPage extends StatefulWidget {
  final String? groupId;
  String name;
  String image;
  String characterId;

  MessagingPage(
      {super.key,
      this.groupId,
      required this.name,
      required this.image,
      required this.characterId});

  @override
  State<MessagingPage> createState() => _MessagingPageState();
}

class Message {
  final String text;
  final bool isMe;
  final DateTime timestamp;
  bool isStarred;
  final String senderName;

  Message({
    required this.text,
    required this.isMe,
    required this.timestamp,
    this.senderName = 'Sender',
    this.isStarred = false,
  });
}

class _MessagingPageState extends State<MessagingPage> {
  static RxInt chatPage = 1.obs;
  @override
  void initState() {
    super.initState();
    confirmed = false;
    ChatController.isLoading(true);
    chatPage(1);
    ChatController.isChatAnimation(false);
    fetchData();
  }

  fetchData() async {
    await ChatController.getChatFromApi(
            widget.characterId, chatPage.value.toString())
        .then(
      (value) async {
        ChatController.messages.clear();
        await loadConversationHistory().then(
          (value) async {
            ChatController.isLoading(false);
            await sendSummeryToApi().then(
              (value) {
                setState(() {});
              },
            );
          },
        );
        ChatController.scrollController
            .addListener(ChatController.scrollListener);
      },
    );
  }

  @override
  void dispose() {
    ChatController.timer?.cancel();
    super.dispose();
  }

  ///save to local storage
  // Future<void> storeConversationHistory(List<Map<String, dynamic>> conversationHistoryList) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setString('conversation_history', jsonEncode(conversationHistoryList));
  //   customPrint("Stored conversation_history: ${prefs.getString('conversation_history')}");
  // }
  Future<void> loadConversationHistory() async {
    try {
      ///local storage get data comment
      //   final prefs = await SharedPreferences.getInstance();
      //   customPrint(
      //       "Loading conversation_history: ${prefs.getString('conversation_history')}");
      //   String? jsonString = prefs.getString('conversation_history');
      //   if (jsonString != null && jsonString.isNotEmpty) {
      //     List<dynamic> jsonList = jsonDecode(jsonString);
      //     List<Map<String, dynamic>> loadedHistory =
      //         List<Map<String, dynamic>>.from(jsonList);
      //     customPrint("Loaded history: $loadedHistory");
      //     setState(() {
      //       conversationHistoryList
      //           .clear(); // Clear the current conversation history
      //       conversationHistoryList.addAll(loadedHistory);
      //       ChatController.messages.clear(); // Clear current messages
      //
      //       // Add messages in reverse order to maintain chronological order
      //       ///
      //       // for (var message in loadedHistory.reversed) {
      //       //   ChatController.messages.add(
      //       //     Message(
      //       //       text: message['content'],
      //       //       isMe: message['role'] == 'user',
      //       //       timestamp: DateTime.parse(message['timestamp']),
      //       //       // Adjust parsing based on your stored format
      //       //       senderName: message['role'] == 'user' ? 'You' : widget.name,
      //       //     ),
      //       //   );
      //       // }
      //     });
      //   } else {
      //     customPrint("No conversation history found.");
      //   }
      ///
      for (var message in ChatController.getChatFromApiModel.value.data!) {
        ChatController.messages.add(
          Message(
            text: (message.question != null)
                ? message.question.toString()
                : message.answer.toString(),
            isMe: message.question != null,
            timestamp: DateTime.parse(message.createdAt.toString()),
            // Adjust parsing based on your stored format
            senderName: message.question != null ? 'You' : widget.name,
          ),
        );

        ///for send to api to know past conversion from past chat list
        // conversationHistoryList.add({
        //   "role": (message.question != null) ? "user" : "assistant",
        //   "content": (message.question != null)
        //       ? message.question.toString()
        //       : message.answer.toString(),
        //   'timestamp': DateTime.parse(message.createdAt.toString())
        // });
      }
    } catch (e) {
      customPrint("Error loading conversation history: $e");
    }
  }

  FocusNode textFieldFocusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return ProgressHUD(
        isLoading: ChatController.isLoading.value,
        child: WillPopScope(
          onWillPop: () async {
            // ChatController.isLoading(true);
            // sendMsgForSummery().then(
            //   (value) {
            //     ChatController.messages.clear();
            //     ChatController.isLoading(false);
            //     Get.back();
            //   },
            // );
            // return true;
            ChatController.isLoading(true);
            try {
              await generateSummary();
              ChatController.messages.clear();
              ChatController.isLoading(false);
              Get.back();
              if (textFieldFocusNode.hasFocus) {
                textFieldFocusNode.unfocus();
                return false;
              }
              return true; // Ensure a boolean value is always returned
            } catch (e) {
              ChatController.isLoading(false);
              return false; // Return false in case of an error to prevent popping
            }
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(70.0),
              child: AppBar(
                backgroundColor: indigo100,
                automaticallyImplyLeading: false,
                title: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          ChatController.isLoading(true);
                          await generateSummary().then(
                            (value) {
                              ChatController.isLoading(false);
                              ChatController.messages.clear();
                              Get.back();
                            },
                          );
                          // Get.back();
                        },
                        child: SvgPicture.asset(
                          'icons/arrowLeft.svg',
                          height: 35,
                          width: 35,
                        ),
                      ),
                      const SizedBox(width: 20),
                      InkWell(
                        onTap: () {
                          // nextPage(const CharacterUnlockPage());
                        },
                        // child: CircleAvatar(
                        //   backgroundColor: primaryColorLite,
                        //   backgroundImage: AssetImage('${widget.image}.png'),
                        // ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(35),
                          // half of the height/width
                          child: CachedNetworkImage(
                            imageUrl:
                                "${DatabaseApi.mainUrlImage}${widget.image}",
                            placeholder: (context, url) => const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(),
                              ],
                            ),
                            errorWidget: (context, url, error) => Container(
                              decoration:
                                  const BoxDecoration(color: AppColors.red),
                              child: const Icon(
                                Icons.error_outline,
                                color: AppColors.black,
                              ),
                            ),
                            height: 45,
                            width: 45,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.name,
                              style: const TextStyle(
                                color: coral500,
                                fontSize: 16,
                                fontFamily: 'Open Sans',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus(); // Close the keyboard
              },
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: RefreshIndicator(
                        onRefresh: () async {
                          await ChatController.getChatFromApi(
                                  widget.characterId,
                                  (chatPage.value + 1).toString())
                              .then((value) {
                            if (ChatController
                                .getChatFromApiModel.value.data!.isEmpty) {
                              chatPage(chatPage.value);
                            } else {
                              chatPage(chatPage.value + 1);
                            }
                            loadConversationHistory().then(
                              (value) {
                                setState(() {});
                              },
                            );
                            ChatController.scrollController
                                .addListener(ChatController.scrollListener);
                          });
                        },
                        child: _buildMessageListView()),
                  ),
                  if (isTyping) // typing...
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: TypingIndicator(
                        showIndicator: isTyping,
                      ),
                    ),
                  1.ph,
                  const Divider(
                    height: 5.0,
                    color: primaryColor,
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 25),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: primaryColor),
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                              ),
                              height: MediaQuery.of(context).size.height / 16,
                              // width: MediaQuery.of(context).size.width / 1.23,
                              child: Row(
                                children: [
                                  // IconButton(
                                  //   icon: const Icon(Icons.insert_emoticon),
                                  //   onPressed: () {},
                                  // ),
                                  const SizedBox(
                                    width: 25,
                                  ),
                                  Expanded(
                                    child: Scrollbar(
                                      radius: const Radius.circular(8),
                                      child: TextFormField(
                                        focusNode: textFieldFocusNode,
                                        controller: ChatController
                                            .textEditingController,
                                        minLines: 1,
                                        maxLines: 10,
                                        cursorColor: primaryColor,
                                        decoration: InputDecoration(
                                          hintText: 'Message'.tr,
                                          fillColor: Colors.blue,
                                          border: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          disabledBorder: InputBorder.none,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 10),
                                        ),
                                      ),
                                      // TextFormField(
                                      //   // keyboardType: TextInputType.,
                                      //   controller:
                                      //       ChatController.textEditingController,
                                      //   minLines: 1,
                                      //   maxLines: 10,
                                      //   // cursorColor: const Color(0xFFFDFFFF),
                                      //   cursorColor: primaryColor,
                                      //   decoration: const InputDecoration(
                                      //     hintText: 'Message',
                                      //     fillColor: Colors.blue,
                                      //     border: InputBorder.none,
                                      //     focusedBorder: InputBorder.none,
                                      //     enabledBorder: InputBorder.none,
                                      //     errorBorder: InputBorder.none,
                                      //     disabledBorder: InputBorder.none,
                                      //     contentPadding:
                                      //         EdgeInsets.symmetric(vertical: 10),
                                      //   ),
                                      // ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 3,
                          ),
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                if (ChatController
                                    .textEditingController.text.isNotEmpty) {
                                  customPrint(
                                      "textEditingController :: ${ChatController.textEditingController.text}");
                                  isTyping = true;
                                  ChatController.isChatAnimation(true);
                                  // onSendMessage();
                                  final body = {
                                    "character_id": widget.characterId,
                                    "question": ChatController
                                        .textEditingController.text,
                                  };
                                  ChatController.sendChatToApi(context, body)
                                      .then(
                                    (value) {},
                                  );
                                  sendMsg();
                                }
                              },
                              // child: Icon(Icons.send),
                              child: SvgPicture.asset(
                                'icons/send_button.svg',
                                height: MediaQuery.of(context).size.height / 16,
                              ),
                            ),
                          ),
                        ],
                      )),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  bool isTyping = false;
  String conversationHistory = '';

  List<Map<String, dynamic>> conversationHistoryList = [];

  ///auto fetch data from api to openai
  // void sendMsg() async {
  //   String text = ChatController.textEditingController.text;
  //   ChatController.textEditingController.clear();
  //
  //   try {
  //     if (text.isNotEmpty) {
  //       // Add the user's message to the chat and update the UI
  //       Message message = Message(
  //         text: text,
  //         senderName: widget.name,
  //         isMe: true,
  //         timestamp: DateTime.now(),
  //       );
  //       setState(() {
  //         ChatController.messages.insert(0, message);
  //         conversationHistoryList.add({
  //           "role": "user",
  //           "content": text,
  //           'timestamp': DateTime.now().toIso8601String(),
  //           // Convert DateTime to String
  //         });
  //         isTyping = true;
  //         customPrint("conversationHistoryList :: ${conversationHistoryList}");
  //       });
  //
  //       // Prepare the request body
  //       var requestBody = jsonEncode({
  //         "model": "gpt-4-turbo",
  //         "messages": conversationHistoryList.map((message) {
  //           // Ensure all DateTime objects are properly converted
  //           return {
  //             "role": message["role"],
  //             "content": message["content"],
  //             'timestamp': (message['timestamp'] is DateTime)
  //                 ? message['timestamp'].toIso8601String()
  //                 : message['timestamp'],
  //           };
  //         }).toList(),
  //       });
  //
  //       d.log("Request Body: $requestBody");
  //
  //       // Send the POST request to OpenAI's API
  //       var response = await http.post(
  //         Uri.parse("https://api.openai.com/v1/chat/completions"),
  //         headers: {
  //           "Authorization": "Bearer $apiKey",
  //           "Content-Type": "application/json"
  //         },
  //         body: requestBody,
  //       );
  //
  //       // Check if the response is successful
  //       if (response.statusCode == 200) {
  //         var json = jsonDecode(response.body);
  //         setState(() {
  //           isTyping = false;
  //
  //           // Extract and display the AI's response
  //           String textToCheck =
  //               json["choices"][0]["message"]["content"].toString().trimLeft();
  //           if (textToCheck.contains("Assistant")) {
  //             textToCheck =
  //                 textToCheck.replaceAll("Assistant", "${widget.name}");
  //           }
  //           ChatController.messages.insert(
  //             0,
  //             Message(
  //               text: textToCheck.toString().trimLeft(),
  //               isMe: false,
  //               senderName: widget.name,
  //               timestamp: DateTime.now(),
  //             ),
  //           );
  //
  //           // Add the AI's response to the conversation history
  //           conversationHistoryList.add({
  //             "role": "assistant",
  //             "content": json["choices"][0]["message"]["content"],
  //             'timestamp': DateTime.now().toIso8601String(),
  //             // Convert DateTime to String
  //           });
  //
  //           // Optionally send the chat to another API or service
  //           final body = {
  //             "character_id": widget.characterId,
  //             "answer": json["choices"][0]["message"]["content"]
  //           };
  //           ChatController.sendChatToApi(context, body).then(
  //             (value) {},
  //           );
  //         });
  //
  //         // Store the updated conversation history locally
  //         // await storeConversationHistory(conversationHistoryList);
  //       } else {
  //         d.log("Failed with status code: ${response.statusCode}");
  //         d.log("Response body: ${response.body}");
  //       }
  //     }
  //   } on Exception catch (e) {
  //     d.log("Error sending message: $e");
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Some error occurred, please try again!")),
  //     );
  //   }
  // }

  void sendMsg() async {
    String text = ChatController.textEditingController.text;
    String apiKey = dotenv.env['OPENAI_API_KEY']!;
    ChatController.textEditingController.clear();

    try {
      if (text.isNotEmpty) {
        // Add the user's message to the chat and update the UI
        Message message = Message(
          text: text,
          senderName: widget.name,
          isMe: true,
          timestamp: DateTime.now(),
        );
        setState(() {
          ChatController.messages.insert(0, message);
          conversationHistoryList.add({
            "role": "user",
            "content": text,
            'timestamp': DateTime.now().toIso8601String(),
          });
          isTyping = true;
          customPrint("conversationHistoryList :: ${conversationHistoryList}");
        });

        // Define the prompt
        String prompt =
            ChatController.getChatFromApiModel.value.prompt.toString().trim();

        // Print the prompt for debugging
        d.log("Prompt: $prompt");

        // Prepare the request body
        var requestBody = jsonEncode({
          "model": "gpt-4-turbo",
          "messages": [
            {
              "role": "system",
              "content": prompt,
            },
            ...conversationHistoryList.map((message) {
              return {
                "role": message["role"],
                "content": message["content"],
                'timestamp': (message['timestamp'] is DateTime)
                    ? message['timestamp'].toIso8601String()
                    : message['timestamp'],
              };
            }).toList(),
          ],
        });

        d.log("Request Body: $requestBody");

        // Send the POST request to OpenAI's API
        var response = await http.post(
          Uri.parse("https://api.openai.com/v1/chat/completions"),
          headers: {
            "Authorization": "Bearer $apiKey",
            "Content-Type": "application/json"
          },
          body: requestBody,
        );

        // Check if the response is successful
        if (response.statusCode == 200) {
          var json = jsonDecode(response.body);
          setState(() {
            isTyping = false;

            // Encode the text
            // List<int> encodedText = utf8.encode(json["choices"][0]["message"]["content"].toString().trimLeft());
            // // Decode the text
            // String textToCheck = utf8.decode(encodedText);
            String textToCheck = utf8.decode(json["choices"][0]["message"]
                    ["content"]
                .toString()
                .trimLeft()
                .codeUnits);

            // Extract and display the AI's response
            if (textToCheck.contains("Assistant")) {
              textToCheck =
                  textToCheck.replaceAll("Assistant", "${widget.name}");
            }
            customPrint("textToCheck :: $textToCheck");

            ChatController.messages.insert(
              0,
              Message(
                text: textToCheck.toString().trimLeft(),
                isMe: false,
                senderName: widget.name,
                timestamp: DateTime.now(),
              ),
            );

            // Add the AI's response to the conversation history
            conversationHistoryList.add({
              "role": "assistant",
              "content": textToCheck,
              'timestamp': DateTime.now().toIso8601String(),
            });

            // Optionally send the chat to another API or service
            final body = {
              "character_id": widget.characterId,
              "answer": textToCheck
            };
            ChatController.sendChatToApi(context, body).then(
              (value) {},
            );
          });
        } else {
          d.log("Failed with status code: ${response.statusCode}");
          d.log("Response body: ${response.body}");
        }
      }
    } on Exception catch (e) {
      d.log("Error sending message: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Some error occurred, please try again!".tr)),
      );
    }
  }

  ///
  // void sendMsg() async {
  //   String text = ChatController.textEditingController.text;
  //   ChatController.textEditingController.clear();
  //
  //   try {
  //     if (text.isNotEmpty) {
  //       Message message = Message(
  //         text: text,
  //         senderName: widget.name,
  //         isMe: true,
  //         timestamp: DateTime.now(),
  //       );
  //       setState(() {
  //         ChatController.messages.insert(0, message);
  //         conversationHistoryList.add({
  //           "role": "user",
  //           "content": text,
  //           'timestamp': DateTime.now().toIso8601String()
  //         });
  //         isTyping = true;
  //         customPrint("conversationHistoryList :: ${conversationHistoryList}");
  //       });
  //       var response = await http.post(
  //         Uri.parse("https://api.openai.com/v1/chat/completions"),
  //         headers: {
  //           "Authorization": "Bearer $apiKey",
  //           "Content-Type": "application/json"
  //         },
  //         body: jsonEncode({
  //           "model": "gpt-4-turbo",
  //           "messages": [
  //             {
  //               /// Supported values are: 'system', 'assistant', 'user', 'function', and 'tool'.
  //               "role": "assistant",
  //               "content":
  //                   "${ChatController.getChatFromApiModel.value.prompt.toString()}"
  //             },
  //             ...conversationHistoryList,
  //           ],
  //         }),
  //       );
  //       d.log(response.body);
  //       if (response.statusCode == 200) {
  //         var json = jsonDecode(response.body);
  //         setState(() {
  //           isTyping = false;
  //           customPrint(
  //               'AI Ans :: ${json["choices"][0]["message"]["content"]}');
  //           String textToCheck =
  //               json["choices"][0]["message"]["content"].toString().trimLeft();
  //           if (textToCheck.contains("Assistant")) {
  //             textToCheck =
  //                 textToCheck.replaceAll("Assistant", "${widget.name}");
  //           }
  //           ChatController.messages.insert(
  //               0,
  //               Message(
  //                   text: textToCheck.toString().trimLeft(),
  //                   isMe: false,
  //                   senderName: widget.name,
  //                   timestamp: DateTime.now()));
  //           conversationHistoryList.add({
  //             "role": "assistant",
  //             "content": json["choices"][0]["message"]["content"],
  //             'timestamp': DateTime.now().toIso8601String()
  //           });
  //           final body = {
  //             "character_id": widget.characterId,
  //             "answer": json["choices"][0]["message"]["content"]
  //           };
  //           ChatController.sendChatToApi(context, body).then(
  //             (value) {},
  //           );
  //         });
  //         // await storeConversationHistory(conversationHistoryList);
  //       }
  //     }
  //   } on Exception {
  //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
  //         content: Text("Some error occurred, please try again!")));
  //   }
  // }
  ///

  Future generateSummary() async {
    String apiKey = dotenv.env['OPENAI_API_KEY']!;
    List<Map<String, dynamic>> conversationHistoryListNew = [];

    for (var entry in conversationHistoryList) {
      conversationHistoryListNew.add(Map<String, dynamic>.from(entry));
    }

    try {
      if (conversationHistoryList.isNotEmpty) {
        setState(() {
          conversationHistoryListNew.add({
            "role": "user",
            "content":
                "Please provide a concise and specific summary of the main points and topics discussed in our previous conversation. Focus only on the key information without offering any additional help or asking questions.",
          });
          customPrint(
              "conversationHistoryListNew :: ${conversationHistoryListNew}");
        });

        var response = await http
            .post(
          Uri.parse("https://api.openai.com/v1/chat/completions"),
          headers: {
            "Authorization": "Bearer $apiKey",
            "Content-Type": "application/json"
          },
          body: jsonEncode({
            "model": "gpt-4-turbo",
            "messages": [
              {
                "role": "assistant",
                "content":
                    "${ChatController.getChatFromApiModel.value.prompt.toString()}"
              },
              ...conversationHistoryList,
            ],
          }),
        )
            .then(
          (value) {
            if (value.statusCode == 200) {
              var json = jsonDecode(value.body);
              setState(() {
                customPrint(
                    'AI Ans summary :: ${json["choices"][0]["message"]["content"]}');
                String textToCheck = json["choices"][0]["message"]["content"]
                    .toString()
                    .trimLeft();
                if (textToCheck.contains("Assistant")) {
                  textToCheck =
                      textToCheck.replaceAll("Assistant", "${widget.name}");
                }
                final body = {
                  "character_id": ChatController
                      .getChatFromApiModel.value.characterId
                      .toString(),
                  "summary": json["choices"][0]["message"]["content"]
                };
                ChatController.updateCharacterSummary(context, body).then(
                  (value) {},
                );
              });
            }
            return true;
          },
        );
      }
    } on Exception {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Some error occurred, please try again!".tr)));
      return false;
    }
  }

  ///
//   Future<void> sendSummeryToApi() async {
//
//     ///
//     // String summaryParagraph =
//     //     ChatController.getChatFromApiModel.value.summary.toString();
//     // String followUpQuestion =
//     //     "Based on this summary, can you provide additional insights or continue the conversation?";
//     String summaryParagraph =
//         ChatController.getChatFromApiModel.value.summary.toString().trim();
//     String followUpQuestion = """
// Here is a summary of our previous conversation:
// $summaryParagraph
//
// Based on this summary, please:
// 1. Continue the conversation by responding to any open topics or questions.
// 2. Provide additional insights or elaborate on any points mentioned in the summary.
// 3. If applicable, ask follow-up questions to clarify or expand on the summary provided.
// 4. Start the conversation with a brief opener, no more than 10 words, that directly references the main topics from the summary.
//
// Please make sure your response is relevant to the points summarized.and send conversational opener
// """;
// customPrint("summary from api :: ${ChatController.getChatFromApiModel.value.summary.toString().trim()}");
//     ///
//     List<Map<String, dynamic>> conversationHistoryListNew =
//         List.from(conversationHistoryList);
//     conversationHistoryListNew.add({
//       "role": "user",
//       "content": summaryParagraph,
//     });
//     conversationHistoryListNew.add({
//       "role": "user",
//       "content": followUpQuestion,
//     });
//     customPrint(
//         "conversationHistoryListNew :: ${conversationHistoryListNew}");
//     try {
//       // Send the updated conversation history to the OpenAI API
//       var responseNew = await http.post(
//         Uri.parse("https://api.openai.com/v1/chat/completions"),
//         headers: {
//           "Authorization": "Bearer $apiKey",
//           "Content-Type": "application/json",
//         },
//         body: jsonEncode({
//           "model": "gpt-4-turbo",
//           "messages": conversationHistoryListNew,
//         }),
//       );
//
//       if (responseNew.statusCode == 200) {
//         ChatController.isChatAnimation(true);
//         var jsonNew = jsonDecode(responseNew.body);
//         setState(() {
//           // Handle the AI response and update the UI
//           customPrint(
//               'AI Answer opener :: ${jsonNew["choices"][0]["message"]["content"]}');
//           String textToCheckNew =
//               jsonNew["choices"][0]["message"]["content"].toString().trimLeft();
//           if (textToCheckNew.contains("Assistant")) {
//             textToCheckNew =
//                 textToCheckNew.replaceAll("Assistant", "${widget.name}");
//           }
//           customPrint('AI Answer opener :: ${textToCheckNew}');
//           ChatController.messages.insert(
//             0,
//             Message(
//               text: jsonNew["choices"][0]["message"]["content"]
//                   .toString()
//                   .trimLeft(),
//               isMe: false,
//               senderName: widget.name,
//               timestamp: DateTime.now(),
//             ),
//           );
//           conversationHistoryList.add({
//             "role": "assistant",
//             "content": jsonNew["choices"][0]["message"]["content"]
//                 .toString()
//                 .trimLeft(),
//             'timestamp': DateTime.now().toIso8601String(),
//             // Convert DateTime to String
//           });
//           // Optionally send the chat to another API or service
//           final body = {
//             "character_id": widget.characterId,
//             "answer": jsonNew["choices"][0]["message"]["content"]
//                 .toString()
//                 .trimLeft()
//           };
//           ChatController.sendChatToApi(context, body).then(
//             (value) {},
//           );
//         });
//       } else {
//         customPrint('Error: ${responseNew.statusCode}');
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Some error occurred, please try again!")),
//       );
//     } finally {
//       setState(() {
//         isTyping =
//             false; // Ensure isTyping is set to false even if an error occurs
//       });
//     }
//   }
  Future<void> sendSummeryToApi() async {
    String apiKey = dotenv.env['OPENAI_API_KEY']!;

    // Fetch the summary from the ChatController
    String summaryParagraph =
        ChatController.getChatFromApiModel.value.summary.toString().trim();

    // Fetch the prompt from the ChatController
    String prompt =
        ChatController.getChatFromApiModel.value.prompt.toString().trim();

    String followUpQuestion;

    if (summaryParagraph.isEmpty || summaryParagraph == "null") {
      // Extract relevant information from the prompt to mention who the assistant is
      String assistantIntroduction =
          "I am here to assist you on the topic of $prompt.";

      // Mention the assistant's name and ensure it starts with an introduction
      followUpQuestion = """
This is our first conversation. My name is [Your Assistant's Name]. $assistantIntroduction

Start the conversation with a brief opener, no more than 10 words, that directly references the topic.
""";
    } else {
      // If summary is available, continue with the regular follow-up question
      followUpQuestion = """
Here is a summary of our previous conversation:
$summaryParagraph

Based on this summary, please:
1. Continue the conversation by responding to any open topics or questions.
2. Provide additional insights or elaborate on any points mentioned in the summary.
3. If applicable, ask follow-up questions to clarify or expand on the summary provided.
4. Start the conversation with a brief opener, no more than 10 words, that directly references the main topics from the summary.

Please make sure your response is relevant to the points summarized and send a conversational opener.
""";
    }

    // customPrint("Summary from API: $summaryParagraph");

    // Prepare conversation history list
    List<Map<String, dynamic>> conversationHistoryListNew =
        List.from(conversationHistoryList);

    if (summaryParagraph.isNotEmpty) {
      conversationHistoryListNew.add({
        "role": "user",
        "content": summaryParagraph,
      });
    }

    // Add the dynamic follow-up question
    conversationHistoryListNew.add({
      "role": "user",
      "content": followUpQuestion,
    });

    customPrint("conversationHistoryListNew: $conversationHistoryListNew");

    try {
      // Send the updated conversation history to the OpenAI API
      var responseNew = await http.post(
        Uri.parse("https://api.openai.com/v1/chat/completions"),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "gpt-4-turbo",
          "messages": conversationHistoryListNew,
        }),
      );

      if (responseNew.statusCode == 200) {
        ChatController.isChatAnimation(true);
        var jsonNew = jsonDecode(responseNew.body);
        setState(() {
          customPrint(
              'AI Answer opener: ${jsonNew["choices"][0]["message"]["content"]}');

          String textToCheckNew =
              jsonNew["choices"][0]["message"]["content"].toString().trimLeft();

          ChatController.messages.insert(
            0,
            Message(
              text: jsonNew["choices"][0]["message"]["content"]
                  .toString()
                  .trimLeft(),
              isMe: false,
              senderName: widget.name,
              timestamp: DateTime.now(),
            ),
          );

          conversationHistoryList.add({
            "role": "assistant",
            "content": jsonNew["choices"][0]["message"]["content"]
                .toString()
                .trimLeft(),
            'timestamp': DateTime.now().toIso8601String(),
          });

          // Optionally send the chat to another API or service
          final body = {
            "character_id": widget.characterId,
            "answer": jsonNew["choices"][0]["message"]["content"]
                .toString()
                .trimLeft()
          };
          ChatController.sendChatToApi(context, body).then(
            (value) {},
          );
        });
      } else {
        customPrint('Error: ${responseNew.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Some error occurred, please try again!")),
      );
    } finally {
      setState(() {
        isTyping =
            false; // Ensure isTyping is set to false even if an error occurs
      });
    }
  }

  ///

  ///
  bool confirmed = false;

  Widget _buildMessage(Message message, int index, int receiverId) {
    // customPrint('message :: ${jsonDecode(message.isMe.toString())}');

    ///long way to check today condition
    // bool isToday = message.timestamp.toLocal().day == DateTime.now().day &&
    //     message.timestamp.toLocal().month == DateTime.now().month &&
    //     message.timestamp.toLocal().year == DateTime.now().year;
    ///short way to check today condition
    bool isToday =
        message.timestamp.toLocal().difference(DateTime.now()).inDays == 0;

    ///

    /// Check if this is the last message from ChatGPT:-
    bool isLastMessageFromChatGPT = !message.isMe &&
        message.senderName == widget.name &&
        index == 0 &&
        ChatController.isChatAnimation.isTrue &&
        isToday;

    ///
    // Parse the UTC time string into a DateTime object
    DateTime utcDateTime = DateTime.parse(message.timestamp.toString()).toUtc();

    // Convert the DateTime from UTC to local time
    DateTime localDateTime = utcDateTime.toLocal();

    // Format the local DateTime
    String formattedTime = DateFormat('h:mm a').format(localDateTime);

    ///
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: GestureDetector(
          onTap: () {
            setState(() {});
          },
          child: Column(
            crossAxisAlignment: message.isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {},
                      child: Text(
                        message.isMe ? 'You' : message.senderName,
                        style: const TextStyle(
                          color: Color(0xFF345C72),
                          fontSize: 14,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      // DateFormat('h:mm a').format(message.timestamp),
                      formattedTime,
                      style: const TextStyle(
                        color: Color(0xFF667085),
                        fontSize: 12,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                subtitle: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: message.isMe
                        ? const Color(0xFFFEE6D6)
                        : const Color(0xFFF9ECFF),
                    borderRadius: !message.isMe
                        ? const BorderRadius.only(
                            topLeft: Radius.zero,
                            topRight: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          )
                        : const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.zero,
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                  ),
                  child: isLastMessageFromChatGPT
                      ? TypewriterAnimatedTextKit(
                          // onTap: () {
                          //   print("Tap Event");
                          // },
                          speed: Duration(milliseconds: 15),
                          text: [message.text],
                          textStyle: TextStyle(
                            color: Color(0xff131114),
                            fontSize: 14,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.start,
                          isRepeatingAnimation: false,
                          // alignment: AlignmentDirectional.topStart // or Alignment.topLeft
                        )
                      : Text(
                          message.text,
                          style: const TextStyle(
                            color: Color(0xff131114),
                            fontSize: 14,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                ),
                trailing: message.isMe
                    ? null
                    : SizedBox(
                        width: MediaQuery.of(context).size.width / 8,
                      ),
                leading: !message.isMe
                    ? null
                    : SizedBox(
                        width: MediaQuery.of(context).size.width / 8,
                      ),
                horizontalTitleGap: 5,
                selectedTileColor: const Color(0xFF39434B),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageListView() {
    if (ChatController.messages.isEmpty) {
      return const SizedBox.shrink();
    }
    List<Widget> messageListViews = [];
    DateTime currentDate = ChatController.messages.first.timestamp;

    List<Message> currentMessages = [];
    for (Message message in ChatController.messages) {
      if (message.timestamp.day != currentDate.day) {
        messageListViews.insert(
          0,
          _buildMessageList(currentMessages, currentDate),
        );
        currentMessages = [];
        currentDate = message.timestamp;
      }
      currentMessages.add(message);
    }

    if (currentMessages.isNotEmpty) {
      messageListViews.insert(
        0,
        _buildMessageList(currentMessages, currentDate),
      );
    }
    return SingleChildScrollView(
      reverse: true,
      child: Column(
        children: messageListViews,
      ),
    );
  }

  ///new working
  // Widget _buildMessage(
  //     Message message, int index, int receiverId, List<Message> allMessages)
  // {
  //   // Check if the current message is the last message in the list
  //   bool isLastMessage = index == 0;
  //
  //   // Check if the current message is the last OpenAI response
  //   bool isLastMessageFromChatGPT = isLastMessage &&
  //       !message.isMe &&
  //       message.senderName == widget.name &&
  //       ChatController.isChatAnimation.isTrue;
  //
  //   // Parse the UTC time string into a DateTime object
  //   DateTime utcDateTime = DateTime.parse(message.timestamp.toString()).toUtc();
  //
  //   // Convert the DateTime from UTC to local time
  //   DateTime localDateTime = utcDateTime.toLocal();
  //
  //   // Format the local DateTime
  //   String formattedTime = DateFormat('h:mm a').format(localDateTime);
  //
  //   return Container(
  //     margin: const EdgeInsets.symmetric(vertical: 5.0),
  //     child: Padding(
  //       padding: const EdgeInsets.symmetric(horizontal: 10),
  //       child: GestureDetector(
  //         onTap: () {
  //           setState(() {});
  //         },
  //         child: Column(
  //           crossAxisAlignment: message.isMe
  //               ? CrossAxisAlignment.end
  //               : CrossAxisAlignment.start,
  //           children: [
  //             ListTile(
  //               contentPadding:
  //               const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
  //               title: Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   InkWell(
  //                     onTap: () {},
  //                     child: Text(
  //                       message.isMe ? 'You' : message.senderName,
  //                       style: const TextStyle(
  //                         color: Color(0xFF345C72),
  //                         fontSize: 14,
  //                         fontFamily: 'Montserrat',
  //                         fontWeight: FontWeight.w600,
  //                       ),
  //                     ),
  //                   ),
  //                   Text(
  //                     formattedTime,
  //                     style: const TextStyle(
  //                       color: Color(0xFF667085),
  //                       fontSize: 12,
  //                       fontFamily: 'Montserrat',
  //                       fontWeight: FontWeight.w400,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //               subtitle: Container(
  //                 padding: const EdgeInsets.symmetric(
  //                   vertical: 15,
  //                   horizontal: 12,
  //                 ),
  //                 decoration: BoxDecoration(
  //                   color: message.isMe
  //                       ? const Color(0xFFFEE6D6)
  //                       : const Color(0xFFF9ECFF),
  //                   borderRadius: !message.isMe
  //                       ? const BorderRadius.only(
  //                     topLeft: Radius.zero,
  //                     topRight: Radius.circular(8),
  //                     bottomLeft: Radius.circular(8),
  //                     bottomRight: Radius.circular(8),
  //                   )
  //                       : const BorderRadius.only(
  //                     topLeft: Radius.circular(8),
  //                     topRight: Radius.zero,
  //                     bottomLeft: Radius.circular(8),
  //                     bottomRight: Radius.circular(8),
  //                   ),
  //                 ),
  //                 child: isLastMessageFromChatGPT
  //                     ? TypewriterAnimatedTextKit(
  //                   speed: Duration(milliseconds: 30),
  //                   text: [message.text],
  //                   textStyle: TextStyle(
  //                     color: Color(0xff131114),
  //                     fontSize: 14,
  //                     fontFamily: 'Montserrat',
  //                     fontWeight: FontWeight.w400,
  //                   ),
  //                   textAlign: TextAlign.start,
  //                   isRepeatingAnimation: false,
  //                 )
  //                     : Text(
  //                   message.text,
  //                   style: const TextStyle(
  //                     color: Color(0xff131114),
  //                     fontSize: 14,
  //                     fontFamily: 'Montserrat',
  //                     fontWeight: FontWeight.w400,
  //                   ),
  //                 ),
  //               ),
  //               trailing: message.isMe
  //                   ? null
  //                   : SizedBox(
  //                 width: MediaQuery.of(context).size.width / 4,
  //               ),
  //               leading: !message.isMe
  //                   ? null
  //                   : SizedBox(
  //                 width: MediaQuery.of(context).size.width / 4,
  //               ),
  //               horizontalTitleGap: 5,
  //               selectedTileColor: const Color(0xFF39434B),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
  //
  // Widget _buildMessageListView() {
  //   if (ChatController.messages.isEmpty) {
  //     return const SizedBox.shrink();
  //   }
  //   List<Widget> messageListViews = [];
  //   DateTime currentDate = ChatController.messages.first.timestamp;
  //
  //   List<Message> currentMessages = [];
  //   for (Message message in ChatController.messages) {
  //     if (message.timestamp.day != currentDate.day) {
  //       messageListViews.insert(
  //         0,
  //         _buildMessageList(currentMessages, currentDate),
  //       );
  //       currentMessages = [];
  //       currentDate = message.timestamp;
  //     }
  //     currentMessages.add(message);
  //   }
  //
  //   if (currentMessages.isNotEmpty) {
  //     messageListViews.insert(
  //       0,
  //       _buildMessageList(currentMessages, currentDate),
  //     );
  //   }
  //   return SingleChildScrollView(
  //     reverse: true,
  //     child: Column(
  //       children: messageListViews,
  //     ),
  //   );
  // }
  ///
  Widget _buildMessageList(List<Message> messages, DateTime date) {
    String formattedDate = DateFormat('dd-MM-yyyy').format(date);
    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              child: Divider(
                color: primaryColor,
                thickness: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                formattedDate,
                style: const TextStyle(
                  color: headingOrange,
                  fontSize: 12,
                ),
              ),
            ),
            const Expanded(
              child: Divider(
                color: primaryColor,
                thickness: 1,
              ),
            ),
          ],
        ),
        ListView.builder(
          shrinkWrap: true,
          reverse: true,
          controller: ChatController.scrollController,
          // physics: const AlwaysScrollableScrollPhysics(),
          itemCount: messages.length,
          itemBuilder: (BuildContext context, int index) {
            return _buildMessage(messages[index], index, 1);
          },
        ),
      ],
    );
  }
}

///

///

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({
    Key? key,
    this.showIndicator = false,
    this.bubbleColor = const Color(0xFF646b7f),
    this.flashingCircleDarkColor = const Color(0xFF333333),
    this.flashingCircleBrightColor = const Color(0xFFaec1dd),
  }) : super(key: key);

  final bool showIndicator;
  final Color bubbleColor;
  final Color flashingCircleDarkColor;
  final Color flashingCircleBrightColor;

  @override
  _TypingIndicatorState createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _appearanceController;

  late Animation<double> _indicatorSpaceAnimation;

  late Animation<double> _smallBubbleAnimation;
  late Animation<double> _mediumBubbleAnimation;
  late Animation<double> _largeBubbleAnimation;

  late AnimationController _repeatingController;
  final List<Interval> _dotIntervals = const [
    Interval(0.25, 0.8),
    Interval(0.35, 0.9),
    Interval(0.45, 1.0),
  ];

  @override
  void initState() {
    super.initState();

    _appearanceController = AnimationController(
      vsync: this,
    )..addListener(() {
        setState(() {});
      });

    _indicatorSpaceAnimation = CurvedAnimation(
      parent: _appearanceController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      reverseCurve: const Interval(0.0, 1.0, curve: Curves.easeOut),
    ).drive(Tween<double>(
      begin: 0.0,
      end: 60.0,
    ));

    _smallBubbleAnimation = CurvedAnimation(
      parent: _appearanceController,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      reverseCurve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    );
    _mediumBubbleAnimation = CurvedAnimation(
      parent: _appearanceController,
      curve: const Interval(0.2, 0.7, curve: Curves.elasticOut),
      reverseCurve: const Interval(0.2, 0.6, curve: Curves.easeOut),
    );
    _largeBubbleAnimation = CurvedAnimation(
      parent: _appearanceController,
      curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
      reverseCurve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );

    _repeatingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    if (widget.showIndicator) {
      _showIndicator();
    }
  }

  @override
  void didUpdateWidget(TypingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.showIndicator != oldWidget.showIndicator) {
      if (widget.showIndicator) {
        _showIndicator();
      } else {
        _hideIndicator();
      }
    }
  }

  @override
  void dispose() {
    _appearanceController.dispose();
    _repeatingController.dispose();
    super.dispose();
  }

  void _showIndicator() {
    _appearanceController
      ..duration = const Duration(milliseconds: 750)
      ..forward();
    _repeatingController.repeat();
  }

  void _hideIndicator() {
    _appearanceController
      ..duration = const Duration(milliseconds: 150)
      ..reverse();
    _repeatingController.stop();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _indicatorSpaceAnimation,
      builder: (context, child) {
        return SizedBox(
          height: _indicatorSpaceAnimation.value,
          child: child,
        );
      },
      child: Stack(
        children: [
          _buildAnimatedBubble(
            animation: _smallBubbleAnimation,
            left: 8,
            bottom: 8,
            bubble: _buildCircleBubble(6),
          ),
          _buildAnimatedBubble(
            animation: _mediumBubbleAnimation,
            left: 10,
            bottom: 10,
            bubble: _buildCircleBubble(13),
          ),
          _buildAnimatedBubble(
            animation: _largeBubbleAnimation,
            left: 12,
            bottom: 12,
            bubble: _buildStatusBubble(),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBubble({
    required Animation<double> animation,
    required double left,
    required double bottom,
    required Widget bubble,
  }) {
    return Positioned(
      left: left,
      bottom: bottom,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Transform.scale(
            scale: animation.value,
            alignment: Alignment.bottomLeft,
            child: child,
          );
        },
        child: bubble,
      ),
    );
  }

  Widget _buildCircleBubble(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          // color: widget.bubbleColor,
          color: Color(0xFFF9ECFF)),
    );
  }

  Widget _buildStatusBubble() {
    return Container(
      width: 75,
      height: 35,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(27),
        color: Color(0xFFF9ECFF),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFlashingCircle(0),
          _buildFlashingCircle(1),
          _buildFlashingCircle(2),
        ],
      ),
    );
  }

  Widget _buildFlashingCircle(int index) {
    return AnimatedBuilder(
      animation: _repeatingController,
      builder: (context, child) {
        final circleFlashPercent =
            _dotIntervals[index].transform(_repeatingController.value);
        final circleColorPercent = sin(pi * circleFlashPercent);

        return Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color.lerp(widget.flashingCircleDarkColor,
                widget.flashingCircleBrightColor, circleColorPercent),
          ),
        );
      },
    );
  }
}

@immutable
class FakeMessage extends StatelessWidget {
  const FakeMessage({
    Key? key,
    required this.isBig,
  }) : super(key: key);

  final bool isBig;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
      height: isBig ? 128.0 : 36.0,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        color: Colors.grey.shade300,
      ),
    );
  }
}
