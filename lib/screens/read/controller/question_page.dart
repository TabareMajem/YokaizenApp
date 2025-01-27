import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yokai_quiz_app/screens/read/controller/read_controller.dart';
import 'package:yokai_quiz_app/screens/read/view/stam_page.dart';
import 'package:yokai_quiz_app/util/const.dart';

import '../../../Widgets/confirmation_box.dart';
import '../../../Widgets/new_button.dart';
import '../../../Widgets/progressHud.dart';
import '../../../Widgets/second_custom_button.dart';
import '../../../api/database_api.dart';
import '../../../global.dart';
import '../../../util/colors.dart';
import '../../../util/text_styles.dart';
import '../view/congratulation_page.dart';

class Question extends StatefulWidget {
  Question(
      {super.key,
      this.subId = "",
      required this.reviewTest,
      this.examType,
      this.title = '',
      this.chapterId = '',
      this.microNotesId = ''});

  bool reviewTest = false;
  final String title;
  final String subId;
  final String chapterId;
  String? examType;
  String microNotesId;

  @override
  State<Question> createState() => _QuestionState();
}

class _QuestionState extends State<Question> {
  int seconds = 1800;
  int minute = 0;
  int second = 0;
  int totalDuration = 30 * 60;
  int score = 0;

  @override
  void initState() {
    super.initState();
    customPrint("Micronotes Id question page:: ${widget.microNotesId}");
    // ReadController.isStampImageAndAudio(false);
    // if (widget.microNotesId != '') {
    fetchExamDetails();
    // }
    customPrint('listofcolor::${multiColor}');
    isLoading(false);
  }

  Future<void> fetchExamDetails() async {
    try {
      // bool success = await ReadController.getActivityDetailsByChapterId(widget.chapterId);
      // if (success) {
      questions.clear();
      options.clear();
      image.clear();
      correctAnswers.clear();
      isExplanation.clear();
      if (!widget.reviewTest) {
        userSelectedAnswer.clear();
        ansIndex.clear();
      }
      if (ReadController.getActivityByChapterId.value.data != null) {
        for (var data
            in ReadController.getActivityByChapterId.value.data![0].details!) {
          questions.add(
              ReadController.decodeApiString(hexString: data.question ?? ''));
          final nonEmptyOptions = (data.options ?? [])
              .where((option) => option.isNotEmpty)
              .toList();
          if (nonEmptyOptions.isNotEmpty) {
            options.add(nonEmptyOptions
                .map((option) =>
                    ReadController.decodeApiString(hexString: option))
                .toList());
          }
          image.add(ReadController
                  .getActivityByChapterId.value.data![0].activityImage ??
              []);
          correctAnswers.add(ReadController.decodeApiString(
              hexString: data.correctAnswer ?? ''));
        }
        setState(() {});
        customPrint("questions :: $questions");
        customPrint("options :: $options");
        customPrint("image :: $image");
        customPrint("correctAnswers :: $correctAnswers");
        customPrint("ansIndex :: $ansIndex");
        customPrint("ansIndex length :: ${ansIndex.length}");
        isLoading(false);
        userSelectedOptions = List.filled(options.length, null);

        customPrint("userSelectedOptions :: $userSelectedOptions");
      }
      // } else {
      //   showErrorMessage(context, "Error fetching questions");
      //   isLoading(false);
      // }
    } catch (e) {
      showErrorMessage("Error $e", errorColor);
      isLoading(false);
    }
  }

  double progressValue = 0.0;
  Timer? timer;
  int currantindex = -1;
  double tap = 0.0;
  List<Color> col = [];
  List multiColor = [];
  RxBool isLoading = true.obs;
  PageController pageController = PageController();

