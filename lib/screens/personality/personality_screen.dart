import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yokai_quiz_app/api/database_api.dart';
import 'package:yokai_quiz_app/global.dart';
import 'package:yokai_quiz_app/models/assessment_model.dart';
import 'package:yokai_quiz_app/screens/challenge/controller/challenge_controller.dart';
import 'package:yokai_quiz_app/screens/chat/controller/chat_controller.dart';
import 'package:yokai_quiz_app/screens/home/controller/home_controller.dart';
import 'package:yokai_quiz_app/screens/personality/controller/controller.dart';
import 'package:yokai_quiz_app/screens/read/controller/read_controller.dart';
import 'package:yokai_quiz_app/screens/read/view/story_open_story_page.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/text_styles.dart';
import 'package:yokai_quiz_app/util/const.dart';

class PersonalityScreen extends StatefulWidget {
  const PersonalityScreen({super.key});

  @override
  State<PersonalityScreen> createState() => _PersonalityScreenState();
}

class _PersonalityScreenState extends State<PersonalityScreen> {
  AssessmentResult? resultData;
  int selectedType = 0;
  List typeOfPersonality = [
    "Bartle",
    "EQ",
    "Big Five",
    "Mental Health",
    "Strength Values",
  ];
  List fixedType = [
    "bartle-test",
    "eq",
    "big-five-personality",
    "personality-assessment",
    "values-strengths"
  ];
  @override
  void initState() {
    PersonalityController.isLoading(true);
    getData();
    super.initState();
  }

  getData() async {
    await PersonalityController.fetchAssignmentResultUserId().then((value) => {
          if (value == true)
            {
              getDataType(),
              PersonalityController.isLoading(false),
            }
        });
  }

