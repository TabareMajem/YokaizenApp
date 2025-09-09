/// chapter_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:yokai_quiz_app/Widgets/progressHud.dart';
import 'package:yokai_quiz_app/global.dart';
import 'package:yokai_quiz_app/screens/read/view/read_stories_screen.dart';
import 'package:yokai_quiz_app/screens/read/view/story_details_screen.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/const.dart';
import 'package:yokai_quiz_app/util/constants.dart';

import '../../../util/text_styles.dart';
import '../../home/controller/home_controller.dart';
import '../controller/read_controller.dart';
import 'open_story_screen.dart';

class ChapterScreen extends StatefulWidget {
  String storyId;
  String storyName;
  ChapterScreen({
    super.key,
    required this.storyId,
    required this.storyName,
  });

  @override
  State<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  RxBool isLoading = false.obs;
  fetchData() async {
    isLoading(true);
    await ReadController.getAllChapterByStoryId(widget.storyId).then((value) {
      if ((ReadController.getChapterByStoryId.value.data?.chapterData?.length ??
              0) >
          0) {
        for (int i = 0;
            i <
                (ReadController
                        .getChapterByStoryId.value.data?.chapterData?.length ??
                    0);
            i++) {
          ReadController.chapterIdForNextPage.add(ReadController
              .getChapterByStoryId.value.data?.chapterData?[i].id);
        }
      }
      isLoading(false);
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
        nextPageOff(
            context, StoryDetailsScreen(storyId: ReadController.storyId.value));
        return true;
      },
      child: Obx(
        () {
          return ProgressHUD(
            isLoading: isLoading.value,
            child: Scaffold(
              backgroundColor: colorWhite,
              floatingActionButton: Container(
                decoration: BoxDecoration(
                  color: coral500.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: IconButton(
                  onPressed: () {
                    ReadController.scrollToTop();
                  },
                  icon: SvgPicture.asset(
                    'icons/arrowUp.svg',
                    height: 24,
                    width: 24,
                  ),
                ),
              ),
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(
                      right: 20, left: 20, top: 13),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              nextPageOff(
                                  context,
                                  StoryDetailsScreen(
                                      storyId: ReadController.storyId.value));
                            },
                            child: SvgPicture.asset(
                              'icons/arrowLeft.svg',
                              height: 35,
                              width: 35,
                            ),
                          ),
                          1.pw,
                          Expanded(
                            child: Text(
                              widget.storyName,
                              style: AppTextStyle.normalBold16
                                  .copyWith(color: coral500),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      3.ph,
                      ((ReadController.getChapterByStoryId.value.data?.chapterData
                                      ?.length ??
                                  0) >
                                  0)
                          ? Expanded(
                              child: ListView.builder(
                                physics: BouncingScrollPhysics(),
                                padding: EdgeInsets.zero,
                                controller: ReadController.controller,
                                shrinkWrap: true,
                                // itemCount: ReadController.chapter.length,
                                itemCount: ReadController.getChapterByStoryId
                                    .value.data?.chapterData?.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      ReadController.chapterIdIndexForNextPage(
                                          index);

                                      ///remove if condition
                                      // if ((ReadController
                                      //             .getChapterByStoryId
                                      //             .value
                                      //             .data
                                      //             ?.chapterData?[index]
                                      //             .readStatus
                                      //             .toString() ??
                                      //         '') ==
                                      //     "0") {
                                      final body = {
                                        "read_status": "1",
                                        "read_date": '${DateTime.now()}'
                                      };
                                      ReadController.updateChapterReadStatus(
                                              context,
                                              ReadController
                                                      .getChapterByStoryId
                                                      .value
                                                      .data
                                                      ?.chapterData?[index]
                                                      .id
                                                      .toString() ??
                                                  '',
                                              body)
                                          .then(
                                        (value) {
                                          HomeController.backToHomeChapter(false);
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
                                            storyName:
                                            // constants.deviceLanguage == "en"
                                                // ?
                                            ReadController.getChapterByStoryId.value.data?.chapterData?[index].name.toString() ?? '',
                                            // : ReadController.getChapterByStoryId.value.data?.chapterData?[index].japanese.toString() ?? '',
                                          ));
                                        },
                                      );
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.only(top: index == 0 ? 3 : 0, right: 20),
                                      child: Column(
                                        children: [
                                          if (index == 0)
                                            const Divider(
                                              color: indigo200,
                                            ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            getChapterNo(index),
                                                            style: AppTextStyle
                                                                .normalBold12
                                                                .copyWith(
                                                                    color: indigo950),
                                                            overflow: TextOverflow.ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    0.5.ph,
                                                    Text(
                                                      DateFormat('dd-MM-yyyy').format(
                                                          DateTime.tryParse(ReadController
                                                                      .getChapterByStoryId
                                                                      .value
                                                                      .data
                                                                      ?.chapterData?[
                                                                          index]
                                                                      .createdAt
                                                                      .toString() ??
                                                                  '') ??
                                                              DateTime.now()),
                                                      style: AppTextStyle
                                                          .normalRegular10
                                                          .copyWith(
                                                              color: dateGrey),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 8.0),
                                                child: SvgPicture.asset(
                                                  'icons/arrowRight.svg',
                                                  height: 24,
                                                  width: 24,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Divider(
                                            color: indigo200,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : Center(
                              child: Text(
                                'No Data Found'.tr,
                                textAlign: TextAlign.center,
                                style: AppTextStyle.normalRegular14
                                    .copyWith(color: indigo950),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  getChapterNo(index) {
    String chapterNo = '${"Chapter".tr} ${ReadController.getChapterByStoryId.value.data?.chapterData?[index].chapterNo!.split(" ")[1].toString()}';
    print("getChapterNo : ${ReadController.getChapterByStoryId.value.data?.chapterData?[index].chapterNo!.split(" ")[1].toString()}");
    String chapterName = ((ReadController.getChapterByStoryId.value.data?.chapterData?[index].chapterNo.toString() ?? '') != '')
        ? '$chapterNo : ${ReadController.getChapterByStoryId.value.data?.name}'
        : '$chapterNo : ${ReadController.getChapterByStoryId.value.data?.name}';
    return chapterName;
  }
}
