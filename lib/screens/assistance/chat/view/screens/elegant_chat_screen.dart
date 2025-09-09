/// elegant_chat_screen.dart -->

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:yokai_quiz_app/global.dart';
import 'package:yokai_quiz_app/screens/assistance/view/widgets/yokais_videos.dart';
import 'package:yokai_quiz_app/util/const.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../../models/chat/chat_model.dart';
import '../../../../../util/colors.dart';
import '../../../../../util/constants.dart';
import '../../../../../util/text_styles.dart';
import '../../../controller/exercises_controller.dart';
import '../../controller/yokai_chat_controller.dart';
import '../widgets/activity_card.dart';
import 'exercise_view.dart';

class MessageSendRes {
  bool? success;
  String? response;
  String? sessionId;
  String? messageId;
  EmotionalState? emotionalState;
  VideoData? video;

  MessageSendRes({
    this.success,
    this.response,
    this.sessionId,
    this.messageId,
    this.emotionalState,
    this.video,
  });

  MessageSendRes.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    response = json['response'];
    sessionId = json['sessionId'];
    messageId = json['messageId'];
    emotionalState = json['emotionalState'] != null 
        ? EmotionalState.fromJson(json['emotionalState']) 
        : null;
    video = json['video'] != null ? VideoData.fromJson(json['video']) : null;
  }
}

class EmotionalState {
  String? category;
  String? primaryEmotion;
  int? intensity;
  String? recommendedCharacter;

  EmotionalState.fromJson(Map<String, dynamic> json) {
    category = json['category'];
    primaryEmotion = json['primaryEmotion'];
    intensity = json['intensity'];
    recommendedCharacter = json['recommendedCharacter'];
  }
}

class VideoData {
  String? fileName;
  String? url;

  VideoData.fromJson(Map<String, dynamic> json) {
    fileName = json['fileName'];
    url = json['url'];
  }
}

class YokaiChat extends StatefulWidget {
  const YokaiChat({Key? key}) : super(key: key);

  @override
  _YokaiChatState createState() => _YokaiChatState();
}

