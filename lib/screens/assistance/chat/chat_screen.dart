import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:yokai_quiz_app/global.dart';
import 'package:yokai_quiz_app/models/chat/chat_model.dart';
import 'package:yokai_quiz_app/models/exercise/Exercise_model.dart';
import 'package:yokai_quiz_app/screens/assistance/chat/controller/controller.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:record/record.dart';
import 'package:yokai_quiz_app/screens/assistance/controller/controller.dart';

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
                  children: [
                    // View Selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
        return ChatView(
          messages: YokaiChatController.messageList,
          onSendMessage: _handleSendMessage,
          scrollController: scrollController,
        );
      case 'voice':
        return VoiceView(
          onRecordingComplete: () {
            print("saasd");
            setState(() => activeView = 'chat');
          },
          scrollController: scrollController,
        );
      case 'activity':
        return const ActivityView();
      default:
        return const SizedBox.shrink();
    }
  }

  void _handleSendMessage(String text) {
    if (text.trim().isEmpty) return;
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

// Chat View
class ChatView extends StatefulWidget {
  final List<Messages> messages;
  final ScrollController scrollController;
  final Function(String) onSendMessage;

  const ChatView({
    super.key,
    required this.messages,
    required this.onSendMessage,
    required this.scrollController,
  });

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
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
                    _MessageBubble(
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
          child: _MessageInput(onSendMessage: widget.onSendMessage),
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
          if (!isUser) _CompanionAvatar(),
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

class _MessageBubble extends StatelessWidget {
  final Messages message;
  final VoidCallback audioPlay;
  final int? playingState;
  final Duration? duration;

  const _MessageBubble(
      {required this.message,
      required this.audioPlay,
      this.playingState,
      this.duration});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isUser) ...[
                _CompanionAvatar(),
                const SizedBox(width: 8),
              ],
              if (message.messageType == "TEXT") ...[
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Linkify(
                        onOpen: (link) async {
                          if (!await launchUrl(Uri.parse(link.url))) {
                            throw Exception('Could not launch ${link.url}');
                          }
                        },
                        text: message.content ?? "",
                        style: GoogleFonts.montserrat(
                          color: AppColors.white,
                          fontSize: 14,
                        ),
                        linkStyle: GoogleFonts.montserrat(
                          color: AppColors.black,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        DateFormat('hh:mm a').format(
                          DateTime.parse(
                            message.sentAt!,
                          ),
                        ),
                        style: GoogleFonts.montserrat(
                          fontSize: 10.0,
                          color: AppColors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.start,
                      )
                    ],
                  ),
                ),
              ] else if (message.messageType == "AUDIO") ...[
                Container(
                  width: MediaQuery.of(context).size.width * .52,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF7F42), Color(0xFFFF4761)],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.only(right: 5),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: audioPlay,
                                  child: Icon(
                                    playingState == 0
                                        ? Icons.play_arrow
                                        : playingState == 1
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                    color: AppColors.white,
                                    size: 22,
                                  ),
                                ),
                                Text(
                                  playingState == 0
                                      ? message.duration
                                      : duration == null
                                          ? message.duration
                                          : duration != null
                                              ? (duration!.inSeconds
                                                          .toString()
                                                          .length ==
                                                      1)
                                                  ? "0${duration!.inMinutes} : 0${duration!.inSeconds}"
                                                  : "0${duration!.inMinutes} : ${duration!.inSeconds}"
                                              : "00 : 00",
                                  maxLines: 1,
                                  style: GoogleFonts.montserrat(
                                    color: AppColors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * .3,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * .3,
                                  child: Text(
                                    message.content!.split("/").last,
                                    maxLines: 1,
                                    textAlign: TextAlign.start,
                                    style: GoogleFonts.montserrat(
                                      color: AppColors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  DateFormat('hh:mm a').format(
                                    DateTime.parse(
                                      message.sentAt!,
                                    ),
                                  ),
                                  style: GoogleFonts.montserrat(
                                    fontSize: 10.0,
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                                const SizedBox(
                                  height: 3,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ]
            ],
          ),
          if (message.isMessageSend) ...[
            const SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _CompanionAvatar(),
                const SizedBox(width: 8),
                Container(
                  alignment: Alignment.centerLeft,
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.3,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Skeletonizer(
                    enabled: true,
                    child: SizedBox(
                      height: 20,
                      width: MediaQuery.of(context).size.width,
                      child: ListView.builder(
                        reverse: true,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.all(0),
                        itemCount: 5,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            height: 10,
                            width: 10,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFFF4761),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ],
      ),
    );
  }
}

class _CompanionAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF7F42), Color(0xFFFF4761)],
        ),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text(
          'Y',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _MessageInput extends StatelessWidget {
  final Function(String) onSendMessage;
  final TextEditingController _controller = TextEditingController();

  _MessageInput({required this.onSendMessage});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Type your message...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
              filled: true,
              fillColor: Colors.black.withOpacity(0.2),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF7F42), Color(0xFFFF4761)],
            ),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          child: IconButton(
            icon: const Icon(Icons.send, color: Colors.white),
            onPressed: () {
              final text = _controller.text;
              if (text.isNotEmpty) {
                onSendMessage(text);
                _controller.clear();
              }
            },
          ),
        ),
      ],
    );
  }
}

