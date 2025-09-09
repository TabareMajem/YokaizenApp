/// yokais_videos.dart

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:chewie/chewie.dart';
import 'dart:async';

import 'package:yokai_quiz_app/util/text_styles.dart';

Map<String, Map<String, String>> videoAssets = {
  "water": {
    "transitioning": "videos/water-transitioning.mp4",
    "acknowledging": "videos/water-acknowledging.mp4",
    "dreaming": "videos/water-dreaming.mp4",
    "grounding": "videos/water-grounding.mp4",
    "reflecting": "videos/water-reflecting.mp4",
    "energetic": "videos/water-energetic.mp4",
    "comforting": "videos/water-comforting.mp4",
    "focused": "videos/water-focused.mp4",
    "playful": "videos/water-playful.mp4",
    "empathizing": "videos/water-empathizing.mp4",
    "proud": "videos/water-proud.mp4",
    "learning": "videos/water-learning.mp4",
    "meditating": "videos/water-meditating.mp4",
    "encouraging": "videos/water-encouraging.mp4",
    "celebrating": "videos/water-celebrating.mp4",
    "nervous": "videos/water-nervous1.mp4",
    "nervous2": "videos/water-nervous2.mp4",
    "calm": "videos/water-calm.mp4",
    "thinking": "videos/water-thinking1.mp4",
    "thinking2": "videos/water-thinking2.mp4",
    "sleeping": "videos/water-sleeping.mp4",
    "hello": "videos/water-hello.mp4",
    "low_energy": "videos/water-low-energy1.mp4",
    "low_energy2": "videos/water-low-energy2.mp4",
    "low_energy3": "videos/water-low-energy3.mp4",
    "low_energy4": "videos/water-low-energy4.mp4",
    "low_harmony": "videos/water-low-harmony.mp4",
    "low_happiness": "videos/water-low-happiness.mp4",
    "talking": "videos/water-talking1.mp4",
    "talking2": "videos/water-talking2.mp4",
    "listening": "videos/water-listening1.mp4",
    "listening2": "videos/water-listening2.mp4",
    "standing": "videos/water-standing.mp4",
  },
  "tanuki": {
    "transitioning": "videos/tanuki-transitioning.mp4",
    "acknowledging": "videos/tanuki-acknowledging.mp4",
    "dreaming": "videos/tanuki-dreaming.mp4",
    "grounding": "videos/tanuki-grounding.mp4",
    "reflecting": "videos/tanuki-reflecting.mp4",
    "energetic": "videos/tanuki-energetic.mp4",
    "comforting": "videos/tanuki-comforting.mp4",
    "focused": "videos/tanuki-focused.mp4",
    "playful": "videos/tanuki-playful.mp4",
    "empathizing": "videos/tanuki-empathizing.mp4",
    "proud": "videos/tanuki-proud.mp4",
    "learning": "videos/tanuki-learning.mp4",
    "meditating": "videos/tanuki-meditating.mp4",
    "encouraging": "videos/tanuki-encouraging.mp4",
    "celebrating": "videos/tanuki-celebrating1.mp4",
    "celebrating2": "videos/tanuki-celebrating2.mp4",
    "nervous": "videos/tanuki-nervous1.mp4",
    "nervous2": "videos/tanuki-nervous2.mp4",
    "calm": "videos/tanuki-calm.mp4",
    "calm2": "videos/tanuki-calm2.mp4",
    "thinking": "videos/tanuki-thinking1.mp4",
    "thinking2": "videos/tanuki-thinking2.mp4",
    "sleeping": "videos/tanuki-sleeping.mp4",
    "hello": "videos/tanuki-hello1.mp4",
    "hello2": "videos/tanuki-hello2.mp4",
    "low_energy": "videos/tanuki-low-energy1.mp4",
    "low_energy2": "videos/tanuki-low-energy2.mp4",
    "low_energy3": "videos/tanuki-low-energy3.mp4",
    "low_energy4": "videos/tanuki-low-energy4.mp4",
    "low_harmony": "videos/tanuki-low-harmony.mp4",
    "low_happiness": "videos/tanuki-low-happiness.mp4",
    "talking": "videos/tanuki-talking.mp4",
    "listening": "videos/tanuki-listening1.mp4",
    "listening2": "videos/tanuki-listening2.mp4",
    "listening3": "videos/tanuki-listening3.mp4",
    "standing": "videos/tanuki-standing.mp4",
    "sad": "videos/tanuki-sad.mp4",
    "0": "videos/tanuki0.mp4",
    "1": "videos/tanuki.mp4",
  },
  "spirit": {
    "transitioning": "videos/spirit-transitioning.mp4",
    "acknowledging": "videos/spirit-acknowledging.mp4",
    "dreaming": "videos/spirit-dreaming.mp4",
    "grounding": "videos/spirit-grounding.mp4",
    "reflecting": "videos/spirit-reflecting.mp4",
    "energetic": "videos/spirit-energetic.mp4",
    "comforting": "videos/spirit-comforting.mp4",
    "focused": "videos/spirit-focused1.mp4",
    "focused2": "videos/spirit-focused2.mp4",
    "playful": "videos/spirit-playful.mp4",
    "empathizing": "videos/spirit-empathizing.mp4",
    "proud": "videos/spirit-proud.mp4",
    "learning": "videos/spirit-learning.mp4",
    "meditating": "videos/spirit-meditating.mp4",
    "encouraging": "videos/spirit-encouraging.mp4",
    "celebrating": "videos/spirit-celebrating.mp4",
    "nervous": "videos/spirit-nervouse.mp4",
    "calm": "videos/spirit-calm.mp4",
    "thinking": "videos/spirit-thinking1.mp4",
    "thinking2": "videos/spirit-thinking2.mp4",
    "hello": "videos/spirit-hello.mp4",
    "low_energy": "videos/spirit-low-energy1.mp4",
    "low_energy2": "videos/spirit-low-energy2.mp4",
    "low_harmony": "videos/spirit-low-harmony.mp4",
    "low_happiness": "videos/spirit-low-happiness.mp4",
    "talking": "videos/spirit-talking.mp4",
    "listening": "videos/spirit-listening.mp4",
    "standing": "videos/spirit-standing.mp4",
    "0": "videos/spirit0.mp4",
    "1": "videos/spirit1.mp4",
  },
  "purple": {
    "transitioning": "videos/purple-transitioning.mp4",
    "acknowledging": "videos/purple-acknowledging.mp4",
    "dreaming": "videos/purple-dreaming.mp4",
    "grounding": "videos/purple-grounding.mp4",
    "reflecting": "videos/purple-reflecting.mp4",
    "energetic": "videos/purple-energetic.mp4",
    "comforting": "videos/purple-comforting.mp4",
    "focused": "videos/purple-focused.mp4",
    "playful": "videos/purple-playful.mp4",
    "empathizing": "videos/purple-empathizing.mp4",
    "proud": "videos/purple-proud.mp4",
    "learning": "videos/purple-learning.mp4",
    "meditating": "videos/purple-meditating.mp4",
    "encouraging": "videos/purple-encouraging.mp4",
    "celebrating": "videos/purple-celebrating1.mp4",
    "celebrating2": "videos/purple-celebrating2.mp4",
    "nervous": "videos/purple-nervous1.mp4",
    "nervous2": "videos/purple-nervous2.mp4",
    "nervous3": "videos/purple-nervous3.mp4",
    "calm": "videos/purple-calm.mp4",
    "thinking": "videos/purple-thinking.mp4",
    "sleeping": "videos/purple-sleeping.mp4",
    "hello": "videos/purple-hello.mp4",
    "low_energy": "videos/purple-low-energy1.mp4",
    "low_energy2": "videos/purple-low-energy2.mp4",
    "low_harmony": "videos/purple-low-harmony1.mp4",
    "low_harmony2": "videos/purple-low-harmony2.mp4",
    "low_happiness": "videos/purple-low-happiness.mp4",
    "talking": "videos/purple-talking1.mp4",
    "talking2": "videos/purple-talking2.mp4",
    "listening": "videos/purple-listening.mp4",
    "standing": "videos/purple-standing1.mp4",
    "standing2": "videos/purple-standing2.mp4",
    "0": "videos/purple.mp4",
  }
};

