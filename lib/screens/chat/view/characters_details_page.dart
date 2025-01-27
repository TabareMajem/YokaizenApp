import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:yokai_quiz_app/Widgets/progressHud.dart';
import 'package:yokai_quiz_app/models/get_all_stories.dart';
import 'package:yokai_quiz_app/screens/read/view/story_open_story_page.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/const.dart';

import '../../../Widgets/second_custom_button.dart';
import '../../../api/database_api.dart';
import '../../../global.dart';
import '../../../util/text_styles.dart';
import '../../home/controller/home_controller.dart';
import '../../navigation/view/navigation.dart';
import '../../read/controller/read_controller.dart';
import '../controller/chat_controller.dart';

class CharactersDetailsPage extends StatefulWidget {
  String characterId;

  CharactersDetailsPage({super.key, required this.characterId});

  @override
  State<CharactersDetailsPage> createState() => _CharactersDetailsPageState();
}

class _CharactersDetailsPageState extends State<CharactersDetailsPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoading(true);
    clearData().then(
      (value) {
        fetchCharactersNyIdData();
      },
    );
  }

  Future clearData() async {
    ChatController.chDetails.clear();
  }

  fetchCharactersNyIdData() async {
    await ChatController.getCharactersById(widget.characterId).then(
      (value) {
  
        ChatController.chDetails.addAll((fixEncoding(ChatController
                    .getCharactersByIdModel.value.data?.tags
                    .toString() ??
                ''))
            .replaceAll("[", '')
            .replaceAll(']', '')
            .split(',')
            .map((e) => e.trim()));
        isLoading(false);
      },
    );
  }

  RxBool isLoading = false.obs;
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        if (ChatController.backToCharactersForCharactersDetails.isTrue) {
          nextPageOff(
            context,
            NavigationPage(
              index: 2,
            ),
          );
        }
        if (HomeController.backToHomeFromCharactersDetails.isTrue) {
          nextPageOff(
            context,
            NavigationPage(
              index: 0,
            ),
          );
        }
        return false;
      },
      child: Obx(() {
        return ProgressHUD(
          isLoading: isLoading.value,
          child: Scaffold(
            backgroundColor: colorWhite,
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(
                    right: 20, left: 20, bottom: 16, top: 60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (ChatController
                                .backToCharactersForCharactersDetails.isTrue) {
                              nextPageOff(
                                context,
                                NavigationPage(
                                  index: 2,
                                ),
                              );
                            }
                            if (HomeController
                                .backToHomeFromCharactersDetails.isTrue) {
                              nextPageOff(
                                context,
                                NavigationPage(
                                  index: 0,
                                ),
                              );
                            }
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
                          'Character Details '.tr,
                          style: AppTextStyle.normalBold16
                              .copyWith(color: coral500),
                        ),
                      ],
                    ),
                    2.ph,
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Center(
                          child: CircularPercentIndicator(
                            radius: 90.0,
                            lineWidth: 8.0,
                            // percent: 10 / 100,
                            percent: (double.tryParse((ChatController
                                                .getCharactersByIdModel
                                                .value
                                                .data
                                                ?.totalReadChapter
                                                ?.toDouble() ??
                                            0.0)
                                        .toString()) ??
                                    0.0) /
                                (double.tryParse((ChatController
                                                .getCharactersByIdModel
                                                .value
                                                .data
                                                ?.totalChapter
                                                ?.toDouble() ??
                                            0.0)
                                        .toString()) ??
                                    0.0),

                            center: ClipRRect(
                              borderRadius: BorderRadius.circular(90),
                              // half of the height/width
                              child: CachedNetworkImage(
                                imageUrl:
                                    "${DatabaseApi.mainUrlImage}${ChatController.getCharactersByIdModel.value.data?.characterImage.toString() ?? ''}",
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
                                height: 150,
                                width: 150,
                                fit: BoxFit.fill,
                              ),
                            ),
                            progressColor: coral500,
                            backgroundColor: coral100,
                          ),
                        ),
                      ],
                    ),
                    1.ph,
                    Center(
                      child: Text(
                        ChatController.getCharactersByIdModel.value.data?.name
                                .toString() ??
                            '',
                        textAlign: TextAlign.center,
                        style: AppTextStyle.normalBold16.copyWith(color: grey3),
                      ),
                    ),
                    2.ph,
                    if ((ChatController.chDetails.length) > 0)
                      Wrap(
                        spacing: 6, // Adjust as needed
                        runSpacing: 10, // Adjust as needed
                        children: List.generate(
                          ChatController.chDetails.length,
                          (index) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              color: coral100,
                              border: Border.all(
                                color: coral500,
                              ),
                            ),
                            child: Text(
                              ChatController.chDetails[index],
                              style: AppTextStyle.normalSemiBold12
                                  .copyWith(color: coral500),
                            ),
                          ),
                        ),
                      ),
                    4.ph,
                    Text(
                      // "Hey there!\n'm ${ChatController.getCharactersByIdModel.value.data?.name.toString() ?? ''}, your AI buddy who's always up for a chat,\na laugh, or a good dose of motivation.",
                      ChatController.getCharactersByIdModel.value.data
                              ?.introduction ??
                          '',
                      style:
                          AppTextStyle.normalRegular14.copyWith(color: grey2),
                    ),
                    // 3.ph,
                    // Text(
                    //   "I'm like your best friend who's always learning\n(and let's be honest, sometimes messing up ), but hey,\nthat's how we grow, right?\nSo, what's on your mind today?",
                    //   style:
                    //       AppTextStyle.normalRegular14.copyWith(color: grey2),
                    // ),
                    4.ph,
                    Text(
                      "To Chat with me:".tr,
                      style: AppTextStyle.normalRegular14
                          .copyWith(color: coral500),
                    ),
                    2.ph,
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text:
                                '1. Complete 3 Activities in this story : '.tr,
                            style: AppTextStyle.normalRegular14
                                .copyWith(color: grey2),
                          ),
                          TextSpan(
                            text: ChatController.getCharactersByIdModel.value
                                    .data?.storyName
                                    .toString() ??
                                '',
                            style: AppTextStyle.normalSemiBold14
                                .copyWith(color: indigo600),
                          ),
                        ],
                      ),
                    ),
                    2.ph,
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text:
                                '2. Read until 5th chapter in this story and collect 400 points from it '
                                    .tr,
                            style: AppTextStyle.normalRegular14
                                .copyWith(color: grey2),
                          ),
                        ],
                      ),
                    ),
                    2.ph,
                    if (ChatController.getCharactersByIdModel.value.data !=
                        null)
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  '3. ${ChatController.getCharactersByIdModel.value.data?.requirements.toString() ?? ''}',
                              style: AppTextStyle.normalRegular14
                                  .copyWith(color: grey2),
                            ),
                          ],
                        ),
                      ),
                    2.ph,
                    SecondCustomButton(
                      onPressed: () {
                        ChatController.backToCharacters(true);
                        HomeController.backToHome(false);
                        ReadController.backToStories(false);
                        ReadController.storyId('');
                        Get.to(OpenStoryPage(
                          storyId: ChatController
                                  .getCharactersByIdModel.value.data?.storiesId
                                  .toString() ??
                              '',
                        ));
                        ReadController.storyId(
                          ChatController
                                  .getCharactersByIdModel.value.data?.storiesId
                                  .toString() ??
                              '',
                        );
                        // nextPage(const CharacterUnlockPage());
                      },
                      width: screenSize.width / 2,
                      height: 50,
                      iconSvgPath: 'icons/arrowRight.svg',
                      text: "Go to Story".tr,
                      textSize: 14,
                    ),
                    5.ph,
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