// Voice View
class VoiceView extends StatefulWidget {
  final ScrollController? scrollController;
  final Function? onRecordingComplete;
  const VoiceView({
    Key? key,
    this.onRecordingComplete,
    @required this.scrollController,
  }) : super(key: key);

  @override
  State<VoiceView> createState() => _VoiceViewState();
}

class _VoiceViewState extends State<VoiceView> {
  bool isRecording = false;
  final audioRecorder = Record();
  int recordDuration = 0;
  Timer? timer;
  @override
  void dispose() {
    if (recordDuration != 0) {
      audioRecorder.stop();
    }

    super.dispose();
  }

  Future<void> audioRecordingStart() async {
    print(await audioRecorder.hasPermission());
    if (await audioRecorder.hasPermission()) {
      await audioRecorder.start();
      recordDuration = 0;

      _startTimer();
    }
  }

  Future<void> audioRecordingStop() async {
    timer?.cancel();

    var path = await audioRecorder.stop();

    if (Platform.isIOS) {
      path = path!.replaceAll('file://', '');
    }

    if (path != null) {
      print("recording Saved $path");
      YokaiChatController.messageList.insert(
          0,
          Messages(
              role: "user",
              content: path,
              messageId: YokaiChatController.messageList.length + 1,
              sentAt: DateTime.now().toString(),
              isProcessed: false));
      YokaiChatController.messageList[0].role = "user";
      YokaiChatController.messageList[0].content = path;
      YokaiChatController.messageList[0].messageId =
          (YokaiChatController.messageList.length + 1).toString();
      YokaiChatController.messageList[0].sentAt = DateTime.now().toString();
      YokaiChatController.messageList[0].isMessageSend = true;
      YokaiChatController.messageList[0].messageType = "AUDIO";
      YokaiChatController.messageList[0].isLocalAudio = true;
      YokaiChatController.messageList[0].duration = recordDuration.toString();
      widget.onRecordingComplete;
      setState(() {
        recordDuration = 0;
      });
    } else {
      setState(() {
        recordDuration = 0;
      });
    }
  }

  void _startTimer() {
    timer?.cancel();

    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => recordDuration++);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: GestureDetector(
              onTapDown: (_) {
                audioRecordingStart();
                setState(() => isRecording = true);
              },
              onTapUp: (_) {
                audioRecordingStop();

                setState(() => isRecording = false);
              },
              onTapCancel: () {
                audioRecordingStop();
                setState(() => isRecording = false);
              },
              child: Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF7F42), Color(0xFFFF4761)],
                  ),
                  borderRadius: BorderRadius.circular(64),
                  boxShadow: isRecording
                      ? [
                          BoxShadow(
                            color: const Color(0xFFFF7F42).withOpacity(0.5),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ]
                      : null,
                ),
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(48),
                  ),
                  child: const Icon(
                    Icons.mic,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (isRecording)
          const Padding(
            padding: EdgeInsets.only(bottom: 32),
            child: Text(
              'Listening...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
      ],
    );
  }
}

// Activity View
class ActivityView extends StatelessWidget {
  const ActivityView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ExercisesController.getChallengeAll.value.exercises!.length,
      itemBuilder: (context, index) {
        return ActivityCard(
          activity: ExercisesController.getChallengeAll.value.exercises![index],
        );
      },
    );
  }
}

class ActivityCard extends StatelessWidget {
  final Exercises? activity;

  const ActivityCard({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      activity!.title ?? "",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF7F42), Color(0xFFFF4761)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        activity!.type ?? "",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  activity!.description ?? "",
                  maxLines: 3,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          " ${activity!.duration} Min",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        // primary: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF7F42), Color(0xFFFF4761)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Positioned(
          //   bottom: 0,
          //   left: 0,
          //   right: 0,
          //   child: Container(
          //     height: 4,
          //     decoration: const BoxDecoration(
          //       gradient: LinearGradient(
          //         colors: [Color(0xFFFF7F42), Color(0xFFFF4761)],
          //       ),
          //       borderRadius: BorderRadius.only(
          //         bottomLeft: Radius.circular(16),
          //         bottomRight: Radius.circular(16),
          //       ),
          //     ),
          //     child: FractionallySizedBox(
          //       widthFactor: activity!.progress / 100,
          //       child: Container(
          //         decoration: BoxDecoration(
          //           gradient: const LinearGradient(
          //             colors: [Color(0xFFFF7F42), Color(0xFFFF4761)],
          //           ),
          //           borderRadius: BorderRadius.circular(2),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

// Voice Commands Widget
class VoiceCommands extends StatelessWidget {
  final List<String> commands = [
    "Start exercise",
    "How are you?",
    "I need help",
    "Tell me more"
  ];

  VoiceCommands({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, bottom: 12),
          child: Text(
            'Voice Commands',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: commands.map((command) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  command,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// Exercise Display Widget
class ExerciseDisplay extends StatelessWidget {
  final String title;
  final List<String> steps;

  const ExerciseDisplay({
    super.key,
    required this.title,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...steps.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF7F42), Color(0xFFFF4761)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
