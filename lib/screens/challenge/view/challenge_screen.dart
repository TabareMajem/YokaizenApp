import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yokai_quiz_app/Widgets/new_button.dart';
import 'package:yokai_quiz_app/Widgets/progressBar.dart';
import 'package:yokai_quiz_app/Widgets/progressHud.dart';
import 'package:yokai_quiz_app/api/database_api.dart';
import 'package:yokai_quiz_app/screens/Authentication/controller/auth_screen_controller.dart';
import 'package:yokai_quiz_app/screens/navigation/view/navigation.dart';
import '../controller/challenge_controller.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/const.dart';
import 'package:yokai_quiz_app/util/text_styles.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';

class ChallengePage extends StatefulWidget {
  const ChallengePage({super.key});

  @override
  State<ChallengePage> createState() => _ChallengePageState();
}

class _ChallengePageState extends State<ChallengePage> {
  bool isLineAccountAdded = false;
  @override
  void initState() {
    super.initState();
    isLoading(true);
    // _checkLineIntegration();
    fetchChallengeData();
  }

  Future<void> _checkLineIntegration() async {
    final prefs = await SharedPreferences.getInstance();
    final isLineConnected = prefs.getString('isLineConnected');
    print("line data $isLineConnected");
    if (isLineConnected == null) {
      Future.delayed(const Duration(milliseconds: 300)).then((v) {
        popUpForLineIntegration();
      });
    }
  }

  fetchChallengeData() async {
    await ChallengeController.fetchChallenges().then(
      (value) async {
        isLoading(false);
      },
    );
  }

  fetchComplaintsData() async {
    await ChallengeController.fetchComplaints().then(
      (value) async {
        isLoading(false);
        setState(() {});
      },
    );
  }

  bool get hasActiveChallenges =>
      ChallengeController.challenges.any((challenge) =>
          challenge['isActive'] > 0 &&
          challenge['isActive'] < challenge['isCompleted']);

  bool get hasCompletedChallenge => ChallengeController.challenges
      .any((challenge) => challenge['isActive'] < challenge['isCompleted']);

