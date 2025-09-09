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
import '../../../api/local_storage.dart';
import '../../../global.dart';
import '../../../main.dart';
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
    
    // Check user login status first
    checkUserLoginStatus();
    
    ChatController.isLoading(true);
    chatPage(1);
    ChatController.isChatAnimation(false);
    fetchData();
  }

  // Helper function to check user login status
  void checkUserLoginStatus() {
    customPrint("checkUserLoginStatus got invoked");
    try {
      customPrint("checkUserLoginStatus inside try");
      String? userId = prefs.getString(LocalStorage.id);
      String? userToken = prefs.getString(LocalStorage.token);
      // bool? isLoggedIn = prefs.getString(LocalStorage.isLogin);
      
      customPrint("🔍 Checking user login status...");
      customPrint("User ID: $userId");
      customPrint("User Token: ${userToken != null ? 'Present' : 'Null'}");
      // customPrint("Is Logged In: $isLoggedIn");
      
      if (userId == null || userId == "null" || userId.isEmpty) {
        customPrint("⚠️ WARNING: User ID is null/empty!");
        customPrint("🔄 User might need to log in again.");
        
        // Show warning to user
        Future.delayed(Duration(seconds: 1), () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Session expired. Please log in again to chat.".tr),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
          }
        });
      } else {
        customPrint("✅ User login status verified. ID: $userId");
      }
    } catch (e) {
      customPrint("❌ Error checking login status: $e");
    }
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
            
            // Check if we need to send auto-greet
            await checkAndSendAutoGreet().then(
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

  // Auto-greet logic
  Future<void> checkAndSendAutoGreet() async {
    try {
      customPrint("🔍 Checking if auto-greet is needed...");
      customPrint("📊 Current messages count: ${ChatController.messages.length}");
      
      // Check if we need to send auto-greet
      bool shouldGreet = false;
      
      if (ChatController.messages.isEmpty) {
        // No messages at all - definitely need to greet
        shouldGreet = true;
        customPrint("✅ No messages found - will send auto-greet");
      } else {
        // Check if the last message from character was a greeting that we should replace
        // or if there are only user messages without character response
        bool hasCharacterMessage = ChatController.messages.any((msg) => !msg.isMe);
        
        if (!hasCharacterMessage) {
          shouldGreet = true;
          customPrint("✅ No character messages found - will send auto-greet");
        } else {
          customPrint("ℹ️ Character messages already exist - skipping auto-greet");
        }
      }
      
      if (shouldGreet) {
        customPrint("🤖 Sending auto-greet for character: ${widget.name}");
        await sendAutoGreet();
      } else {
        customPrint("⏭️ Auto-greet not needed");
      }
    } catch (e) {
      customPrint("❌ Error in checkAndSendAutoGreet: $e");
    }
  }

  // Future<void> sendAutoGreet() async {
  //   try {
  //     // Validate user ID first
  //     int? userId = prefs.getInt(LocalStorage.id);
  //     customPrint("sendAutoGreet userId : $userId");
  //     if (userId == null || userId == "null") {
  //       customPrint("❌ User ID is null or invalid. User might not be logged in properly.");
  //       customPrint("🔄 Attempting to refresh user session...");
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("Please log in again to chat with characters.".tr)),
  //       );
  //       return;
  //     }
  //
  //     customPrint("✅ User ID validated: $userId");
  //
  //     String apiKey = dotenv.env['OPENAI_API_KEY']!;
  //     String prompt = ChatController.getChatFromApiModel.value.prompt.toString().trim();
  //
  //     // Prepare auto-greet request
  //     var requestBody = jsonEncode({
  //       "model": "gpt-4-turbo",
  //       "messages": [
  //         {
  //           "role": "system",
  //           "content": prompt,
  //         },
  //         {
  //           "role": "user",
  //           "content": "Please greet the user as this character would. Keep it warm, welcoming, and in character. This is the first message they'll see.",
  //         }
  //       ],
  //     });
  //
  //     // Send request to OpenAI
  //     var response = await http.post(
  //       Uri.parse("https://api.openai.com/v1/chat/completions"),
  //       headers: {
  //         "Authorization": "Bearer $apiKey",
  //         "Content-Type": "application/json"
  //       },
  //       body: requestBody,
  //     );
  //
  //     if (response.statusCode == 200) {
  //       var json = jsonDecode(response.body);
  //       String greetText = utf8.decode(json["choices"][0]["message"]["content"]
  //           .toString()
  //           .trimLeft()
  //           .codeUnits);
  //
  //       // Clean up the greeting text
  //       if (greetText.contains("Assistant")) {
  //         greetText = greetText.replaceAll("Assistant", widget.name);
  //       }
  //
  //       // Add greeting message to UI
  //       setState(() {
  //         ChatController.messages.insert(
  //           0,
  //           Message(
  //             text: greetText,
  //             isMe: false,
  //             senderName: widget.name,
  //             timestamp: DateTime.now(),
  //           ),
  //         );
  //       });
  //
  //       // Store the greeting in database with validated user ID
  //       final body = {
  //         "user_id": userId,  // Use validated user ID
  //         "character_id": widget.characterId,
  //         "question": "character greet", // Special marker for greet
  //         "answer": greetText
  //       };
  //
  //       customPrint("💾 Storing auto-greet with validated user ID: $userId");
  //       await ChatController.sendChatToApi(context, body);
  //       customPrint("✅ Auto-greet sent and stored successfully");
  //
  //       // Enable chat animation for the greeting
  //       ChatController.isChatAnimation(true);
  //     } else {
  //       customPrint("❌ OpenAI API failed with status: ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     customPrint("❌ Error in sendAutoGreet: $e");
  //   }
  // }

  // Send automatic greeting from character
  Future<void> sendAutoGreet() async {
    try {
      // Validate user ID first
      int? userId = prefs.getInt(LocalStorage.id);
      customPrint("sendAutoGreet userId : $userId");
      if (userId == null || userId == "null") {
        customPrint("❌ User ID is null or invalid. User might not be logged in properly.");
        customPrint("🔄 Attempting to refresh user session...");

        // Try to get user ID from token or re-authenticate
        // For now, show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please log in again to chat with characters.".tr)),
        );
        return;
      }

      customPrint("✅ User ID validated: $userId");

      String apiKey = dotenv.env['OPENAI_API_KEY']!;
      String prompt = ChatController.getChatFromApiModel.value.prompt.toString().trim();
      // Clean the prompt to prevent encoding issues
      prompt = prompt.replaceAll(RegExp(r'[^\x20-\x7E]'), '');

      // Prepare auto-greet request with encoding safety
      var requestBody;
      try {
        requestBody = jsonEncode({
          "model": "gpt-4-turbo",
          "messages": [
            {
              "role": "system",
              "content": prompt,
            },
            {
              "role": "user",
              "content": "Please greet the user as this character would. Keep it warm, welcoming, and in character. This is the first message they'll see.",
            }
          ],
        });
      } catch (e) {
        customPrint("❌ Error encoding auto-greet request body: $e");
        // Fallback: create a simplified request
        requestBody = jsonEncode({
          "model": "gpt-4-turbo",
          "messages": [
            {
              "role": "system",
              "content": "You are a helpful assistant. Please greet the user warmly.",
            },
            {
              "role": "user",
              "content": "Please greet the user as this character would. Keep it warm, welcoming, and in character. This is the first message they'll see.",
            }
          ],
        });
      }

      // Send request to OpenAI
      var response = await http.post(
        Uri.parse("https://api.openai.com/v1/chat/completions"),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json"
        },
        body: requestBody,
      );

      if (response.statusCode == 200) {
        var json;
        try {
          json = jsonDecode(response.body);
        } catch (e) {
          customPrint("❌ Error decoding auto-greet response body: $e");
          customPrint("Response body: ${response.body}");
          return;
        }
        String greetText;
        try {
          // Validate response structure first
          if (json["choices"] == null || 
              json["choices"].isEmpty || 
              json["choices"][0] == null || 
              json["choices"][0]["message"] == null || 
              json["choices"][0]["message"]["content"] == null) {
            throw Exception("Invalid response structure from GPT API");
          }
          
          // First try to decode normally
          greetText = json["choices"][0]["message"]["content"].toString().trimLeft();
          
          // Apply encoding fix to handle any UTF-8 issues
          greetText = fixEncoding(greetText);
        } catch (e) {
          customPrint("⚠️ Error decoding greeting response, using fallback: $e");
          // Fallback: try to clean the response manually
          try {
            greetText = json["choices"][0]["message"]["content"].toString().trimLeft();
            // Remove any problematic characters
            greetText = greetText.replaceAll(RegExp(r'[^\x20-\x7E]'), '');
          } catch (e2) {
            customPrint("❌ Complete failure decoding greeting response: $e2");
            greetText = "Hello! I'm here to help you. How can I assist you today?";
          }
        }

        // Clean up the greeting text
        if (greetText.contains("Assistant")) {
          greetText = greetText.replaceAll("Assistant", widget.name);
        }

        // Add greeting message to UI
        setState(() {
          ChatController.messages.add(  // Changed from insert(0,) to add()
            Message(
              text: greetText,
              isMe: false,
              senderName: widget.name,
              timestamp: DateTime.now(),
            ),
          );
        });

        // Auto-scroll to bottom to show new message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (ChatController.scrollController.hasClients) {
            ChatController.scrollController.animateTo(
              ChatController.scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });

        // Store the greeting in database with validated user ID
        final body = {
          "user_id": userId,  // Use validated user ID
          "character_id": widget.characterId,
          "question": "character greet", // Special marker for greet
          "answer": greetText
        };

        customPrint("💾 Storing auto-greet with validated user ID: $userId");
        await ChatController.sendChatToApi(context, body);
        customPrint("✅ Auto-greet sent and stored successfully");

        // Enable chat animation for the greeting
        ChatController.isChatAnimation(true);
      } else {
        customPrint("❌ OpenAI API failed with status: ${response.statusCode}");
      }
    } catch (e) {
      customPrint("❌ Error in sendAutoGreet: $e");
    }
  }

  @override
  void dispose() {
    ChatController.timer?.cancel();
    super.dispose();
  }

  // Future<void> loadConversationHistory() async {
  //   try {
  //     customPrint("📥 Loading conversation history...");
  //
  //     for (var message in ChatController.getChatFromApiModel.value.data!) {
  //       // Handle greeting messages - only show answer, hide question
  //       if (message.question != null &&
  //           (message.question.toString().trim() == "character greet" ||
  //            message.question.toString().trim() == " ")) {
  //
  //         // Only add the character's answer (greeting) - skip the question
  //         if (message.answer != null && message.answer.toString().isNotEmpty) {
  //           ChatController.messages.add(
  //             Message(
  //               text: message.answer.toString(),
  //               isMe: false,
  //               timestamp: DateTime.parse(message.createdAt.toString()),
  //               senderName: widget.name,
  //             ),
  //           );
  //           // Safe substring for logging
  //           String answerPreview = message.answer.toString();
  //           if (answerPreview.length > 50) {
  //             answerPreview = answerPreview.substring(0, 50) + "...";
  //           }
  //           customPrint("📝 Added greeting answer: $answerPreview");
  //         }
  //       }
  //       // Handle normal conversations - show both question and answer
  //       else {
  //         // Add user's question
  //         if (message.question != null && message.question.toString().isNotEmpty) {
  //           ChatController.messages.add(
  //             Message(
  //               text: message.question.toString(),
  //               isMe: true,
  //               timestamp: DateTime.parse(message.createdAt.toString()),
  //               senderName: 'You',
  //             ),
  //           );
  //           // Safe substring for logging
  //           String questionPreview = message.question.toString();
  //           if (questionPreview.length > 50) {
  //             questionPreview = questionPreview.substring(0, 50) + "...";
  //           }
  //           customPrint("📝 Added user question: $questionPreview");
  //         }
  //
  //         // Add character's answer
  //         if (message.answer != null && message.answer.toString().isNotEmpty) {
  //           ChatController.messages.add(
  //             Message(
  //               text: message.answer.toString(),
  //               isMe: false,
  //               timestamp: DateTime.parse(message.createdAt.toString()),
  //               senderName: widget.name,
  //             ),
  //           );
  //           // Safe substring for logging
  //           String answerPreview = message.answer.toString();
  //           if (answerPreview.length > 50) {
  //             answerPreview = answerPreview.substring(0, 50) + "...";
  //           }
  //           customPrint("📝 Added character answer: $answerPreview");
  //         }
  //       }
  //     }
  //
  //     customPrint("✅ Loaded ${ChatController.messages.length} messages total");
  //   } catch (e) {
  //     customPrint("❌ Error loading conversation history: $e");
  //   }
  // }

  Future<void> loadConversationHistory() async {
    try {
      customPrint("📥 Loading conversation history...");

      // Clear existing messages to avoid duplicates
      ChatController.messages.clear();

      // The API returns data in reverse chronological order (newest first)
      // Since UI uses natural order, we need to process from oldest to newest
      var apiData = ChatController.getChatFromApiModel.value.data!;

      // Sort by created_at to ensure proper chronological order (oldest first)
      var sortedMessages = List.from(apiData);
      sortedMessages.sort((a, b) => DateTime.parse(a.createdAt.toString())
          .compareTo(DateTime.parse(b.createdAt.toString())));

      customPrint("📊 Processing ${sortedMessages.length} conversation entries...");

      // Temporary list to hold all messages in chronological order
      List<Message> tempMessages = [];

      for (var message in sortedMessages) {
        DateTime baseTime = DateTime.parse(message.createdAt.toString());

        // Handle greeting messages - only show answer, hide question
        if (message.question != null &&
            (message.question.toString().trim() == "character greet" ||
                message.question.toString().trim() == " ")) {

          // Only add the character's answer (greeting) - skip the question
          if (message.answer != null && message.answer.toString().isNotEmpty) {
            String fixedAnswerText = fixEncoding(message.answer.toString());
            tempMessages.add(
              Message(
                text: fixedAnswerText,
                isMe: false,
                timestamp: baseTime,
                senderName: widget.name,
              ),
            );

            String answerPreview = fixedAnswerText;
            if (answerPreview.length > 50) {
              answerPreview = answerPreview.substring(0, 50) + "...";
            }
            customPrint("📝 Added greeting answer: $answerPreview");
          }
        }
        // Handle normal conversations - show question FIRST, then answer
        else {
          // Add user's question FIRST
          if (message.question != null && message.question.toString().isNotEmpty) {
            String fixedQuestionText = fixEncoding(message.question.toString());
            tempMessages.add(
              Message(
                text: fixedQuestionText,
                isMe: true,
                timestamp: baseTime,
                senderName: 'You',
              ),
            );

            String questionPreview = fixedQuestionText;
            if (questionPreview.length > 50) {
              questionPreview = questionPreview.substring(0, 50) + "...";
            }
            customPrint("📝 Added user question: $questionPreview");
          }

          // Then add character's answer (1 second later to maintain order)
          if (message.answer != null && message.answer.toString().isNotEmpty) {
            DateTime answerTime = baseTime.add(Duration(seconds: 1));
            String fixedAnswerText = fixEncoding(message.answer.toString());

            tempMessages.add(
              Message(
                text: fixedAnswerText,
                isMe: false,
                timestamp: answerTime,
                senderName: widget.name,
              ),
            );

            String answerPreview = fixedAnswerText;
            if (answerPreview.length > 50) {
              answerPreview = answerPreview.substring(0, 50) + "...";
            }
            customPrint("📝 Added character answer: $answerPreview");
          }
        }
      }

      // Add messages to controller in chronological order (oldest first)
      // The UI will display them in natural chronological order
      ChatController.messages.addAll(tempMessages);

      customPrint("✅ Loaded ${ChatController.messages.length} messages total");

      // Clean the conversation history to prevent encoding issues
      conversationHistoryList = conversationHistoryList.map((message) {
        return {
          "role": message["role"],
          "content": message["content"].toString().replaceAll(RegExp(r'[^\x20-\x7E]'), ''),
          'timestamp': message['timestamp'],
        };
      }).toList();

      // Debug: Print the first few messages in order
      customPrint("📊 Final message order (chronological):");
      for (int i = 0; i < ChatController.messages.length && i < 6; i++) {
        var msg = ChatController.messages[i];
        String preview = msg.text.length > 30 ? msg.text.substring(0, 30) + "..." : msg.text;
        String timeStr = "${msg.timestamp.day}/${msg.timestamp.month} ${msg.timestamp.hour}:${msg.timestamp.minute}";
        customPrint("  ${i + 1}: [$timeStr] ${msg.isMe ? 'User' : 'Character'} - $preview");
      }

      // Auto-scroll to bottom after loading conversation history
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (ChatController.scrollController.hasClients && ChatController.messages.isNotEmpty) {
          ChatController.scrollController.animateTo(
            ChatController.scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        }
      });

    } catch (e) {
      customPrint("❌ Error loading conversation history: $e");
    }
    }

  // Load additional conversation history for pagination without clearing existing messages
  Future<void> loadAdditionalConversationHistory() async {
    try {
      customPrint("📥 Loading additional conversation history...");

      // DON'T clear existing messages - this is for pagination
      // ChatController.messages.clear(); // <- This line is removed for pagination

      // The API returns data in reverse chronological order (newest first)
      // Since UI uses natural order, we need to process from oldest to newest
      var apiData = ChatController.getChatFromApiModel.value.data!;
      
      // Sort by created_at to ensure proper chronological order (oldest first)
      var sortedMessages = List.from(apiData);
      sortedMessages.sort((a, b) => DateTime.parse(a.createdAt.toString())
          .compareTo(DateTime.parse(b.createdAt.toString())));

      customPrint("📊 Processing ${sortedMessages.length} additional conversation entries...");

      // Temporary list to hold new messages in chronological order
      List<Message> newMessages = [];

      // Check if message already exists to avoid duplicates
      Set<String> existingMessageIds = {};
      for (var existingMsg in ChatController.messages) {
        // Create a unique ID based on text and timestamp
        String messageId = "${existingMsg.text}_${existingMsg.timestamp.millisecondsSinceEpoch}";
        existingMessageIds.add(messageId);
      }

      for (var message in sortedMessages) {
        DateTime baseTime = DateTime.parse(message.createdAt.toString());

        // Handle greeting messages - only show answer, hide question
        if (message.question != null &&
            (message.question.toString().trim() == "character greet" ||
                message.question.toString().trim() == " ")) {

          // Only add the character's answer (greeting) - skip the question
          if (message.answer != null && message.answer.toString().isNotEmpty) {
            String fixedAnswerText = fixEncoding(message.answer.toString());
            String messageId = "${fixedAnswerText}_${baseTime.millisecondsSinceEpoch}";
            
            if (!existingMessageIds.contains(messageId)) {
              newMessages.add(
                Message(
                  text: fixedAnswerText,
                  isMe: false,
                  timestamp: baseTime,
                  senderName: widget.name,
                ),
              );

              String answerPreview = fixedAnswerText;
              if (answerPreview.length > 50) {
                answerPreview = answerPreview.substring(0, 50) + "...";
              }
              customPrint("📝 Added new greeting answer: $answerPreview");
            }
          }
        }
        // Handle normal conversations - show question FIRST, then answer
        else {
          // Add user's question FIRST
          if (message.question != null && message.question.toString().isNotEmpty) {
            String fixedQuestionText = fixEncoding(message.question.toString());
            String messageId = "${fixedQuestionText}_${baseTime.millisecondsSinceEpoch}";
            
            if (!existingMessageIds.contains(messageId)) {
              newMessages.add(
                Message(
                  text: fixedQuestionText,
                  isMe: true,
                  timestamp: baseTime,
                  senderName: 'You',
                ),
              );

              String questionPreview = fixedQuestionText;
              if (questionPreview.length > 50) {
                questionPreview = questionPreview.substring(0, 50) + "...";
              }
              customPrint("📝 Added new user question: $questionPreview");
            }
          }

          // Then add character's answer (1 second later to maintain order)
          if (message.answer != null && message.answer.toString().isNotEmpty) {
            DateTime answerTime = baseTime.add(Duration(seconds: 1));
            String fixedAnswerText = fixEncoding(message.answer.toString());
            String messageId = "${fixedAnswerText}_${answerTime.millisecondsSinceEpoch}";
            
            if (!existingMessageIds.contains(messageId)) {
              newMessages.add(
                Message(
                  text: fixedAnswerText,
                  isMe: false,
                  timestamp: answerTime,
                  senderName: widget.name,
                ),
              );

              String answerPreview = fixedAnswerText;
              if (answerPreview.length > 50) {
                answerPreview = answerPreview.substring(0, 50) + "...";
              }
              customPrint("📝 Added new character answer: $answerPreview");
            }
          }
        }
      }

      // Insert new messages at the beginning (older messages)
      // Since we're loading older pages, they should appear before existing messages
      if (newMessages.isNotEmpty) {
        ChatController.messages.insertAll(0, newMessages);
        customPrint("✅ Added ${newMessages.length} new messages. Total: ${ChatController.messages.length}");
        
        // Clean the conversation history to prevent encoding issues
        conversationHistoryList = conversationHistoryList.map((message) {
          return {
            "role": message["role"],
            "content": message["content"].toString().replaceAll(RegExp(r'[^\x20-\x7E]'), ''),
            'timestamp': message['timestamp'],
          };
        }).toList();
      } else {
        customPrint("ℹ️ No new messages to add (all were duplicates)");
      }

    } catch (e) {
      customPrint("❌ Error loading additional conversation history: $e");
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
                          customPrint("🔄 Refresh triggered - loading more messages");
                          await ChatController.getChatFromApi(
                                  widget.characterId,
                                  (chatPage.value + 1).toString())
                              .then((value) {
                            if (ChatController
                                .getChatFromApiModel.value.data!.isEmpty) {
                              chatPage(chatPage.value);
                              customPrint("📭 No more messages to load");
                            } else {
                              chatPage(chatPage.value + 1);
                              customPrint("📄 Loading page ${chatPage.value}");
                              // Load additional conversation history without clearing existing
                              loadAdditionalConversationHistory().then(
                                (value) {
                                  setState(() {});
                                },
                              );
                            }
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
                                  // final body = {
                                  //   "user_id" : prefs.getString(LocalStorage.id).toString(),
                                  //   "character_id": widget.characterId,
                                  //   "question": ChatController
                                  //       .textEditingController.text,
                                  //   "answer" :
                                  // };
                                  // ChatController.sendChatToApi(context, body)
                                  //     .then(
                                  //   (value) {},
                                  // );
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

  // void sendMsg() async {
  //   String text = ChatController.textEditingController.text;
  //   String apiKey = dotenv.env['OPENAI_API_KEY']!;
  //   ChatController.textEditingController.clear();
  //
  //   try {
  //     if (text.isNotEmpty) {
  //       // Validate user ID first
  //       String? userId = prefs.getString(LocalStorage.id);
  //       if (userId == null || userId == "null" || userId.isEmpty) {
  //         customPrint("❌ User ID is null or invalid. User might not be logged in properly.");
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text("Please log in again to chat with characters.".tr)),
  //         );
  //         return;
  //       }
  //
  //       customPrint("📤 Sending message: $text");
  //       customPrint("✅ User ID validated: $userId");
  //
  //       // Add the user's message to the chat UI
  //       Message userMessage = Message(
  //         text: text,
  //         senderName: 'You',
  //         isMe: true,
  //         timestamp: DateTime.now(),
  //       );
  //
  //       setState(() {
  //         ChatController.messages.insert(0, userMessage);
  //         conversationHistoryList.add({
  //           "role": "user",
  //           "content": text,
  //           'timestamp': DateTime.now().toIso8601String(),
  //         });
  //         isTyping = true;
  //         customPrint("📝 Added user message to conversation history");
  //       });
  //
  //       // Get prompt for the character
  //       String prompt = ChatController.getChatFromApiModel.value.prompt.toString().trim();
  //       customPrint("🎭 Using character prompt for response");
  //
  //       // Prepare the request body for GPT
  //       var requestBody = jsonEncode({
  //         "model": "gpt-4-turbo",
  //         "messages": [
  //           {
  //             "role": "system",
  //             "content": prompt,
  //           },
  //           ...conversationHistoryList.map((message) {
  //             return {
  //               "role": message["role"],
  //               "content": message["content"],
  //               'timestamp': (message['timestamp'] is DateTime)
  //                   ? message['timestamp'].toIso8601String()
  //                   : message['timestamp'],
  //             };
  //           }).toList(),
  //         ],
  //       });
  //
  //       customPrint("🤖 Sending request to GPT...");
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
  //
  //         setState(() {
  //           isTyping = false;
  //
  //           // Decode the AI response properly
  //           String aiResponse = utf8.decode(json["choices"][0]["message"]["content"]
  //               .toString()
  //               .trimLeft()
  //               .codeUnits);
  //
  //           // Clean up response text
  //           if (aiResponse.contains("Assistant")) {
  //             aiResponse = aiResponse.replaceAll("Assistant", widget.name);
  //           }
  //
  //           // Safe preview for logging
  //           String responsePreview = aiResponse;
  //           if (responsePreview.length > 50) {
  //             responsePreview = responsePreview.substring(0, 50) + "...";
  //           }
  //           customPrint("🎯 Received AI response: $responsePreview");
  //
  //           // Add AI response to chat UI
  //           ChatController.messages.insert(
  //             0,
  //             Message(
  //               text: aiResponse,
  //               isMe: false,
  //               senderName: widget.name,
  //               timestamp: DateTime.now(),
  //             ),
  //           );
  //
  //           // Add AI response to conversation history
  //           conversationHistoryList.add({
  //             "role": "assistant",
  //             "content": aiResponse,
  //             'timestamp': DateTime.now().toIso8601String(),
  //           });
  //
  //           customPrint("💾 Storing conversation in database...");
  //
  //           // Store the complete conversation (question + answer) in database
  //           final body = {
  //             "user_id": userId,  // Use validated user ID
  //             "character_id": widget.characterId,
  //             "question": text,  // User's question
  //             "answer": aiResponse  // Character's answer
  //           };
  //
  //           ChatController.sendChatToApi(context, body).then((success) {
  //             if (success) {
  //               customPrint("✅ Conversation stored successfully");
  //             } else {
  //               customPrint("❌ Failed to store conversation");
  //             }
  //           });
  //         });
  //       } else {
  //         setState(() {
  //           isTyping = false;
  //         });
  //         customPrint("❌ GPT API failed with status: ${response.statusCode}");
  //         customPrint("Response: ${response.body}");
  //       }
  //     }
  //   } on Exception catch (e) {
  //     setState(() {
  //       isTyping = false;
  //     });
  //     customPrint("❌ Error sending message: $e");
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Some error occurred, please try again!".tr)),
  //     );
  //   }
  // }

  void sendMsg() async {
    String text = ChatController.textEditingController.text;
    String apiKey = dotenv.env['OPENAI_API_KEY']!;
    ChatController.textEditingController.clear();

    try {
      if (text.isNotEmpty) {
        // Validate user ID first
        String? userId = prefs.getString(LocalStorage.id);
        if (userId == null || userId == "null" || userId.isEmpty) {
          customPrint("❌ User ID is null or invalid. User might not be logged in properly.");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Please log in again to chat with characters.".tr)),
          );
          return;
        }

        customPrint("📤 Sending message: $text");
        customPrint("✅ User ID validated: $userId");

        // Clean the user message to prevent encoding issues (only for API calls)
        String cleanText = text.replaceAll(RegExp(r'[^\x20-\x7E]'), '');
        
        // Add the user's message to the chat UI (use original text for display)
        Message userMessage = Message(
          text: text,  // Use original text for UI display
          senderName: 'You',
          isMe: true,
          timestamp: DateTime.now(),
        );

        setState(() {
          ChatController.messages.add(userMessage);  // Changed from insert(0,) to add()
          conversationHistoryList.add({
            "role": "user",
            "content": cleanText,  // Use cleaned text for API calls
            'timestamp': DateTime.now().toIso8601String(),
          });
          isTyping = true;
          customPrint("📝 Added user message to conversation history");
        });
        
        // Clean the conversation history to prevent encoding issues
        conversationHistoryList = conversationHistoryList.map((message) {
          return {
            "role": message["role"],
            "content": message["content"].toString().replaceAll(RegExp(r'[^\x20-\x7E]'), ''),
            'timestamp': message['timestamp'],
          };
        }).toList();

        // Auto-scroll to bottom to show new user message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (ChatController.scrollController.hasClients) {
            ChatController.scrollController.animateTo(
              ChatController.scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });

        // Get prompt for the character
        String prompt = ChatController.getChatFromApiModel.value.prompt.toString().trim();
        // Clean the prompt to prevent encoding issues
        prompt = prompt.replaceAll(RegExp(r'[^\x20-\x7E]'), '');
        customPrint("🎭 Using character prompt for response");

        // Clean conversation history to prevent encoding issues
        List<Map<String, dynamic>> cleanConversationHistory = conversationHistoryList.map((message) {
          return {
            "role": message["role"],
            "content": message["content"].toString().replaceAll(RegExp(r'[^\x20-\x7E]'), ''),
            'timestamp': (message['timestamp'] is DateTime)
                ? message['timestamp'].toIso8601String()
                : message['timestamp'].toString(),
          };
        }).toList();
        
        // Prepare the request body for GPT with encoding safety
        var requestBody;
        try {
          requestBody = jsonEncode({
            "model": "gpt-4-turbo",
            "messages": [
              {
                "role": "system",
                "content": prompt.replaceAll(RegExp(r'[^\x20-\x7E]'), ''),
              },
              ...cleanConversationHistory,
            ],
          });
        } catch (e) {
          customPrint("❌ Error encoding request body: $e");
          // Fallback: create a simplified request
          requestBody = jsonEncode({
            "model": "gpt-4-turbo",
            "messages": [
              {
                "role": "system",
                "content": "You are a helpful assistant, Detect the language of the user's message and respond in the same language. Be natural and fluent in that language.",
              },
              {
                "role": "user",
                "content": cleanText,
              },
            ],
          });
        }

        customPrint("🤖 Sending request to GPT...");

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
          var json;
          try {
            json = jsonDecode(response.body);
          } catch (e) {
            customPrint("❌ Error decoding response body: $e");
            customPrint("Response body: ${response.body}");
            setState(() {
              isTyping = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error processing response. Please try again.".tr)),
            );
            return;
          }

          setState(() {
            isTyping = false;

            // Decode the AI response properly with error handling
            String aiResponse;
            try {
              // Validate response structure first
              if (json["choices"] == null || 
                  json["choices"].isEmpty || 
                  json["choices"][0] == null || 
                  json["choices"][0]["message"] == null || 
                  json["choices"][0]["message"]["content"] == null) {
                throw Exception("Invalid response structure from GPT API");
              }
              
              // First try to decode normally
              aiResponse = json["choices"][0]["message"]["content"].toString().trimLeft();
              
              // Apply encoding fix to handle any UTF-8 issues
              aiResponse = fixEncoding(aiResponse);
            } catch (e) {
              customPrint("⚠️ Error decoding AI response, using fallback: $e");
              // Fallback: try to clean the response manually
              try {
                aiResponse = json["choices"][0]["message"]["content"].toString().trimLeft();
                // Remove any problematic characters
                aiResponse = aiResponse.replaceAll(RegExp(r'[^\x20-\x7E]'), '');
              } catch (e2) {
                customPrint("❌ Complete failure decoding response: $e2");
                aiResponse = "I apologize, but I encountered an error processing your message. Please try again.";
              }
            }

            // Clean up response text
            if (aiResponse.contains("Assistant")) {
              aiResponse = aiResponse.replaceAll("Assistant", widget.name);
            }

            // Safe preview for logging
            String responsePreview = aiResponse;
            if (responsePreview.length > 50) {
              responsePreview = responsePreview.substring(0, 50) + "...";
            }
            customPrint("🎯 Received AI response: $responsePreview");

            // Add AI response to chat UI
            ChatController.messages.add(  // Changed from insert(0,) to add()
              Message(
                text: aiResponse,
                isMe: false,
                senderName: widget.name,
                timestamp: DateTime.now(),
              ),
            );

                    // Add AI response to conversation history (ensure it's clean)
        conversationHistoryList.add({
          "role": "assistant",
          "content": aiResponse.replaceAll(RegExp(r'[^\x20-\x7E]'), ''),
          'timestamp': DateTime.now().toIso8601String(),
        });

            // Auto-scroll to bottom to show new AI response
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (ChatController.scrollController.hasClients) {
                ChatController.scrollController.animateTo(
                  ChatController.scrollController.position.maxScrollExtent,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            });

            customPrint("💾 Storing conversation in database...");

            // Store the complete conversation (question + answer) in database
            final body = {
              "user_id": userId,  // Use validated user ID
              "character_id": widget.characterId,
              "question": text,  // User's question (original text for database)
              "answer": aiResponse  // Character's answer
            };

            ChatController.sendChatToApi(context, body).then((success) {
              if (success) {
                customPrint("✅ Conversation stored successfully");
              } else {
                customPrint("❌ Failed to store conversation");
              }
            });
          });
        } else {
          setState(() {
            isTyping = false;
          });
          customPrint("❌ GPT API failed with status: ${response.statusCode}");
          customPrint("Response: ${response.body}");
        }
      }
    } on Exception catch (e) {
      setState(() {
        isTyping = false;
      });
      customPrint("❌ Error sending message: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Some error occurred, please try again!".tr)),
      );
    }
  }

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
          
          // Clean the conversation history to prevent encoding issues
          conversationHistoryListNew = conversationHistoryListNew.map((message) {
            return {
              "role": message["role"],
              "content": message["content"].toString().replaceAll(RegExp(r'[^\x20-\x7E]'), ''),
              'timestamp': message['timestamp'],
            };
          }).toList();
          
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
                  "${ChatController.getChatFromApiModel.value.prompt.toString().replaceAll(RegExp(r'[^\x20-\x7E]'), '')}"
            },
            ...conversationHistoryList.map((message) {
              return {
                "role": message["role"],
                "content": message["content"].toString().replaceAll(RegExp(r'[^\x20-\x7E]'), ''),
              };
            }).toList(),
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
                String textToCheck;
                try {
                  textToCheck = json["choices"][0]["message"]["content"].toString().trimLeft();
                  textToCheck = fixEncoding(textToCheck);
                } catch (e) {
                  customPrint("⚠️ Error decoding summary response, using fallback: $e");
                  textToCheck = json["choices"][0]["message"]["content"].toString().trimLeft();
                  textToCheck = textToCheck.replaceAll(RegExp(r'[^\x20-\x7E]'), '');
                }
                customPrint(
                    'AI Ans summary after encoding fixed : $textToCheck');

                if (textToCheck.contains("Assistant")) {
                  textToCheck =
                      textToCheck.replaceAll("Assistant", "${widget.name}");
                  customPrint("Now, inside if, this textToCheck : $textToCheck");
                  textToCheck = fixEncoding(textToCheck);
                  customPrint("Now, inside if, after the encoding fixed textToCheck : $textToCheck");
                }
                final body = {
                  "character_id": ChatController
                      .getChatFromApiModel.value.characterId
                      .toString(),
                  "summary": textToCheck,
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

  String fixEncoding(String encodedString) {
    try {
      // First try to decode normally
      return utf8.decode(encodedString.runes.toList());
    } catch (e) {
      customPrint("⚠️ UTF-8 decode failed, trying alternative methods: $e");
      
      try {
        // Try to decode with error handling
        return utf8.decode(encodedString.runes.toList(), allowMalformed: true);
      } catch (e2) {
        customPrint("⚠️ UTF-8 decode with allowMalformed failed: $e2");
        
        // Last resort: clean the string by removing problematic characters
        String cleaned = encodedString.replaceAll(RegExp(r'[^\x20-\x7E]'), '');
        customPrint("🧹 Cleaned string length: ${cleaned.length} (was: ${encodedString.length})");
        return cleaned;
      }
    }
  }

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
    
    // Clean the conversation history to prevent encoding issues
    conversationHistoryListNew = conversationHistoryListNew.map((message) {
      return {
        "role": message["role"],
        "content": message["content"].toString().replaceAll(RegExp(r'[^\x20-\x7E]'), ''),
        'timestamp': message['timestamp'],
      };
    }).toList();

    if (summaryParagraph.isNotEmpty) {
      conversationHistoryListNew.add({
        "role": "user",
        "content": summaryParagraph.replaceAll(RegExp(r'[^\x20-\x7E]'), ''),
      });
    }

    // Add the dynamic follow-up question
    conversationHistoryListNew.add({
      "role": "user",
      "content": followUpQuestion.replaceAll(RegExp(r'[^\x20-\x7E]'), ''),
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
          "messages": conversationHistoryListNew.map((message) {
            return {
              "role": message["role"],
              "content": message["content"].toString().replaceAll(RegExp(r'[^\x20-\x7E]'), ''),
            };
          }).toList(),
        }),
      );

      if (responseNew.statusCode == 200) {
        ChatController.isChatAnimation(true);
        var jsonNew = jsonDecode(responseNew.body);
        setState(() {
          customPrint(
              'AI Answer opener: ${jsonNew["choices"][0]["message"]["content"]}');

          String textToCheckNew;
          try {
            textToCheckNew = jsonNew["choices"][0]["message"]["content"].toString().trimLeft();
            textToCheckNew = fixEncoding(textToCheckNew);
          } catch (e) {
            customPrint("⚠️ Error decoding opener response, using fallback: $e");
            textToCheckNew = jsonNew["choices"][0]["message"]["content"].toString().trimLeft();
            textToCheckNew = textToCheckNew.replaceAll(RegExp(r'[^\x20-\x7E]'), '');
          }

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
                .trimLeft()
                .replaceAll(RegExp(r'[^\x20-\x7E]'), ''),
            'timestamp': DateTime.now().toIso8601String(),
          });

          // Optionally send the chat to another API or service
          final body = {
            "user_id" :  prefs.getString(LocalStorage.id).toString(),
            "character_id": widget.characterId,
            "question" : "question",
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

  bool confirmed = false;

  Widget _buildMessage(Message message, int index, int receiverId) {
 
    bool isToday =
        message.timestamp.toLocal().difference(DateTime.now()).inDays == 0;

    // Check if this is the most recent message from the character
    bool isLastMessageFromChatGPT = !message.isMe &&
        message.senderName == widget.name &&
        ChatController.isChatAnimation.isTrue &&
        isToday &&
        ChatController.messages.isNotEmpty &&
        ChatController.messages.last == message;

    DateTime utcDateTime = DateTime.parse(message.timestamp.toString()).toUtc();
    DateTime localDateTime = utcDateTime.toLocal();
    String formattedTime = DateFormat('h:mm a').format(localDateTime);
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

    // Group messages by date for display
    Map<String, List<Message>> messagesByDate = {};
    
    for (Message message in ChatController.messages) {
      String dateKey = DateFormat('dd-MM-yyyy').format(message.timestamp);
      if (messagesByDate[dateKey] == null) {
        messagesByDate[dateKey] = [];
      }
      messagesByDate[dateKey]!.add(message);
    }

    // Get sorted date keys (oldest first)
    List<String> sortedDates = messagesByDate.keys.toList();
    sortedDates.sort((a, b) {
      DateTime dateA = DateFormat('dd-MM-yyyy').parse(a);
      DateTime dateB = DateFormat('dd-MM-yyyy').parse(b);
      return dateA.compareTo(dateB);
    });

    return ListView.builder(
      controller: ChatController.scrollController,
      // Remove reverse: true to show messages in natural order
      itemCount: sortedDates.length,
      itemBuilder: (BuildContext context, int dateIndex) {
        String dateKey = sortedDates[dateIndex];
        List<Message> messagesForDate = messagesByDate[dateKey]!;
        
        return _buildMessageList(messagesForDate, dateKey);
      },
    );
  }

  Widget _buildMessageList(List<Message> messages, String formattedDate) {
    return Column(
      children: [
        // Date separator
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
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
        ),
        // Messages for this date in chronological order
        ...messages.map((message) {
          int messageIndex = ChatController.messages.indexOf(message);
          return _buildMessage(message, messageIndex, 1);
        }).toList(),
      ],
    );
  }
}

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
