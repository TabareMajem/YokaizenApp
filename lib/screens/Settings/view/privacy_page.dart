import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart'; // Make sure you're using GetX for state management
import 'package:yokai_quiz_app/screens/Settings/controller/setting_controller.dart';
import 'package:yokai_quiz_app/screens/Settings/view/language_page.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/const.dart';
import 'package:yokai_quiz_app/util/text_styles.dart';

class PrivacySetting extends StatefulWidget {
  const PrivacySetting({super.key});

  @override
  State<PrivacySetting> createState() => _PrivacySettingState();
}

class _PrivacySettingState extends State<PrivacySetting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Row(
                children: [
                  SvgPicture.asset('icons/arrowLeft.svg'),
                  Text(
                    "Privacy Settings".tr,
                    style: AppTextStyle.normalBold20.copyWith(color: coral500),
                  ),
                ],
              ),
            ),
            3.ph,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Mark as offline'.tr),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      SettingController.isMarkedOffline.value =
                          !SettingController.isMarkedOffline.value;
                    });
                  },
                  child: Obx(() => SettingController.isMarkedOffline.value
                      ? SvgPicture.asset('icons/isOpen.svg')
                      : SvgPicture.asset('icons/isClosed.svg')),
                )
              ],
            ),
            2.ph,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Language'.tr),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LanguageSetting(),
                      ),
                    );
                  },
                  child: Obx(
                    () => Text(
                      SettingController.prilmaryLanguage.value,
                      style: const TextStyle(color: indigo700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
