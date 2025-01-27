import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:yokai_quiz_app/Widgets/progressHud.dart';
import 'package:yokai_quiz_app/global.dart';
import 'package:yokai_quiz_app/screens/read/view/read_stories_page.dart';
import 'package:yokai_quiz_app/screens/read/view/story_open_story_page.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/const.dart';

import '../../../util/text_styles.dart';
import '../../home/controller/home_controller.dart';
import '../controller/read_controller.dart';

class ChapterPage extends StatefulWidget {
  String storyId;
  String storyName;
  ChapterPage({
    super.key,
    required this.storyId,
    required this.storyName,
  });

  @override
  State<ChapterPage> createState() => _ChapterPageState();
}

class _ChapterPageState extends State<ChapterPage> {
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
            context, OpenStoryPage(storyId: ReadController.storyId.value));
        return true;
      },
      child: Obx(
        () {
          return ProgressHUD(
            isLoading: isLoading.value,
            child: Scaffold(
              backgroundColor: colorWhite,
              floatingActionButton: GestureDetector(
                onTap: () {
                  ReadController.scrollToTop();
                },
                child: SvgPicture.asset('icons/arrowUp.svg'),
              ),
              body: Padding(
                padding: const EdgeInsets.only(
                    right: 20, left: 20, top: 60, bottom: 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Get.back();

                            nextPageOff(
                                context,
                                OpenStoryPage(
                                    storyId: ReadController.storyId.value));
                          },
                          child: SvgPicture.asset(
                            'icons/arrowLeft.svg',
                            height: 35,
                            width: 35,
                          ),
                        ),
                        1.pw,
                        Text(
                          widget.storyName,
                          style: AppTextStyle.normalBold16
                              .copyWith(color: coral500),
                        ),
                      ],
                    ),
                    1.ph,
                    ((ReadController.getChapterByStoryId.value.data?.chapterData
                                    ?.length ??
                                0) >
                            0)
                        ? Expanded(
                            child: ListView.builder(
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
                                        nextPage(ReadStoriesPage(
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
                                      },
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 20),
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
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      // 'Chapter ${ReadController.chapter[index]['chapter']}',
                                                      ((ReadController
                                                                      .getChapterByStoryId
                                                                      .value
                                                                      .data
                                                                      ?.chapterData?[
                                                                          index]
                                                                      .chapterNo
                                                                      .toString() ??
                                                                  '') !=
                                                              '')
                                                          ? '${ReadController.getChapterByStoryId.value.data?.chapterData?[index].chapterNo.toString() ?? ''} : ${ReadController.getChapterByStoryId.value.data?.chapterData?[index].name.toString() ?? ''}'
                                                          : 'Chapter :'.tr,

                                                      style: AppTextStyle
                                                          .normalBold12
                                                          .copyWith(
                                                              color: indigo950),
                                                    ),
                                                  ],
                                                ),
                                                0.5.ph,
                                                Text(
                                                  // ReadController.chapter[index]['date'],
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
                                            SvgPicture.asset(
                                              // '${ReadController.chapter[index]['image']}.svg',
                                              'icons/arrowRight.svg',
                                              height: 35,
                                              width: 35,
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
          );
        },
      ),
    );
  }
}