class _YokaiChatState extends State<YokaiChat> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _activeTab = 'text';
  bool _isRecording = false;
  bool _isVoiceResponse = false;
  RxBool isLoading = false.obs;
  final audioRecorder = AudioRecorder();
  final audioPlayer = AudioPlayer();
  bool _isProcessing = false;
  Timer? _timer;
  String? _recordedPath;
  int _recordDuration = 0;
  String? _currentVideoUrl;
  bool _isAudioPlaying = false;
  bool _showMicButton = true;

  @override
  void initState() {
    super.initState();
    _getChatMessage();
    _initRecorder();
    _fetchExercises();
    // _checkForLatestVideoUrl();
  }

  Future<void> _fetchExercises() async {
    try {
      setState(() {
        isLoading.value = true;
      });

      // Fetch exercises from the backend
      await ExercisesController.getAllExercise();

    } catch (e) {
      print('Error fetching exercises: $e');
      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load exercises: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading.value = false;
      });
    }
  }


  Future _getChatMessage() async {
    try {
      setState(() {
        YokaiChatController.isLoading(true);
      });
      await YokaiChatController.getChatMessage(context: context);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        YokaiChatController.isLoading(false);
      });
    }
  }

  void _handleSendMessage(String text) {
    customPrint("_handleSendMessage got invoked");
    if (text.trim().isEmpty) return;

    // Check if already waiting for response
    if (YokaiChatController.messageList.isNotEmpty &&
        YokaiChatController.messageList[0].isMessageSend == true) {
      return;
    }

    // Add user message to the list with all required fields
    YokaiChatController.messageList.insert(0, Messages(
      role: "user",
      content: text,
      messageId: YokaiChatController.messageList.length + 1,
      sentAt: DateTime.now().toString(),
      isProcessed: false,
    ));

    // Set additional required properties
    YokaiChatController.messageList[0].role = "user";
    YokaiChatController.messageList[0].content = text;
    YokaiChatController.messageList[0].messageId =
        (YokaiChatController.messageList.length + 1).toString();
    YokaiChatController.messageList[0].sentAt = DateTime.now().toString();
    YokaiChatController.messageList[0].isMessageSend = true;
    YokaiChatController.messageList[0].messageType = "TEXT";

    // Clear text field
    _messageController.clear();

    // Scroll to bottom and update UI
    _scrollToBottom();
    setState(() {});

    // Send message to backend
    YokaiChatController.sendMessage(context: context, message: text).then((response) {
      if (response is Map<String, dynamic> &&
          response.containsKey('video') &&
          response['video'] != null) {
        setState(() {
          _currentVideoUrl = response['video']['url'];
        });
      }
      _scrollToBottom();
      setState(() {});
    });
  }

  // void _handleSendMessage(String text) {
  //   customPrint("_handleSendMessage got invoked text : $text");
  //   if (text.trim().isEmpty) {
  //     customPrint("inside if means, something is wrong");
  //     return;
  //   };
  //   customPrint("_handleSendMessage YokaiChatController.messageList length : ${YokaiChatController.messageList.length}");
  //   if(YokaiChatController.messageList.isNotEmpty) {
  //     if (YokaiChatController.messageList[0].isMessageSend == true) {
  //       showSucessMessage("Yokai is typing please wait".tr, colorSuccess);
  //       return;
  //     }
  //   }
  //
  //
  //   customPrint("_handleSendMessage if conditioned passed");
  //
  //   try {
  //     YokaiChatController.messageList.insert(
  //         0,
  //         Messages(
  //             role: "user",
  //             content: text,
  //             messageId: YokaiChatController.messageList.length + 1,
  //             sentAt: DateTime.now().toString(),
  //             isProcessed: false));
  //     YokaiChatController.messageList[0].role = "user";
  //     YokaiChatController.messageList[0].content = text;
  //     YokaiChatController.messageList[0].messageId =
  //         (YokaiChatController.messageList.length + 1).toString();
  //     YokaiChatController.messageList[0].sentAt = DateTime.now().toString();
  //     YokaiChatController.messageList[0].isMessageSend = true;
  //     YokaiChatController.messageList[0].messageType = "TEXT";
  //     _messageController.clear();
  //
  //     _scrollToBottom();
  //     setState(() {});
  //
  //     // Send message to backend with proper error handling
  //     customPrint("Sending message to backend: $text");
  //     YokaiChatController.sendMessage(context: context, message: text).then((response) {
  //       customPrint("Message sent, response received: $response");
  //
  //       if (response == false) {
  //         // Handle failed request
  //         customPrint("Error sending message to backend");
  //         // Remove the "typing" indicator
  //         setState(() {
  //           if (YokaiChatController.messageList.isNotEmpty) {
  //             YokaiChatController.messageList[0].isMessageSend = false;
  //           }
  //         });
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text('Failed to send message. Please try again.')),
  //         );
  //         return;
  //       }
  //
  //       // Process video URL if available
  //       if (response is Map<String, dynamic> &&
  //           response.containsKey('video') &&
  //           response['video'] != null) {
  //         customPrint("Video URL found in response: ${response['video']['url']}");
  //         setState(() {
  //           _currentVideoUrl = response['video']['url'];
  //         });
  //       }
  //
  //       _scrollToBottom();
  //       setState(() {});
  //     }).catchError((error) {
  //       customPrint("Error in sendMessage: $error");
  //       // Remove the "typing" indicator
  //       setState(() {
  //         if (YokaiChatController.messageList.isNotEmpty) {
  //           YokaiChatController.messageList[0].isMessageSend = false;
  //         }
  //       });
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('An error occurred. Please try again.')),
  //       );
  //     });
  //   } catch (e) {
  //     customPrint("Exception in _handleSendMessage: $e");
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('An error occurred. Please try again.')),
  //     );
  //   }
  // }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Widget _buildChatTab() {
    return Column(
      children: [
        Expanded(
          child: Obx(() => YokaiChatController.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
            controller: _scrollController,
            reverse: true,
            padding: const EdgeInsets.all(16),
            itemCount: YokaiChatController.messageList.length,
            itemBuilder: (context, index) {
              final message = YokaiChatController.messageList[index];
              return Column(
                children: [
                  _buildMessage(
                    message.content ?? "",
                    isUser: message.role == "user",
                  ),
                  if (index == 0 && message.isMessageSend == true)
                    _buildTypingIndicator(),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
          ),
        ),
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildMessageInput() {
    // Check if button should be disabled
    bool isButtonDisabled = YokaiChatController.messageList.isNotEmpty &&
                           YokaiChatController.messageList[0].isMessageSend;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              constraints: const BoxConstraints(maxHeight: 100),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: "Type Your Message".tr,
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: isButtonDisabled
                ? Colors.grey
                : Colors.orange.shade500,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed:
              isButtonDisabled
                ? null
                :
                  () {
                    if (_messageController.text.isNotEmpty) {
                      _handleSendMessage(_messageController.text);
                    }
                  },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Text("Yokai is typing"),
                const SizedBox(width: 8),
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.purple.shade600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _stopRecording();
    _timer?.cancel();
    audioRecorder.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw 'Microphone permission not granted';
    }
  }


// Update the _startRecording method to set proper state
  Future<void> _startRecording() async {
    try {
      if (!mounted || _isProcessing) return;

      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

      // Updated for record 5.2.1
      final config = RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      );
      
      await audioRecorder.start(config, path: path);

      setState(() {
        _isRecording = true;
        _recordDuration = 0;
        _recordedPath = path;
        _showMicButton = false;
      });

      _startTimer();
    } catch (e) {
      debugPrint('Error starting recording: $e');
    }
  }

// Update the _stopRecording method to track processing and audio playback states
  Future<void> _stopRecording() async {
    try {
      if (!mounted || !_isRecording) return;
      _timer?.cancel();
      
      final path = await audioRecorder.stop();

      setState(() {
        _isRecording = false;
        _isProcessing = true;
        _recordDuration = 0;
        _showMicButton = true;
      });

      if (path != null) {
        final file = XFile(path, mimeType: "multipart/form-data");
        if (await file.path.isNotEmpty) {
          print("this is selected yokai : ${constants.selectedYokai}");
          String voice = "alloy";
          if (constants.selectedYokai == "tanuki") {
            voice = "echo";
          } else if (constants.selectedYokai == "spirit") {
            voice = "shimmer";
          } else if (constants.selectedYokai == "water") {
            voice = "fable";
          } else if (constants.selectedYokai == "purple") {
            voice = "onyx";
          }
          final responseFile = await YokaiChatController.sendVoice(
            context: context,
            audio: file,
            voice: voice,
          );
          if (responseFile != null) {
            await _playResponseAudio(responseFile);
          }
        }
      }

      setState(() {
        _isProcessing = false;
      });
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      setState(() {
        _isProcessing = false;
      });
    }
  }

// Update the _playResponseAudio method to track audio playback
  Future<void> _playResponseAudio(File audioFile) async {
    try {
      setState(() {
        _isAudioPlaying = true;  // Set to true when audio starts playing
      });

      await audioPlayer.play(DeviceFileSource(audioFile.path));

      audioPlayer.onPlayerComplete.listen((_) {
        setState(() {
          _isAudioPlaying = false;  // Set to false when audio finishes
        });
      });
    } catch (e) {
      debugPrint('Error playing audio: $e');
      setState(() {
        _isAudioPlaying = false;
      });
    }
  }

// Update the _getVideoState method to handle different states correctly
  String _getVideoState() {
    if (_activeTab != "voice") {
      return "hello";  // Default state for non-voice tabs
    }

    if (_isRecording) {
      return "listening";  // Show listening animation during recording
    }

    if (_isProcessing) {
      return "standing";  // Show standing animation during processing
    }

    if (_isAudioPlaying) {
      return "talking";  // Show talking animation during audio playback
    }

    return "standing";  // Default to standing in voice tab
  }

// Alternatively, if you want more variety in animations, you can use this more complex version:
  String getEmotion() {
    if (_activeTab != "voice") {
      return "hello"; // Default state for non-voice tabs
    }

    if (_isRecording) {
      // During recording, show listening animation
      final selectedYokai = constants.selectedYokai;
      if (selectedYokai == "tanuki") {
        // For tanuki, we have multiple listening animations, randomly choose one
        final options = ["listening", "listening2", "listening3"];
        return options[Random().nextInt(options.length)];
      } else if (selectedYokai == "water") {
        final options = ["listening", "listening2"];
        return options[Random().nextInt(options.length)];
      }
      return "listening"; // Default for other yokais
    }

    if (_isProcessing) {
      return "standing"; // During processing, show standing animation
    }

    if (_isAudioPlaying) {
      // During response playback, show talking animation
      final selectedYokai = constants.selectedYokai;
      if (selectedYokai == "water" || selectedYokai == "purple") {
        final options = ["talking", "talking2"];
        return options[Random().nextInt(options.length)];
      }
      return "talking"; // Default talking animation
    }

    return "standing"; // Default state for voice tab
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => _recordDuration++);
    });
  }

  String _formatDuration(int duration) {
    final minutes = (duration / 60).floor().toString().padLeft(2, '0');
    final seconds = (duration % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Widget _buildVoiceTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Animated ring
              if (_isRecording)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orange.shade500.withOpacity(0.2),
                  ),
                ),
              // Mic button
              GestureDetector(
                onTap: () async {
                  if (_isRecording) {
                    await _stopRecording();
                  } else {
                    await _startRecording();
                  }
                },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _isProcessing
                      ? LinearGradient(colors: [Colors.grey, Colors.grey.withOpacity(0.7)])
                      : _isRecording
                        ? LinearGradient(colors: [Colors.red, Colors.red.shade700])
                        : LinearGradient(colors: [Colors.orange.shade500, Colors.orange.shade700]),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Icon(
                        _isRecording ? Icons.stop : Icons.mic,
                        color: Colors.white,
                        size: 40,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_isRecording)
            Column(
              children: [
                Text(
                  _formatDuration(_recordDuration),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Recording...',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
              ],
            )
          else
            Text(
              "Tap To Start Recording".tr,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExercisesTab() {
    if (isLoading.value) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final exercises = ExercisesController.getChallengeAll.value.exercises;

    if (exercises == null || exercises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No exercises available'.tr,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _fetchExercises,
              child: Text('Retry'.tr,),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchExercises,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          final exercise = exercises[index];
          return ActivityCard(
            activity: exercise,
            onPressed: () {
              // Handle exercise selection
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EnhancedExerciseView(
                    steps: exercise.steps ?? [],
                    exerciseType: exercise.type ?? '',
                    duration: exercise.duration ?? 30,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }


  Widget _buildMessage(String text, {required bool isUser}) {
    return Row(
      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isUser) _buildAvatar(isUser),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isUser ? Colors.orange.shade100 : Colors.purple.shade100,
              borderRadius: BorderRadius.circular(16).copyWith(
                topLeft: isUser ? null : Radius.zero,
                topRight: isUser ? Radius.zero : null,
              ),
            ),
            child: Text(text),
          ),
        ),
        const SizedBox(width: 8),
        if (isUser) _buildAvatar(isUser),
      ],
    );
  }

  Widget _buildAvatar(bool isUser) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isUser ? Colors.orange.shade500 : Colors.purple.shade600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Row(
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
              1.pw,
              Text(
                "Yokai Assistant".tr,
                style: AppTextStyle.normalBold16.copyWith(
                  color: coral500,
                ),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Video container with dynamic height
              getVideoContainer(isKeyboardVisible, screenHeight, screenWidth),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTabButton("text", Icons.chat_bubble_outline, "Text".tr),
                    _buildTabButton('voice', Icons.mic_none, "Voice".tr),
                    _buildTabButton('exercises', Icons.book_outlined, "Exercises".tr),
                  ],
                ),
              ),

              // Tab Content
              Expanded(
                child: IndexedStack(
                  index: _activeTab == 'text'
                      ? 0
                      : _activeTab == 'voice'
                      ? 1
                      : 2,
                  children: [
                    _buildChatTab(),
                    _buildVoiceTab(),
                    _buildExercisesTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
        resizeToAvoidBottomInset: true,
      ),
    );
  }

  Widget getVideoContainer(isKeyboardVisible, screenHeight, screenWidth) {
    Widget container = Container(
      height: isKeyboardVisible
          ? screenHeight * 0.13
          : screenHeight * 0.35,
      padding: const EdgeInsets.symmetric(horizontal: 45.0, vertical: 16.0),
      child: LayoutBuilder(
          builder: (context, constraints) {
            final size = min(constraints.maxWidth, constraints.maxHeight);
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.orange.shade400,
                    Colors.purple.shade600,
                    Colors.purple.shade900,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.shade200,
                    blurRadius: 15,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: constants.selectedYokai == "default_yokai" ?
              Stack(
                children: [
                  // Glow effect
                  Center(
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.purple.shade300.withOpacity(0.6),
                            Colors.purple.shade900.withOpacity(0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Yokai character placeholder
                  Center(
                    child: Text(
                      '妖',
                      style: TextStyle(
                        fontSize: 72,
                        color: Colors.white.withOpacity(0.9),
                        shadows: [
                          BoxShadow(
                            color: Colors.orange.shade500.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
                  : SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: ClipOval(
                  child: Center(
                      child: getYokaiVideo(size, getEmotion(), networkUrl: _currentVideoUrl)
                  ),
                ),
              ),
            );
          }
      ),
    );
    return container;
  }

  Widget getYokaiVideo(size, emotion, {String? networkUrl}) {
    Widget yokai = YokaiVideos(
      yokaiType: constants.selectedYokai,
      imageUrl: getYokaiImageUrl(constants.selectedYokai),
      index: 0,
      emotion: _getVideoState(),
      height: size,
      width: size,
      isSelected: true,
      networkUrl: networkUrl,
    );
    return yokai;
  }

  Widget _buildTabButton(String tab, IconData icon, String label) {
    final isActive = _activeTab == tab;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTab = tab;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.orange.shade500 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : Colors.grey.shade600,
              size: 20,
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String getYokaiImageUrl(String selectedYokai) {
    String yokaiImagUrl;
    if(selectedYokai=="tanuki") {
      yokaiImagUrl = "gif/tanuki1.gif";
    } else if(selectedYokai=="water") {
      yokaiImagUrl = "gif/water1.gif";
    } else if(selectedYokai=="spirit") {
      yokaiImagUrl = "gif/spirit1.gif";
    } else if(selectedYokai=="purple") {
      yokaiImagUrl = "gif/purple1.gif";
    } else {
      yokaiImagUrl = "gif/yokai.gif";
    }
    return yokaiImagUrl;
  }
}
