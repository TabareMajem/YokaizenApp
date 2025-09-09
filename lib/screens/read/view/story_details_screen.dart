import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:yokai_quiz_app/Widgets/progressHud.dart';
import 'package:yokai_quiz_app/Widgets/second_custom_button.dart';
import 'package:yokai_quiz_app/api/database_api.dart';
import 'package:yokai_quiz_app/global.dart';
import 'package:yokai_quiz_app/screens/home/controller/home_controller.dart';
import 'package:yokai_quiz_app/screens/navigation/view/navigation.dart';
import 'package:yokai_quiz_app/screens/read/controller/read_controller.dart';
import 'package:yokai_quiz_app/screens/read/view/read_stories_screen.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/const.dart';
import 'package:yokai_quiz_app/util/constants.dart';
import 'package:yokai_quiz_app/util/text_styles.dart';

class StoryDetailsScreen extends StatefulWidget {
  final String storyId;

  StoryDetailsScreen({Key? key, required this.storyId}) : super(key: key);

  @override
  State<StoryDetailsScreen> createState() => _StoryDetailsScreenState();
}

class _StoryDetailsScreenState extends State<StoryDetailsScreen> with SingleTickerProviderStateMixin {
  RxBool isLoadingStory = false.obs;
  RxBool isLoadingChapters = false.obs;
  late TabController _tabController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    customPrint('storyId :: ${widget.storyId}');
    HomeController.backToHomeChapter(false);
    loadStoryData();
    _tabController.addListener(() {
      if (_tabController.index == 1) {
        loadChaptersData();
      }
      setState(() {}); // Refresh UI when tab changes to update bottom button
    });
  }

  void loadStoryData() async {
    isLoadingStory(true);
    await ReadController.getStoryByStoriesId(widget.storyId).then((value) {
      isLoadingStory(false);
    });
  }

  Future<void> loadChaptersData() async {
    isLoadingChapters(true);
    await ReadController.getAllChapterByStoryId(widget.storyId).then((value) {
      if ((ReadController.getChapterByStoryId.value.data?.chapterData?.length ?? 0) > 0) {
        ReadController.chapterIdForNextPage.clear();
        for (int i = 0; i < (ReadController.getChapterByStoryId.value.data?.chapterData?.length ?? 0); i++) {
          ReadController.chapterIdForNextPage.add(ReadController.getChapterByStoryId.value.data?.chapterData?[i].id);
        }
      }
      isLoadingChapters(false);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Helper method to extract chapter number from chapterNo string
  int extractChapterNumber(String? chapterNo) {
    if (chapterNo == null || chapterNo.isEmpty) return 0;
    
    // Remove any non-digit characters and parse
    final cleanNumber = chapterNo.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleanNumber) ?? 0;
  }

  // Helper method to get sorted chapters by chapter number
  List<dynamic> getSortedChapters() {
    final chapters = ReadController.getChapterByStoryId.value.data?.chapterData ?? [];
    
    // Debug: Print original chapters
    print("Original chapters:");
    for (int i = 0; i < chapters.length; i++) {
      print("  Index $i: chapterNo='${chapters[i].chapterNo}', name='${chapters[i].name}'");
    }
    
    final sortedChapters = List.from(chapters)..sort((a, b) {
      // Parse chapter numbers and sort numerically
      final aNum = extractChapterNumber(a.chapterNo);
      final bNum = extractChapterNumber(b.chapterNo);
      print("Sorting: Chapter ${a.chapterNo} (${aNum}) vs Chapter ${b.chapterNo} (${bNum})");
      return aNum.compareTo(bNum);
    });
    
    print("Sorted chapters:");
    for (int i = 0; i < sortedChapters.length; i++) {
      print("  Index $i: chapterNo='${sortedChapters[i].chapterNo}', name='${sortedChapters[i].name}'");
    }
    
    return sortedChapters;
  }

  // Helper method to get original index from sorted index
  int getOriginalIndex(int sortedIndex) {
    final chapters = ReadController.getChapterByStoryId.value.data?.chapterData ?? [];
    final sortedChapters = getSortedChapters();
    if (sortedIndex < sortedChapters.length) {
      final chapter = sortedChapters[sortedIndex];
      return chapters.indexOf(chapter);
    }
    return sortedIndex;
  }

  void startReading(int index) {
    if ((ReadController.getChapterByStoryId.value.data?.chapterData?.length ?? 0) > index) {
      final chapter = ReadController.getChapterByStoryId.value.data?.chapterData?[index];
      if (chapter != null) {
        ReadController.chapterIdIndexForNextPage(index);
        final body = {
          "read_status": "1",
          "read_date": '${DateTime.now()}'
        };
        ReadController.updateChapterReadStatus(
            context,
            chapter.id.toString(),
            body
        ).then((value) {
          HomeController.backToHomeChapter(false);
          nextPage(ReadStoriesScreen(
            chapterId: chapter.id.toString(),
            storyName: chapter.name.toString(),
          ));
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationPage(index: 1)));
        return false;
      },
      child: Obx(() {
        return ProgressHUD(
          isLoading: isLoadingStory.value || isLoadingChapters.value,
          child: Scaffold(
            backgroundColor: colorWhite,
            body: Stack(
              children: [
                // Full height image
                CachedNetworkImage(
                  imageUrl: "${DatabaseApi.mainUrlImage}${ReadController.getStoriesById.value.data?.storiesImage.toString() ?? ''}",
                  placeholder: (context, url) => const Padding(
                    padding: EdgeInsets.all(constants.defaultPadding * 2),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.error,
                    color: AppColors.black,
                  ),
                  fit: BoxFit.cover,
                  height: screenSize.height,
                  width: screenSize.width,
                ),

                // Back button
                Positioned(
                  top: 40,
                  left: 15,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => NavigationPage(index: 1))
                      );
                    },
                    child: SvgPicture.asset(
                      'icons/arrowLeft1.svg',
                      height: 40,
                      width: 40,
                    ),
                  ),
                ),

                // Bottom sheet with tabs
                DraggableScrollableSheet(
                  initialChildSize: 0.5,
                  minChildSize: 0.4,
                  maxChildSize: 0.8,
                  builder: (context, scrollController) {
                    return Container(
                      decoration: const BoxDecoration(
                        color: colorWhite,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 12, bottom: 8),
                            child: Container(
                              height: 4,
                              width: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),

                          // Tab Bar
                          TabBar(
                            controller: _tabController,
                            labelColor: coral500,
                            unselectedLabelColor: greyCh,
                            indicatorColor: coral500,
                            tabs: [
                              Tab(text: "Description".tr),
                              Tab(text: "Chapters".tr),
                            ],
                          ),

                          // Tab content - Expanded to take available space
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                // Description Tab
                                SingleChildScrollView(
                                  controller: scrollController,
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ReadController.getStoriesById.value.data?.name ?? '',
                                        style: AppTextStyle.normalBold16.copyWith(color: coral500),
                                      ),
                                      2.ph,
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${ReadController.getStoriesById.value.data?.chapterCount.toString() ?? ''} ' + 'Chapters'.tr,
                                            style: AppTextStyle.normalBold12.copyWith(color: greyCh),
                                          ),
                                          Text(
                                            '${ReadController.getStoriesById.value.data?.activityCount.toString() ?? ''} ' + 'Activities'.tr,
                                            style: AppTextStyle.normalBold12.copyWith(color: greyCh),
                                          ),
                                          Text(
                                            'Unlock Character'.tr,
                                            style: AppTextStyle.normalBold12.copyWith(color: greyCh),
                                          ),
                                        ],
                                      ),
                                      2.ph,
                                      Text(
                                        ReadController.getStoriesById.value.data?.discription.toString() ?? '',
                                        style: AppTextStyle.normalBold12.copyWith(color: grey2),
                                      ),
                                      SizedBox(height: 100), // Extra space for button
                                    ],
                                  ),
                                ),

                                // Chapters Tab
                                CustomScrollView(
                                  controller: scrollController,
                                  slivers: [
                                    SliverToBoxAdapter(
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Row(
                                          children: [
                                            Text(
                                              "${ReadController.getChapterByStoryId.value.data?.chapterData?.length ?? 0} "+ "Chapters".tr,
                                              style: AppTextStyle.normalBold14.copyWith(color: indigo950),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Chapter list
                                    ((ReadController.getChapterByStoryId.value.data?.chapterData?.length ?? 0) > 0)
                                        ? SliverList(
                                                                              delegate: SliverChildBuilderDelegate(
                                            (context, index) {
                                              customPrint("SliverChildBuilderDelegate getStory index : $index");
                                          
                                          // Get sorted chapters by chapter number
                                          final sortedChapters = getSortedChapters();
                                          final chapter = sortedChapters[index];
                                          final originalIndex = getOriginalIndex(index); // Get original index for startReading
                                          
                                          print("Displaying at index $index: Chapter ${chapter?.chapterNo}. ${chapter?.name}");
                                          
                                          return InkWell(
                                            onTap: () {
                                              startReading(originalIndex);
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  top: BorderSide(color: Colors.grey.withOpacity(0.2)),
                                                  bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      "${chapter?.chapterNo ?? ''}. ${chapter?.name ?? ''}",
                                                      style: AppTextStyle.normalBold14.copyWith(color: indigo950),
                                                    ),
                                                  ),
                                                  // Lock icon for locked chapters - use chapter number instead of index
                                                  if (extractChapterNumber(chapter?.chapterNo) > 5)
                                                    Icon(
                                                      Icons.lock,
                                                      color: greyCh,
                                                      size: 18,
                                                    ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                        childCount: ReadController.getChapterByStoryId.value.data?.chapterData?.length ?? 0,
                                      ),
                                    )
                                        : SliverFillRemaining(
                                      child: Center(
                                        child: Text(
                                          'No Data Found'.tr,
                                          textAlign: TextAlign.center,
                                          style: AppTextStyle.normalRegular14.copyWith(color: indigo950),
                                        ),
                                      ),
                                    ),
                                    SliverToBoxAdapter(
                                      child: SizedBox(height: 100), // Extra space for button
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // Button fixed at bottom
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _tabController.index == 0
                        ? SecondCustomButton(
                      width: screenSize.width / 2,
                      iconSvgPath: 'icons/readNow.svg',
                      text: "Read Now".tr,
                      onPressed: () async {
                        // First load chapters data
                        await loadChaptersData();
                        // Switch to chapters tab
                        _tabController.animateTo(1);
                      },
                    )
                        : SecondCustomButton(
                      width: screenSize.width / 2,
                      iconSvgPath: 'icons/readNow.svg',
                      text: "Continue".tr,
                      onPressed: () {
                        if ((ReadController.getChapterByStoryId.value.data?.chapterData?.length ?? 0) > 0) {
                          // Get the first chapter's original index using helper method
                          final originalIndex = getOriginalIndex(0);
                          startReading(originalIndex);
                        }
                      },
                    ),
                  ),
                ),

              ],
            ),
          ),
        );
      }),
    );
  }
}