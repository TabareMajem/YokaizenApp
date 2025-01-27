import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:yokai_quiz_app/Widgets/progressHud.dart';
import 'package:yokai_quiz_app/screens/read/view/quiz_page.dart';
import 'package:yokai_quiz_app/screens/read/view/read_stories_page.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/const.dart';
import 'package:yokai_quiz_app/util/constants.dart';

import '../../../Widgets/new_button.dart';
import '../../../Widgets/second_custom_button.dart';
import '../../../api/database_api.dart';
import '../../../global.dart';
import '../../../util/text_styles.dart';
import '../controller/read_controller.dart';

class StartActivityPage extends StatefulWidget {
  String chapter;
  String chapterId;
  String? storyName;

  StartActivityPage(
      {super.key,
      required this.chapter,
      required this.chapterId,
      this.storyName});

  @override
  State<StartActivityPage> createState() => _StartActivityPageState();
}

class _StartActivityPageState extends State<StartActivityPage> {
  //  late ScrollController scrollController;
  //
  //  void scrollToTopSingleChild() {
  //   scrollController = ScrollController();
  //   // Scroll to the top when the page is loaded
  //
  // }
  //
  RxBool isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    fetchActivityData();
  }

  fetchActivityData() async {
    isLoading(true);
    await ReadController.getActivityDetailsByChapterId(widget.chapterId).then(
      (value) {
        isLoading(false);
      },
    );
    ReadController.chapterName('');
    ReadController.chapterId('');
  }
  //
  // @override
  // void dispose() {
  //  scrollController.dispose();
  //   super.dispose();
  // }

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
                        "Exit Activity ?".tr,
                        style: AppTextStyle.normalBold20
                            .copyWith(color: includedColor),
                      ),
                      const SizedBox(
                        height: 3.5,
                      ),
                      Text(
                        "Your progress will be lost :(\nThere’s only a little more to go !"
                            .tr,
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
                              // Get.back();
                              // Get.back();
                              nextPageOff(
                                  context,
                                  ReadStoriesPage(
                                      storyName: widget.chapter,
                                      chapterId: widget.chapterId));
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
            body: SingleChildScrollView(
              // controller:scrollController,
              child: Padding(
                padding: const EdgeInsets.only(
                    right: 20, left: 20, bottom: 16, top: 60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
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
                                      width: MediaQuery.of(context).size.width /
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
                                            "Exit Activity ?".tr,
                                            style: AppTextStyle.normalBold20
                                                .copyWith(color: includedColor),
                                          ),
                                          const SizedBox(
                                            height: 3.5,
                                          ),
                                          Text(
                                            "Your progress will be lost :(\nThere’s only a little more to go !"
                                                .tr,
                                            style: AppTextStyle.normalRegular14
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
                                                  // Get.back();
                                                  // Get.back();
                                                  nextPageOff(
                                                      context,
                                                      ReadStoriesPage(
                                                          storyName:
                                                              widget.chapter,
                                                          chapterId: widget
                                                              .chapterId));
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
                          },
                          child: SvgPicture.asset(
                            'icons/arrowLeft.svg',
                            height: 35,
                            width: 35,
                          ),
                        ),
                        1.pw,
                        Text(
                          'Activity'.tr,
                          style: AppTextStyle.normalBold16
                              .copyWith(color: coral500),
                        ),
                      ],
                    ),
                    2.ph,
                    Container(
                      height: screenSize.height / 3.5,
                      width: screenSize.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ((ReadController.getActivityByChapterId.value
                                          .data?[0].activityImage
                                          .toString() ??
                                      '') !=
                                  '' &&
                              (ReadController.getActivityByChapterId.value
                                          .data?[0].activityImage
                                          .toString() ??
                                      '') !=
                                  'null')
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child:
                                  // Image.network(
                                  //     '${DatabaseApi.mainUrlImage}${ReadController.getActivityByChapterId.value.data?[0].activityImage.toString() ?? ''}',
                                  // width: screenSize.width,
                                  // fit: BoxFit.fill,
                                  //   ),
                                  CachedNetworkImage(
                                imageUrl:
                                    "${DatabaseApi.mainUrlImage}${ReadController.getActivityByChapterId.value.data?[0].activityImage.toString() ?? ''}",
                                // placeholder: (context, url) => CircularProgressIndicator(),
                                placeholder: (context, url) => const Padding(
                                  padding: EdgeInsets.all(
                                      constants.defaultPadding * 2),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircularProgressIndicator(),
                                    ],
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(
                                  Icons.error,
                                  color: AppColors.black,
                                ),
                                width: screenSize.width,
                                fit: BoxFit.fill,
                                // fit: BoxFit.contain,
                              ),
                            )
                          : Center(
                              child: Text(
                                'Photo Not Added'.tr,
                              ),
                            ),
                      // Image.asset(
                      //   'icons/bear.png',
                      //   width: screenSize.width,
                      //   fit: BoxFit.fill,
                      // ),
                    ),
                    2.ph,
                    Text(
                      'Healthy Coping Mechanisms Quiz'.tr,
                      style:
                          AppTextStyle.normalBold16.copyWith(color: indigo950),
                    ),
                    2.ph,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 70,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: indigo200),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Time'.tr,
                                style: AppTextStyle.normalRegular12
                                    .copyWith(color: grey2),
                              ),
                              0.5.ph,
                              Text(
                                '${ReadController.getActivityByChapterId.value.data?[0].time.toString() ?? ''} Minutes',
                                style: AppTextStyle.normalRegular12
                                    .copyWith(color: coral500),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 70,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: indigo200),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Type'.tr,
                                style: AppTextStyle.normalRegular12
                                    .copyWith(color: grey2),
                              ),
                              0.5.ph,
                              Text(
                                'Quiz'.tr,
                                style: AppTextStyle.normalRegular12
                                    .copyWith(color: coral500),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 70,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: indigo200),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Chapter'.tr,
                                style: AppTextStyle.normalRegular12
                                    .copyWith(color: grey2),
                              ),
                              0.5.ph,
                              Text(
                                ReadController.getActivityByChapterId.value
                                        .data?[0].chapterName
                                        .toString() ??
                                    '',
                                style: AppTextStyle.normalRegular12
                                    .copyWith(color: coral500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    2.ph,
                    Text(
                      // "Feeling stressed? It happens to everyone!\nBut how we handle those tough moments can make a\nbig difference.\nThis short quiz will explore your coping mechanisms\nand see if you have a healthy toolbox for dealing with\nlife's challenges.\nLet's see if your go-to strategies are helping you thrive!",
                      ReadController.getActivityByChapterId.value.data?[0]
                              .shortDiscription
                              .toString() ??
                          '',
                      style:
                          AppTextStyle.normalRegular12.copyWith(color: grey2),
                    ),
                    3.ph,
                    Text(
                      'Complete this activity to Chat with :'.tr,
                      style: AppTextStyle.normalRegular12
                          .copyWith(color: coral500),
                    ),
                    1.ph,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${ReadController.getActivityByChapterId.value.data?[0].characterName.toString() ?? ''}',
                          style: AppTextStyle.normalBold12
                              .copyWith(color: indigo700),
                        ),
                        1.pw,
                        ClipRRect(
                          borderRadius: BorderRadius.circular(35),
                          // half of the height/width
                          child: CachedNetworkImage(
                            imageUrl:
                                "${DatabaseApi.mainUrlImage}${ReadController.getActivityByChapterId.value.data?[0].characterImage.toString() ?? ''}",
                            placeholder: (context, url) => const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(),
                              ],
                            ),
                            errorWidget: (context, url, error) => Container(
                              decoration:
                                  const BoxDecoration(color: AppColors.red),
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
                        // CircleAvatar(
                        //   backgroundColor: colorWhite,
                        //   radius: 25,
                        //   child: Image.asset("icons/buddies.png"),
                        // ),
                      ],
                    ),
                    if (ReadController.isActivityAvailable.isTrue)
                      SecondCustomButton(
                        onPressed: () {
                          // ReadController.singleChild(false);
                          ReadController.chapterName(widget.chapter);
                          ReadController.chapterId(widget.chapterId);
                          nextPage(QuizPage(
                            chapterId: widget.chapterId,
                            chapter: widget.chapter,
                          ));
                        },
                        width: screenSize.width / 2,
                        iconSvgPath: 'icons/arrowRight.svg',
                        text: "Start Activity".tr,
                        textSize: 14,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
