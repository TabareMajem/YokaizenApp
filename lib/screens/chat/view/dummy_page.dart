import 'dart:convert';

import 'package:chat_bubbles/bubbles/bubble_normal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yokai_quiz_app/Widgets/progressHud.dart';

import '../../../global.dart';
import '../../../util/colors.dart';
import 'character_unlock_page.dart';

class ChatScreen extends StatefulWidget {
  final String? groupId;
  String name;
  String image;
  ChatScreen(
      {super.key, this.groupId, required this.name, required this.image});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController controller = TextEditingController();
  ScrollController scrollController = ScrollController();
  List<Message> msgs = [];
  bool isTyping = false;
  String conversationHistory = '';

  List<Map<String, dynamic>> conversationHistoryList = [];

  void sendMsg() async {
    String text = controller.text;
    String apiKey = dotenv.env['OPENAI_API_KEY']!;
    controller.clear();
    try {
      if (text.isNotEmpty) {
        setState(() {
          msgs.insert(0, Message(true, text));
          isTyping = true;
        });
        scrollController.animateTo(0.0,
            duration: const Duration(seconds: 1), curve: Curves.easeOut);

        // Append the new message to the conversation history list
        conversationHistoryList.add({"role": "user", "content": text});

        // Store the conversation history
        await storeConversationHistory(jsonEncode(conversationHistoryList));

        var response = await http.post(
          Uri.parse("https://api.openai.com/v1/chat/completions"),
          headers: {
            "Authorization": "Bearer $apiKey",
            "Content-Type": "application/json"
          },
          body: jsonEncode({
            "model": "gpt-3.5-turbo",
            "messages": [
              ...conversationHistoryList,
              {"role": "assistant", "content": ""}
            ]
          }),
        );

        if (response.statusCode == 200) {
          var json = jsonDecode(response.body);
          setState(() {
            isTyping = false;
            msgs.insert(
                0,
                Message(
                    false,
                    json["choices"][0]["message"]["content"]
                        .toString()
                        .trimLeft()));
          });
          scrollController.animateTo(0.0,
              duration: const Duration(seconds: 1), curve: Curves.easeOut);
        }
      }
    } on Exception {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Some error occurred, please try again!".tr),
        ),
      );
    }
  }

  Future<void> storeConversationHistory(String conversationHistory) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('conversation_history', conversationHistory);
  }

  // Future<void> retrieveConversationHistory() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   String? storedConversationHistory = prefs.getString('conversation_history');
  //   if (storedConversationHistory != null) {
  //     conversationHistoryList = List<Map<String, dynamic>>.from(
  //         jsonDecode(storedConversationHistory));
  //   }
  // }
  Future<void> retrieveConversationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedConversationHistory = prefs.getString('conversation_history');
    if (storedConversationHistory != null) {
      conversationHistoryList = List<Map<String, dynamic>>.from(
          jsonDecode(storedConversationHistory));
      setState(() {
        for (var message in conversationHistoryList) {
          if (message["role"] == "user") {
            msgs.add(Message(true, message["content"]));
          } else {
            msgs.add(Message(false, message["content"]));
          }
          print('msgsmsgs :: ${message["content"]}');
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    retrieveConversationHistory();
  }

  RxBool isLoading = false.obs;
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return ProgressHUD(
        isLoading: isLoading.value,
        child: Scaffold(
          // appBar: AppBar(
          //   title: const Text("Chat Bot"),
          // ),
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(70.0),
            child: AppBar(
              backgroundColor: indigo100,
              automaticallyImplyLeading: false,
              title: Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: SvgPicture.asset(
                        'icons/arrowLeft.svg',
                        height: 35,
                        width: 35,
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () {
                        // nextPage(const CharacterUnlockPage());
                      },
                      child: const CircleAvatar(
                        backgroundColor: primaryColorLite,
                        backgroundImage: AssetImage('images/appLogo_yokai.png'),
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
          body: Column(
            children: [
              const SizedBox(
                height: 8,
              ),
              Expanded(
                child: ListView.builder(
                    controller: scrollController,
                    itemCount: msgs.length,
                    shrinkWrap: true,
                    reverse: true,
                    itemBuilder: (context, index) {
                      return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: isTyping && index == 0
                              ? Column(
                                  children: [
                                    BubbleNormal(
                                      text: msgs[0].msg,
                                      isSender: true,
                                      color: Colors.blue.shade100,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 16, top: 4),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text("Typing...".tr),
                                      ),
                                    )
                                  ],
                                )
                              : BubbleNormal(
                                  text: msgs[index].msg,
                                  isSender: msgs[index].isSender,
                                  color: msgs[index].isSender
                                      ? Colors.blue.shade100
                                      : Colors.grey.shade200,
                                ));
                    }),
              ),
              const Divider(
                height: 5.0,
                color: primaryColor,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Row(
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
                                radius: Radius.circular(8),
                                child: TextFormField(
                                  controller: controller,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  onFieldSubmitted: (value) {
                                    sendMsg();
                                  },
                                  minLines: 1,
                                  maxLines: 10,
                                  cursorColor: const Color(0xFFFDFFFF),
                                  decoration: const InputDecoration(
                                    hintText: 'Message',
                                    fillColor: Colors.blue,
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 3,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: sendMsg,
                        child: Text("Send".tr),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class Message {
  bool isSender;
  String msg;

  Message(this.isSender, this.msg);
}