  @override
  void dispose() {
    super.dispose();
    timer!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Obx(() {
        return ProgressHUD(
          isLoading: isLoading.value,
          child: Scaffold(
            backgroundColor: colorWhite,
            body: Center(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Flexible(
                        child: PageView.builder(
                            controller: pageController,
                            physics: const NeverScrollableScrollPhysics(),
                            // itemCount: ReadController.questionexam.length,
                            itemCount: ReadController.getActivityByChapterId
                                .value.data?[0].details?.length,
                            itemBuilder: (context, index) {
                              List.generate(
                                  (ReadController.getActivityByChapterId.value
                                          .data?[0].details?.length) ??
                                      0,
                                  (index) => isExplanation.add(false));
                              return SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // if (ReadController
                                    //     .isStampImageAndAudio.isFalse)
                                    if (isExplanation[index] == false)
                                      Text(
                                        '${index + 1}.${ReadController.decodeApiString(hexString: ReadController.getActivityByChapterId.value.data?[0].details?[index].question.toString() ?? '')}',
                                        style: AppTextStyle.normalSemiBold13
                                            .copyWith(color: queGrey),
                                      ),
                                    // if (ReadController
                                    //     .isStampImageAndAudio.isFalse)
                                    if (isExplanation[index] == false)
                                      if (((ReadController
                                                      .getActivityByChapterId
                                                      .value
                                                      .data?[0]
                                                      .details?[index]
                                                      .image
                                                      .toString() ??
                                                  '') !=
                                              '') &&
                                          ((ReadController
                                                      .getActivityByChapterId
                                                      .value
                                                      .data?[0]
                                                      .details?[index]
                                                      .image
                                                      .toString() ??
                                                  '') !=
                                              'null'))
                                        2.ph,
                                    // if (ReadController
                                    //     .isStampImageAndAudio.isFalse)
                                    if (isExplanation[index] == false)
                                      if (((ReadController
                                                      .getActivityByChapterId
                                                      .value
                                                      .data?[0]
                                                      .details?[index]
                                                      .image
                                                      .toString() ??
                                                  '') !=
                                              '') &&
                                          ((ReadController
                                                      .getActivityByChapterId
                                                      .value
                                                      .data?[0]
                                                      .details?[index]
                                                      .image
                                                      .toString() ??
                                                  '') !=
                                              'null'))
                                        Center(
                                            child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.network(
                                            '${DatabaseApi.mainUrlImage}${ReadController.getActivityByChapterId.value.data?[0].details?[index].image.toString() ?? ''}',
                                            fit: BoxFit.fill,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                5.5,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                          ),
                                        )),
                                    // if (ReadController
                                    //     .isStampImageAndAudio.isFalse)
                                    if (isExplanation[index] == false)
                                      ListView.builder(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: options[index].length,
                                        itemBuilder: (context, listIndex) {
                                          col = List.generate(
                                              options[index].length,
                                              (index) =>
                                                  const Color(0xffEEF9FF));

                                          bool isSelected =
                                              currantindex == listIndex;
                                          Color optionColor =
                                              const Color(0xffEEF9FF);
                                          if (widget.reviewTest) {
                                            if (listIndex == currantindex) {
                                              optionColor = ansIndex
                                                          .isNotEmpty &&
                                                      ansIndex.length > index &&
                                                      ansIndex[index]
                                                              ['index'] ==
                                                          listIndex
                                                  ? ansIndex[index]['color']
                                                  : optionColor;
                                            } else if (options[index]
                                                    [listIndex] ==
                                                correctAnswers[index]) {
                                              optionColor = rightAns;
                                            } else {
                                              optionColor = ansIndex
                                                          .isNotEmpty &&
                                                      ansIndex.length > index &&
                                                      ansIndex[index]
                                                              ['index'] ==
                                                          listIndex
                                                  ? ansIndex[index]['color']
                                                  : optionColor;
                                            }
                                          } else {
                                            if (isSelected) {
                                              optionColor = primaryColorLite;
                                            }
                                          }

                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 5),
                                            child: GestureDetector(
                                              onTap: () {
                                                if (!widget.reviewTest) {
                                                  setState(() {
                                                    currantindex = listIndex;
                                                  });
                                                }
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: indigo300,
                                                    // isSelected
                                                    //     ? indigo300
                                                    //     : Colors.transparent,
                                                    width: 1,
                                                  ),
                                                  color: colorWhite,
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10,
                                                      vertical: 4),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Flexible(
                                                        child: Text(
                                                          // ReadController
                                                          //         .option[index]
                                                          //     [listIndex],
                                                          ///decode comment
                                                          // ReadController
                                                          //     .decodeApiString(
                                                          //         hexString:
                                                          options[index]
                                                              [listIndex],
                                                          // ),
                                                          ///

                                                          style: TextStyle(
                                                            color: isSelected
                                                                ? indigo700
                                                                : const Color(
                                                                    0xFF122E59),
                                                            fontSize: 14,
                                                            fontFamily:
                                                                'Montserrat',
                                                            fontWeight:
                                                                isSelected
                                                                    ? FontWeight
                                                                        .w700
                                                                    : FontWeight
                                                                        .w500,
                                                          ),
                                                        ),
                                                      ),
                                                      // if (!widget.reviewTest)
                                                      Radio(
                                                        activeColor:
                                                            primaryColor,
                                                        value: listIndex,
                                                        groupValue:
                                                            currantindex,
                                                        onChanged: !widget
                                                                .reviewTest
                                                            ? (value) {
                                                                setState(() {
                                                                  currantindex =
                                                                      value
                                                                          as int;
                                                                  [listIndex];
                                                                });
                                                              }
                                                            : null,
                                                        autofocus: true,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    3.ph,
                                    // if (ReadController
                                    //     .isStampImageAndAudio.isFalse)
                                    //   if (isExplanation[index] == true) 2.ph,
                                    // if (ReadController
                                    //     .isStampImageAndAudio.isFalse)
                                    if (isExplanation[index] == true)
                                      Text(
                                        '${"Explanation".tr} : ${ReadController.decodeApiString(hexString: ReadController.getActivityByChapterId.value.data?[0].details?[index].explation.toString() ?? '')}',
                                        style: AppTextStyle.normalSemiBold13
                                            .copyWith(color: queGrey),
                                      ),

                                    4.ph,
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          CustomButton(
                                            onPressed: () {
                                              if (index != 0) {
                                                // index--;
                                                // pageController
                                                //     .jumpToPage(index);
                                                ///
                                                index--;
                                                currantindex =
                                                    ansIndex[index]['index'];
                                                isExplanation[index] = false;
                                                // mapColors = {
                                                //   'index': ansIndex[index]['index'],
                                                //   'color': ansIndex[index]['color']
                                                // };
                                                pageController
                                                    .jumpToPage(index);
                                              }
                                            },
                                            text: 'Previous'.tr,
                                            colorText: primaryColor,
                                            textSize: 14,
                                            iconSvgPath: 'icons/arrowLeft.svg',
                                            colorSvg: primaryColor,
                                            color: indigo50,
                                            border:
                                                Border.all(color: indigo700),
                                            width: screenSize.width / 2.6,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                          ),
                                          SecondCustomButton(
                                            onPressed: () {
                                              customPrint(
                                                  "abcdef :: ${((ReadController.getActivityByChapterId.value.data?[0].audio.toString() ?? '') == "null" && (ReadController.getActivityByChapterId.value.data?[0].audio.toString() ?? '') == "" && (ReadController.getActivityByChapterId.value.data?[0].image.toString() ?? '') == "null" && (ReadController.getActivityByChapterId.value.data?[0].image.toString() ?? '') == "")}");
                                              if (widget.reviewTest != true) {
                                                if (index !=
                                                        (ReadController
                                                                    .getActivityByChapterId
                                                                    .value
                                                                    .data?[0]
                                                                    .details
                                                                    ?.length ??
                                                                0) -
                                                            1 &&
                                                    currantindex != -1) {
                                                  if (isExplanation[index] ==
                                                      false) {
                                                    isExplanation[index] = true;
                                                    customPrint(
                                                        'isExplanation :: ${isExplanation[index]}');
                                                  } else {
                                                    customPrint(
                                                        'isExplanation :: ${isExplanation[index]}');
                                                    checkAnswer(
                                                        index, currantindex);
                                                    tap++;
                                                    currantindex = -1;
                                                    index++;
                                                    pageController
                                                        .jumpToPage(index);
                                                  }
                                                } else if (index ==
                                                    (ReadController
                                                                .getActivityByChapterId
                                                                .value
                                                                .data?[0]
                                                                .details
                                                                ?.length ??
                                                            0) -
                                                        1) {
                                                  if (isExplanation[index] ==
                                                      false) {
                                                    isExplanation[index] = true;
                                                    customPrint(
                                                        'isExplanation :: ${isExplanation[index]}');
                                                  } else {
                                                    // if ((ReadController
                                                    //     .getActivityByChapterId
                                                    //     .value
                                                    //     .data?[0]
                                                    //     .readStatus
                                                    //     .toString() ??
                                                    //     '') ==
                                                    //     'yes') {
                                                    String? audio = ReadController
                                                        .getActivityByChapterId
                                                        .value
                                                        .data?[0]
                                                        .audio
                                                        ?.toString();
                                                    String? image = ReadController
                                                        .getActivityByChapterId
                                                        .value
                                                        .data?[0]
                                                        .image
                                                        ?.toString();
                                                    customPrint(
                                                        "audio :: $audio");
                                                    customPrint(
                                                        "image :: $image");
                                                    // Check if both audio and image are either "null" or empty string ""
                                                    customPrint(
                                                        "stamp audio :: ${(audio == null || audio == "") && (image == null || image == "")}");
                                                    if ((audio == null ||
                                                            audio == "" ||
                                                            audio == "null") &&
                                                        (image == null ||
                                                            image == "" ||
                                                            image == "null")) {
                                                      nextPage(
                                                        CongratulationPage(
                                                          length: ReadController
                                                                  .getActivityByChapterId
                                                                  .value
                                                                  .data?[0]
                                                                  .details
                                                                  ?.length
                                                                  .toString() ??
                                                              '',
                                                          score:
                                                              score.toString(),
                                                        ),
                                                      );
                                                    } else {
                                                      nextPage(
                                                          const StampPage());
                                                    }
                                                    // nextPage(
                                                    //     CongratulationPage(
                                                    //       length: ReadController
                                                    //           .getActivityByChapterId
                                                    //           .value
                                                    //           .data?[0]
                                                    //           .details
                                                    //           ?.length
                                                    //           .toString() ??
                                                    //           '',
                                                    //       score: score.toString(),
                                                    //     ));
                                                    // } else {
                                                    //   nextPage(
                                                    //       CharacterUnlockPage(characterId: '',
                                                    //         characterName: ReadController
                                                    //             .getActivityByChapterId
                                                    //             .value
                                                    //             .data?[0]
                                                    //             .characterName
                                                    //             .toString() ??
                                                    //             '',
                                                    //         characterImage: ReadController
                                                    //             .getActivityByChapterId
                                                    //             .value
                                                    //             .data?[0]
                                                    //             .characterImage
                                                    //             .toString() ??
                                                    //             '',
                                                    //         length: ReadController
                                                    //             .getActivityByChapterId
                                                    //             .value
                                                    //             .data?[0]
                                                    //             .details
                                                    //             ?.length
                                                    //             .toString() ??
                                                    //             '',
                                                    //         score: score.toString(),
                                                    //       ));
                                                    // }
                                                    checkAnswer(
                                                        index, currantindex);

                                                    // submitMcq();
                                                  }
                                                } else {
                                                  customPrint(
                                                      'Please Select One Option');
                                                  showErrorMessage(
                                                      'Please Select One Option',
                                                      errorColor);
                                                }
                                              } else {
                                                if (isExplanation[index] ==
                                                    false) {
                                                  isExplanation[index] = true;
                                                  customPrint(
                                                      'isExplanation :: ${isExplanation[index]}');
                                                } else {
                                                  if (index !=
                                                      (ReadController
                                                                  .getActivityByChapterId
                                                                  .value
                                                                  .data?[0]
                                                                  .details
                                                                  ?.length ??
                                                              0) -
                                                          1) {
                                                    customPrint(
                                                        'isExplanation :: ${isExplanation[index]}');
                                                    tap++;
                                                    index++;
                                                    pageController
                                                        .jumpToPage(index);
                                                  } else if (index ==
                                                      (ReadController
                                                                  .getActivityByChapterId
                                                                  .value
                                                                  .data?[0]
                                                                  .details
                                                                  ?.length ??
                                                              0) -
                                                          1) {
                                                    // if ((ReadController
                                                    //     .getActivityByChapterId
                                                    //     .value
                                                    //     .data?[0]
                                                    //     .readStatus
                                                    //     .toString() ??
                                                    //     '') !=
                                                    //     'yes') {
                                                    String? audio = ReadController
                                                        .getActivityByChapterId
                                                        .value
                                                        .data?[0]
                                                        .audio
                                                        ?.toString();
                                                    String? image = ReadController
                                                        .getActivityByChapterId
                                                        .value
                                                        .data?[0]
                                                        .image
                                                        ?.toString();

                                                    // Check if both audio and image are either "null" or empty string ""
                                                    if ((audio == "null" ||
                                                            audio!.isEmpty) &&
                                                        (image == "null" ||
                                                            image!.isEmpty)) {
                                                      nextPage(
                                                        CongratulationPage(
                                                          length: ReadController
                                                                  .getActivityByChapterId
                                                                  .value
                                                                  .data?[0]
                                                                  .details
                                                                  ?.length
                                                                  ?.toString() ??
                                                              '',
                                                          score:
                                                              score.toString(),
                                                        ),
                                                      );
                                                    } else {
                                                      nextPage(
                                                          const StampPage());
                                                    }

                                                    // nextPage(
                                                    //     CongratulationPage(
                                                    //       length: ReadController
                                                    //           .getActivityByChapterId
                                                    //           .value
                                                    //           .data?[0]
                                                    //           .details
                                                    //           ?.length
                                                    //           .toString() ??
                                                    //           '',
                                                    //       score: score.toString(),
                                                    //     ));
                                                    // } else {
                                                    //   nextPage(
                                                    //       CharacterUnlockPage(
                                                    //         characterId: '',
                                                    //         characterName: ReadController
                                                    //             .getActivityByChapterId
                                                    //             .value
                                                    //             .data?[0]
                                                    //             .characterName
                                                    //             .toString() ??
                                                    //             '',
                                                    //         characterImage: ReadController
                                                    //             .getActivityByChapterId
                                                    //             .value
                                                    //             .data?[0]
                                                    //             .characterImage
                                                    //             .toString() ??
                                                    //             '',
                                                    //         length: ReadController
                                                    //             .getActivityByChapterId
                                                    //             .value
                                                    //             .data?[0]
                                                    //             .details
                                                    //             ?.length
                                                    //             .toString() ??
                                                    //             '',
                                                    //         score: score.toString(),
                                                    //       ));
                                                    // }
                                                  }
                                                }
                                              }
                                              setState(() {});
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
                              );
                            })),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Future<void> submitMcq() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialog(
            title: "End Test?".tr,
            content: Text(
              'Are you sure you want to end this test?\nYou will not be able to change answers once you \npress “Confirm”'
                  .tr,
              style: const TextStyle(
                color: Color(0xFF637577),
                fontSize: 14,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w400,
              ),
            ),
            cancelButtonText: 'Cancel'.tr,
            confirmButtonText: 'Confirm'.tr,
            onCancel: () {
              Navigator.pop(context);
            },
            displayIcon: false,
            customImageAsset: 'icons/appLogo.png',
            onConfirm: () async {
              bool pass = (score >=
                  (0.6 *
                      (ReadController.getActivityByChapterId.value.data?[0]
                              .details?.length ??
                          0)));

              // nextPage();
            });
      },
    );
  }

  List<int> alreadyChecked = [];

  void checkAnswer(int questionIndex, int selectedIndex) {
    if (!widget.reviewTest) {
      userSelectedAnswer.add(options[questionIndex][selectedIndex]);
      customPrint("userSelectedAnswer :: $userSelectedAnswer");
      bool isCorrect = options[questionIndex][selectedIndex].trim() ==
          correctAnswers[questionIndex].trim();

      if (!alreadyChecked.contains(questionIndex)) {
        alreadyChecked.add(questionIndex);

        if (isCorrect) {
          setState(() {
            score++;
            customPrint("score :: $score");
          });
        }
      }

      Color userSelectedColor = isCorrect ? rightAns : wrongAns;

      Map<String, dynamic> mapColors = {
        'index': selectedIndex,
        'color': userSelectedColor,
      };
      ansIndex.add(mapColors);

      setState(() {});
    }
  }
}
