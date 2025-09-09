/// read_stories_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:yokai_quiz_app/Widgets/new_button.dart';
import 'package:yokai_quiz_app/Widgets/progressHud.dart';
import 'package:yokai_quiz_app/global.dart';
import 'package:yokai_quiz_app/screens/read/view/start_activity_page.dart';
import 'package:yokai_quiz_app/screens/read/view/story_details_screen.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/const.dart';

import '../../../Widgets/second_custom_button.dart';
import '../../../api/database_api.dart';
import '../../../util/constants.dart';
import '../../../util/text_styles.dart';
import '../../home/controller/home_controller.dart';
import '../../navigation/view/navigation.dart';
import '../controller/read_controller.dart';
import 'chapter_screen.dart';

class ReadStoriesScreen extends StatefulWidget {
  String chapterId;
  String storyName;

  ReadStoriesScreen({
    super.key,
    required this.chapterId,
    required this.storyName,
  });

  @override
  State<ReadStoriesScreen> createState() => _ReadStoriesScreenState();
}

class _ReadStoriesScreenState extends State<ReadStoriesScreen> {
  RxBool isLoading = false.obs;

  // Add a boolean to track the PDF view mode
  RxBool isScrollMode = false.obs;

  // Add loading state for PDF
  RxBool isPdfLoading = false.obs;

  // Add initial PDF loading state
  RxBool isInitialPdfLoading = true.obs;

  // Add PDF loaded state to prevent reloading
  RxBool isPdfFullyLoaded = false.obs;

  // Create a unique key to force PDF rebuild when mode changes
  Key? pdfKey;

  // Track the current PDF path to detect changes
  String? currentPdfPath;

  // Cache for loaded PDFs
  Map<String, bool> pdfCache = {};

  String formUrl = constants.deviceLanguage == "en"
      ? '${DatabaseApi.mainUrlImage}${(ReadController.getChapterByChapterId.value.data?.chapterDocument.toString() ?? '').trimLeft().trimRight()}'
      : '${DatabaseApi.mainUrlImage}${(ReadController.getChapterByChapterId.value.data?.chapterDocumentJapanese.toString() ?? '').trimLeft().trimRight()}';

  fetchData() async {
    isLoading(true);
    await ReadController.getAllChapterByChapterId(widget.chapterId)
        .then((value) async {
      customPrint(
          'chapterDocumentEnglish :: ${DatabaseApi.mainUrlImage}${(ReadController.getChapterByChapterId.value.data?.chapterDocument.toString() ?? '').trimLeft().trimRight()}');
      await ReadController.getActivityDetailsByChapterId(widget.chapterId).then(
        (value) {
          isLoading(false);
          // Reset PDF loading states for new chapter
          isInitialPdfLoading(true);
          isPdfFullyLoaded(false);
        },
      );
    });
  }

  @override
  void initState() {
    super.initState();
    // Initialize PDF key
    pdfKey = Key('pdf_initial_${DateTime.now().millisecondsSinceEpoch}');
    fetchData();
  }