class YokaiVideos extends StatefulWidget {
  final String yokaiType;
  final String imageUrl;
  final int index;
  final VoidCallback? onTap;
  final String? yokaiName;
  final bool isSelected;
  final String emotion;
  final double height;
  final double width;
  final String? networkUrl;

  const YokaiVideos({
    required this.yokaiType,
    required this.imageUrl,
    required this.index,
    required this.emotion,
    required this.height,
    required this.width,
    this.onTap,
    this.yokaiName,
    required this.isSelected,
    this.networkUrl,
    Key? key,
  }) : super(key: key);

  @override
  _YokaiVideosState createState() => _YokaiVideosState();
}

class _YokaiVideosState extends State<YokaiVideos> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isDisposed = false;
  bool _isNetworkVideo = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    if (_isDisposed) return;

    try {
      // Check if we have a network URL first
      if (widget.networkUrl != null && widget.networkUrl!.isNotEmpty) {
        _isNetworkVideo = true;
        _videoController = VideoPlayerController.network(widget.networkUrl!);
      } else {
        // Fall back to asset videos if no network URL is available
        final videoPath = videoAssets[widget.yokaiType.toLowerCase()]?[widget.emotion];

        print("Using local video asset: $videoPath");

        if (videoPath != null) {
          _videoController = VideoPlayerController.asset(videoPath);
        } else {
          setState(() => _isLoading = false);
          return;
        }
      }

      // Initialize the controller
      await _videoController!.initialize();

      if (!_isDisposed) {
        _chewieController = ChewieController(
          videoPlayerController: _videoController!,
          autoPlay: true,
          looping: true,
          showControls: false,
          aspectRatio: _videoController!.value.aspectRatio,
          autoInitialize: true,
          showControlsOnInitialize: false,
          allowMuting: true,
          allowPlaybackSpeedChanging: false,
          draggableProgressBar: false,
          zoomAndPan: false,
        );

        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
      setState(() => _isLoading = false);

      // If network video fails, try falling back to asset video
      if (_isNetworkVideo && !_isDisposed) {
        _isNetworkVideo = false;
        _videoController?.dispose();
        _videoController = null;
        _chewieController?.dispose();
        _chewieController = null;

        // Try initializing with asset instead
        final videoPath = videoAssets[widget.yokaiType.toLowerCase()]?[widget.emotion];
        if (videoPath != null) {
          try {
            _videoController = VideoPlayerController.asset(videoPath);
            await _videoController!.initialize();

            if (!_isDisposed) {
              _chewieController = ChewieController(
                videoPlayerController: _videoController!,
                autoPlay: true,
                looping: true,
                showControls: false,
                aspectRatio: _videoController!.value.aspectRatio,
                autoInitialize: true,
                showControlsOnInitialize: false,
                allowMuting: true,
                allowPlaybackSpeedChanging: false,
                draggableProgressBar: false,
                zoomAndPan: false,
              );
              setState(() {});
            }
          } catch (fallbackError) {
            debugPrint('Error initializing fallback video: $fallbackError');
          }
        }
      }
    }
  }

  @override
  void didUpdateWidget(YokaiVideos oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Reinitialize video if networkUrl or emotion changes
    if (widget.networkUrl != oldWidget.networkUrl ||
        widget.emotion != oldWidget.emotion) {
      _disposeControllers();
      _initializeVideo();
    }
  }

  void _disposeControllers() {
    _videoController?.dispose();
    _videoController = null;
    _chewieController?.dispose();
    _chewieController = null;
  }

  @override
  void dispose() {
    _isDisposed = true;
    _disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isVideoReady = _chewieController != null &&
        _videoController != null &&
        _videoController!.value.isInitialized;

    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        children: [
          Container(
            height: widget.height,
            width: widget.width,
            decoration: BoxDecoration(
              border: Border.all(
                width: 4,
                color: widget.isSelected ? Colors.orange.shade500 : Colors.white,
              ),
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: _isLoading
                  ? Center(
                child: CircularProgressIndicator(
                  color: Colors.orange.shade500,
                ),
              )
                  : isVideoReady
                  ? Chewie(controller: _chewieController!)
                  : Image.asset(
                widget.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.yokaiName ?? "",
            style: AppTextStyle.normalBold16,
          ),
        ],
      ),
    );
  }
}
