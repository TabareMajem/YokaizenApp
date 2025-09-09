import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Ensure to import this for date formatting
import 'package:yokai_quiz_app/Widgets/progressHud.dart';
import 'package:get/get.dart';
import 'package:yokai_quiz_app/Widgets/textfield.dart';
import 'package:yokai_quiz_app/screens/mood_tracker/controller/mood_controller.dart';
import 'package:yokai_quiz_app/screens/profile/controller/profile_controller.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/const.dart';
import 'package:yokai_quiz_app/util/custom_app_bar.dart';
import 'package:yokai_quiz_app/util/text_styles.dart';

import '../../assistance/view/screens/assistance_screen.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({Key? key}) : super(key: key);

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  int selectedEmojiIndex = 2;
  final List<String> emojiGifs = [
    'images/awesome.gif',
    'images/good.gif',
    'images/neutral.gif',
    'images/sad.gif',
    'images/angry.gif',
  ];
  final List<String> emotions = [
    'Awesome'.tr,
    'Good'.tr,
    'Neutral'.tr,
    'Sad'.tr,
    'Angry'.tr,
  ];

  // Store the dates for the 7-day period
  bool isTodayAdded = false;
  List<DateTime> dates = [];
  List<DateTime> moodChart = [];
  DateTime selectedDate =
      DateTime.now(); // Add a variable to track the selected date

  @override
  void initState() {
    super.initState();
    MoodController.isLoading(true);
    _generateDateRange();
    fetchMoods();
    MoodController.isLoading(false);
  }

  fetchMoods() async {
    await MoodController.fetchGifsByUserId().then((value) => {
          MoodController.fetchMoodSummeryByUserId().then((value) => {
                MoodController.isLoading(false),
                setState(
                  () {
                    var moodDataForDate = MoodController.moodList.firstWhere(
                      (mood) {
                        DateTime moodDate = DateTime.parse(mood['date']);
                        final moodDay = DateFormat('EEE').format(moodDate);
                        return moodDay ==
                            DateFormat('EEE').format(selectedDate);
                      },
                      orElse: () => {},
                    );

                    if (moodDataForDate.isNotEmpty) {
                      isTodayAdded = true;
                      setState(() {});
                    }
                  },
                ),
              })
        });
  }

  void _generateDateRange() {
    final now = DateTime.now();
    for (int i = -3; i <= 3; i++) {
      dates.add(now.add(Duration(days: i)));
    }
    for (int i = -6; i <= 0; i++) {
      moodChart.add(now.add(Duration(days: i)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      isLoading: MoodController.isLoading.value,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Container(
          padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // GestureDetector(
                //   onTap: () {
                //     Navigator.pop(context);
                //   },
                //   child: Row(
                //     children: [
                //       SvgPicture.asset('icons/arrowLeft.svg'),
                //       Text(
                //         "Mood Tracker".tr,
                //         style:
                //             AppTextStyle.normalBold20.copyWith(color: coral500),
                //       ),
                //     ],
                //   ),
                // ),
                CustomAppBar(
                  title: "Mood Tracker".tr,
                  isBackButton: true,
                  isColor: false,
                  onButtonPressed: () {
                    Navigator.pop(context);
                  }
                ),
                1.ph,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(dates.length, (index) {
                    // Get day name and date
                    final day = DateFormat('EEE').format(dates[index]);
                    final date = dates[index].day;

                    return _buildDayButton(
                      day,
                      date,
                      day == DateFormat('EEE').format(selectedDate),
                    );
                  }),
                ),
                if (isTodayAdded == true) ...[
                  4.ph,
                  Text(
                    "Today's check-in".tr,
                    style: AppTextStyle.normalBold18,
                  ),
                  2.ph,
                  GestureDetector(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: const Color(0xFFFADDE7),
                          borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(50)),
                                child: Image.asset(
                                  'icons/celebrate.png',
                                ),
                              ),
                              1.pw,
                              Text(
                                "Check-in".tr,
                                style: AppTextStyle.normalBold14,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Image.asset(
                                'icons/checkin.png',
                                height: 30,
                                width: 30,
                              ),
                              1.pw,
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  4.ph,
                  Column(
                    children: [
                      Text(
                        'Hey, how are you feeling today!'.tr,
                        style: AppTextStyle.normalBold16
                            .copyWith(color: indigo700),
                      ),
                      2.ph,
                      SizedBox(
                        height: 90,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: emojiGifs.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  isTodayAdded = true;
                                  selectedEmojiIndex = index;
                                });
                                double moodType = 0;
                                if (index == 0) {
                                  moodType = 1.0;
                                } else if (index == 1) {
                                  moodType = 0.75;
                                } else if (index == 2) {
                                  moodType = 0.5;
                                } else if (index == 3) {
                                  moodType = 0.25;
                                } else {
                                  moodType = 0.0;
                                }
                                final body = {
                                  "user_id":
                                      ProfileController.userId.value.toString(),
                                  "mood_level": moodType,
                                  "mood_gif": index,
                                  "date": DateTime.now().toString(),
                                };
                                MoodController.addOrUpdateMood(context, body);
                                fetchMoods();
                                popForMoodUpdate(index);
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * .18,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 0),
                                child: Column(
                                  children: [
                                    Image.asset(
                                      emojiGifs[index],
                                      height:
                                          index == selectedEmojiIndex ? 60 : 45,
                                      width:
                                          index == selectedEmojiIndex ? 60 : 45,
                                    ),
                                    if (index == selectedEmojiIndex)
                                      Container(
                                        margin: const EdgeInsets.only(top: 5),
                                        height: 4,
                                        width: 4,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          color: Colors.purple,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
                2.ph,

                /// commented for the first version

                // Container(
                //   decoration: BoxDecoration(
                //     color: AppColors.whiteColor,
                //     borderRadius: BorderRadius.circular(10),
                //   ),
                //   padding: const EdgeInsets.all(10),
                //   width: MediaQuery.of(context).size.width,
                //   child: Column(
                //     children: [
                //       Row(
                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         children: [
                //           Container(
                //             height: 40,
                //             width: MediaQuery.of(context).size.width * .42,
                //             decoration: BoxDecoration(
                //               borderRadius: BorderRadius.circular(5),
                //               color: indigo700.withOpacity(0.1),
                //             ),
                //             child: Row(
                //               mainAxisAlignment: MainAxisAlignment.center,
                //               crossAxisAlignment: CrossAxisAlignment.center,
                //               children: [
                //                 const Icon(
                //                   Icons.edit,
                //                   color: indigo700,
                //                   size: 17,
                //                 ),
                //                 const SizedBox(
                //                   width: 4,
                //                 ),
                //                 Text(
                //                   "Write Journal".tr,
                //                   style: GoogleFonts.montserrat(
                //                     fontSize: 14,
                //                     color: indigo700,
                //                     fontWeight: FontWeight.w500,
                //                   ),
                //                 )
                //               ],
                //             ),
                //           ),
                //           Container(
                //             height: 40,
                //             width: MediaQuery.of(context).size.width * .42,
                //             decoration: BoxDecoration(
                //               borderRadius: BorderRadius.circular(5),
                //               color: AppColors.whiteColor,
                //             ),
                //             child: Row(
                //               mainAxisAlignment: MainAxisAlignment.center,
                //               crossAxisAlignment: CrossAxisAlignment.center,
                //               children: [
                //                 const Icon(
                //                   Icons.chat_bubble_outline,
                //                   color: AppColors.blackColor,
                //                   size: 17,
                //                 ),
                //                 const SizedBox(
                //                   width: 4,
                //                 ),
                //                 Text(
                //                   "Talk to me".tr,
                //                   style: GoogleFonts.montserrat(
                //                     fontSize: 14,
                //                     color: AppColors.blackColor,
                //                     fontWeight: FontWeight.w500,
                //                   ),
                //                 )
                //               ],
                //             ),
                //           ),
                //         ],
                //       ),
                //       2.ph,
                //       TextFeildStyle(
                //         onChanged: (p0) {
                //           // validateEmail(p0);
                //         },
                //         maxLines: 7,
                //         // controller: emailController,
                //         height: 50,
                //         hintText: "Write Your Journal".tr,
                //         decoration: BoxDecoration(
                //           borderRadius: BorderRadius.circular(100),
                //           border: Border.all(color: greyborder),
                //         ),
                //         hintStyle: AppTextStyle.normalRegular10
                //             .copyWith(color: hintText),
                //         border: InputBorder.none,
                //       ),
                //     ],
                //   ),
                // ),
                // 5.ph,
                _buildMoodChart(),
                3.ph,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Connect with Nature".tr,
                      style: AppTextStyle.normalBold16,
                    ),
                    GestureDetector(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SvgPicture.asset('icons/hint.svg'),
                          Text(
                            'Tip'.tr,
                            style: AppTextStyle.normalBold14.copyWith(
                                fontWeight: FontWeight.normal,
                                color: const Color(0xFFE8B50E)),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                2.ph,
                Text(
                  "Spend time outdoors, surrounded by greenery and fresh air."
                      .tr,
                  style: const TextStyle(color: Colors.grey),
                ),
                6.ph,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayButton(String day, int date, bool isSelected) {
    Map<int, String> gifMap = {
      0: "images/awesome.gif",
      1: 'images/good.gif',
      2: "images/neutral.gif",
      3: "images/sad.gif",
      4: "images/angry.gif",
    };
    var moodDataForDate = MoodController.moodList.firstWhere(
      (mood) {
        DateTime moodDate = DateTime.parse(mood['date']);
        final moodDay = DateFormat('EEE').format(moodDate);
        return moodDay == day;
      },
      orElse: () => {},
    );
    String gifPath = "";
    if (moodDataForDate.isNotEmpty) {
      gifPath = gifMap[moodDataForDate['mood_gif']] ?? "";
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 2),
          height: 50,
          width: 40,
          decoration: BoxDecoration(
            color: isSelected ? indigo700 : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFFD3C0), width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                day,
                style: AppTextStyle.normalBold10.copyWith(
                  fontWeight: FontWeight.normal,
                  color:
                      isSelected ? AppColors.whiteColor : AppColors.blackColor,
                ),
              ),
              Container(
                width: double.infinity,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0x35FFD3C0),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  date.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : coral500,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (gifPath != "") ...[
          const SizedBox(
            height: 7,
          ),
          Image.asset(
            gifPath,
            height: 40,
            width: 40,
          ),
        ],
      ],
    );
  }

  Widget _buildMoodChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFFE4DFFB),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Mood Chart".tr,
                style: AppTextStyle.normalBold18,
              ),
              Text(
                'Last 7 days'.tr,
                style: AppTextStyle.normalBold12
                    .copyWith(fontWeight: FontWeight.normal),
              )
            ],
          ),
          2.ph,
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * .32,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: moodChart.length,
                itemBuilder: (context, index) {
                  return _buildMoodBar(
                    moodChart[index],
                  );
                }),
          ),
        ],
      ),
    );
  }

  void popForMoodUpdate(index) async {
    String responseText = "";
    if (index == 0) {
      responseText =
          "You're on a wonderful path! Your day is going amazing Keep this positive energy flowing and remember what contributed to this great mood."
              .tr;
    } else if (index == 1) {
      responseText =
          "You're on a good way! Your day shows promise Notice the positive choices you're making today."
              .tr;
    } else if (index == 2) {
      responseText =
          "You're maintaining balance! Your day is steady It's okay to be in the middle - every emotion has its purpose."
              .tr;
    } else if (index == 3) {
      responseText =
          "You're being very aware! Your day needs some care Remember this feeling is temporary - let's find one small positive step."
              .tr;
    } else {
      responseText =
          "You're brave for sharing this! Your day needs extra support Reaching out is a sign of strength - let's work through this together."
              .tr;
    }
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
                      child: Container(
                        height: 110,
                        width: 110,
                        margin: const EdgeInsets.all(15),
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Color(0xAABAE6FF),
                              Color(0x55D0CFE9),
                              Color(0xFFFFCEB7),
                              Color(0xFFDF2771)
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomRight,
                            stops: [0, 0.4, 0.7, 1],
                          ),
                        ),
                        child: Image.asset(
                          emojiGifs[index],
                          height: 75,
                          width: 75,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    RichText(
                      text: TextSpan(
                        text: 'You\'re on a '.tr,
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.blackColor,
                        ),
                        children: [
                          TextSpan(
                            text: 'good way!'.tr,
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.purple,
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      responseText,
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
                    Text(
                      "Keep tracking your mood to know how to improve your mental health."
                          .tr,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.grey,
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * .05,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  width: 2,
                                  color: AppColors.grey,
                                )),
                            height: 45,
                            width: MediaQuery.of(context).size.width * .3,
                            alignment: Alignment.center,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Text(
                                'Close'.tr,
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: AppColors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Navigator.pop(context);
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                              return const YokaiAssistanceScreen();
                            },));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.purple,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            height: 45,
                            width: MediaQuery.of(context).size.width * .3,
                            alignment: Alignment.center,
                            child: Center(
                              child: Text(
                                  'Talk to me'.tr,
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: AppColors.whiteColor,
                                  ),
                                ),
                              ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
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

  Widget _buildMoodBar(DateTime day) {
    Map<int, String> gifMap = {
      0: "images/awesome.gif",
      1: 'images/good.gif',
      2: "images/neutral.gif",
      3: "images/sad.gif",
      4: "images/angry.gif",
    };
    Color? mainColor = Colors.green;
    double moodValue = 0;
    var moodDataForDate = MoodController.moodSummeryList.firstWhere(
      (mood) {
        DateTime moodDate = DateTime.parse(mood['date']);
        final moodDay = DateFormat('dd-MM-yyyy').format(moodDate);
      
        return moodDay == DateFormat('dd-MM-yyyy').format(day);
      },
      orElse: () => {},
    );
    String gifPath = "";
    if (moodDataForDate.isNotEmpty) {
      if (moodDataForDate['mood_level'] == 0.5) {
        mainColor = Colors.green;
        gifPath = gifMap[2] ?? "";
      } else if (moodDataForDate['mood_level'] == 0.25) {
        mainColor = Colors.greenAccent;
        gifPath = gifMap[1] ?? "";
      } else if (moodDataForDate['mood_level'] == 0.75) {
        mainColor = Colors.red.withOpacity(0.5);

        gifPath = gifMap[3] ?? "";
      } else if (moodDataForDate['mood_level'] == 1.0) {
        mainColor = Colors.red;

        gifPath = gifMap[4] ?? "";
      } else if (moodDataForDate['mood_level'] == 0.0) {
        mainColor = Colors.green[900];
        gifPath = gifMap[0] ?? "";
      } else {
        mainColor = Colors.green;

        gifPath = gifMap[2] ?? "";
      }
      moodValue = moodDataForDate['mood_level'];
    }
    return SizedBox(
      height: MediaQuery.of(context).size.height * .32,
      width: MediaQuery.of(context).size.width * .115,
      child: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * .28,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height *
                      .28 *
                      moodValue, // Adjust the height based on mood value
                  width: 30,
                  decoration: BoxDecoration(
                    color: mainColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(
                        gifPath,
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          1.ph,
          Text(
            DateFormat('EEE').format(day),
            style: AppTextStyle.normalBold12.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }
}
