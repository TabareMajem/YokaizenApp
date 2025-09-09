import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:yokai_quiz_app/Widgets/confirmation_box.dart';
import 'package:yokai_quiz_app/main.dart';
import 'package:yokai_quiz_app/screens/about_us/about_page.dart';
import 'package:yokai_quiz_app/screens/Authentication/controller/auth_screen_controller.dart';
import 'package:yokai_quiz_app/screens/Authentication/login_screen.dart';
import 'package:yokai_quiz_app/screens/FAQ/faq_page.dart';
import 'package:yokai_quiz_app/screens/refer_and_earn/view/refer_and_earn.dart';
import 'package:yokai_quiz_app/screens/Settings/view/account_info.dart';
import 'package:yokai_quiz_app/screens/Settings/view/language_page.dart';
import 'package:yokai_quiz_app/screens/Settings/view/notification_page.dart';
import 'package:yokai_quiz_app/screens/Settings/view/privacy_page.dart';
import 'package:yokai_quiz_app/screens/connected_devices/view/connected_devices.dart';
// import 'package:yokai_quiz_app/screens/settings/view/rank_list.dart';
import 'package:yokai_quiz_app/screens/settings/view/user_agreement_screen.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/const.dart';
import 'package:yokai_quiz_app/util/custom_app_bar.dart';
import 'package:yokai_quiz_app/util/text_styles.dart';
import 'package:get/get.dart';

import '../../../visual_novels/lib/config/game_screen.dart';
import '../../../visual_novels/lib/game/harmony-seekers-game.dart';
import '../../../visual_novels/lib/managers/assets-manager.dart';
import '../../../visual_novels/lib/managers/audio-manager.dart';
import '../../../visual_novels/lib/managers/character-position-manager.dart';
import '../../../visual_novels/lib/state/game-state.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // const SizedBox(
              //   height: 10,
              // ),
              // GestureDetector(
              //   onTap: () {
              //     Navigator.pop(context);
              //   },
              //   child: Row(
              //     children: [
              //       SvgPicture.asset('icons/arrowLeft.svg'),
              //       Text(
              //         "  Settings".tr,
              //         style: AppTextStyle.normalBold20.copyWith(color: coral500),
              //       ),
              //     ],
              //   ),
              // ),
              CustomAppBar(
                title: "Settings".tr,
                isBackButton: true,
                isColor: false,
                onButtonPressed: () {
                  Navigator.pop(context);
                },
              ),
              OptionItem(
                iconPath: 'icons/profile3.svg',
                title: 'Account Info'.tr,
                handleTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AccountInfoPage()));
                },
              ),
              OptionItem(
                iconPath: 'icons/notes.svg',
                title: 'Language Change'.tr,
                handleTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LanguageSetting(
                        isFromSplashScreen: false,
                      ),
                    ),
                  );
                },
              ),
              OptionItem(
                iconPath: 'icons/home3.svg',
                title: 'About us'.tr,
                handleTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AboutPage(),
                    ),
                  );
                },
              ),
              OptionItem(
                iconPath: 'icons/lock2.svg',
                title: 'Privacy Settings'.tr,
                handleTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PrivacySetting()));
                },
              ),
              OptionItem(
                iconPath: 'icons/bell.svg',
                title: 'Notification Settings'.tr,
                handleTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NotificationSetting()));
                },
              ),
              OptionItem(
                iconPath: 'icons/cup.svg',
                title: 'Refer & Earn'.tr,
                handleTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ReferEarnPage()));
                },
              ),
              OptionItem(
                iconPath: 'icons/devices.svg',
                title: 'Connected Devices'.tr,
                handleTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ConnectedDevicesPage()));
                },
              ),
              OptionItem(
                iconPath: 'icons/faq.svg',
                title: 'FAQ\'s'.tr,
                handleTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FaqPage(),
                    ),
                  );

                },
              ),
              OptionItem(
                iconPath: 'icons/notes.svg',
                title: 'User Agreements'.tr,
                handleTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const UserAgreementsScreen(),));
                },
              ),
              if (((AuthScreenController.getProfileModel.value.user?.loginType ??
                          '') !=
                          '1') &&
                      ((AuthScreenController.getProfileModel.value.user?.loginType ??
                              '') !=
                          '2'))
                4.ph,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return ConfirmationDialog(
                            title: "Log Out?".tr,
                            content: Text(
                              'Are you sure you want to log out of the app? Your data will not be lost. '
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
                            displayIcon: true,
                            customImageAsset: 'images/appLogo_yokai.png',
                            onConfirm: () async {
                              AuthScreenController.signOutWithFirebase().then(
                                (value) {
                                  if (value) {
                                    prefs.clear();
                                    navigator?.pushAndRemoveUntil(
                                        MaterialPageRoute(
                                      builder: (context) {
                                        return LoginScreen();
                                      },
                                    ), (route) => false);
                                  } else {
                                    return;
                                  }
                                },
                              );
                            });
                      },
                    );
                  },
                  child: Center(
                    child: Text(
                      'Logout'.tr,
                      style: textStyle.button.copyWith(color: primaryColor),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OptionItem extends StatelessWidget {
  final String iconPath;
  final String title;
  final Function handleTap;

  const OptionItem(
      {super.key,
      required this.iconPath,
      required this.title,
      required this.handleTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: GestureDetector(
        onTap: () => handleTap(),
        child: ListTile(
          leading: SvgPicture.asset(
            iconPath,
            // height: 25,
            // width: 25,
          ),
          title: Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 12,
          ),
        ),
      ),
    );
  }
}
