import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:yokai_quiz_app/Widgets/new_button.dart';
import 'package:yokai_quiz_app/Widgets/textfield.dart';
import 'package:yokai_quiz_app/global.dart';
import 'package:yokai_quiz_app/screens/Authentication/controller/auth_screen_controller.dart';
import 'package:get/get.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/const.dart';
import 'package:yokai_quiz_app/util/text_styles.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  static String countryCodeController = '';

  void updateProfileButtonPressed(BuildContext context) async {
    // Prepare the body with updated profile data
    Map<String, dynamic> body = {
      "name": nameController.text,
      "email": emailController.text,
      "phone_number": "$countryCodeController ${phoneController.text}",
    };

    // Call the updateProfile function
    bool isUpdated = await AuthScreenController.updateProfile(context, body);

    if (isUpdated) Navigator.pop(context);
    if (!isUpdated) showSucessMessage("Updated Failed".tr, colorError);
  }

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
                      "Edit Profile".tr,
                      style:
                          AppTextStyle.normalBold20.copyWith(color: coral500),
                    ),
                  ],
                ),
              ),
              6.ph,
              Text(
                'Name'.tr,
                style: AppTextStyle.normalRegular14.copyWith(color: labelColor),
              ),
              0.5.ph,
              TextFeildStyle(
                hintText: 'Lorem'.tr,
                controller: nameController,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: greyborder),
                ),
                hintStyle:
                    AppTextStyle.normalRegular10.copyWith(color: hintText),
                border: InputBorder.none,
              ),
              3.ph,
              Text(
                'Email'.tr,
                style: AppTextStyle.normalRegular14.copyWith(color: labelColor),
              ),
              0.5.ph,
              TextFeildStyle(
                hintText: 'loremipsum@gmail.com',
                onChanged: (p0) {
                  validateEmail(p0);
                },
                controller: emailController,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: greyborder),
                ),
                hintStyle:
                    AppTextStyle.normalRegular10.copyWith(color: hintText),
                border: InputBorder.none,
              ),
              if (_errorTextEmail != null)
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    top: 3,
                  ),
                  child: Text(
                    _errorTextEmail!,
                    style: const TextStyle(
                        color: Colors.red,
                        fontSize: 10,
                        fontFamily: "Montserrat"),
                  ),
                ),
              3.ph,
              Text(
                'Phone No.'.tr,
                style: AppTextStyle.normalRegular14.copyWith(color: labelColor),
              ),
              0.5.ph,
              IntlPhoneField(
                initialCountryCode: 'JP',
                disableLengthCheck: true,
                controller: phoneController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(left: 12, right: 10),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: greyborder),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: greyborder),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: greyborder),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintStyle:
                      AppTextStyle.normalRegular14.copyWith(color: hintColor),
                  labelStyle:
                      AppTextStyle.normalRegular14.copyWith(color: textColor),
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: greyborder),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  LengthLimitingTextInputFormatter(10),
                ],
                keyboardType: TextInputType.phone,
                languageCode: "en",
                onChanged: (phone) {
                  _validatePhoneNumber(phone.number);
                  setState(() {
                    countryCodeController = phone.countryCode;
                  });
                },
              ),
              Builder(
                builder: (BuildContext context) {
                  if (_errorphone != null) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 20, top: 3),
                      child: Text(
                        _errorphone!,
                        style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontFamily: 'Montserrat'),
                      ),
                    );
                  } else {
                    return const SizedBox();
                  }
                },
              ),
              4.ph,
              CustomButton(
                text: "Update Profile".tr,
                textSize: 16,
                onPressed: () {
                  _errorphone == null &&
                          _errorTextEmail == null &&
                          nameController.text.isNotEmpty
                      ? updateProfileButtonPressed(context)
                      : showErrorMessage("Provide all data", colorError);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _errorTextEmail;

  String? _errorphone;

  void _validatePhoneNumber(String phoneNumber) {
    if (phoneNumber.length < 9) {
      setState(() {
        _errorphone = 'Enter a valid number';
      });
    } else {
      setState(() {
        _errorphone = null;
      });
    }
  }

  void validateEmail(String value) {
    RegExp regex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    var passNonNullValue = value ?? "";
    if (passNonNullValue.isEmpty) {
      setState(() {
        _errorTextEmail = "Please enter an email address";
      });
    } else if (!regex.hasMatch(passNonNullValue)) {
      setState(() {
        _errorTextEmail = "Please enter a valid email address";
      });
    } else {
      setState(() {
        _errorTextEmail = null;
      });
    }
  }
}
