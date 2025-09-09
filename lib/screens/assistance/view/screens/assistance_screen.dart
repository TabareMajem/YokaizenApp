// assistance_screen.dart

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/constants.dart';
import 'package:yokai_quiz_app/util/text_styles.dart';
import 'package:yokai_quiz_app/util/const.dart';

import '../../../../global.dart';
import '../../../../services/purchase_service.dart';
import '../../../subscriptions/paywall_screens.dart';
import '../../chat/view/screens/elegant_chat_screen.dart';
import '../../controller/progress_controller.dart';
import '../../model/yokai_details.dart';
import '../widgets/yokais_videos.dart';

class YokaiAssistanceScreen extends StatefulWidget {
  const YokaiAssistanceScreen({super.key});

  @override
  State<YokaiAssistanceScreen> createState() => YokaiAssistanceScreenState();
}

class YokaiAssistanceScreenState extends State<YokaiAssistanceScreen> {
  int? selectedYokais;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isDisposed = false;

  List yokaiList = [
    "gif/tanuki1.gif",
    "gif/water1.gif",
    "gif/spirit1.gif",
    "gif/purple1.gif",
  ];

  List yokaiName = [
    "Tanuki".tr,
    "Water".tr,
    "Spirit".tr,
    "Purple".tr
  ];

  int selectedIndex = 0;
  RxBool isLoading = false.obs;
  bool isDetailView = false;
  bool isTutorialView = false;
  YokaiDetails? selectedYokaiDetails;
  String? selectedYokaiType; // To track selected yokai type
  String? selectedYokaiNameStr;

