import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../models/chat/chat_model.dart';
import '../../../../../util/colors.dart';
import '../../controller/yokai_chat_controller.dart';
import '../widgets/companion_avatar.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';


class ChatViewScreen extends StatefulWidget {
  final List<Messages> messages;
  final ScrollController scrollController;
  final Function(String) onSendMessage;

  const ChatViewScreen({
    super.key,
    required this.messages,
    required this.onSendMessage,
    required this.scrollController,
  });

  @override
  State<ChatViewScreen> createState() => _ChatViewScreenState();
}

class _ChatViewScreenState extends State<ChatViewScreen> {
  final player = AudioPlayer();
  Duration? duration;
  int playingStatus = 0;
  int? playingIndex;
  @override
  void initState() {
    super.initState();
    player.onPositionChanged.listen((Duration p) {
      setState(() {
        duration = p;
      });
    });
    player.onPlayerComplete.listen((_) {
      setState(() {
        duration = null;
        playingStatus = 0;
      });
    });
  }

  _playAudio(int? index) async {
    playingIndex = index;
    setState(() {
      playingStatus = 1;
    });
    if (widget.messages[index!].isLocalAudio == false) {
      await player.play(UrlSource(widget.messages[index].content!));
    } else {
      await player.play(DeviceFileSource(widget.messages[index].content!));
    }
  }

  _playResume() async {
    setState(() {
      playingStatus = 1;
    });
    await player.resume();
  }

  _playPause() async {
    setState(() {
      playingStatus = 2;
    });
    await player.pause();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (YokaiChatController.isLoading.value == true) ...[
          Expanded(
            child: Skeletonizer(
              enabled: true,
              child: ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(16),
                itemCount: 20,
                itemBuilder: (BuildContext context, int index) {
                  return chatSkeleton(
                    context: context,
                    isUser: index.isEven ? true : false,
                  );
                },
              ),
            ),
          ),
        ] else ...[
          Expanded(
            child: ListView.builder(
              reverse: true,
              controller: widget.scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: widget.messages.length,
              itemBuilder: (context, index) {
                final message = widget.messages[index];
                return Column(
                  children: [
                    (index + 1 != widget.messages.length)
                        ? DateFormat('dd/MM/yyyy').format(
                      DateTime.parse(
                          widget.messages[index + 1].sentAt!),
                    ) ==
                        DateFormat('dd/MM/yyyy').format(
                          DateTime.parse(
                            widget.messages[index].sentAt!,
                          ),
                        )
                        ? const SizedBox.shrink()
                        : rowDate(
                      (DateFormat('dd/MM/yyyy')
                          .format(DateTime.now()) ==
                          DateFormat('dd/MM/yyyy').format(
                            DateTime.parse(
                              widget.messages[index].sentAt!,
                            ),
                          ))
                          ? "Today".tr
                          : DateFormat('dd-MMMM-yyyy')
                          .format(
                        DateTime.parse(
                          widget.messages[index].sentAt!,
                        ),
                      )
                          .toString(),
                    )
                        : rowDate(
                      (DateFormat('dd/MM/yyyy').format(DateTime.now()) ==
                          DateFormat('dd/MM/yyyy').format(
                            DateTime.parse(
                              widget.messages[index].sentAt!,
                            ),
                          ))
                          ? "Today".tr
                          : DateFormat('dd-MMMM-yyyy')
                          .format(
                        DateTime.parse(
                          widget.messages[index].sentAt!,
                        ),
                      )
                          .toString(),
                    ),
                    MessageBubble(
                      message: message,
                      audioPlay: () {
                        if (index == playingIndex) {
                          if (playingStatus == 0) {
                            _playAudio(index);
                          } else if (playingStatus == 1) {
                            _playPause();
                          } else if (playingStatus == 2) {
                            _playResume();
                          }
                        } else {
                          _playAudio(index);
                        }
                      },
                      duration: duration,
                      playingState: playingIndex == index ? playingStatus : 0,
                    )
                  ],
                );
              },
            ),
          ),
        ],

        // Input Area
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
          ),
          child: MessageInput(onSendMessage: widget.onSendMessage),
        ),
      ],
    );
  }

  rowDate(String? date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        date!,
        style: GoogleFonts.montserrat(
          color: AppColors.white,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget chatSkeleton({BuildContext? context, bool? isUser}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
        isUser! ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) CompanionAvatar(),
          const SizedBox(width: 8),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context!).size.width * 0.7,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: isUser
                  ? const LinearGradient(
                colors: [Color(0xFFFF7F42), Color(0xFFFF4761)],
              )
                  : null,
              color: isUser ? null : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isUser ? 20 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 20),
              ),
            ),
            child: const Text(
              "hello it is dummy message ",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}