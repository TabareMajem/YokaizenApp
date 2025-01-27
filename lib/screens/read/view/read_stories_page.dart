import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:yokai_quiz_app/Widgets/new_button.dart';
import 'package:yokai_quiz_app/Widgets/progressHud.dart';
import 'package:yokai_quiz_app/global.dart';
import 'package:yokai_quiz_app/screens/read/view/start_activity_page.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/const.dart';

import '../../../Widgets/second_custom_button.dart';
import '../../../api/database_api.dart';
import '../../../util/text_styles.dart';
import '../../home/controller/home_controller.dart';
import '../../navigation/view/navigation.dart';
import '../controller/read_controller.dart';
import 'chapter_page.dart';

class ReadStoriesPage extends StatefulWidget {
  String chapterId;
  String storyName;

  ReadStoriesPage({
    super.key,
    required this.chapterId,
    required this.storyName,
  });

  @override
  State<ReadStoriesPage> createState() => _ReadStoriesPageState();
}

class _ReadStoriesPageState extends State<ReadStoriesPage> {
  RxBool isLoading = false.obs;
  fetchData() async {
    isLoading(true);
    await ReadController.getAllChapterByChapterId(widget.chapterId)
        .then((value) async {
      customPrint(
          'chapterDocumentEnglish :: ${DatabaseApi.mainUrlImage}${(ReadController.getChapterByChapterId.value.data?.chapterDocumentEnglish.toString() ?? '').trimLeft().trimRight()}');
      await ReadController.getActivityDetailsByChapterId(widget.chapterId).then(
        (value) {
          isLoading(false);
        },
      );
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
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
                                    ChapterPage(
                                      storyId: ReadController.storyId.value,
                                      storyName: widget.storyName,
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
            // floatingActionButton: GestureDetector(
            //   onTap: () {
            //     ReadController.pdfPageNumber(1);
            //   },
            //   child: SvgPicture.asset('icons/arrowUp.svg'),
            // ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 20, left: 20, top: 60),
                  child: Column(
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
                                                          ChapterPage(
                                                            storyId:
                                                                ReadController
                                                                    .storyId
                                                                    .value,
                                                            storyName: widget
                                                                .storyName,
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
                              height: 35,
                              width: 35,
                            ),
                          ),
                          1.pw,
                          Text(
                            '${ReadController.getChapterByChapterId.value.data?.chapterNo.toString() ?? ''} : ${((ReadController.getChapterByChapterId.value.data?.name.toString() ?? '') != '') ? ((ReadController.getChapterByChapterId.value.data?.name.toString() ?? '').length > 25) ? '${(ReadController.getChapterByChapterId.value.data?.name.toString() ?? '').substring(0, 25)}...' : ReadController.getChapterByChapterId.value.data?.name.toString() ?? '' : ''}',
                            style: AppTextStyle.normalBold16
                                .copyWith(color: coral500),
                          ),
                        ],
                      ),
                      2.ph,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          (ReadController.chapterIdIndexForNextPage.value + 1 >=
                                  (ReadController.getChapterByStoryId.value.data
                                          ?.chapterData!.length ??
                                      0))
                              ? const SizedBox()
                              : CustomButton(
                                  onPressed: () async {
                                    isLoading(true);
                                    final int? index;
                                    if (ReadController.chapterIdIndexForNextPage
                                                .value +
                                            1 >=
                                        (ReadController
                                                .getChapterByStoryId
                                                .value
                                                .data
                                                ?.chapterData!
                                                .length ??
                                            0)) {
                                      index = 0;
                                      customPrint(
                                          'chapterIdIndexForNextPage : minus');
                                      showErrorMessage(
                                          'No Previous Chapter Found',
                                          errorColor);
                                      isLoading(false);
                                      return;
                                    } else {
                                      index = ReadController
                                              .chapterIdIndexForNextPage.value +
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
                                    }
                                    await ReadController
                                            .getAllChapterByChapterId(
                                                ReadController
                                                        .getChapterByStoryId
                                                        .value
                                                        .data
                                                        ?.chapterData?[index]
                                                        .id
                                                        .toString() ??
                                                    '')
                                        .then((value) {
                                      customPrint(
                                          'chapterDocumentEnglish :: ${DatabaseApi.mainUrlImage}${(ReadController.getChapterByChapterId.value.data?.chapterDocumentEnglish.toString() ?? '').trimLeft().trimRight()}');
                                      isLoading(false);
                                    });
                                  },
                                  text: 'Previous'.tr,
                                  colorText: primaryColor,
                                  textSize: 14,
                                  iconSvgPath: 'icons/arrowLeft.svg',
                                  colorSvg: primaryColor,
                                  color: indigo50,
                                  border: Border.all(color: indigo700),
                                  width: screenSize.width / 2.6,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                ),
                          (ReadController.chapterIdIndexForNextPage.value <= 0)
                              ? const SizedBox()
                              : SecondCustomButton(
                                  onPressed: () async {
                                    isLoading(true);
                                    final int? index;
                                    if (ReadController
                                            .chapterIdIndexForNextPage.value <=
                                        0) {
                                      index = 0;
                                      customPrint(
                                          'chapterIdIndexForNextPage : 0');
                                      showErrorMessage(
                                          'No Next Chapter Found', errorColor);
                                      isLoading(false);
                                      return;
                                    } else {
                                      index = ReadController
                                              .chapterIdIndexForNextPage.value -
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
                                    }
                                    await ReadController
                                            .getAllChapterByChapterId(
                                                ReadController
                                                        .getChapterByStoryId
                                                        .value
                                                        .data
                                                        ?.chapterData?[index]
                                                        .id
                                                        .toString() ??
                                                    '')
                                        .then((value) {
                                      customPrint(
                                          'chapterDocumentEnglish :: ${DatabaseApi.mainUrlImage}${(ReadController.getChapterByChapterId.value.data?.chapterDocumentEnglish.toString() ?? '').trimLeft().trimRight()}');
                                      isLoading(false);
                                    });
                                  },
                                  width: screenSize.width / 2.6,
                                  iconSvgPath: 'icons/arrowRight.svg',
                                  text: "Next".tr,
                                  textSize: 14,
                                ),
                        ],
                      ),
                    ],
                  ),
                ),
                1.ph,

                ///pdfpdf
                // Expanded(
                //   child: SfPdfViewer.network(
                //     'https://www.pdf995.com/samples/pdf.pdf',
                //   ),
                // ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: PDF(
                      // swipeHorizontal: true,

                      enableSwipe: true,
                      defaultPage: ReadController.pdfPageNumber.value,
                    ).fromUrl(
                      '${DatabaseApi.mainUrlImage}${(ReadController.getChapterByChapterId.value.data?.chapterDocumentEnglish.toString() ?? '').trimLeft().trimRight()}',
                    ),
                    // PDF(
                    //   // swipeHorizontal: true,
                    //
                    //   enableSwipe: true,
                    //   defaultPage: ReadController.pdfPageNumber.value,
                    // ).fromAsset(
                    //   'images/examPdf.pdf',
                    // ),
                  ),
                ),
                // Expanded(
                //   child: const PDF(
                //     swipeHorizontal: true,
                //   ).cachedFromUrl(
                //     'https://www.pdf995.com/samples/pdf.pdf',
                //     placeholder: (progress) => Center(child: Text('$progress %')),
                //     errorWidget: (error) => Center(child: Text(error.toString())),
                //   ),
                // ),
                1.ph,
                if (widget.chapterId != '' && widget.chapterId != 'null')
                  if (ReadController.isActivityAvailable.isTrue)
                    SecondCustomButton(
                      onPressed: () {
                        nextPage(StartActivityPage(
                          storyName: widget.storyName,
                          chapter: ReadController
                                  .getChapterByChapterId.value.data?.name
                                  .toString() ??
                              '',
                          chapterId: widget.chapterId,
                        ));
                      },
                      width: screenSize.width / 2,
                      height: 50,
                      iconSvgPath: 'icons/arrowRight.svg',
                      text: "Start Activity".tr,
                      textSize: 14,
                    ),
                2.ph,
              ],
            ),
          ),
        );
      }),
    );
  }
}
