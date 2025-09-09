import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:yokai_quiz_app/screens/Settings/view/change_password.dart';
import 'package:yokai_quiz_app/screens/Settings/view/view_profile.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/const.dart';
import 'package:yokai_quiz_app/util/text_styles.dart';
import 'package:get/get.dart';
import 'package:yokai_quiz_app/Widgets/confirmation_box.dart';
import 'package:yokai_quiz_app/main.dart';
import 'package:yokai_quiz_app/screens/Authentication/login_screen.dart';
import 'package:yokai_quiz_app/screens/Authentication/controller/auth_screen_controller.dart';

import '../../../util/custom_app_bar.dart';

class AccountInfoPage extends StatefulWidget {
  const AccountInfoPage({super.key});

  @override
  State<AccountInfoPage> createState() => _AccountInfoPageState();
}

class _AccountInfoPageState extends State<AccountInfoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
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
            //         "Account info".tr,
            //         style: AppTextStyle.normalBold20.copyWith(color: coral500),
            //       ),
            //     ],
            //   ),
            // ),
            CustomAppBar(
              title: 'Account info'.tr,
              isBackButton: true,
              isColor: false,
              onButtonPressed: () {
                Navigator.pop(context);
              },
            ),
            3.ph,
            OptionItem(
              iconPath: 'icons/profile3.svg',
              title: 'View Profile'.tr,
              handleTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ViewProfilePage()));
              },
            ),
            OptionItem(
              iconPath: 'icons/lock2.svg',
              title: 'Change Password'.tr,
              handleTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ChangePasswordPage()));
              },
            ),
            OptionItem(
              iconPath: 'icons/delete.jpeg',
              title: 'Delete Profile'.tr,
              handleTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ConfirmationDialog(
                        title: "Delete Profile?".tr,
                        content: Text(
                          'Are you sure you want to delete your profile? This action cannot be undone.'.tr,
                          style: const TextStyle(
                            color: Color(0xFF637577),
                            fontSize: 14,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        cancelButtonText: 'Cancel'.tr,
                        confirmButtonText: 'Delete'.tr,
                        onCancel: () {
                          Navigator.pop(context);
                        },
                        displayIcon: true,
                        customImageAsset: 'images/appLogo_yokai.png',
                        onConfirm: () async {
                          // TODO: Implement profile deletion logic
                          // You'll need to add the delete profile method in AuthScreenController
                          AuthScreenController.deleteProfile().then((value) {
                            if (value) {
                              prefs.clear();
                              navigator?.pushAndRemoveUntil(
                                  MaterialPageRoute(
                                builder: (context) {
                                  return LoginScreen();
                                },
                              ), (route) => false);
                            }
                          });
                        });
                  },
                );
              },
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }
}

class OptionItem extends StatelessWidget {
  final String iconPath;
  final String title;
  final Function handleTap;
  final bool isDestructive;

  const OptionItem(
      {super.key,
      required this.iconPath,
      required this.title,
      required this.handleTap,
      this.isDestructive = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: GestureDetector(
        onTap: () => handleTap(),
        child: ListTile(
          leading: iconPath.contains("delete") ? Icon(Icons.delete_forever_outlined, color: Color.fromRGBO(0, 63, 119, 1),) : SvgPicture.asset(
            iconPath,
            // height: 25,
            // width: 25,
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: isDestructive ? Colors.red : null,
            ),
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
