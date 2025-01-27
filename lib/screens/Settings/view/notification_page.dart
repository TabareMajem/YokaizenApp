import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:yokai_quiz_app/screens/Settings/controller/setting_controller.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/const.dart';
import 'package:yokai_quiz_app/util/text_styles.dart';
import 'package:get/get.dart';

class NotificationSetting extends StatefulWidget {
  const NotificationSetting({super.key});

  @override
  State<NotificationSetting> createState() => _NotificationSettingState();
}

class _NotificationSettingState extends State<NotificationSetting> {
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
                    "Notification Settings".tr,
                    style: AppTextStyle.normalBold20.copyWith(color: coral500),
                  ),
                ],
              ),
            ),
            3.ph,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('General Notification'),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      SettingController.isGeneralNotificatonActive.value =
                          !SettingController.isGeneralNotificatonActive.value;
                    });
                  },
                  child: SettingController.isGeneralNotificatonActive.value
                      ? SvgPicture.asset('icons/isOpen.svg')
                      : SvgPicture.asset('icons/isClosed.svg'),
                )
              ],
            ),
            2.ph,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Sound'.tr),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      SettingController.isSoundNotification.value =
                          !SettingController.isSoundNotification.value;
                    });
                  },
                  child: SettingController.isSoundNotification.value
                      ? SvgPicture.asset('icons/isOpen.svg')
                      : SvgPicture.asset('icons/isClosed.svg'),
                )
              ],
            ),
            2.ph,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Vibrate'.tr),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      SettingController.isVibrateNotification.value =
                          !SettingController.isVibrateNotification.value;
                    });
                  },
                  child: SettingController.isVibrateNotification.value
                      ? SvgPicture.asset('icons/isOpen.svg')
                      : SvgPicture.asset('icons/isClosed.svg'),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
