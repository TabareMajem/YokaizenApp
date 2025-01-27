import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/get.dart';
import 'package:yokai_quiz_app/screens/Authentication/controller/auth_screen_controller.dart';
import 'package:yokai_quiz_app/screens/Settings/controller/setting_controller.dart';
import 'package:yokai_quiz_app/screens/Settings/view/edit_profile.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/const.dart';
import 'package:yokai_quiz_app/util/text_styles.dart';

class ViewProfilePage extends StatefulWidget {
  const ViewProfilePage({super.key});

  @override
  State<ViewProfilePage> createState() => _ViewProfilePageState();
}

class _ViewProfilePageState extends State<ViewProfilePage> {
  @override
  void initState() {
    super.initState();
    SettingController.isLoading(true);
    AuthScreenController.fetchData().then((value) => {
          SettingController.userName(
              AuthScreenController.getProfileModel.value.user?.name ?? ""),
          SettingController.userEmail(
              AuthScreenController.getProfileModel.value.user?.email ?? ""),
          SettingController.userPhoneNumber(
              AuthScreenController.getProfileModel.value.user?.phoneNumber ??
                  ""),
        });
    SettingController.isLoading(false);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return Scaffold(
          body: Stack(
            children: [
              Align(
                alignment: Alignment.bottomRight,
                child: Opacity(
                  opacity: 0.2,
                  child: Image.asset(
                    'images/bgviewprofile.png',
                    height: 270,
                    width: 270,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Main content
              Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.only(top: 50, left: 20, right: 20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Row(
                                children: [
                                  SvgPicture.asset('icons/arrowLeft.svg'),
                                  Text(
                                    "View Profile".tr,
                                    style: AppTextStyle.normalBold20
                                        .copyWith(color: coral500),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const EditProfilePage()));
                              },
                              child: Row(
                                children: [
                                  SvgPicture.asset('icons/edit.svg'),
                                  Text(
                                    "Edit".tr,
                                    style: AppTextStyle.normalBold14.copyWith(
                                      color: coral500,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Container(
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
                        2.ph,
                        Text(
                          SettingController.userName.value,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textDarkGrey,
                          ),
                        ),
                        3.ph,
                        GestureDetector(
                          child: Container(
                            width: 150,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFBAF3D), Color(0xFFFFF372)],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  'Upgrade to '.tr,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SvgPicture.asset('icons/pro.svg'),
                                Text(
                                  'PRO'.tr,
                                  style: AppTextStyle.normalBold14
                                      .copyWith(color: coral500),
                                ),
                              ],
                            ),
                          ),
                        ),
                        6.ph,
                        Row(
                          children: [
                            SvgPicture.asset('icons/email.svg'),
                            const SizedBox(width: 8),
                            Text(
                              SettingController.userEmail.value,
                              style: const TextStyle(color: textDarkGrey),
                            ),
                          ],
                        ),
                        3.ph,
                        Row(
                          children: [
                            SvgPicture.asset(
                              'icons/phone.svg',
                            ),
                            const SizedBox(width: 8),
                            Text(
                              SettingController.userPhoneNumber.value,
                              style: const TextStyle(color: textDarkGrey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, top: 30, bottom: 50),
                    decoration: const BoxDecoration(
                        border: Border(
                            top: BorderSide(color: lightgrey, width: 1))),
                    child: Column(
                      children: [
                        Text(
                          'Enjoying the app?'.tr,
                          style: const TextStyle(color: coral500, fontSize: 16),
                        ),
                        Text(
                          'Would you mind rating us?'.tr,
                          style: const TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.normal,
                              fontSize: 12),
                        ),
                        1.5.ph,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4.0), // Space between stars
                              child: SvgPicture.asset('icons/star.svg'),
                            );
                          }),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
