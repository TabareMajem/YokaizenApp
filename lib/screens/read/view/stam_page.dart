import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/const.dart';

import '../../../Widgets/new_button.dart';
import '../../../Widgets/second_custom_button.dart';
import '../../../api/database_api.dart';
import '../../../global.dart';
import '../../../util/text_styles.dart';
import '../../chat/view/character_unlock_page.dart';
import '../controller/read_controller.dart';
import 'audio_ui.dart';
import 'congratulation_page.dart';

class StampPage extends StatefulWidget {
  const StampPage({super.key});

  @override
  State<StampPage> createState() => _StampPageState();
}

class _StampPageState extends State<StampPage> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Obx(() {
      return Scaffold(
        backgroundColor: colorWhite,
        body: Padding(
          padding:
              const EdgeInsets.only(right: 20, left: 20, bottom: 16, top: 60),
          child: Column(
            children: [
              3.ph,
              Row(
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
                  Center(
                    child: Text(
                      'Healthy Coping Mechanisms Quiz'.tr,
                      style:
                          AppTextStyle.normalBold16.copyWith(color: coral500),
                    ),
                  ),
                ],
              ),
              5.ph,
              if (((ReadController.getActivityByChapterId.value.data?[0].audio
                              .toString() ??
                          '') !=
                      '') &&
                  ((ReadController.getActivityByChapterId.value.data?[0].audio
                              .toString() ??
                          '') !=
                      'null'))
                Container(
                  height: 170,
                  // width: screenWidth / 3,
                  // margin:
                  //     const EdgeInsets.symmetric(vertical: 28),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: containerBack,
                    border: Border.all(color: containerBorder),
                  ),
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: AudioPlayerWidget(
                          audioUrl:
                              "${DatabaseApi.mainUrlImage}${ReadController.getActivityByChapterId.value.data?[0].audio.toString() ?? ''}",
                          fileName: (ReadController.getActivityByChapterId.value
                                      .data?[0].audio
                                      .toString() ??
                                  '')
                              .split('/')
                              .last,
                        ),
                      ),
                    ],
                  ),
                ),
              // 2.ph,
              // if (ReadController.isStampShow.value == 1)
              //   if (((ReadController.getActivityByChapterId.value.data?[0].image
              //                   .toString() ??
              //               '') !=
              //           '') &&
              //       ((ReadController.getActivityByChapterId.value.data?[0].image
              //                   .toString() ??
              //               '') !=
              //           'null'))
              //     Center(
              //       child: ClipRRect(
              //         borderRadius: BorderRadius.circular(12),
              //         child: Image.network(
              //           '${DatabaseApi.mainUrlImage}${ReadController.getActivityByChapterId.value.data?[0].image.toString() ?? ''}',
              //           fit: BoxFit.contain,
              //           height: MediaQuery.of(context).size.height / 3,
              //           width: MediaQuery.of(context).size.width / 1.2,
              //         ),
              //       ),
              //     ),
              4.ph,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomButton(
                      onPressed: () {
                        Get.back();
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
                    SecondCustomButton(
                      onPressed: () {
                        if (ReadController.isStampShow.value == 0) {
                          ReadController.isStampShow(1);
                        } else {
                          final readStatus = ReadController
                                  .getActivityByChapterId
                                  .value
                                  .data?[0]
                                  .readStatus
                                  .toString() ??
                              '';
                          final unlockedCharacterStatus = ReadController
                                  .getActivityByChapterId
                                  .value
                                  .data?[0]
                                  .unlockedCharacterStatus
                                  .toString() ??
                              '';
                          if (readStatus == 'yes' &&
                              unlockedCharacterStatus == 'no') {
                            nextPage(CharacterUnlockPage(
                              characterId: ReadController.getActivityByChapterId
                                      .value.data?[0].characterId
                                      .toString() ??
                                  '',
                              characterName: ReadController
                                      .getActivityByChapterId
                                      .value
                                      .data?[0]
                                      .unlockedCharacterStatus
                                      .toString() ??
                                  '',
                              characterImage: ReadController
                                      .getActivityByChapterId
                                      .value
                                      .data?[0]
                                      .characterImage
                                      .toString() ??
                                  '',
                              length: ReadController.getActivityByChapterId
                                      .value.data?[0].details?.length
                                      .toString() ??
                                  '',
                            ));
                          } else {
                            nextPage(CongratulationPage(
                              length: ReadController.getActivityByChapterId
                                      .value.data?[0].details?.length
                                      .toString() ??
                                  '',
                            ));
                          }
                        }
                      },
                      width: screenSize.width / 2.6,
                      iconSvgPath: 'icons/arrowRight.svg',
                      text: "Next".tr,
                      textSize: 14,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}
