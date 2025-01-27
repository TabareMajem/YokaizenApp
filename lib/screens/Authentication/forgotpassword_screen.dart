import 'package:flutter/material.dart';
import 'package:yokai_quiz_app/Widgets/new_button.dart';
import 'package:yokai_quiz_app/global.dart';
import 'package:yokai_quiz_app/screens/Create%20Account/confirmation_screen.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/const.dart';
import 'package:yokai_quiz_app/util/text_styles.dart';

import '../../Widgets/textfield.dart';
import 'controller/auth_screen_controller.dart';
import 'package:get/get.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

TextEditingController phoneNoController = TextEditingController();
FocusNode _emailfocusnode = FocusNode();

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    phoneNoController.clear();
    // Api.getShow_byPhoneNo(context,phoneNoController.value.text ).then((value){
    //   studentId=Api.studentshowPhone.value.data?[0].id.toString();
    // });
  }

  String? studentId;
  String selectedCountryCode = '';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double screenWidth = mediaQueryData.size.width;
    double screenHeight = mediaQueryData.size.height;
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width / 15,
          ),
          child: Column(
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.only(
                      left: screenWidth / 3.5,
                      right: screenWidth / 3.5,
                      top: screenHeight / 8),
                  child: Image.asset('images/appLogo_yokai.png'),
                ),
              ),
              SizedBox(
                height: screenHeight / 18,
              ),
              Text(
                'Forgot Password'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: headingOrange,
                  fontSize: 28,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                  height: 0,
                ),
              ),
              SizedBox(
                height: screenHeight / 30,
              ),
              Text(
                'We will send you the link to reset password on your registered phone number'
                    .tr,
                // textAlign: TextAlign.start,
                style: const TextStyle(
                  color: colorfont,
                  fontSize: 14,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: screenHeight / 30,
              ),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email'.tr,
                      style: AppTextStyle.normalRegular14
                          .copyWith(color: labelColor),
                    ),
                    0.5.ph,
                    TextFeildStyle(
                      onChanged: (p0) {
                        validateEmail(p0);
                      },
                      controller: emailController,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: greyborder),
                      ),
                      hintStyle: AppTextStyle.normalRegular10
                          .copyWith(color: hintText),
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
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: screenWidth / 12,
                    right: screenWidth / 12,
                    top: screenHeight / 9),
                child: CustomButton(
                    // iconSvgPath: 'icons/forward_icon.svg',
                    text: "Send Email".tr,
                    onPressed: () async {
                      AuthScreenController.forgotPasswordWithFirebase(
                              context, emailController.text.trim())
                          .then(
                        (value) {
                          if (value) {
                            nextPage(
                              ConfirmationScreen(
                                title: 'Reset Link Sent !'.tr,
                                email: emailController.text.trim(),
                                message:
                                    'Please check your registered email for the password reset link and steps. \n\nYou can log in with the new password once it has been reset. '
                                        .tr,
                                buttonText: 'Log In'.tr,
                              ),
                            );
                          } else {}
                        },
                      );
                    }),
              ),
              SizedBox(
                height: screenHeight / 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  2.pw,
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Center(
                      child: Text(
                        'Back'.tr,
                        style: textStyle.button,
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _errorTextEmail;

  void validateEmail(String value) {
    RegExp regex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    var passNonNullValue = value;
    if (passNonNullValue.isEmpty) {
      setState(() {
        _errorTextEmail = "Please enter an email address".tr;
      });
    } else if (!regex.hasMatch(passNonNullValue)) {
      setState(() {
        _errorTextEmail = "Please enter a valid email address".tr;
      });
    } else {
      setState(() {
        _errorTextEmail = null;
      });
    }
  }
}