  getDataType() {
    for (var result in PersonalityController.personalityResultList) {
      if (result.assessmentType == fixedType[selectedType]) {
        resultData = result;
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Padding(
        padding:
            const EdgeInsets.only(right: 20, left: 20, top: 60, bottom: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  Text(
                    "Personality Insights",
                    style: AppTextStyle.normalBold16.copyWith(
                      color: coral500,
                    ),
                  ),
                ],
              ),
              3.ph,
              SizedBox(
                height: 40,
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: typeOfPersonality.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        selectedType = index;
                        resultData = null;
                        getDataType();
                        setState(() {});
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              typeOfPersonality[index],
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                color: AppColors.black,
                                fontWeight: selectedType == index
                                    ? FontWeight.w800
                                    : FontWeight.w400,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            if (selectedType == index) ...[
                              Container(
                                height: 3,
                                width: 25,
                                decoration: BoxDecoration(
                                  color: coral500,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              6.ph,
              if (resultData != null) ...[
                AspectRatio(
                  aspectRatio: 1.3,
                  child: RadarChart(
                    RadarChartData(
                      radarTouchData: RadarTouchData(
                        enabled: false,
                      ),
                      dataSets: [
                        // Dominant Strength (Green)
                        RadarDataSet(
                          fillColor: Colors.green.withOpacity(0.2),
                          borderColor: Colors.green,
                          entryRadius: 2,
                          dataEntries: [
                            RadarEntry(
                                value: resultData!.radarData!.values![0]),
                            RadarEntry(
                                value: resultData!.radarData!.values![1]),
                            RadarEntry(
                                value: resultData!.radarData!.values![2]),
                            RadarEntry(
                                value: resultData!.radarData!.values![3]),
                          ],
                        ),
                      ],
                      radarShape: RadarShape.polygon,
                      radarBorderData:
                          BorderSide(color: Colors.grey.withOpacity(0.2)),
                      ticksTextStyle: const TextStyle(
                          color: Colors.transparent, fontSize: 1),
                      titleTextStyle:
                          const TextStyle(color: Colors.black, fontSize: 12),
                      tickBorderData:
                          BorderSide(color: Colors.grey.withOpacity(0.2)),
                      gridBorderData:
                          BorderSide(color: Colors.grey.withOpacity(0.2)),
                      titlePositionPercentageOffset: 0.2,
                      radarBackgroundColor: const Color(0x8BFFF2ED),
                      tickCount: 5,
                      getTitle: (index, angle) {
                        switch (index) {
                          case 0:
                            return RadarChartTitle(
                                text: resultData!.radarData!.categories![0],
                                angle: angle);
                          case 1:
                            return RadarChartTitle(
                                text: resultData!.radarData!.categories![1],
                                angle: angle);
                          case 2:
                            return RadarChartTitle(
                                text: resultData!.radarData!.categories![2],
                                angle: angle);
                          case 3:
                            return RadarChartTitle(
                                text: resultData!.radarData!.categories![3],
                                angle: angle);
                          case 4:
                            return RadarChartTitle(
                                text: resultData!.radarData!.categories![3],
                                angle: angle);
                          default:
                            return const RadarChartTitle(text: '');
                        }
                      },
                    ),
                  ),
                ),
                6.ph,
                commonWidget(
                  color: const Color(0xFF6FD18C),
                  title: resultData?.insights?.dominantStrength,
                  text: resultData?.insights?.dominantDescription,
                ),
                4.ph,
                commonWidget(
                  color: const Color(0xFFEE9D1A),
                  title: resultData?.insights?.supportingStrength,
                  text: resultData?.insights?.supportingDescription,
                ),
                4.ph,
                commonWidget(
                  color: const Color(0xFF7086FD),
                  title: "Development Areas",
                  text: resultData?.insights?.developmentAreas,
                ),
              ] else ...[
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * .25,
                  child: Center(
                    child: Text(
                      "Please complete the quiz to get the data".tr,
                      style: GoogleFonts.montserrat(
                        color: AppColors.blackColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
              6.ph,
              if ((ReadController.getAllStoriesBy.value.data?.length ?? 0) > 0)
                Text(
                  'Recommended for you'.tr,
                  textAlign: TextAlign.start,
                  style: AppTextStyle.normalBold16.copyWith(color: coral500),
                ),
              1.ph,
              if ((ReadController.getAllStoriesBy.value.data?.length ?? 0) > 0)
                SizedBox(
                  height: screenSize.height / 4,
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount:
                        ((ReadController.getAllStoriesBy.value.data?.length ??
                                    0) >
                                5)
                            ? 5
                            : ReadController.getAllStoriesBy.value.data?.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: GestureDetector(
                          onTap: () {
                            HomeController.backToHome(false);
                            ChatController.backToCharacters(false);
                            ReadController.backToStories(false);
                            ChallengeController.backToChallenge(true);
                            ReadController.storyId('');
                            nextPage(OpenStoryPage(
                              storyId: ReadController
                                      .getAllStoriesBy.value.data?[index].id
                                      .toString() ??
                                  '',
                            ));
                            ReadController.storyId(
                              ReadController
                                      .getAllStoriesBy.value.data?[index].id
                                      .toString() ??
                                  '',
                            );
                          },
                          child: Container(
                            height: screenSize.height / 4,
                            width: screenSize.width / 3,
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
                                children: [
                                  CachedNetworkImage(
                                    imageUrl:
                                        "${DatabaseApi.mainUrlImage}${ReadController.getAllStoriesBy.value.data?[index].storiesImage}",
                                    placeholder: (context, url) => const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircularProgressIndicator(),
                                      ],
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      decoration: const BoxDecoration(
                                          color: AppColors.red),
                                      child: const Icon(
                                        Icons.error_outline,
                                        color: AppColors.black,
                                      ),
                                    ),
                                    height: screenSize.height / 5.3,
                                    width: screenSize.width / 3,
                                    fit: BoxFit.cover,
                                  ),
                                  0.5.ph,
                                  Text(
                                    ((ReadController.getAllStoriesBy.value
                                                        .data?[index].name
                                                        .toString() ??
                                                    '')
                                                .length >
                                            25)
                                        ? '${(ReadController.getAllStoriesBy.value.data?[index].name.toString() ?? '').substring(0, 25)}...'
                                        : ReadController.getAllStoriesBy.value
                                                .data?[index].name
                                                .toString() ??
                                            '',
                                    style: AppTextStyle.normalBold12
                                        .copyWith(color: headingColour),
                                    maxLines: 2,
                                  ),
                                  0.5.ph,
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              4.ph,
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xFFFFF2EC),
                ),
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Invite your friends".tr,
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * .55,
                            child: Text(
                              "Invite friends and get special perks and badges."
                                  .tr,
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.grey,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * .2,
                            child: Image.asset("images/gift.png"),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              2.ph,
            ],
          ),
        ),
      ),
    );
  }

  Widget commonWidget({
    Color? color,
    String? title,
    String? text,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              height: 12,
              width: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * .8,
              child: Text(
                title ?? "",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          text ?? "",
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class ChartData {
  final String label;
  final double value;

  ChartData(this.label, this.value);
}
