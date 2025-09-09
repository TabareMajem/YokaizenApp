import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yokai_quiz_app/Widgets/progressHud.dart';
import 'package:yokai_quiz_app/screens/Authentication/controller/auth_screen_controller.dart';
import 'package:yokai_quiz_app/screens/Settings/view/setting_screen.dart';
import 'package:yokai_quiz_app/screens/assistance/view/screens/assistance_screen.dart';
import 'package:yokai_quiz_app/screens/badges/controller/badge_controller.dart';
import 'package:yokai_quiz_app/screens/mood_tracker/controller/mood_controller.dart';
import 'package:yokai_quiz_app/screens/mood_tracker/view/mood_tracker_screen.dart';
import 'package:yokai_quiz_app/screens/personality/view/personality_screen.dart';
import 'package:yokai_quiz_app/screens/profile/controller/profile_controller.dart';
import 'package:yokai_quiz_app/screens/profile/view/privacy__policy_screen.dart';
import 'package:yokai_quiz_app/screens/settings/view/user_agreement_screen.dart';
import 'package:yokai_quiz_app/screens/stamps/view/stamps_screen.dart';
import 'package:yokai_quiz_app/screens/ring/view/ring_screen.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/const.dart';
import 'package:yokai_quiz_app/util/text_styles.dart';
import 'package:get/get.dart';

import '../../badges/view/hardcoded_badges_screen.dart';
import '../../../services/purchase_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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

  @override
  void initState() {
    super.initState();
    ProfileController.isLoading(true);
    fetchInfoData();
  }

  fetchInfoData() async {
    AuthScreenController.fetchData().then((value) async {
      ProfileController.userName(
          AuthScreenController.getProfileModel.value.user?.name ?? "");
      ProfileController.userId(
          AuthScreenController.getProfileModel.value.user?.userId ?? 1);
      await BadgeController.fetchAllBadges()
          .then((value) => {ProfileController.isLoading(false)});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return ProgressHUD(
        isLoading: ProfileController.isLoading.value,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Stack(
              children: [
                Container(
                  height: 200,
                  padding:
                      // const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  const EdgeInsets.only(top: 60, left: 20, right: 20),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/bgProfile.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Profile'.tr,
                        style: AppTextStyle.normalBold20
                            .copyWith(color: indigo950),
                      ),
                      InkWell(
                        onTap: () {
                          PurchaseService.showHostedPaywall(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFBAF3D), Color(0xFFFFF372)],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                          child: Text(
                            'Upgrade'.tr,
                            style: AppTextStyle.normalBold12
                                .copyWith(color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(top: 200),
                    color: Colors.white,
                    child: Column(
                      children: [
                        10.ph,
                        Text(
                          ProfileController.userName.value,
                          style: AppTextStyle.normalBold16
                              .copyWith(color: textDarkGrey),
                        ),
                        4.ph,
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
                                    "user_id": ProfileController.userId.value
                                        .toString(),
                                    "mood_level": moodType,
                                    "mood_gif": index,
                                    "date": DateTime.now().toString(),
                                  };
                                  MoodController.addOrUpdateMood(context, body);
                                  popForMoodUpdate(index);
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width * .2,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        emojiGifs[index],
                                        height: index == selectedEmojiIndex
                                            ? 60
                                            : 45,
                                        width: index == selectedEmojiIndex
                                            ? 60
                                            : 45,
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
                        Text(
                          emotions[selectedEmojiIndex],
                          style: AppTextStyle.normalBold18.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        3.ph,
                        OptionItem(
                          iconPath: 'icons/mood.png',
                          title: 'Mood Tracker'.tr,
                          handleTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MoodTrackerScreen(),
                              ),
                            );
                          },
                        ),
                        OptionItem(
                          iconPath: 'icons/insights.png',
                          title: 'Personality Insights'.tr,
                          handleTap: () {
                            Get.to(
                              () => const PersonalityScreen(),
                            );
                          },
                        ),
                        OptionItem(
                          iconPath: 'icons/ring2.png',
                          title: 'Ring'.tr,
                          handleTap: () {
                            Get.to(() => const RingScreen());
                          },
                        ),
                        OptionItem(
                          iconPath: 'icons/badges.png',
                          title: 'Badges'.tr,
                          handleTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HardcodedBadgesScreen(),
                              ),
                            );
                          },
                        ),
                        OptionItem(
                          iconPath: 'icons/stamps.png',
                          title: 'Stamps'.tr,
                          handleTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const StampScreen()));
                          },
                        ),
                        OptionItem(
                          iconPath: 'icons/settings.png',
                          title: 'Settings'.tr,
                          handleTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingScreen(),
                              ),
                            );
                          },
                        ),
                        3.ph,
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => PrivacyPolicyScreen(),));
                                  },
                                child: Text(
                                  'Privacy Policy'.tr,
                                  style: AppTextStyle.normalBold12.copyWith(
                                    color: Colors.black45,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => UserAgreementsScreen(),));
                                },
                                child: Text(
                                  'Terms & Conditions'.tr,
                                  style: AppTextStyle.normalBold12.copyWith(
                                    color: Colors.black45,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        3.ph,
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 150,
                  left: MediaQuery.of(context).size.width / 2 -
                      60, // Center horizontally
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 1,
                          spreadRadius: 10,
                          color: coral100,
                        ),
                      ],
                      color: Colors.white,
                      border: Border.all(color: coral500),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: const CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('images/profile.png'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
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
                            child:
                            // Padding(
                            //   padding:
                            //       const EdgeInsets.symmetric(horizontal: 15),
                            //   child:
                              Text(
                                'Talk to me'.tr,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: AppColors.whiteColor,
                                ),
                              // ),
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
}

class OptionItem extends StatelessWidget {
  final String iconPath;
  final String title;
  final Function handleTap;

  const OptionItem({
    super.key,
    required this.iconPath,
    required this.title,
    required this.handleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: GestureDetector(
        onTap: () => handleTap(),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 252, 245, 255),
            border: Border.all(color: indigo300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: Image.asset(
              iconPath,
              height: 40,
              width: 40,
            ),
            title: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            trailing: SvgPicture.asset('icons/arrow3.svg'),
          ),
        ),
      ),
    );
  }
}
