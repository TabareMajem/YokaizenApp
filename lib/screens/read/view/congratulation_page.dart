import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:yokai_quiz_app/screens/read/view/read_stories_screen.dart';
import 'package:yokai_quiz_app/screens/read/view/start_activity_page.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/const.dart';

import '../../../Widgets/second_custom_button.dart';
import '../../../api/database_api.dart';
import '../../../global.dart';
import '../../../util/text_styles.dart';
import '../../navigation/view/navigation.dart';
import '../controller/read_controller.dart';

class CongratulationPage extends StatefulWidget {
  String? score;
  String length;
  String? title;


  CongratulationPage({super.key, required this.length, this.score, this.title});

  @override
  State<CongratulationPage> createState() => _CongratulationPageState();
}

class _CongratulationPageState extends State<CongratulationPage> {
  String title = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    customPrint("chapterName :: ${ReadController.chapterName.value}");
    customPrint("chapterId ::${ReadController.chapterId.value}");
    if(widget.title!.isNotEmpty && widget.title != null) title = widget.title!;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        nextPageOff(
            context,
            StartActivityPage(
                chapter: ReadController.chapterName.value,
                chapterId: ReadController.chapterId.value));
        ReadController.chapterName('');
        ReadController.chapterId('');
        return false;
      },
      child: Obx(() {
        return Scaffold(
          backgroundColor: colorWhite,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                  right: 20, left: 20, bottom: 16, top: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  3.ph,
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Get.back();
                            nextPageOff(
                                context,
                                StartActivityPage(
                                    chapter: ReadController.chapterName.value,
                                    chapterId: ReadController.chapterId.value));
                            ReadController.chapterName('');
                            ReadController.chapterId('');
                          },
                          child: SvgPicture.asset(
                            'icons/arrowLeft.svg',
                            height: 35,
                            width: 35,
                          ),
                        ),
                        1.pw,
                        Center(
                          child: Text(
                            // 'Healthy Coping Mechanisms Quiz'.tr,
                            title,
                            style: AppTextStyle.normalBold16
                                .copyWith(color: coral500),
                          ),
                        ),
                      ],
                    ),
                  ),
                  5.ph,
                  Stack(
                    children: [
                      Center(
                        child: Column(
                          children: [
                            ((ReadController.getActivityByChapterId.value
                                            .data?[0].endImage
                                            .toString() ??
                                        '') !=
                                    "null")
                                ? SizedBox(
                                    height: 200,
                                    width: 200,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      // half of the height/width
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            "${DatabaseApi.mainUrlImage}${ReadController.getActivityByChapterId.value.data?[0].endImage.toString() ?? ''}",
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
                                            color: AppColors.red,
                                          ),
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
                                  )
                                : Image.asset(
                                    'icons/cong.png',
                                    height: 200,
                                    width: 200,
                                  ),
                            // SvgPicture.asset('icons/cong.svg', height: 160, width: 160),
                            4.ph,
                            Text(
                              "Woohoo ! ".tr,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontFamily: "Montserrat",
                                fontSize: 20,
                                color: coral500,
                              ),
                            ),
                            4.ph,
                            Text(
                              "Looks like you’re on the right track,\nCongratulations! "
                                  .tr,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontFamily: "Montserrat",
                                fontSize: 14,
                                color: Color(0xFF122E59),
                              ),
                            ),
                            if ((ReadController.getActivityByChapterId.value
                                        .data?[0].readChapterCount ??
                                    0) <
                                3)
                              4.ph,
                            if ((ReadController.getActivityByChapterId.value
                                        .data?[0].readChapterCount ??
                                    0) <
                                3)


                              /// this portion is commented by Krishnansh, later will be un commented on requirement

                              // SizedBox(
                              //   width: MediaQuery.of(context).size.width / 1.1,
                              //   child: Row(
                              //     children: [
                              //       Expanded(
                              //         child: Column(
                              //           crossAxisAlignment:
                              //               CrossAxisAlignment.start,
                              //           children: [
                              //             Stack(
                              //               alignment: Alignment.centerLeft,
                              //               children: [
                              //                 Padding(
                              //                   padding: EdgeInsets.symmetric(
                              //                       horizontal:
                              //                           screenSize.width / 9),
                              //                   child: Column(
                              //                     children: [
                              //                       Text(
                              //                         "Only a few more chapters to unlock : "
                              //                             .tr,
                              //                         textAlign:
                              //                             TextAlign.center,
                              //                         style: AppTextStyle
                              //                             .normalBold12
                              //                             .copyWith(
                              //                                 color: greyCh),
                              //                       ),
                              //                       4.ph,
                              //                     ],
                              //                   ),
                              //                 ),
                              //                 Stack(
                              //                   alignment:
                              //                       Alignment.centerRight,
                              //                   children: [
                              //                     SliderTheme(
                              //                       data: const SliderThemeData(
                              //                         thumbShape:
                              //                             RoundSliderThumbShape(
                              //                                 enabledThumbRadius:
                              //                                     0.0),
                              //                         trackHeight: 10,
                              //                       ),
                              //                       child: Slider(
                              //                         value: double.tryParse(ReadController
                              //                                     .getActivityByChapterId
                              //                                     .value
                              //                                     .data?[0]
                              //                                     .readChapterCount
                              //                                     .toString() ??
                              //                                 '') ??
                              //                             0,
                              //                         // max: double.tryParse(ReadController.getActivityByChapterId.value.data?[0].totalChapterCount.toString()??'') ??
                              //                         max: 3,
                              //                         min: 0,
                              //                         activeColor: coral500,
                              //                         inactiveColor: coral100,
                              //                         onChanged: (value) {
                              //                           ReadController.progress(
                              //                               value);
                              //                         },
                              //                       ),
                              //                     ),
                              //                     ClipRRect(
                              //                       borderRadius:
                              //                           BorderRadius.circular(
                              //                               35),
                              //                       // half of the height/width
                              //                       child: CachedNetworkImage(
                              //                         imageUrl:
                              //                             "${DatabaseApi.mainUrlImage}${ReadController.getActivityByChapterId.value.data?[0].characterImage.toString() ?? ''}",
                              //                         placeholder:
                              //                             (context, url) =>
                              //                                 const Row(
                              //                           mainAxisAlignment:
                              //                               MainAxisAlignment
                              //                                   .center,
                              //                           mainAxisSize:
                              //                               MainAxisSize.min,
                              //                           children: [
                              //                             CircularProgressIndicator(),
                              //                           ],
                              //                         ),
                              //                         errorWidget: (context,
                              //                                 url, error) =>
                              //                             Container(
                              //                           decoration:
                              //                               const BoxDecoration(
                              //                             color: AppColors.red,
                              //                           ),
                              //                           child: const Icon(
                              //                             Icons.error_outline,
                              //                             color:
                              //                                 AppColors.black,
                              //                           ),
                              //                         ),
                              //                         height: 45,
                              //                         width: 45,
                              //                         fit: BoxFit.cover,
                              //                       ),
                              //                     ),
                              //                   ],
                              //                 ),
                              //                 Column(
                              //                   children: [
                              //                     4.ph,
                              //                     Padding(
                              //                       padding: EdgeInsets.only(
                              //                         left:
                              //                             screenSize.width / 9,
                              //                         right:
                              //                             screenSize.width / 8,
                              //                       ),
                              //                       child: Row(
                              //                         mainAxisAlignment:
                              //                             MainAxisAlignment
                              //                                 .spaceBetween,
                              //                         children: [
                              //                           Text(
                              //                             // "${ReadController.getActivityByChapterId.value.data?[0].readChapterCount.toString()}/${ReadController.getActivityByChapterId.value.data?[0].totalChapterCount.toString()}",
                              //                       ReadController.getActivityByChapterId.value.data?[0].readChapterCount.toString() != "null" ?
                              //                             "${ReadController.getActivityByChapterId.value.data?[0].readChapterCount.toString()}/3" : "1/3",
                              //                             textAlign:
                              //                                 TextAlign.center,
                              //                             style: AppTextStyle
                              //                                 .normalBold12
                              //                                 .copyWith(
                              //                                     color:
                              //                                         coral500),
                              //                           ),
                              //                           Text(
                              //                             // "GAMMA",
                              //                             ReadController
                              //                                     .getActivityByChapterId
                              //                                     .value
                              //                                     .data?[0]
                              //                                     .characterName
                              //                                     .toString() ??
                              //                                 '',
                              //                             textAlign:
                              //                                 TextAlign.center,
                              //                             style: AppTextStyle
                              //                                 .normalBold12
                              //                                 .copyWith(
                              //                                     color:
                              //                                         coral500),
                              //                           ),
                              //                         ],
                              //                       ),
                              //                     ),
                              //                   ],
                              //                 ),
                              //               ],
                              //             ),
                              //           ],
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),

                              /// this portion is commented by Krishnansh, later will be un commented on requirement

                            15.ph,
                            (ReadController.chapterIdIndexForNextPage.value ==
                                    0)
                                ? SecondCustomButton(
                                    onPressed: () async {
                                      nextPageOff(
                                          context,
                                          NavigationPage(
                                            index: 1,
                                          ));
                                    },
                                    width: screenSize.width / 2,
                                    iconSvgPath: 'icons/arrowRight.svg',
                                    text: "Read Another Story".tr,
                                    textSize: 14,
                                  )
                                : SecondCustomButton(
                                    onPressed: () async {
                                      customPrint(
                                          'chapterIdIndexForNextPage og :: ${ReadController.chapterIdIndexForNextPage.value}');
                                      customPrint(
                                          'getChapterByStoryId length :: ${ReadController.getChapterByStoryId.value.data?.chapterData!.length}');

                                      ///new update code
                                      final int? index;
                                      if (ReadController
                                                  .chapterIdIndexForNextPage
                                                  .value +
                                              1 >=
                                          (ReadController
                                                  .getChapterByStoryId
                                                  .value
                                                  .data
                                                  ?.chapterData!
                                                  .length ??
                                              0)) {
                                        index = ReadController
                                                .chapterIdIndexForNextPage
                                                .value +
                                            1;
                                        ReadController.chapterIdIndexForNextPage(
                                            ReadController
                                                    .chapterIdIndexForNextPage
                                                    .value +
                                                1);
                                        customPrint(
                                            'chapterIdIndexForNextPage : plus');
                                        customPrint(
                                            'chapterIdIndexForNextPage : ${ReadController.chapterIdIndexForNextPage.value}');
                                        customPrint(
                                            'chapterIdIndexForNextPage : ${ReadController.getChapterByStoryId.value.data?.chapterData!.length}');

                                        nextPage(ReadStoriesScreen(
                                          // chapter: ReadController.chapter[index]['chapter'],

                                          chapterId: ReadController
                                                  .getChapterByStoryId
                                                  .value
                                                  .data
                                                  ?.chapterData?[index]
                                                  .id
                                                  .toString() ??
                                              '',
                                          storyName: ReadController
                                                  .getChapterByStoryId
                                                  .value
                                                  .data
                                                  ?.chapterData?[index]
                                                  .name
                                                  .toString() ??
                                              '',
                                        ));
                                      } else {
                                        index = ReadController
                                                .chapterIdIndexForNextPage
                                                .value -
                                            1;
                                        ReadController.chapterIdIndexForNextPage(
                                            ReadController
                                                    .chapterIdIndexForNextPage
                                                    .value -
                                                1);
                                        customPrint(
                                            'chapterIdIndexForNextPage : minus');
                                        customPrint(
                                            'chapterIdIndexForNextPage : ${ReadController.chapterIdIndexForNextPage.value}');
                                        customPrint(
                                            'chapterIdIndexForNextPage : ${ReadController.getChapterByStoryId.value.data?.chapterData!.length}');

                                        nextPage(ReadStoriesScreen(
                                          // chapter: ReadController.chapter[index]['chapter'],

                                          chapterId: ReadController
                                                  .getChapterByStoryId
                                                  .value
                                                  .data
                                                  ?.chapterData?[index]
                                                  .id
                                                  .toString() ??
                                              '',
                                          storyName: ReadController
                                                  .getChapterByStoryId
                                                  .value
                                                  .data
                                                  ?.chapterData?[index]
                                                  .name
                                                  .toString() ??
                                              '',
                                        ));
                                      }
                                    },
                                    width: screenSize.width / 2,
                                    iconSvgPath: 'icons/arrowRight.svg',
                                    text: "Next Chapter".tr,
                                    textSize: 14,
                                  ),
                          ],
                        ),
                      ),
                      Positioned(
                        child: Lottie.asset('assets/rightansanimation.json'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
