import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:yokai_quiz_app/screens/Settings/view/change_password.dart';
import 'package:yokai_quiz_app/screens/Settings/view/view_profile.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/const.dart';
import 'package:yokai_quiz_app/util/text_styles.dart';
import 'package:get/get.dart';

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
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Row(
                children: [
                  SvgPicture.asset('icons/arrowLeft.svg'),
                  Text(
                    "Account info".tr,
                    style: AppTextStyle.normalBold20.copyWith(color: coral500),
                  ),
                ],
              ),
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
