import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:yokai_quiz_app/Widgets/new_button.dart';
import 'package:yokai_quiz_app/Widgets/textfield.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/const.dart';
import 'package:yokai_quiz_app/util/text_styles.dart';
import 'package:get/get.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  bool setobscureTextOld = true;
  bool setobscureTextNew = true;
  bool setobscureTextConfirm = true;
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
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
                      "Change Password".tr,
                      style:
                          AppTextStyle.normalBold20.copyWith(color: coral500),
                    ),
                  ],
                ),
              ),
              5.ph,
              Text(
                'Old Password'.tr,
                style: AppTextStyle.normalRegular14.copyWith(color: labelColor),
              ),
              0.5.ph,
              TextFeildStyle(
                hintText: '●●●●●●●●●',
                obscureText: setobscureTextOld,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      setobscureTextOld = !setobscureTextOld;
                    });
                  },
                  icon: SvgPicture.asset(
                    setobscureTextOld
                        ? "icons/password.svg"
                        : "icons/closepasswordeye_icon.svg",
                    color: headingOrange,
                  ),
                ),
                textAlignVertical: TextAlignVertical.center,
                controller: oldPasswordController,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: greyborder),
                ),
                hintStyle:
                    AppTextStyle.normalRegular20.copyWith(color: hintText),
                border: InputBorder.none,
              ),
              4.ph,
              Text(
                'New Password'.tr,
                style: AppTextStyle.normalRegular14.copyWith(color: labelColor),
              ),
              0.5.ph,
              TextFeildStyle(
                hintText: '●●●●●●●●●',
                onChanged: (value) {
                  _validatePassword(value);
                },
                obscureText: setobscureTextNew,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      setobscureTextNew = !setobscureTextNew;
                    });
                  },
                  icon: SvgPicture.asset(
                    setobscureTextNew
                        ? "icons/password.svg"
                        : "icons/closepasswordeye_icon.svg",
                    color: headingOrange,
                  ),
                ),
                textAlignVertical: TextAlignVertical.center,
                controller: newPasswordController,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: greyborder),
                ),
                hintStyle:
                    AppTextStyle.normalRegular20.copyWith(color: hintText),
                border: InputBorder.none,
              ),
              if (_errorTextpass != null)
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    top: 3,
                  ),
                  child: Text(
                    _errorTextpass!,
                    style: const TextStyle(
                        color: Colors.red,
                        fontSize: 10,
                        fontFamily: "Montserrat"),
                  ),
                ),
              4.ph,
              Text(
                'Confirm New Password'.tr,
                style: AppTextStyle.normalRegular14.copyWith(color: labelColor),
              ),
              0.5.ph,
              TextFeildStyle(
                hintText: '●●●●●●●●●',
                obscureText: setobscureTextConfirm,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      setobscureTextConfirm = !setobscureTextConfirm;
                    });
                  },
                  icon: SvgPicture.asset(
                    setobscureTextConfirm
                        ? "icons/password.svg"
                        : "icons/closepasswordeye_icon.svg",
                    color: headingOrange,
                  ),
                ),
                textAlignVertical: TextAlignVertical.center,
                controller: confirmPasswordController,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: greyborder),
                ),
                hintStyle:
                    AppTextStyle.normalRegular20.copyWith(color: hintText),
                border: InputBorder.none,
              ),
              5.ph,
              CustomButton(
                text: "Change Password".tr,
                textSize: 16,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _errorTextpass;

  void _validatePassword(String value) {
    var passNonNullValue = value ?? "";
    if (passNonNullValue.isEmpty) {
      setState(() {
        _errorTextpass = "Password is required".tr;
      });
    } else if (passNonNullValue.length < 6 || passNonNullValue.length > 10) {
      setState(() {
        _errorTextpass = "Password must be between 6 and 10 characters long".tr;
      });
    } else {
      setState(() {
        _errorTextpass = null;
      });
    }
  }
}
