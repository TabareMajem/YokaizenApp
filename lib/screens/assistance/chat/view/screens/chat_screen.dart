/// chat_screen.dart -->

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:yokai_quiz_app/global.dart';
import 'package:yokai_quiz_app/models/chat/chat_model.dart';
import 'package:yokai_quiz_app/screens/assistance/chat/controller/yokai_chat_controller.dart';
import 'package:yokai_quiz_app/screens/assistance/chat/view/screens/chat_view_screen.dart';
import 'package:yokai_quiz_app/screens/assistance/chat/view/screens/voice_view_screen.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:get/get.dart';
import '../../../controller/exercises_controller.dart';
import 'activity_view_screen.dart';


class ChatWithYokaiScreen extends StatefulWidget {
  const ChatWithYokaiScreen({super.key});

  @override
  State<ChatWithYokaiScreen> createState() => _ChatWithYokaiScreenState();
}

class _ChatWithYokaiScreenState extends State<ChatWithYokaiScreen> {
  final ScrollController scrollController = ScrollController();
  String activeView = 'chat';
  RxBool isLoading = false.obs;

  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    _getChatMessage();
    _getExercise();
    super.initState();
  }

  Future _getExercise() async {
    setState(() {
      isLoading.value = true;
    });
    await ExercisesController.getAllExercise().then((v) {
      setState(() {
        isLoading.value = false;
      });
    });
  }

  Future _getChatMessage() async {
    try {
      setState(() {
        YokaiChatController.isLoading(true);
      });
      await YokaiChatController.getChatMessage(context: context).then((v) {});
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        YokaiChatController.isLoading(false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2A0845),
                  Color(0xFF6441A5),
                  Color(0xFF45046A)
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // View Selector

                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.white
                          )
                        ),
                          child:
                          Icon(Icons.keyboard_backspace_outlined, color: AppColors.white,)
                      ),
                      // SvgPicture.asset(
                      //   'icons/arrowLeft1.svg',
                      //   height: 40,
                      //   width: 40,
                      // ),

                    ),
                    const SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _ViewButton(
                          icon: Icons.chat_bubble_outline,
                          label: 'Chat',
                          isActive: activeView == 'chat',
                          onTap: () => setState(() => activeView = 'chat'),
                        ),
                        _ViewButton(
                          icon: Icons.mic,
                          label: 'Voice',
                          isActive: activeView == 'voice',
                          onTap: () => setState(() => activeView = 'voice'),
                        ),
                        _ViewButton(
                          icon: Icons.fitness_center,
                          label: 'Activities',
                          isActive: activeView == 'activity',
                          onTap: () => setState(() => activeView = 'activity'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Main Content Area
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: _buildActiveView(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          isLoading.value == true
              ? const Center(
                  child: SizedBox(
                    height: 35,
                    width: 35,
                    child: CircularProgressIndicator(),
                  ),
                )
              : const SizedBox()
        ],
      ),
    );
  }

  Widget _buildActiveView() {
    switch (activeView) {
      case 'chat':
        return ChatViewScreen(
          messages: YokaiChatController.messageList,
          onSendMessage: _handleSendMessage,
          scrollController: scrollController,
        );
      case 'voice':
        return VoiceViewScreen(
          onRecordingComplete: () {
            print("saasd");
            setState(() => activeView = 'chat');
          },
          scrollController: scrollController,
        );
      case 'activity':
        return const ActivityViewScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  void _handleSendMessage(String text) {
    customPrint("_handleSendMessage got invoked text : $text");
    if (text.trim().isEmpty) {
      customPrint("inside if means, something is wrong");
      return;
    };
    customPrint("_handleSendMessage YokaiChatController.messageList length : ${YokaiChatController.messageList.length}");
    if (YokaiChatController.messageList[0].isMessageSend == true) {
      showSucessMessage("Yokai is typing please wait".tr, colorSuccess);
      return;
    }
    YokaiChatController.messageList.insert(
        0,
        Messages(
            role: "user",
            content: text,
            messageId: YokaiChatController.messageList.length + 1,
            sentAt: DateTime.now().toString(),
            isProcessed: false));
    YokaiChatController.messageList[0].role = "user";
    YokaiChatController.messageList[0].content = text;
    YokaiChatController.messageList[0].messageId =
        (YokaiChatController.messageList.length + 1).toString();
    YokaiChatController.messageList[0].sentAt = DateTime.now().toString();
    YokaiChatController.messageList[0].isMessageSend = true;
    YokaiChatController.messageList[0].messageType = "TEXT";
    _messageController.clear();
    scrollController.animateTo(
      scrollController.position.minScrollExtent,
      duration: const Duration(microseconds: 1000),
      curve: Curves.fastOutSlowIn,
    );
    setState(() {});

    YokaiChatController.sendMessage(context: context, message: text).then((v) {
      scrollController.animateTo(
        scrollController.position.minScrollExtent,
        duration: const Duration(microseconds: 1000),
        curve: Curves.fastOutSlowIn,
      );
      setState(() {});
    });
  }
}

class _ViewButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ViewButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        height: 60,
        width: 100,
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: [Color(0xFFFF7F42), Color(0xFFFF4761)],
                )
              : null,
          color: isActive ? null : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}