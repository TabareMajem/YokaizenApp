/// home_screen.dart

import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:yokai_quiz_app/Widgets/progressHud.dart';
import 'package:yokai_quiz_app/config/app_tracking_config.dart';
import 'package:yokai_quiz_app/screens/Authentication/controller/auth_screen_controller.dart';
import 'package:yokai_quiz_app/screens/assistance/view/screens/assistance_screen.dart';
import 'package:yokai_quiz_app/screens/challenge/controller/challenge_controller.dart';
import 'package:yokai_quiz_app/screens/games/view/games_screen.dart';
import 'package:yokai_quiz_app/screens/navigation/view/navigation.dart';
import 'package:yokai_quiz_app/screens/todo/view/todo_screen.dart';
import 'package:yokai_quiz_app/services/app_state_manager.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/const.dart';
import 'package:yokai_quiz_app/util/constants.dart';
import 'package:yokai_quiz_app/util/text_styles.dart';
import 'package:yokai_quiz_app/Widgets/skeleton_components.dart';
import '../../../api/database_api.dart';
import '../../../api/local_storage.dart';
import '../../../global.dart';
import '../../../main.dart';
import '../../chat/controller/chat_controller.dart';
import '../../chat/view/characters_details_page.dart';
import '../../chat/view/messaging_page.dart';
import '../../read/controller/read_controller.dart';
import '../../read/view/open_story_screen.dart';
import '../../read/view/read_stories_screen.dart';
import '../../read/view/story_details_screen.dart';
import '../controller/home_controller.dart';
import '../../assistance/view/widgets/yokais_videos.dart';
import '../../../global.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late AppStateManager appStateManager;
  String deviceId = "Fetching device info...";
  String deviceName = "";
    String ipAddress = "192.168.0.1";
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isDisposed = false;
  bool _isVideoInitialized = false;
  String? _videoError;

  @override
  void initState() {
    super.initState();
    _initializeOptimizedHome();
    AppTrackingConfig.initPlugin();
    if (constants.appYokaiPath != null) {
      print('Initializing video with path: ${constants.appYokaiPath}');
      _initializeVideo();
    }
  }

  /// Initialize optimized home screen with ULTRA FAST performance (Netflix-style)
  void _initializeOptimizedHome() {
    customPrint('🚀 ULTRA FAST: Initializing home screen with Netflix-level performance');
    
    // Get the app state manager instance
    appStateManager = AppStateManager.instance;
    
    // Defer state updates to prevent setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      customPrint('⚡ ULTRA FAST: Home screen initialization callback');
      
      // Start home screen loading process (now ultra-fast)
      appStateManager.startHomeScreenLoading();
      
      // Load device info asynchronously (non-blocking)
      if (!appStateManager.hasComponentData('device_info')) {
        _loadDeviceInfo();
      }
    });
  }

  /// Load device info separately if not prefetched
  Future<void> _loadDeviceInfo() async {
    try {
      await getDeviceInfo();
      await HomeController.recordDevice(deviceId, deviceName, ipAddress);
      appStateManager.setComponentData('device_info', {
        'deviceId': deviceId,
        'deviceName': deviceName,
        'ipAddress': ipAddress,
      });
    } catch (e) {
      appStateManager.setComponentError('device_info', e.toString());
    }
  }

  Future<void> _initializeVideo() async {
    if (_isDisposed) return;

    try {
      // Extract yokai type and emotion from the path
      final pathParts = constants.appYokaiPath!.split('/');
      final fileName = pathParts.last;
      final yokaiType = fileName.split('-')[0]; // e.g., "tanuki", "water", etc.
      final emotion = fileName.split('-')[1].split('.')[0]; // e.g., "hello"

      // Get the correct video path from videoAssets
      final videoPath = videoAssets[yokaiType]?[emotion];

      if (videoPath == null) {
        setState(() {
          _videoError = 'Video path not found';
        });
        return;
      }

      _videoController = VideoPlayerController.asset(videoPath);
      await _videoController!.initialize();

      if (!_isDisposed) {
        _chewieController = ChewieController(
          videoPlayerController: _videoController!,
          autoPlay: true,
          looping: true,
          showControls: false,
          aspectRatio: 1, // Force 1:1 aspect ratio for circular shape
          autoInitialize: true,
          showControlsOnInitialize: false,
          allowMuting: true,
          allowPlaybackSpeedChanging: false,
          draggableProgressBar: false,
          zoomAndPan: false,
        );

        setState(() {
          _isVideoInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
      setState(() {
        _videoError = e.toString();
      });
    }
  }

  Future<void> _initializeApp() async {
    try {
      // Start video preloading first
      // Then continue with other initialization
      // Data fetching is now handled by the app state manager during splash
      // This method is kept for backward compatibility but is largely unused
    } catch (e) {
      debugPrint('Error in app initialization: $e');
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  String hashString(String input) {
    var bytes = utf8.encode(input);
    var digest = sha256.convert(bytes);
    return digest.toString().substring(0, 10);
  }

  fetchData() async {
    await HomeController.getLastReadChapter().then((value) async {
      await AuthScreenController.fetchData().then((value) async {
        await HomeController.incrementUserLog().then((value) async {
          await ChallengeController.getAllChallenges().then((value) async {
                      // Device info loading is now handled by app state manager
          // This section is kept for backward compatibility
          });
        });
      });
    });
  }

  Future<void> getDeviceInfo() async {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    try {
      if (GetPlatform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
        setState(() {
          deviceId = hashString('${androidInfo.device}${androidInfo.id}');
          deviceName = androidInfo.device;
        });
      } else if (GetPlatform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
        setState(() {
          deviceId = '${iosInfo.name}${iosInfo.identifierForVendor}';
          deviceName = iosInfo.name;
        });
      }
    } catch (e) {
      setState(() {
        deviceId = 'Failed to get device info: $e';
      });
    }
  }

  void _reinitializeVideo() {
    setState(() {
      _isVideoInitialized = false;
      _videoError = null;
    });
    _videoController?.dispose();
    _chewieController?.dispose();
    if (constants.appYokaiPath != null) {
      _initializeVideo();
    }
  }

  Widget getYokaiGif() {
    Widget getGifContent(String gifPath) {
      return Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: ClipOval(
          child: Image.asset(
            gifPath,
            height: 50,
            width: 50,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    switch (constants.selectedYokai) {
      case "tanuki":
        return getGifContent('gif/tanuki1.gif');
      case "water":
        return getGifContent('gif/water1.gif');
      case "spirit":
        return getGifContent('gif/spirit1.gif');
      case "purple":
        return getGifContent('gif/purple1.gif');
      case "default_yokai":
      default:
        return getGifContent('gif/yokai.gif');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Obx(() {
      return ProgressHUD(
        isLoading: appStateManager.isHomeScreenLoading,
        child: Scaffold(
          backgroundColor: colorWhite,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Profile Section - ORIGINAL
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${"Hi".tr} ${(prefs.getString(LocalStorage.username) != null) ? prefs.getString(LocalStorage.username) : ''}${(prefs.getString(LocalStorage.username) != null) ? '!' : ''}',
                          style: AppTextStyle.normalBold20.copyWith(color: headingColour),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.to(() => const YokaiAssistanceScreen());
                        },
                        child: getYokaiGif(),
                      ),
                    ],
                  ),
                  2.ph,
                  if ((ReadController.getAllStoriesBy.value.data?.length ?? 0) >
                      0)
                    Text(
                      'Trending'.tr,
                      style:
                          AppTextStyle.normalBold16.copyWith(color: coral500),
                    ),
                  1.ph,
                  if ((ReadController.getAllStoriesBy.value.data?.length ?? 0) >
                      0)
                    SizedBox(
                      height: screenSize.height / 3.6,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: ((ReadController
                                        .getAllStoriesBy.value.data?.length ??
                                    0) >
                                5)
                            ? 5
                            : ReadController.getAllStoriesBy.value.data?.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: GestureDetector(
                              onTap: () {
                                HomeController.backToHome(false);
                                ChatController.backToCharacters(false);
                                ReadController.backToStories(false);
                                ChallengeController.backToChallenge(true);
                                ReadController.storyId('');
                                // nextPage(OpenStoryScreen(
                                //   storyId: ReadController
                                //           .getAllStoriesBy.value.data?[index].id
                                //           .toString() ??
                                //       '',
                                // )
                                nextPage(StoryDetailsScreen(
                                  storyId: ReadController
                                      .getAllStoriesBy.value.data?[index].id
                                      .toString() ??
                                      '',
                                )
                                );
                                ReadController.storyId(
                                  ReadController
                                          .getAllStoriesBy.value.data?[index].id
                                          .toString() ??
                                      '',
                                );
                              },
                              child: Container(
                                height: screenSize.height / 3.7,
                                width: screenSize.width / 2.8,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: indigo50, width: 2),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.grey.withOpacity(0.05),
                                          blurRadius: 5,
                                          spreadRadius: 3)
                                    ]),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Column(
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl:
                                            "${DatabaseApi.mainUrlImage}${ReadController.getAllStoriesBy.value.data?[index].storiesImage}",
                                        placeholder: (context, url) =>
                                            const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CircularProgressIndicator(),
                                          ],
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Container(
                                          decoration: const BoxDecoration(
                                              color: AppColors.red),
                                          child: const Icon(
                                            Icons.error_outline,
                                            color: AppColors.black,
                                          ),
                                        ),
                                        height: screenSize.height / 5.3,
                                        width: screenSize.width / 2.8,
                                        fit: BoxFit.cover,
                                      ),
                                      0.5.ph,
                                      Container(
                                        alignment: Alignment.center,
                                        height: screenSize.height / 15.5,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 3),
                                          child: Text(
                                            ((ReadController
                                                                .getAllStoriesBy
                                                                .value
                                                                .data?[index]
                                                                .name
                                                                .toString() ??
                                                            '')
                                                        .length >
                                                    25)
                                                ? '${(ReadController.getAllStoriesBy.value.data?[index].name.toString() ?? '').substring(0, 25)}...'
                                                : ReadController.getAllStoriesBy
                                                        .value.data?[index].name
                                                        .toString() ??
                                                    '',
                                            textAlign: TextAlign.center,
                                            style: AppTextStyle.normalBold12
                                                .copyWith(color: headingColour),
                                            maxLines: 2,
                                          ),
                                        ),
                                      ),
                                      0.5.ph,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  2.ph,
                  Text(
                    'Explore'.tr,
                    style: AppTextStyle.normalBold16.copyWith(color: coral500),
                  ),
                  1.ph,
                  ChallengeController.getChallengeAll.value.data == null
                      ? const SizedBox()
                      : SizedBox(
                    height: screenSize.height / 14,
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: ChallengeController.getChallengeAll.value.data!.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NavigationPage(index: 3),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Container(
                              height: screenSize.height / 10,
                              width: screenSize.width / 2.8,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: AppColors.white,
                                border: Border.all(color: indigo50, width: 2),
                                image: DecorationImage(
                                  image: NetworkImage(
                                    "${DatabaseApi.mainUrlImage}${ChallengeController.getChallengeAll.value.data![index].image!}",
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.5),
                                    ],
                                  ),
                                ),
                                child: Center( // Wrap with Center widget
                                  child: Padding( // Add padding to prevent text from touching edges
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      ChallengeController.getChallengeAll.value.data![index].name!,
                                      maxLines: 1,
                                      textAlign: TextAlign.center, // Add text alignment
                                      style: AppTextStyle.normalBold12.copyWith(
                                        color: AppColors.white,
                                        shadows: [
                                          Shadow(
                                            offset: const Offset(1.0, 1.0),
                                            blurRadius: 3.0,
                                            color: Colors.black.withOpacity(0.5),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Games Section
                  2.ph,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Voice Bridge Games'.tr,
                        style: AppTextStyle.normalBold16.copyWith(color: coral500),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GamesScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'View All'.tr,
                          style: AppTextStyle.normalBold12.copyWith(color: indigo500),
                        ),
                      ),
                    ],
                  ),
                  1.ph,
                  SizedBox(
                    height: screenSize.height / 8,
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: 2, // Two games available
                      itemBuilder: (context, index) {
                        final games = [
                          {
                            'title': 'VoiceBridge Classic',
                            'icon': Icons.mic,
                            'color': indigo500,
                          },
                          {
                            'title': 'VoiceBridge Polished',
                            'icon': Icons.graphic_eq,
                            'color': coral500,
                          },
                        ];
                        final game = games[index];
                        
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const GamesScreen(),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: Container(
                              width: screenSize.width / 2.2,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: AppColors.white,
                                border: Border.all(color: indigo50, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: (game['color'] as Color).withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: (game['color'] as Color).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      game['icon'] as IconData,
                                      color: game['color'] as Color,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      game['title'] as String,
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      style: AppTextStyle.normalBold12.copyWith(
                                        color: headingColour,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  2.ph,
                  GestureDetector(
                    onTap: () {
                      HomeController.backToHome(false);
                      ChatController.backToCharacters(false);
                      ReadController.backToStories(false);
                      ChallengeController.backToChallenge(true);
                      nextPage(const TodoScreen());
                    },
                    child: Container(
                      width: double.infinity,
                      height: 110,
                      // padding: const EdgeInsets.symmetric(horizontal: 20),
                      padding: EdgeInsets.only(left: 20, right: 20, top: 10, ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromRGBO(209, 76, 223, 0.86),
                            Color.fromRGBO(135, 77, 188, 0.77),
                            Color.fromRGBO(63, 78, 153, 0.98),
                          ],
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                        ),
                        color: Colors.red,
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -40,
                            top: 0,
                            child: Opacity(
                              opacity: .2,
                              child: Image.asset(
                                'images/bgviewprofile.png',
                                width: 180, // Adjust the width as needed
                                height: 180, // Adjust the height as needed
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              1.ph,
                              Text(
                                "To Do List".tr,
                                style: AppTextStyle.normalBold18
                                    .copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                              ),
                              1.ph,
                              Row(
                                children: [
                                  Image.asset(
                                    'icons/todo.png',
                                    height: 30,
                                    width: 30,
                                  ),
                                  1.pw,
                                  Flexible(
                                    child: Text(
                                      "Complete tasks & win exclusive badges and premium subscriptions."
                                          .tr,
                                      style: AppTextStyle.normalBold14.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              1.ph
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  2.ph,
                  if ((HomeController
                              .getLastReadChapterModel.value.data?.length ??
                          0) >
                      0)
                    Text(
                      'Pick up where you left off'.tr,
                      style:
                          AppTextStyle.normalBold16.copyWith(color: coral500),
                    ),
                  1.ph,
                  if ((HomeController
                              .getLastReadChapterModel.value.data?.length ??
                          0) >
                      0)
                    SizedBox(
                      height: screenSize.height / 4,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: HomeController
                            .getLastReadChapterModel.value.data?.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () async {
                              final body = {
                                "read_status": "1",
                                "read_date": '${DateTime.now()}'
                              };
                              await ReadController.updateChapterReadStatus(
                                      context,
                                      HomeController.getLastReadChapterModel
                                              .value.data?[index].id
                                              .toString() ??
                                          '',
                                      body)
                                  .then(
                                (value) {
                                  HomeController.backToHomeChapter(true);
                                  nextPage(ReadStoriesScreen(
                                    // chapter: ReadController.chapter[index]['chapter'],
                                    chapterId: HomeController
                                            .getLastReadChapterModel
                                            .value
                                            .data?[index]
                                            .id
                                            .toString() ??
                                        '',
                                    storyName: HomeController
                                            .getLastReadChapterModel
                                            .value
                                            .data?[index]
                                            .storyName
                                            .toString() ??
                                        '',
                                  ));
                                },
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: Container(
                                height: screenSize.height / 4,
                                width: screenSize.width / 3,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: indigo50, width: 2),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.grey.withOpacity(0.05),
                                          blurRadius: 5,
                                          spreadRadius: 3)
                                    ]),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Expanded(
                                        child: Stack(
                                          alignment: Alignment.topCenter,
                                          children: [
                                            CachedNetworkImage(
                                              imageUrl:
                                                  "${DatabaseApi.mainUrlImage}${HomeController.getLastReadChapterModel.value.data?[index].storyImage.toString() ?? ''}",
                                              placeholder: (context, url) =>
                                                  const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  CircularProgressIndicator(),
                                                ],
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Container(
                                                decoration: const BoxDecoration(
                                                    color: AppColors.red),
                                                child: const Icon(
                                                  Icons.error_outline,
                                                  color: AppColors.black,
                                                ),
                                              ),
                                              height: screenSize.height / 4,
                                              width: screenSize.width / 3,
                                              fit: BoxFit.cover,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              ((HomeController
                                                                  .getLastReadChapterModel
                                                                  .value
                                                                  .data?[index]
                                                                  .name
                                                                  .toString() ??
                                                              '')
                                                          .length >
                                                      12)
                                                  ? '${(HomeController.getLastReadChapterModel.value.data?[index].name.toString() ?? '').substring(0, 12)}...'
                                                  : HomeController
                                                          .getLastReadChapterModel
                                                          .value
                                                          .data?[index]
                                                          .name
                                                          .toString() ??
                                                      '',
                                              style: AppTextStyle.normalBold12
                                                  .copyWith(
                                                      color: headingColour),
                                            ),
                                            Text(
                                              HomeController
                                                      .getLastReadChapterModel
                                                      .value
                                                      .data?[index]
                                                      .chapterNo
                                                      .toString() ??
                                                  '',
                                              style: AppTextStyle.normalBold12
                                                  .copyWith(color: greyCh),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  2.ph,
                  if ((ChatController
                              .getAllCharactersModel.value.data?.length ??
                          0) >
                      0)
                    Text(
                      'Buddies'.tr,
                      style:
                          AppTextStyle.normalBold16.copyWith(color: coral500),
                    ),
                  if ((ChatController.getAllCharactersModel.value.data?.length ?? 0) > 0)
                    1.ph,
                  if ((ChatController.getAllCharactersModel.value.data?.length ??
                          0) >
                      0)
                    SizedBox(
                      height: screenSize.height / 10,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: ((ChatController.getAllCharactersModel.value
                                        .data?.length ??
                                    0) >
                                5)
                            ? 5
                            : ChatController
                                .getAllCharactersModel.value.data?.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 30),
                            child: GestureDetector(
                              onTap: () {
                                bool isUnlocked = ChatController.getAllCharactersModel.value.data?[index].isCharacterUnlocked ?? false;
                                
                                if (isUnlocked) {
                                  // If character is unlocked, go to messaging page
                                  nextPage(MessagingPage(
                                    name: ChatController.getAllCharactersModel.value.data?[index].name.toString() ?? '',
                                    image: ChatController.getAllCharactersModel.value.data?[index].characterImage.toString() ?? '',
                                    characterId: ChatController.getAllCharactersModel.value.data?[index].id.toString() ?? '',
                                  ));
                                } else {
                                  // If character is locked, go to character details page
                                  HomeController.backToHomeFromCharactersDetails(true);
                                  ChatController.backToCharactersForCharactersDetails(false);
                                  nextPage(
                                    CharactersDetailsPage(
                                      characterId: ChatController.getAllCharactersModel.value.data?[index].id.toString() ?? '',
                                    ),
                                  );
                                }
                              },
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Stack(
                                      alignment: Alignment.bottomRight,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(35),
                                          // half of the height/width
                                          child: CachedNetworkImage(
                                            imageUrl:
                                                "${DatabaseApi.mainUrlImage}${ChatController.getAllCharactersModel.value.data?[index].characterImage.toString() ?? ''}",
                                            placeholder: (context, url) =>
                                                const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                CircularProgressIndicator(),
                                              ],
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Container(
                                              decoration: const BoxDecoration(
                                                  color: AppColors.red),
                                              child: const Icon(
                                                Icons.error_outline,
                                                color: AppColors.black,
                                              ),
                                            ),
                                            height: 60,
                                            width: 60,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        // SvgPicture.asset('icons/lock.svg')
                                        getLockImage(index),

                                      ],
                                    ),
                                  ),
                                  
                                  Text(
                                    ((ChatController.getAllCharactersModel.value
                                                        .data?[index].name
                                                        .toString() ??
                                                    '')
                                                .length >
                                            10)
                                        ? '${(ChatController.getAllCharactersModel.value.data?[index].name.toString() ?? '').substring(0, 10)}...'
                                        : ChatController.getAllCharactersModel
                                                .value.data?[index].name
                                                .toString() ??
                                            '',
                                    style: AppTextStyle.normalBold10
                                        .copyWith(color: indigo700),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  2.ph,
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  getLockImage(int index) {
    Widget lockImage = !(ChatController
        .getAllCharactersModel
        .value
        .data?[index]
        .isCharacterUnlocked ?? false) ?
    SvgPicture.asset('icons/lock.svg') : Container();
    return lockImage;
  }


}