  @override
  void dispose() {
    // Clear any loading states and cache
    isPdfLoading.value = false;
    isInitialPdfLoading.value = false;
    isPdfFullyLoaded.value = false;
    pdfCache.clear();
    customPrint('ReadStoriesScreen disposed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                elevation: 1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Container(
                  width: MediaQuery.of(context).size.width / 1.4,
                  height: MediaQuery.of(context).size.height / 3,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                            offset: const Offset(12, 26),
                            blurRadius: 50,
                            spreadRadius: 0,
                            color: Colors.grey.withOpacity(.1)),
                      ]),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        "images/appLogo_yokai.png",
                        height: 50,
                        width: 55,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        "Exit Chapter ?".tr,
                        style: AppTextStyle.normalBold20
                            .copyWith(color: includedColor),
                      ),
                      const SizedBox(
                        height: 3.5,
                      ),
                      Text(
                        "An activity is coming up ahead ! ".tr,
                        style: AppTextStyle.normalRegular14
                            .copyWith(color: bordertext),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SecondCustomButton(
                            onPressed: () {
                              if (HomeController.backToHomeChapter.isFalse) {
                                nextPageOff(
                                    context,
                                    StoryDetailsScreen(
                                      storyId: ReadController.storyId.value,
                                      // storyName: widget.storyName,
                                    ));
                              } else {
                                HomeController.backToHomeChapter(false);
                                nextPageOff(
                                  context,
                                  NavigationPage(index: 0),
                                );
                              }
                            },
                            width: screenSize.width / 4,
                            text: "Confirm".tr,
                            textSize: 14,
                          ),
                          CustomButton(
                            onPressed: () {
                              Get.back();
                            },
                            text: 'Cancel'.tr,
                            colorText: ironColor,
                            textSize: 14,
                            color: indigo50,
                            border: Border.all(color: colorBorder),
                            width: screenSize.width / 4,
                            mainAxisAlignment: MainAxisAlignment.center,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            });
        return false;
      },
      child: Obx(() {
        return ProgressHUD(
          isLoading: isLoading.value,
          child: Scaffold(
            backgroundColor: colorWhite,
            // floatingActionButton can be kept if needed
            // floatingActionButton: GestureDetector(
            //   onTap: () {
            //     ReadController.pdfPageNumber(1);
            //   },
            //   child: SvgPicture.asset('icons/arrowUp.svg'),
            // ),
            body: Column(
              children: [
                // Compact header - taking minimal space
                Container(
                  padding: const EdgeInsets.only(
                      right: 16, left: 16, top: 50, bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // First row: Back button + Title + Mode Toggle
                      Row(
                        children: [
                          // Back button - compact
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Dialog(
                                      elevation: 1,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                1.4,
                                        height:
                                            MediaQuery.of(context).size.height /
                                                3,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15, vertical: 10),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                            boxShadow: [
                                              BoxShadow(
                                                  offset: const Offset(12, 26),
                                                  blurRadius: 50,
                                                  spreadRadius: 0,
                                                  color: Colors.grey
                                                      .withOpacity(.1)),
                                            ]),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Image.asset(
                                              "images/appLogo_yokai.png",
                                              height: 50,
                                              width: 55,
                                            ),
                                            const SizedBox(
                                              height: 15,
                                            ),
                                            Text(
                                              "Exit Story ?".tr,
                                              style: AppTextStyle.normalBold20
                                                  .copyWith(
                                                      color: includedColor),
                                            ),
                                            const SizedBox(
                                              height: 3.5,
                                            ),
                                            Text(
                                              "An activity is coming up ahead ! "
                                                  .tr,
                                              style: AppTextStyle
                                                  .normalRegular14
                                                  .copyWith(color: bordertext),
                                            ),
                                            const SizedBox(
                                              height: 15,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                SecondCustomButton(
                                                  onPressed: () {
                                                    if (HomeController
                                                        .backToHomeChapter
                                                        .isFalse) {
                                                      nextPageOff(
                                                          context,
                                                          StoryDetailsScreen(
                                                            storyId:
                                                                ReadController
                                                                    .storyId
                                                                    .value,
                                                            // storyName: widget
                                                            //     .storyName,
                                                          ));
                                                    } else {
                                                      HomeController
                                                          .backToHomeChapter(
                                                              false);
                                                      Navigator.pop(context);
                                                    }
                                                  },
                                                  width: screenSize.width / 4,
                                                  text: "Confirm".tr,
                                                  textSize: 14,
                                                ),
                                                CustomButton(
                                                  onPressed: () {
                                                    Get.back();
                                                  },
                                                  text: 'Cancel'.tr,
                                                  colorText: ironColor,
                                                  textSize: 14,
                                                  color: indigo50,
                                                  border: Border.all(
                                                      color: colorBorder),
                                                  width: screenSize.width / 4,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                              // Get.back();
                            },
                            child: SvgPicture.asset(
                              'icons/arrowLeft.svg',
                              height: 28,
                              width: 28,
                            ),
                          ),

                          SizedBox(width: 12),

                          // Title - compact
                          Expanded(
                            child: Text(
                              getChapterName(),
                              style: AppTextStyle.normalBold14
                                  .copyWith(color: coral500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          SizedBox(width: 12),

                          // Mode toggle - compact and in header
                          Obx(() => Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: indigo50,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: primaryColor.withOpacity(0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        if (!isPdfLoading.value) {
                                          switchViewMode(false);
                                        }
                                      },
                                      child: AnimatedContainer(
                                        duration: Duration(milliseconds: 200),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: !isScrollMode.value
                                              ? primaryColor
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.chrome_reader_mode,
                                          size: 14,
                                          color: !isScrollMode.value
                                              ? Colors.white
                                              : primaryColor,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        if (!isPdfLoading.value) {
                                          switchViewMode(true);
                                        }
                                      },
                                      child: AnimatedContainer(
                                        duration: Duration(milliseconds: 200),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isScrollMode.value
                                              ? primaryColor
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.vertical_align_center,
                                          size: 14,
                                          color: isScrollMode.value
                                              ? Colors.white
                                              : primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),

                      SizedBox(height: 8),
                      // Remove the Previous/Next buttons from here - they'll go to bottom
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     (ReadController.chapterIdIndexForNextPage.value + 1 >=
                      //         (ReadController.getChapterByStoryId.value.data
                      //             ?.chapterData!.length ??
                      //             0))
                      //         ? const SizedBox(width: 80)
                      //         : CustomButton(
                      //       onPressed: () async {
                      //         isLoading(true);
                      //         final int? index;
                      //         if (ReadController.chapterIdIndexForNextPage
                      //             .value +
                      //             1 >=
                      //             (ReadController
                      //                 .getChapterByStoryId
                      //                 .value
                      //                 .data
                      //                 ?.chapterData!
                      //                 .length ??
                      //                 0)) {
                      //           index = 0;
                      //           customPrint(
                      //               'chapterIdIndexForNextPage : minus');
                      //           showErrorMessage(
                      //               'No Previous Chapter Found',
                      //               errorColor);
                      //           isLoading(false);
                      //           return;
                      //         } else {
                      //           index = ReadController
                      //               .chapterIdIndexForNextPage.value +
                      //               1;
                      //           ReadController.chapterIdIndexForNextPage(
                      //               ReadController
                      //                   .chapterIdIndexForNextPage
                      //                   .value +
                      //                   1);
                      //           customPrint(
                      //               'chapterIdIndexForNextPage : plus');
                      //           customPrint(
                      //               'chapterIdIndexForNextPage : ${ReadController.chapterIdIndexForNextPage.value}');
                      //           customPrint(
                      //               'chapterIdIndexForNextPage : ${ReadController.getChapterByStoryId.value.data?.chapterData!.length}');
                      //         }
                      //         await ReadController
                      //             .getAllChapterByChapterId(
                      //             ReadController
                      //                 .getChapterByStoryId
                      //                 .value
                      //                 .data
                      //                 ?.chapterData?[index]
                      //                 .id
                      //                 .toString() ??
                      //                 '')
                      //             .then((value) {
                      //           customPrint('chapterDocumentEnglish :: $formUrl');
                      //           isLoading(false);
                      //         });
                      //       },
                      //       text: 'Previous'.tr,
                      //       colorText: primaryColor,
                      //       textSize: 12,
                      //       iconSvgPath: 'icons/arrowLeft.svg',
                      //       colorSvg: primaryColor,
                      //       color: indigo50,
                      //       border: Border.all(color: indigo700),
                      //       width: screenSize.width / 3.2,
                      //       height: 36,
                      //       mainAxisAlignment: MainAxisAlignment.center,
                      //     ),
                      //     (ReadController.chapterIdIndexForNextPage.value <= 0)
                      //         ? const SizedBox(width: 80)
                      //         : SecondCustomButton(
                      //       onPressed: () async {
                      //         isLoading(true);
                      //         final int? index;
                      //         if (ReadController
                      //             .chapterIdIndexForNextPage.value <=
                      //             0) {
                      //           index = 0;
                      //           customPrint(
                      //               'chapterIdIndexForNextPage : 0');
                      //           showErrorMessage(
                      //               'No Next Chapter Found', errorColor);
                      //           isLoading(false);
                      //           return;
                      //         } else {
                      //           index = ReadController
                      //               .chapterIdIndexForNextPage.value -
                      //               1;
                      //           ReadController.chapterIdIndexForNextPage(
                      //               ReadController
                      //                   .chapterIdIndexForNextPage
                      //                   .value -
                      //                   1);
                      //           customPrint(
                      //               'chapterIdIndexForNextPage : minus');
                      //           customPrint(
                      //               'chapterIdIndexForNextPage : ${ReadController.chapterIdIndexForNextPage.value}');
                      //           customPrint(
                      //               'chapterIdIndexForNextPage : ${ReadController.getChapterByStoryId.value.data?.chapterData!.length}');
                      //         }
                      //         await ReadController
                      //             .getAllChapterByChapterId(
                      //             ReadController
                      //                 .getChapterByStoryId
                      //                 .value
                      //                 .data
                      //                 ?.chapterData?[index]
                      //                 .id
                      //                 .toString() ??
                      //                 '')
                      //             .then((value) {
                      //           customPrint(
                      //               'chapterDocumentEnglish :: $formUrl');
                      //           isLoading(false);
                      //         });
                      //       },
                      //       width: screenSize.width / 3.2,
                      //       height: 36,
                      //       iconSvgPath: 'icons/arrowRight.svg',
                      //       text: "Next".tr,
                      //       textSize: 12,
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),

                // PDF Viewer with maximum space (90% of available screen)
                getPdf(),

                // Modern fixed bottom navigation - always show all 3 positions
                Obx(() {
                  bool hasPrevious =
                      ReadController.chapterIdIndexForNextPage.value + 1 <
                          (ReadController.getChapterByStoryId.value.data
                                  ?.chapterData!.length ??
                              0);
                  bool hasNext =
                      ReadController.chapterIdIndexForNextPage.value > 0;
                  bool hasActivity = widget.chapterId != '' &&
                      widget.chapterId != 'null' &&
                      ReadController.isActivityAvailable.isTrue;

                  return Container(
                    margin: EdgeInsets.fromLTRB(8, 15, 8, 15), // Reduced horizontal margins
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Changed to spaceEvenly for better distribution
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Previous Button - Flexible width
                        Flexible(
                          flex: 2, // Give it 2 parts of the available space
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: screenSize.width * 0.28, // Reduced max width
                              minWidth: screenSize.width * 0.22, // Added min width
                            ),
                            child: hasPrevious
                                ? Material(
                                    elevation: 4,
                                    shadowColor: Colors.black.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(25),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(25),
                                        color: Colors.white,
                                        border: Border.all(
                                          color: Colors.grey.withOpacity(0.15),
                                          width: 1,
                                        ),
                                      ),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(25),
                                        onTap: () async {
                                          isLoading(true);
                                          int index = ReadController
                                                  .chapterIdIndexForNextPage
                                                  .value +
                                              1;
                                          ReadController
                                              .chapterIdIndexForNextPage(index);

                                          await ReadController
                                                  .getAllChapterByChapterId(
                                                      ReadController
                                                              .getChapterByStoryId
                                                              .value
                                                              .data
                                                              ?.chapterData?[
                                                                  index]
                                                              .id
                                                              .toString() ??
                                                          '')
                                              .then((value) async {
                                            await ReadController
                                                .getActivityDetailsByChapterId(
                                                    ReadController
                                                            .getChapterByStoryId
                                                            .value
                                                            .data
                                                            ?.chapterData?[index]
                                                            .id
                                                            .toString() ??
                                                        '');
                                            isInitialPdfLoading.value = true;
                                            isPdfFullyLoaded.value = false;
                                            isLoading(false);
                                          });
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 8), // Reduced padding
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.chevron_left_rounded,
                                                color: Colors.grey[700],
                                                size: 16, // Reduced icon size
                                              ),
                                              SizedBox(width: 2),
                                              Flexible(
                                                child: Text(
                                                  'Previous'.tr,
                                                  style: TextStyle(
                                                    color: Colors.grey[700],
                                                    fontSize: 11, // Reduced font size
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 8), // Reduced padding
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      color: Colors.grey.withOpacity(0.05),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.chevron_left_rounded,
                                          color: Colors.grey.withOpacity(0.3),
                                          size: 16, // Reduced icon size
                                        ),
                                        SizedBox(width: 2),
                                        Flexible(
                                          child: Text(
                                            'Previous'.tr,
                                            style: TextStyle(
                                              color: Colors.grey.withOpacity(0.3),
                                              fontSize: 11, // Reduced font size
                                              fontWeight: FontWeight.w500,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ),

                        // Start Activity Button - Center with flexible width
                        Flexible(
                          flex: 3, // Give it 3 parts of the available space
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: screenSize.width * 0.4, // Reduced max width
                              minWidth: screenSize.width * 0.32, // Added min width
                            ),
                            child: hasActivity
                                ? Material(
                                    elevation: 8,
                                    shadowColor: primaryColor.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(28),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(28),
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            primaryColor,
                                            primaryColor.withOpacity(0.85),
                                          ],
                                        ),
                                      ),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(28),
                                        onTap: () {
                                          nextPage(StartActivityPage(
                                            storyName: widget.storyName,
                                            chapter: ReadController
                                                    .getChapterByChapterId
                                                    .value
                                                    .data
                                                    ?.name
                                                    .toString() ??
                                                '',
                                            chapterId: widget.chapterId,
                                          ));
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 10), // Reduced padding
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.play_arrow_rounded,
                                                color: Colors.white,
                                                size: 16, // Reduced icon size
                                              ),
                                              SizedBox(width: 4), // Reduced spacing
                                              Flexible(
                                                child: Text(
                                                  "Start Activity".tr,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12, // Reduced font size
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10), // Reduced padding
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(28),
                                      color: Colors.grey.withOpacity(0.05),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.play_arrow_rounded,
                                          color: Colors.grey.withOpacity(0.3),
                                          size: 16, // Reduced icon size
                                        ),
                                        SizedBox(width: 4), // Reduced spacing
                                        Flexible(
                                          child: Text(
                                            "No Activity".tr,
                                            style: TextStyle(
                                              color: Colors.grey.withOpacity(0.3),
                                              fontSize: 12, // Reduced font size
                                              fontWeight: FontWeight.w500,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ),

                        // Next Button - Flexible width
                        Flexible(
                          flex: 2, // Give it 2 parts of the available space
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: screenSize.width * 0.28, // Reduced max width
                              minWidth: screenSize.width * 0.22, // Added min width
                            ),
                            child: hasNext
                                ? Material(
                                    elevation: 4,
                                    shadowColor: Colors.black.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(25),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(25),
                                        color: Colors.white,
                                        border: Border.all(
                                          color: Colors.grey.withOpacity(0.15),
                                          width: 1,
                                        ),
                                      ),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(25),
                                        onTap: () async {
                                          isLoading(true);
                                          int index = ReadController
                                                  .chapterIdIndexForNextPage
                                                  .value -
                                              1;
                                          ReadController
                                              .chapterIdIndexForNextPage(index);

                                          await ReadController
                                                  .getAllChapterByChapterId(
                                                      ReadController
                                                              .getChapterByStoryId
                                                              .value
                                                              .data
                                                              ?.chapterData?[
                                                                  index]
                                                              .id
                                                              .toString() ??
                                                          '')
                                              .then((value) async {
                                            await ReadController
                                                .getActivityDetailsByChapterId(
                                                    ReadController
                                                            .getChapterByStoryId
                                                            .value
                                                            .data
                                                            ?.chapterData?[index]
                                                            .id
                                                            .toString() ??
                                                        '');
                                            isInitialPdfLoading.value = true;
                                            isPdfFullyLoaded.value = false;
                                            isLoading(false);
                                          });
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 8), // Reduced padding
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  'Next'.tr,
                                                  style: TextStyle(
                                                    color: Colors.grey[700],
                                                    fontSize: 11, // Reduced font size
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              SizedBox(width: 2),
                                              Icon(
                                                Icons.chevron_right_rounded,
                                                color: Colors.grey[700],
                                                size: 16, // Reduced icon size
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 8), // Reduced padding
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      color: Colors.grey.withOpacity(0.05),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            'Next'.tr,
                                            style: TextStyle(
                                              color: Colors.grey.withOpacity(0.3),
                                              fontSize: 11, // Reduced font size
                                              fontWeight: FontWeight.w500,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(width: 2),
                                        Icon(
                                          Icons.chevron_right_rounded,
                                          color: Colors.grey.withOpacity(0.3),
                                          size: 16, // Reduced icon size
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      }),
    );
  }

  // Optimized method to handle mode switching with 90% PDF space utilization
  void switchViewMode(bool scrollMode) {
    if (isScrollMode.value != scrollMode) {
      customPrint(
          '🔄 Switching PDF view mode to: ${scrollMode ? "Scroll Mode (Vertical)" : "Page Mode (Horizontal)"}');
      customPrint('📱 PDF utilizing 90% of screen space');

      // Only show loading during mode switch if PDF is already loaded
      if (isPdfFullyLoaded.value) {
        isPdfLoading.value = true;
      }

      setState(() {
        isScrollMode.value = scrollMode;
        // Generate a new key to force PDF widget recreation only for mode switch
        pdfKey = Key(
            'pdf_mode_${scrollMode ? "scroll" : "page"}_${DateTime.now().millisecondsSinceEpoch}');
      });

      // Clear loading state after optimized delay (only if we set it)
      if (isPdfFullyLoaded.value) {
        Future.delayed(const Duration(milliseconds: 300), () {
          isPdfLoading.value = false;
          customPrint(
              '✅ PDF mode switch completed - ${scrollMode ? "Scroll" : "Page"} mode active');
        });
      }
    }
  }

  Widget getPdf() {
    try {
      String pdfPath =
          '${DatabaseApi.mainUrlImage}${(ReadController.getChapterByChapterId.value.data?.chapterDocument.toString() ?? '').trimLeft().trimRight()}';

      // Check if PDF path has changed
      if (currentPdfPath != pdfPath) {
        currentPdfPath = pdfPath;
        // Reset loading states for new PDF
        isPdfFullyLoaded.value = false;
        isInitialPdfLoading.value = true;
        // Generate new key when PDF path changes
        pdfKey = Key(
            'pdf_${isScrollMode.value ? "scroll" : "page"}_${DateTime.now().millisecondsSinceEpoch}');
        customPrint('📄 New PDF detected - Path: $pdfPath');
      }

      // Ensure we have a key
      pdfKey ??= Key(
          'pdf_${isScrollMode.value ? "scroll" : "page"}_${DateTime.now().millisecondsSinceEpoch}');

      customPrint(
          '🏗️ Building optimized PDF widget with mode: ${isScrollMode.value ? "Scroll (Vertical)" : "Page (Horizontal)"}');
      customPrint('📄 PDF Path: $pdfPath');
      customPrint('🎯 PDF Fully Loaded: ${isPdfFullyLoaded.value}');

      return Expanded(
        flex: 9, // Takes 90% of available space
        child: Obx(() {
          // Show loading only during mode switching
          if (isPdfLoading.value) {
            return Container(
              color: Colors.white,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text(
                      'Switching view mode...',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Container(
            key: pdfKey,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            child: PDF(
              swipeHorizontal: !isScrollMode.value,
              enableSwipe: true,
              defaultPage: ReadController.pdfPageNumber.value,
              autoSpacing: isScrollMode.value,
              pageFling: !isScrollMode.value,
              pageSnap: !isScrollMode.value,
              nightMode: false,
              fitEachPage: true,
              fitPolicy: FitPolicy.BOTH,
              onError: (error) {
                customPrint('PDF Error: $error');
                isInitialPdfLoading.value = false;
                isPdfFullyLoaded.value = false;
              },
              onPageChanged: (int? page, int? total) {
                if (page != null) {
                  ReadController.pdfPageNumber(page);
                  // Only log during initial load, not during scrolling
                  if (isInitialPdfLoading.value) {
                    customPrint('PDF Page changed to: $page of $total');
                  }
                }
              },
              onViewCreated: (pdfViewController) {
                // Mark PDF as fully loaded once the view is created
                Future.delayed(Duration(milliseconds: 500), () {
                  isPdfFullyLoaded.value = true;
                  isInitialPdfLoading.value = false;
                  pdfCache[pdfPath] = true;
                  customPrint('✅ PDF fully loaded and cached successfully');
                  customPrint(
                      '📱 Mode: ${isScrollMode.value ? "Scroll (Vertical)" : "Page (Horizontal)"}');
                  customPrint('🎯 Ready for smooth scrolling without loading');
                });
              },
            ).fromUrl(
              pdfPath,
              placeholder: (progress) {
                // Only show loading during initial PDF load
                if (!isPdfFullyLoaded.value && isInitialPdfLoading.value) {
                  return Container(
                    color: Colors.white,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: progress / 100,
                            backgroundColor: Colors.grey[300],
                            valueColor:
                                AlwaysStoppedAnimation<Color>(primaryColor),
                            strokeWidth: 3,
                          ),
                          SizedBox(height: 16),
                          Text(
                            '${'Loading PDF...'.tr} ${progress.toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Please wait while we load the entire chapter',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                // Return empty container if PDF is already loaded
                return Container();
              },
              errorWidget: (error) {
                return Container(
                  color: Colors.white,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.red),
                        SizedBox(height: 16),
                        Text(
                          'Failed to load PDF',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Please check your internet connection',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              // Reset loading states and force reload
                              isPdfFullyLoaded.value = false;
                              isInitialPdfLoading.value = true;
                              pdfKey = Key(
                                  'pdf_retry_${DateTime.now().millisecondsSinceEpoch}');
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: Icon(Icons.refresh,
                              color: Colors.white, size: 18),
                          label: Text(
                            'Retry',
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }),
      );
    } catch (e, s) {
      customPrint("getPdf Exception : $e, $s");
      return Expanded(
        child: Container(
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'Error initializing PDF viewer',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    e.toString(),
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  String getChapterName() {
    if (ReadController.getChapterByChapterId.value.data == null) {
      return widget.storyName;
    }

    String chapterNo = ReadController
            .getChapterByChapterId.value.data?.chapterNo!
            .split(" ")[1] ??
        '';
    String name = ReadController.getChapterByChapterId.value.data?.name ?? '';

    if (chapterNo.isEmpty) {
      return name;
    }

    return '${"Chapter".tr} $chapterNo : $name';
  }
}
