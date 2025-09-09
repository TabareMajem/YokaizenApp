import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import '../../controller/yokai_chat_controller.dart';

class VoiceViewScreen extends StatefulWidget {
  final ScrollController? scrollController;
  final Function? onRecordingComplete;
  const VoiceViewScreen({
    Key? key,
    this.onRecordingComplete,
    @required this.scrollController,
  }) : super(key: key);

  @override
  State<VoiceViewScreen> createState() => _VoiceViewScreenState();
}

class _VoiceViewScreenState extends State<VoiceViewScreen> {
  bool isRecording = false;
  bool isProcessing = false;
  final audioRecorder = AudioRecorder();
  final audioPlayer = AudioPlayer();
  int recordDuration = 0;
  Timer? timer;
  String? recordedPath;

  @override
  void initState() {
    super.initState();
    initRecorder();
  }

  @override
  void dispose() {
    stopRecording();
    timer?.cancel();
    audioRecorder.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  Future<void> initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw 'Microphone permission not granted';
    }
  }

  Future<void> startRecording() async {
    try {
      if (!mounted || isProcessing) return;

      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

      final config = RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      );
      
      await audioRecorder.start(config, path: path);

      setState(() {
        isRecording = true;
        recordDuration = 0;
        recordedPath = path;
      });

      _startTimer();
    } catch (e) {
      debugPrint('Error starting recording: $e');
    }
  }

  Future<void> stopRecording() async {
    try {
      if (!mounted || !isRecording) return;
      timer?.cancel();
      
      final path = await audioRecorder.stop();

      setState(() {
        isRecording = false;
        isProcessing = true;
        recordDuration = 0;
      });

      if (path != null) {
        final file = XFile(path, mimeType: "multipart/form-data");

        if (await file.path.isNotEmpty) {
          final responseFile = await YokaiChatController.sendVoice(context: context, audio: file);
          if (responseFile != null) {
            await playAudioFile(responseFile);
          }
        }
      }

      setState(() {
        isProcessing = false;
      });
    } catch (e) {
      debugPrint('Error stopping recording: $e');
    }
  }

  Future<void> playAudioFile(File audioFile) async {
    try {
      await audioPlayer.play(DeviceFileSource(audioFile.path));
      audioPlayer.onPlayerComplete.listen((event) {
        setState(() {
          isProcessing = false;
        });
      });
    } catch (e) {
      debugPrint('Error playing audio file: $e');
    }
  }

  void _startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => recordDuration++);
    });
  }

  String _formatDuration(int duration) {
    final minutes = (duration / 60).floor().toString().padLeft(2, '0');
    final seconds = (duration % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Center(
            child: GestureDetector(
              onTap: () {
                if (isRecording) {
                  stopRecording();
                } else {
                  startRecording();
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  gradient: isProcessing ?
                    LinearGradient(colors: [ Colors.grey, Colors.transparent]) :
                    isRecording ?
                      LinearGradient(colors: [ Colors.red,Colors.grey]) :
                      LinearGradient(colors: [ Color(0xFFFF7F42), Color(0xFFFF4761) ] ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: isProcessing
                    // ? Lottie.asset('animations/loader4.json')
                    ? const CircularProgressIndicator(color: Colors.deepOrange)
                    : Icon(
                  isRecording ? Icons.stop : Icons.mic,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ),
        ),
        if (isRecording)
          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              children: [
                Text(
                  _formatDuration(recordDuration),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Recording...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}