  @override
  void initState() {
    super.initState();
    // Remove the automatic _checkForYokai() call
    // _checkForYokai(); // <- REMOVE THIS LINE
    fetchProgress();
    if (constants.appYokaiPath != null) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    if (_isDisposed) return;

    try {
      _videoController = VideoPlayerController.asset(constants.appYokaiPath!);
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
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  _checkForYokai() async {
    Future.delayed(const Duration(milliseconds: 250)).then((v) async {
      if (constants.appYokaiPath == null) {
        await showCommonModelBottomSheet(context: context);
        setState(() {});
      }
    });
  }

  // Add this method to manually trigger the bottom sheet
  void showYokaiSelectionBottomSheet() {
    if (constants.appYokaiPath == null) {
      showCommonModelBottomSheet(context: context);
    }
  }

  fetchProgress() async {
    customPrint("fetchProgress got invoked");
    setState(() {
      isLoading.value = true;
    });
    await ProgressController.getAllProgress().then((v) {
      setState(() {
        isLoading.value = false;
      });
    });
  }

  void _reinitializeVideo() {
    _videoController?.dispose();
    _chewieController?.dispose();
    _initializeVideo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              "Yokai Companion".tr,
              style: AppTextStyle.normalBold16.copyWith(
                color: coral500,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () {
            Get.to(
              // () => const ChatWithYokaiScreen(),
                () => YokaiChat(),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
            height: 50,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: const Color(0xFFEF5A20),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              "Talk with Yokai".tr,
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                color: AppColors.white,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * .03,
            ),

            InkWell(
              onTap: () {
                showCommonModelBottomSheet(context: context);
              },
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  height: MediaQuery.of(context).size.height * .2,
                  width: MediaQuery.of(context).size.height * .2, // Make it square
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    // overflow: Overflow.hidden,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height * .1), // Half of height
                    child:
                    constants.appYokaiPath == null
                      ? Image.asset(
                          "gif/yokai.gif",
                          fit: BoxFit.cover,
                        )
                        : _chewieController != null &&
                        _videoController != null &&
                        _videoController!.value.isInitialized
                        ? AspectRatio(
                            aspectRatio: 1.0,
                              child: Chewie(
                                controller: _chewieController!,
                              ),
                          )
                          : Image.asset(
                              "gif/yokai.gif",
                              fit: BoxFit.cover,
                            )
                          ),
                        ),
              ),
            ),

            SizedBox(
              height: MediaQuery.of(context).size.height * .03,
            ),
            Container(
              height: 55,
              margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * .04,
              ),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color.fromRGBO(255, 242, 237, 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  commonContainer(
                    index: 0,
                    onTap: () {
                      selectedIndex = 0;
                      setState(() {});
                    },
                    title: "Overview".tr,
                  ),
                  commonContainer(
                    index: 1,
                    onTap: () {
                      selectedIndex = 1;
                      setState(() {});
                    },
                    title: "SEL Progress".tr,
                  ),
                  commonContainer(
                    index: 2,
                    onTap: () {
                      selectedIndex = 2;
                      setState(() {});
                    },
                    title: "CBT Progress".tr,
                  ),
                ],
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
            : progressContainer(selectedIndex),
          ],
        ),
      ),
    );
  }

  Widget commonContainer({
    VoidCallback? onTap,
    int? index,
    String? title,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width * .28,
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: index == selectedIndex
                ? const Color(0xFFEF5A20)
                : Colors.transparent),
        alignment: Alignment.center,
        child: Text(
          title!,
          style: GoogleFonts.montserrat(
            color: index == selectedIndex ? AppColors.white : AppColors.black,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  showCommonModelBottomSheet({
    BuildContext? context,
  }) {
    setState(() {
      isDetailView = false;
      isTutorialView = false;
    });
    showModalBottomSheet<void>(
        isScrollControlled: true,
        context: context!,
        backgroundColor: Colors.white,
        builder: (BuildContext context1) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Container(
                  height: MediaQuery.of(context).size.height * .70,
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Top Bar with Close Button
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  margin: const EdgeInsets.symmetric(vertical: 10),
                                  width: 140,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: const Color(0xffB9C4C9),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 20.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    isTutorialView
                                        ? "Get Started with Your Yokai".tr
                                        : isDetailView
                                        ? "About Your YOKAI".tr
                                        : "Select Your Prefer YOKAI".tr,
                                    style: GoogleFonts.getFont(
                                      'Rubik',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20,
                                      height: 1,
                                      color: const Color(0xFF444C5C),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      if (isTutorialView) {
                                        setState(() {
                                          isTutorialView = false;
                                          isDetailView = true;
                                        });
                                      } else if (isDetailView) {
                                        setState(() {
                                          isDetailView = false;
                                        });
                                      } else {
                                        Navigator.pop(context);
                                      }
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      height: 33,
                                      width: 33,
                                      decoration: const BoxDecoration(
                                        color: Color(0xffB9C4C9),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                          isTutorialView || isDetailView ? Icons.arrow_back : Icons.close,
                                          color: Colors.black
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Content based on view
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                if (!isDetailView && !isTutorialView) ...[
                                  const SizedBox(height: 20),
                                  // Selection Grid
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: List.generate(2, (index) {
                                          return YokaiVideos(
                                            yokaiType: index == 0 ? 'tanuki' : 'water',
                                            imageUrl: yokaiList[index],
                                            index: index,
                                            isSelected: selectedYokais == index,
                                            yokaiName: yokaiName[index],
                                            onTap: () {
                                              setState(() {
                                                selectedYokais = index;
                                              });
                                            },
                                            emotion: 'standing',
                                            height: 120,
                                            width: 120,
                                          );
                                        }),
                                      ),
                                      const SizedBox(height: 15),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: List.generate(2, (index) {
                                          return YokaiVideos(
                                            yokaiType: index == 0 ? 'spirit' : 'purple',
                                            imageUrl: yokaiList[index + 2],
                                            index: index + 2,
                                            isSelected: selectedYokais == (index + 2),
                                            yokaiName: yokaiName[index + 2],
                                            onTap: () {
                                              setState(() {
                                                selectedYokais = index + 2;
                                              });
                                            },
                                            emotion: 'standing',
                                            height: 120,
                                            width: 120,
                                          );
                                        }),
                                      ),
                                    ],
                                  ),
                                ] else if (isDetailView && !isTutorialView) ...[
                                  // Detail View
                                  Column(
                                    children: [
                                      const SizedBox(height: 20),
                                      Container(
                                        height: 200,
                                        width: 200,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: primaryColor,
                                            width: 4,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(100),
                                          child: Image.asset(
                                            selectedYokaiDetails?.imageUrl ?? "",
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Text(
                                        selectedYokaiDetails?.name ?? "",
                                        style: GoogleFonts.montserrat(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF444C5C),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        selectedYokaiDetails?.description ?? "",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ] else if (isTutorialView) ...[
                                  // Tutorial View - Third View
                                  Column(
                                    children: [
                                      const SizedBox(height: 20),
                                      // Yokai image
                                      Container(
                                        height: 180,
                                        width: 180,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: primaryColor,
                                            width: 4,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(90),
                                          child: Image.asset(
                                            'gif/${selectedYokaiType}1.gif',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      // Yokai name
                                      Text(
                                        selectedYokaiDetails?.name ?? "",
                                        style: GoogleFonts.montserrat(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF444C5C),
                                        ),
                                      ),
                                      const SizedBox(height: 32),
                                      // Tutorial items
                                      _buildTutorialItem(
                                        context,
                                        title: 'Talk with Your Yokai'.tr,
                                        description: 'Your Yokai companion is always ready to talk and help you with your emotions'.tr,
                                        icon: Icons.chat_bubble_outline,
                                      ),
                                      _buildTutorialItem(
                                        context,
                                        title: 'Track Your Progress'.tr,
                                        description: 'Monitor your emotional growth and learning journey with detailed progress tracking'.tr,
                                        icon: Icons.trending_up,
                                      ),
                                      _buildTutorialItem(
                                        context,
                                        title: 'Learn and Grow'.tr,
                                        description: 'Develop emotional intelligence and coping skills through fun interactions'.tr,
                                        icon: Icons.school_outlined,
                                      ),
                                      _buildTutorialItem(
                                        context,
                                        title: 'Daily Companion'.tr,
                                        description: 'Your Yokai will be with you every day to support your emotional wellbeing'.tr,
                                        icon: Icons.calendar_today,
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        // Button
                        Container(
                          margin: const EdgeInsets.only(top: 20, bottom: 25),
                          child: Visibility(
                            visible: isTutorialView || selectedYokais != null,
                            child: GestureDetector(
                              onTap: () async {
                                if (!isDetailView && !isTutorialView) {
                                  // First view - Show detail view
                                  final Map<int, String> yokaiTypes = {
                                    0: 'tanuki',
                                    1: 'water',
                                    2: 'spirit',
                                    3: 'purple'
                                  };
                                  String selectedType = yokaiTypes[selectedYokais] ?? 'tanuki';
                                  setState(() {
                                    selectedYokaiDetails = yokaiDetailsMap[selectedType];
                                    selectedYokaiType = selectedType;
                                    isDetailView = true;
                                  });
                                } else if (isDetailView && !isTutorialView) {
                                  // Second view - Show tutorial view
                                  setState(() {
                                    isDetailView = false;
                                    isTutorialView = true;
                                  });
                                } else if (isTutorialView) {
                                  // Third view - Directly confirm selection without paywall
                                  final Map<int, String> yokaiTypes = {
                                    0: 'tanuki',
                                    1: 'water',
                                    2: 'spirit',
                                    3: 'purple'
                                  };
                                  String yokaiType = selectedYokaiType ?? yokaiTypes[selectedYokais] ?? 'tanuki';
                                  String videoPath = videoAssets[yokaiType]?['hello'] ?? videoAssets['tanuki']!['hello']!;
                                  String selectedYokaiName = selectedYokaiDetails?.name ?? yokaiName[selectedYokais ?? 0];

                                  try {
                                    final pref = await SharedPreferences.getInstance();
                                    await pref.setString('yokaiImage', videoPath);
                                    await pref.setString('yokaiName', yokaiType);

                                    constants.appYokaiPath = videoPath;
                                    setState(() {
                                      _reinitializeVideo();
                                      constants.selectedYokai = yokaiType;
                                    });

                                    Get.back(result: 1);
                                  } catch (e) {
                                    debugPrint('Error in Yokai selection process: $e');
                                    // Handle error if needed
                                  }
                                }
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: 50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: primaryColor
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  isTutorialView ? "Continue".tr :
                                  isDetailView ? "Continue".tr : "Continue".tr,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }
          );
        }
    );
  }

  // Helper method for tutorial items
  Widget _buildTutorialItem(
      BuildContext context, {
        required String title,
        required String description,
        required IconData icon,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0, left: 16.0, right: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF2ED),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFEF5A20),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF444C5C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget imageDesign({String? imageUrl, int? index, VoidCallback? onTap, String? yokaiName}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              border: Border.all(
                width: 4,
                color: index == selectedYokais ? primaryColor : Colors.white,
              ),
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage(imageUrl!),
              ),
            ),
          ),
          const SizedBox(height: 10,),
          Text(yokaiName! ?? "", style: AppTextStyle.normalSemiBold14,),
        ],
      ),
    );
  }

  Widget progressContainer(int selectedIndex) {
    if(selectedIndex == 0) {
      return buildOverview();
    } else if(selectedIndex == 1 ) {
      return buildSocialEmotionalLearning();
    } else {
      return buildCognitiveBehavioralTheory();
    }
  }

  Widget buildProgressItem(String title, int color, double progress) {
    // Map category names to their corresponding icon paths
    print("buildProgressItem got invoked title : $title");
    
    // Define icon paths for each category type
    final Map<String, String> iconPaths = {
      // Overview icons
      'energy': 'icons/progress-icons/energy.png',
      'happiness': 'icons/progress-icons/happiness.png',
      'harmony': 'icons/progress-icons/harmony.png',
      
      // SEL icons
      'self_awareness': 'icons/progress-icons/self-awareness.png',
      'self_management': 'icons/progress-icons/self-management.png',
      'social_awareness': 'icons/progress-icons/social-awareness.png',
      'relationship_skills': 'icons/progress-icons/relationship-skills.png',
      'responsible_decision': 'icons/progress-icons/responsible-decision.png',
      
      // CBT icons
      'thought_recognition': 'icons/progress-icons/thought-recognition.png',
      'cognitive_reconstruction': 'icons/progress-icons/cognitive-reconstruction.png',
      'behavioral_activation': 'icons/progress-icons/behavioral-activation.png',
      'coping_skills': 'icons/progress-icons/coping-skills.png',
      'problem_solving': 'icons/progress-icons/problem-solving.png',
    };
    
    // Map that translates category titles to their icon keys
    final Map<String, String> categoryToIconKey = {
      // English
      'Energy': 'energy',
      'Happiness': 'happiness',
      'Harmony': 'harmony',
      'Self Awareness': 'self_awareness',
      'Self Management': 'self_management',
      'Social Awareness': 'social_awareness',
      'Relationship Skills': 'relationship_skills',
      'Responsible Decision': 'responsible_decision',
      'Thought Recognition': 'thought_recognition',
      'Cognitive Reconstruction': 'cognitive_reconstruction',
      'Behavioral Activation': 'behavioral_activation',
      'Coping Skills': 'coping_skills',
      'Problem Solving Skills': 'problem_solving',
      
      // Japanese
      'エネルギー': 'energy',
      '幸福度': 'happiness',
      '調和': 'harmony',
      '自己認識': 'self_awareness',
      '自己管理': 'self_management',
      '社会的認識': 'social_awareness',
      '対人関係スキル': 'relationship_skills',
      '責任ある意思決定': 'responsible_decision',
      '思考認識': 'thought_recognition',
      '認知の再構築': 'cognitive_reconstruction',
      '行動活性化': 'behavioral_activation',
      'コーピングスキル': 'coping_skills',
      '問題解決スキル': 'problem_solving',
    };
    
    // Get the correct icon key based on the title
    String? iconKey = categoryToIconKey[title];
    // Get the icon path or use a default
    String iconPath = iconKey != null ? iconPaths[iconKey]! : 'icons/gift1.svg';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                iconPath,
                width: 18,
                height: 18,
                // color: progressColors[color],
              ),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyle.normalRegular14.copyWith(
                fontWeight: FontWeight.w500
              )),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: progress / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(progressColors[color]),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 10),
              Text("${progress.toInt()}%"),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overall Progress'.tr,
                  style: AppTextStyle.normalBold17,
                ),
                const SizedBox(height: 20),
                Obx(() {
                  final overview = ProgressController.progressData.value.data
                      ?.overview;
                  final categories = overview?.categories ?? {};
                  final translations = overview?.translations ?? {};
                  int e = 0;
                  return Column(
                    children: categories.entries.map((entry) {
                      return buildProgressItem(
                          translations[entry.key] ?? entry.key, e++,
                          entry.value);
                    }).toList(),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSocialEmotionalLearning() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Social Emotional Learning'.tr,
                  style: AppTextStyle.normalBold17
                ),
              ],
            ),
            const SizedBox(height: 20),
            Obx(() {
              int e = 0;
              final categories = ProgressController.progressData.value.data?.sel?.categories ?? {};
              return Column(
                children: categories.entries.map((entry) {
                  return buildProgressItem(entry.key, e++, entry.value);
                }).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget buildCognitiveBehavioralTheory() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cognitive Behavioral Theory'.tr,
                  style: AppTextStyle.normalBold17,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Obx(() {
              final categories = ProgressController.progressData.value.data?.cbt?.categories ?? {};
              int e = 0;
              return Column(
                children: categories.entries.map((entry) {
                  return buildProgressItem(entry.key, e++, entry.value);
                }).toList(),
              );
            }),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
