import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yokai_quiz_app/Widgets/progressHud.dart';
import 'package:yokai_quiz_app/screens/read/view/story_details_screen.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/const.dart';
import 'package:yokai_quiz_app/util/constants.dart';

import '../../../Widgets/searchbar.dart';
import '../../../api/database_api.dart';
import '../../../util/text_styles.dart';
import '../../chat/controller/chat_controller.dart';
import '../../home/controller/home_controller.dart';
import '../controller/read_controller.dart';
import 'open_story_screen.dart';

class BrowseStoriesPage extends StatefulWidget {
  const BrowseStoriesPage({super.key});

  @override
  State<BrowseStoriesPage> createState() => _BrowseStoriesPageState();
}

class _BrowseStoriesPageState extends State<BrowseStoriesPage> {
  RxBool isLoading = false.obs;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoading(true);
    ReadController.getAllStoriesData('').then((value) {
      isLoading(false);
    });
    // ReadController.isLoading(false);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Obx(() {
      return ProgressHUD(
        isLoading: isLoading.value,
        child: Scaffold(
          backgroundColor: colorWhite,
          body: Padding(
            padding:
                const EdgeInsets.only(right: 20, left: 20, bottom: 16, top: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Browse Stories '.tr,
                  style:
                      AppTextStyle.normalBold20.copyWith(color: headingColour),
                ),
                2.ph,
                CustomSearchBar(
                  hintText: 'Search Stories by Name'.tr,
                  controller: ReadController.searchStoriesController,
                  onTextChanged: (p0) {
                    // isLoading(true);
                    ReadController.getAllStoriesData(
                            ReadController.searchStoriesController.text)
                        .then((value) {
                      // isLoading(false);
                    });
                  },
                ),
                // 2.ph,
                Expanded(
                  child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1,
                        crossAxisSpacing: 1,
                        mainAxisSpacing: 5,
                        mainAxisExtent: screenSize.height / 4.7),
                    // itemCount: ReadController.read.length,
                    itemCount:
                        ReadController.getAllStoriesBy.value.data?.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          ReadController.backToStories(true);
                          ChatController.backToCharacters(false);
                          HomeController.backToHome(false);
                          ReadController.storyId('');
                          Get.to(StoryDetailsScreen(
                            storyId: ReadController
                                    .getAllStoriesBy.value.data?[index].id
                                    .toString() ??
                                '',
                          ));
                          ReadController.storyId(ReadController
                                  .getAllStoriesBy.value.data?[index].id
                                  .toString() ??
                              '');
                        },
                        child: Container(
                          height: screenSize.height / 4.5,
                          width: screenSize.width / 4,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: indigo50, width: 2),
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
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CachedNetworkImage(
                                  imageUrl:
                                      "${DatabaseApi.mainUrlImage}${ReadController.getAllStoriesBy.value.data?[index].storiesImage.toString() ?? ''}",
                                  height: screenSize.height / 6.8,
                                  // placeholder: (context, url) => CircularProgressIndicator(),
                                  placeholder: (context, url) => const Padding(
                                    padding: EdgeInsets.all(
                                        constants.defaultPadding * 2),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                  fit: BoxFit.cover,
                                ),
                                0.8.ph,
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: Text(
                                    ((ReadController.getAllStoriesBy.value
                                                        .data?[index].name
                                                        .toString() ??
                                                    '')
                                                .length >
                                            35)
                                        ? '${(ReadController.getAllStoriesBy.value.data?[index].name.toString() ?? '').substring(0, 35)}...'
                                        : ReadController.getAllStoriesBy.value
                                                .data?[index].name
                                                .toString() ??
                                            '',
                                    style: AppTextStyle.normalSemiBold10
                                        .copyWith(color: indigo950),
                                    maxLines: 2,
                                  ),
                                ),
                                0.8.ph,
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
