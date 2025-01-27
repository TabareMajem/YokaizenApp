import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:yokai_quiz_app/Widgets/new_button.dart';
import 'package:yokai_quiz_app/Widgets/splash_screen.dart';
import 'package:yokai_quiz_app/screens/Authentication/login_screen.dart';
import 'package:yokai_quiz_app/screens/Settings/controller/setting_controller.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/const.dart';
import 'package:yokai_quiz_app/util/constants.dart';
import 'package:yokai_quiz_app/util/text_styles.dart';

class LanguageSetting extends StatefulWidget {
  final bool? isFromSplashScreen;
  const LanguageSetting({super.key, this.isFromSplashScreen});

  @override
  State<LanguageSetting> createState() => _LanguageSettingState();
}

class _LanguageSettingState extends State<LanguageSetting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        // Replaced with SingleChildScrollView for scrolling behavior
        child: Container(
          padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Row(
                  children: [
                    SvgPicture.asset('icons/arrowLeft.svg'),
                    Text(
                      "Language".tr,
                      style:
                          AppTextStyle.normalBold20.copyWith(color: coral500),
                    ),
                  ],
                ),
              ),
              3.ph,
              Text('Suggested'.tr, style: AppTextStyle.normalBold16),
              2.ph,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "English (UK)".tr,
                    style: AppTextStyle.normalBold14
                        .copyWith(fontWeight: FontWeight.normal),
                  ),
                  GestureDetector(
                    onTap: () {
                      constants.deviceLanguage = "en";
                      Get.updateLocale(
                        const Locale('en'),
                      );
                      SettingController.prilmaryLanguage.value = "English (UK)";
                      Get.to(() => const SplashScreen());
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: indigo700,
                          width: SettingController.prilmaryLanguage.value ==
                                  "English (UK)"
                              ? 4.0
                              : 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              3.ph,
              Text('Other'.tr, style: AppTextStyle.normalBold16),
              2.ph,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Japanese".tr,
                    style: AppTextStyle.normalBold14
                        .copyWith(fontWeight: FontWeight.normal),
                  ),
                  GestureDetector(
                    onTap: () {
                      SettingController.prilmaryLanguage.value = "Japanese";

                      constants.deviceLanguage = "ja";
                      Get.updateLocale(
                        const Locale('ja'),
                      );
                      Get.to(() => const SplashScreen());
                      Get.to(() => const SplashScreen());
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: indigo700,
                          width: SettingController.prilmaryLanguage.value ==
                                  "Japanese"
                              ? 4.0
                              : 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // 2.ph,
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text(
              //       "Korean".tr,
              //       style: AppTextStyle.normalBold14
              //           .copyWith(fontWeight: FontWeight.normal),
              //     ),
              //     GestureDetector(
              //       onTap: () {
              //         SettingController.prilmaryLanguage.value = "Korean";

              //         constants.deviceLanguage = "ko";
              //         Get.updateLocale(
              //           const Locale('ko'),
              //         );

              //         Get.to(() => const SplashScreen());
              //       },
              //       child: Container(
              //         margin: const EdgeInsets.symmetric(vertical: 5),
              //         width: 20,
              //         height: 20,
              //         decoration: BoxDecoration(
              //           borderRadius: BorderRadius.circular(20),
              //           border: Border.all(
              //             color: indigo700,
              //             width: SettingController.prilmaryLanguage.value ==
              //                     "Korean"
              //                 ? 4.0
              //                 : 1.0,
              //           ),
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              10.ph,
              CustomButton(
                text: "Continue".tr,
                textSize: 16,
                onPressed: () {
                  if (widget.isFromSplashScreen == true) {
                    Get.to(() => LoginScreen());
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