  RxBool isLoading = false.obs;
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Obx(() {
      return ProgressHUD(
        isLoading: isLoading.value,
        child: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 60, left: 10, right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                ChallengeController.isChallengeOrComplaint(
                                    true);
                                isLoading(true);
                                fetchChallengeData();
                              },
                              child: Container(
                                height: 40,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: (ChallengeController
                                          .isChallengeOrComplaint.isTrue)
                                      ? indigo700
                                      : colorWhite,
                                  boxShadow: [
                                    if (ChallengeController
                                        .isChallengeOrComplaint.isTrue)
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                  ],
                                  border: Border.all(color: indigo700),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(40),
                                    bottomLeft: Radius.circular(40),
                                  ),
                                ),
                                child: Text(
                                  'Challenges'.tr,
                                  style: AppTextStyle.normalBold14.copyWith(
                                      color: (ChallengeController
                                              .isChallengeOrComplaint.isTrue)
                                          ? colorWhite
                                          : indigo700),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                ChallengeController.isChallengeOrComplaint(
                                    false);
                                isLoading(true);
                                fetchComplaintsData();
                              },
                              child: Container(
                                height: 40,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: (ChallengeController
                                          .isChallengeOrComplaint.isFalse)
                                      ? indigo700
                                      : colorWhite,
                                  boxShadow: [
                                    if (ChallengeController
                                        .isChallengeOrComplaint.isFalse)
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                  ],
                                  border: Border.all(color: indigo700),
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(40),
                                    bottomRight: Radius.circular(40),
                                  ),
                                ),
                                child: Text(
                                  'Compliments'.tr,
                                  style: AppTextStyle.normalBold14.copyWith(
                                      color: (ChallengeController
                                              .isChallengeOrComplaint.isFalse)
                                          ? colorWhite
                                          : indigo700),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (ChallengeController.isChallengeOrComplaint.isTrue)
                        3.ph,
                      if (ChallengeController.isChallengeOrComplaint.isTrue)
                        if (ChallengeController.challenges.isNotEmpty)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Daily Challenges".tr,
                                style: AppTextStyle.normalBold20
                                    .copyWith(color: textDarkGrey),
                              ),
                              Row(
                                children: [
                                  Text(
                                    "View all".tr,
                                    style: textStyle.button.copyWith(
                                        color: textDarkGrey,
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  1.pw,
                                  SvgPicture.asset('icons/arrowRight1.svg')
                                ],
                              ),
                            ],
                          ),
                      3.ph,
                      if (ChallengeController.isChallengeOrComplaint.isTrue)
                        if (ChallengeController.challenges.isNotEmpty)
                          SizedBox(
                            height: screenSize.height / 3.5,
                            child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount:
                                  ChallengeController.challenges.length > 3
                                      ? 3
                                      : ChallengeController.challenges.length,
                              itemBuilder: (context, index) {
                                final challenge =
                                    ChallengeController.challenges[index];
                                if (challenge['isActive'] != 0) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(right: 20),
                                  child: InkWell(
                                    child: Container(
                                      height: screenSize.height / 3.5,
                                      width: screenSize.width / 1.1,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          color: colorWhite,
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.05),
                                                blurRadius: 5,
                                                spreadRadius: 3)
                                          ]),
                                      child: ClipRect(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Container(
                                                      width: 120,
                                                      height: 120,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            width: 4,
                                                            color: lightgrey),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(60),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(10),
                                                        child: ClipOval(
                                                          child: Image.asset(
                                                            ChallengeController
                                                                    .challenges[
                                                                index]['image'],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 20),
                                                        child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                ChallengeController
                                                                            .challenges[
                                                                        index]
                                                                    ['heading'],
                                                                maxLines: 3,
                                                                style: AppTextStyle
                                                                    .normalBold20,
                                                              ),
                                                              const SizedBox(
                                                                  height: 4),
                                                              RichText(
                                                                text: TextSpan(
                                                                  children: [
                                                                    TextSpan(
                                                                      text:
                                                                          "Unlock ",
                                                                      style: AppTextStyle
                                                                          .normalBold14
                                                                          .copyWith(
                                                                        fontWeight:
                                                                            FontWeight.w400,
                                                                        color: Colors
                                                                            .black38,
                                                                      ),
                                                                    ),
                                                                    TextSpan(
                                                                      text:
                                                                          "${ChallengeController.challenges[index]['badge']} ",
                                                                      style: AppTextStyle
                                                                          .normalBold14
                                                                          .copyWith(
                                                                        fontWeight:
                                                                            FontWeight.w400,
                                                                        color:
                                                                            coral500,
                                                                      ),
                                                                    ),
                                                                    TextSpan(
                                                                      text:
                                                                          "Badge",
                                                                      style: AppTextStyle
                                                                          .normalBold14
                                                                          .copyWith(
                                                                        fontWeight:
                                                                            FontWeight.w400,
                                                                        color: Colors
                                                                            .black38, // Color for the final text
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              )
                                                            ]),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20),
                                                child: CustomButton(
                                                  text: "Start Challenge".tr,
                                                  textSize: 16,
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return ChallengeDialog(
                                                          image: challenge[
                                                              'image'],
                                                          badge: challenge[
                                                              'badge'],
                                                          heading: challenge[
                                                              'heading'],
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                      if (ChallengeController.isChallengeOrComplaint.isTrue)
                        4.ph,
                      if (ChallengeController.isChallengeOrComplaint.isTrue &&
                          hasActiveChallenges)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Active Challenges".tr,
                              style: AppTextStyle.normalBold20
                                  .copyWith(color: textDarkGrey),
                            ),
                            Row(
                              children: [
                                Text(
                                  "View All".tr,
                                  style: textStyle.button.copyWith(
                                      color: textDarkGrey,
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal),
                                ),
                                1.pw,
                                SvgPicture.asset('icons/arrowRight1.svg')
                              ],
                            ),
                          ],
                        ),
                      if (ChallengeController.isChallengeOrComplaint.isTrue &&
                          hasActiveChallenges)
                        3.ph,
                      if (ChallengeController.isChallengeOrComplaint.isTrue &&
                          hasActiveChallenges)
                        SizedBox(
                          height: screenSize.height / 5,
                          child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: ChallengeController.challenges.length,
                            itemBuilder: (context, index) {
                              final challenge =
                                  ChallengeController.challenges[index];
                              if (challenge['isActive'] == 0 ||
                                  challenge['isActive'] >=
                                      challenge['isCompleted']) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: InkWell(
                                  child: GestureDetector(
                                    onTap: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return ChallengeDialog(
                                              image: challenge['image'],
                                              badge: challenge['badge'],
                                              heading: challenge['heading'],
                                              typeValue: 1,
                                              isActive: challenge['isActive'],
                                              isCompleted:
                                                  challenge['isCompleted'],
                                            );
                                          });
                                    },
                                    child: Container(
                                      height: screenSize.height / 4,
                                      width: screenSize.width / 1.5,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          color: colorWhite,
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.05),
                                                blurRadius: 5,
                                                spreadRadius: 3)
                                          ]),
                                      child: ClipRect(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Container(
                                                      width: 80,
                                                      height: 80,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            width: 4,
                                                            color: lightgrey),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(60),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(10),
                                                        child: ClipOval(
                                                          child: Image.asset(
                                                            ChallengeController
                                                                    .challenges[
                                                                index]['image'],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 20),
                                                        child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                ChallengeController
                                                                            .challenges[
                                                                        index]
                                                                    ['heading'],
                                                                maxLines: 3,
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style: AppTextStyle
                                                                    .normalBold14,
                                                              ),
                                                              const SizedBox(
                                                                  height: 4),
                                                              RichText(
                                                                text: TextSpan(
                                                                  children: [
                                                                    TextSpan(
                                                                      text:
                                                                          "Unlock ",
                                                                      style: AppTextStyle
                                                                          .normalBold12
                                                                          .copyWith(
                                                                        fontWeight:
                                                                            FontWeight.w300,
                                                                        color: Colors
                                                                            .black38,
                                                                      ),
                                                                    ),
                                                                    TextSpan(
                                                                      text:
                                                                          "${ChallengeController.challenges[index]['badge']} ",
                                                                      style: AppTextStyle
                                                                          .normalBold12
                                                                          .copyWith(
                                                                        fontWeight:
                                                                            FontWeight.w300,
                                                                        color:
                                                                            coral500,
                                                                      ),
                                                                    ),
                                                                    TextSpan(
                                                                      text:
                                                                          "Badge",
                                                                      style: AppTextStyle
                                                                          .normalBold12
                                                                          .copyWith(
                                                                        fontWeight:
                                                                            FontWeight.w300,
                                                                        color: Colors
                                                                            .black38,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              )
                                                            ]),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20),
                                                child: ProgressBar(
                                                  totalValue:
                                                      ChallengeController
                                                              .challenges[index]
                                                          ['isCompleted'],
                                                  completedValue:
                                                      ChallengeController
                                                              .challenges[index]
                                                          ['isActive'],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      if (ChallengeController.isChallengeOrComplaint.isTrue &&
                          hasActiveChallenges)
                        4.ph,
                      if (ChallengeController.isChallengeOrComplaint.isTrue &&
                          hasCompletedChallenge)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Completed Challenges".tr,
                              style: AppTextStyle.normalBold20
                                  .copyWith(color: textDarkGrey),
                            ),
                            Row(
                              children: [
                                Text(
                                  "View All".tr,
                                  style: textStyle.button.copyWith(
                                      color: textDarkGrey,
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal),
                                ),
                                1.pw,
                                SvgPicture.asset('icons/arrowRight1.svg')
                              ],
                            ),
                          ],
                        ),
                      if (ChallengeController.isChallengeOrComplaint.isTrue &&
                          hasCompletedChallenge)
                        3.ph,
                      if (ChallengeController.isChallengeOrComplaint.isTrue &&
                          hasCompletedChallenge)
                        SizedBox(
                          height: screenSize.height / 5,
                          child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: ChallengeController.challenges.length,
                            itemBuilder: (context, index) {
                              final challenge =
                                  ChallengeController.challenges[index];
                              if (challenge['isActive'] <
                                  challenge['isCompleted']) {
                                return const SizedBox.shrink();
                              }
                              return GestureDetector(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return ChallengeDialog(
                                          image: challenge['image'],
                                          badge: challenge['badge'],
                                          heading: challenge['heading'],
                                          typeValue: 2,
                                        );
                                      });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 20),
                                  child: InkWell(
                                    child: Container(
                                      height: screenSize.height / 4,
                                      width: screenSize.width / 1.5,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          color: colorWhite,
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.05),
                                                blurRadius: 5,
                                                spreadRadius: 3)
                                          ]),
                                      child: ClipRect(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Container(
                                                      width: 80,
                                                      height: 80,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            width: 4,
                                                            color: lightgrey),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(60),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(10),
                                                        child: ClipOval(
                                                          child: Image.asset(
                                                            ChallengeController
                                                                    .challenges[
                                                                index]['image'],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 20),
                                                        child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                ChallengeController
                                                                            .challenges[
                                                                        index]
                                                                    ['heading'],
                                                                maxLines: 3,
                                                                style: AppTextStyle
                                                                    .normalBold14,
                                                              ),
                                                              const SizedBox(
                                                                  height: 4),
                                                              RichText(
                                                                text: TextSpan(
                                                                  children: [
                                                                    TextSpan(
                                                                      text:
                                                                          "Unlock ",
                                                                      style: AppTextStyle
                                                                          .normalBold12
                                                                          .copyWith(
                                                                        fontWeight:
                                                                            FontWeight.w300,
                                                                        color: Colors
                                                                            .black38,
                                                                      ),
                                                                    ),
                                                                    TextSpan(
                                                                      text:
                                                                          "${ChallengeController.challenges[index]['badge']} ",
                                                                      style: AppTextStyle
                                                                          .normalBold12
                                                                          .copyWith(
                                                                        fontWeight:
                                                                            FontWeight.w300,
                                                                        color:
                                                                            coral500,
                                                                      ),
                                                                    ),
                                                                    TextSpan(
                                                                      text: "Badge"
                                                                          .tr,
                                                                      style: AppTextStyle
                                                                          .normalBold12
                                                                          .copyWith(
                                                                        fontWeight:
                                                                            FontWeight.w300,
                                                                        color: Colors
                                                                            .black38,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              )
                                                            ]),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20),
                                                child: ProgressBar(
                                                  totalValue:
                                                      ChallengeController
                                                              .challenges[index]
                                                          ['isCompleted'],
                                                  completedValue:
                                                      ChallengeController
                                                              .challenges[index]
                                                          ['isActive'],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      if (ChallengeController.isChallengeOrComplaint.isTrue &&
                          hasCompletedChallenge)
                        4.ph,
                      Container(
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 252, 206, 168),
                            borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SvgPicture.asset('icons/sword.svg'),
                            SizedBox(
                              width: screenSize.width * 0.7,
                              child: Expanded(
                                child: Text(
                                  'Play with friends, earn badges and share compliments!'
                                      .tr,
                                  style: AppTextStyle.normalBold14
                                      .copyWith(color: Colors.white),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      if (ChallengeController.isChallengeOrComplaint.isTrue)
                        2.ph,
                      if (ChallengeController.isChallengeOrComplaint.isFalse)
                        2.ph,
                      if (ChallengeController.isChallengeOrComplaint.isFalse)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                              onTap: () => {
                                ChallengeController.isReceivedOrSent.value =
                                    false,
                              },
                              child: Container(
                                height: 25,
                                decoration: BoxDecoration(
                                  border: ChallengeController
                                          .isReceivedOrSent.isFalse
                                      ? const Border(
                                          bottom: BorderSide(
                                            color: coral500,
                                            width: 2.0,
                                          ),
                                        )
                                      : null,
                                ),
                                child: Text(
                                  'Received'.tr,
                                  style: AppTextStyle.normalBold14.copyWith(
                                      color: ChallengeController
                                              .isReceivedOrSent.isFalse
                                          ? coral500
                                          : textDarkGrey),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => {
                                ChallengeController.isReceivedOrSent.value =
                                    true,
                              },
                              child: Container(
                                height: 20,
                                decoration: BoxDecoration(
                                  border: ChallengeController
                                          .isReceivedOrSent.isTrue
                                      ? const Border(
                                          bottom: BorderSide(
                                            color: coral500,
                                            width: 2.0,
                                          ),
                                        )
                                      : null,
                                ),
                                child: Text(
                                  'Sent to friends'.tr,
                                  style: AppTextStyle.normalBold14.copyWith(
                                      color: ChallengeController
                                              .isReceivedOrSent.isTrue
                                          ? coral500
                                          : textDarkGrey),
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (ChallengeController.isChallengeOrComplaint.isFalse)
                        1.ph,
                      if (ChallengeController.isChallengeOrComplaint.isFalse)
                        (ChallengeController.complaints.isNotEmpty)
                            ? GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  childAspectRatio: 0.9,
                                  crossAxisSpacing: 0.1,
                                  mainAxisSpacing: 40,
                                  mainAxisExtent: 100,
                                ),
                                itemCount:
                                    ChallengeController.complaints.length,
                                itemBuilder: (context, index) {
                                  return SizedBox(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        ClipOval(
                                          child: Image.network(
                                            DatabaseApi.mainUrlImage +
                                                ChallengeController
                                                    .complaints[index]
                                                    .questionImage
                                                    .toString(),
                                            fit: BoxFit.cover,
                                            height: 80,
                                            width: 80,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Text(
                                            ChallengeController
                                                    .complaints[index]
                                                    .complimentName ??
                                                "",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTextStyle.normalBold12
                                                .copyWith(
                                                    fontSize: 12,
                                                    color: indigo700,
                                                    fontWeight:
                                                        FontWeight.w300),
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                },
                              )
                            : Center(
                                child: Text('No Data Found'.tr),
                              ),
                      if (ChallengeController.isChallengeOrComplaint.isFalse)
                        const SizedBox(height: 20),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  void popUpForLineIntegration() async {
    return showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: const RoundedRectangleBorder(
                side: BorderSide(
                  color: AppColors.whiteColor,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(15.0),
                ),
              ),
              elevation: 0,
              backgroundColor: AppColors.whiteColor,
              actionsPadding: const EdgeInsets.symmetric(vertical: 0),
              title: Container(
                alignment: Alignment.topLeft,
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                width: MediaQuery.of(context).size.width * .7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        height: 100,
                        width: 100,
                        child: Image.asset(
                          "images/battle.png",
                          height: 75,
                          width: 75,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      "Challenge Friends & Win",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Take on daily challenges or challenge your friends and snag special perks and badges!",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * .05,
                    ),
                    GestureDetector(
                      onTap: () async {
                        try {
                          final result = await LineSDK.instance.login(
                              scopes: ["profile", "openid", "email"]
                              
                            // option: LoginOption()
                          );
                          print(result.accessToken.data);
                          print(result.accessToken.data["access_token"]);
                          if (result.userProfile != null) {
                            // Store LINE account info
                            setState(() {
                              isLineAccountAdded = true;
                            });

                            // Save to preferences/storage that LINE is connected
                            final prefs = await SharedPreferences.getInstance(

                            );
                            await prefs.setString(
                              'isLineConnected',
                              result.accessToken.data["access_token"],
                            );

                            // Close dialog
                            Navigator.pop(context);

                            // Show success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'LINE account connected successfully'.tr,
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          print('LINE login error: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Failed to connect LINE account'.tr,
                              ),
                            ),
                          );
                        } finally {
                          Get.back();
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            width: 1,
                            color: AppColors.player3,
                          ),
                        ),
                        height: 55,
                        width: MediaQuery.of(context).size.width,
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset("images/line.png"),
                            const SizedBox(
                              width: 15,
                            ),
                            Text(
                              'Link your account'.tr,
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: AppColors.player3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () {
                          Get.back();
                        },
                        child: Text(
                          'Skip'.tr,
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: AppColors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class ChallengeDialog extends StatelessWidget {
  final String image;
  final String heading;
  final String badge;
  final int typeValue;
  final int isCompleted;
  final int isActive;

  const ChallengeDialog({
    super.key,
    required this.image,
    required this.badge,
    required this.heading,
    this.typeValue = 0,
    this.isCompleted = 0,
    this.isActive = 0,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40.0),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 500,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [Icon(Icons.close, size: 16)],
                  ),
                ),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    border: Border.all(width: 4, color: lightgrey),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: ClipOval(
                      child: Image.asset(image),
                    ),
                  ),
                ),
                4.ph,
                Text(
                  heading,
                  maxLines: 3,
                  style: AppTextStyle.normalBold20,
                ),
                2.ph,
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Unlock ".tr,
                        style: AppTextStyle.normalBold14.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                      TextSpan(
                        text: "$badge ",
                        style: AppTextStyle.normalBold14.copyWith(
                          fontWeight: FontWeight.w500,
                          color: coral500,
                        ),
                      ),
                      TextSpan(
                        text: "Badge".tr,
                        style: AppTextStyle.normalBold14.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                2.ph,
                Text(
                  "Lorem ipsum dolor sit amet consectetur. Non sapien elementum dui aliquet. Lorem ipsum dolor sit amet consectetur. Non sapien elementum dui aliquet."
                      .tr,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.normalBold10.copyWith(
                    fontWeight: FontWeight.normal,
                    color: Colors.black54,
                  ),
                ),
                const Spacer(),
                if (typeValue == 0)
                  CustomButton(
                    text: "Invite Friends".tr,
                    onPressed: () {},
                    textSize: 16,
                  ),
                if (typeValue == 2)
                  CustomButton(
                    text: "Claim Reward".tr,
                    onPressed: () {},
                    textSize: 16,
                  ),
                if (typeValue == 1)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: indigo100,
                          borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                'icons/challengeavatar.svg',
                                height: 50,
                                width: 50,
                              ),
                              1.5.pw,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AuthScreenController.nameController.text,
                                    style: AppTextStyle.normalBold16,
                                  ),
                                  Text(
                                    '$isActive/$isCompleted ${"Completed".tr}',
                                    textAlign: TextAlign.start,
                                    style: AppTextStyle.normalBold12.copyWith(
                                      color: Colors.black45,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          2.ph,
                          ProgressBar(
                            totalValue: isCompleted,
                            completedValue: isActive,
                            withIcon: false,
                            withText: false,
                          )
                        ],
                      ),
                    ),
                  ),
                3.ph,
              ],
            ),
          ),
          // Positioned round container with arrow icon extending past dialog

          Positioned(
            bottom: -30,
            left: screenSize.width / 2 - 70,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NavigationPage(
                      index: 1,
                    ),
                  ),
                );
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: coral500,
                  borderRadius: BorderRadius.circular(35),
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
