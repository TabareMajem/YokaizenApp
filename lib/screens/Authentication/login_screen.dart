import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:yokai_quiz_app/Widgets/new_button.dart';
import 'package:yokai_quiz_app/Widgets/progressHud.dart';
import 'package:yokai_quiz_app/screens/Create Account/CreateAccount_screen.dart';
import 'package:yokai_quiz_app/util/const.dart';
import 'package:yokai_quiz_app/util/constants.dart';

import '../../Widgets/textfield.dart';
import '../../global.dart';
import '../../util/colors.dart';
import '../../util/text_styles.dart';
import '../navigation/view/navigation.dart';
import 'controller/auth_screen_controller.dart';
import 'forgotpassword_screen.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool setobscureText = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  RxBool loading = false.obs;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  // final LoginController c = Get.put(LoginController());
  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance!.addPostFrameCallback((_) {
    //   c.emailController.value.clear();
    //   c.passwordController.value.clear();
    //   c.isLogin(false);
    // });
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double screenWidth = mediaQueryData.size.width;
    double screenHeight = mediaQueryData.size.height;
    return Obx(() {
      return ProgressHUD(
        isLoading: loading.value,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 20,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    Center(
                      child: Text(
                        'Log In'.tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: headingOrange,
                          fontSize: 28,
                          // fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w700,
                          height: 0,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: constants.defaultPadding * 2,
                    ),
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
                    2.5.ph,
                    Text(
                      'Password'.tr,
                      style: AppTextStyle.normalRegular14
                          .copyWith(color: labelColor),
                    ),
                    0.5.ph,
                    TextFeildStyle(
                      onChanged: (value) {
                        _validatePassword(value);
                      },
                      obscureText: setobscureText,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            setobscureText = !setobscureText;
                          });
                        },
                        icon: SvgPicture.asset(
                          setobscureText
                              ? "icons/password.svg"
                              : "icons/closepasswordeye_icon.svg",
                          color: headingOrange,
                        ),
                      ),
                      textAlignVertical: TextAlignVertical.center,
                      controller: passwordController,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: greyborder),
                      ),
                      hintStyle: AppTextStyle.normalRegular10
                          .copyWith(color: hintText),
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
                    const SizedBox(
                      height: constants.defaultPadding,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return const ForgotPasswordScreen();
                                },
                              ),
                            );
                          },
                          child: Text(
                            'Forgot password?'.tr,
                            textAlign: TextAlign.right,
                            style: AppTextStyle.normalSemiBold12
                                .copyWith(color: primaryColor),
                          ),
                        )
                      ],
                    ),
                    5.ph,
                    CustomButton(
                        // iconSvgPath: 'icons/forward_icon.svg',
                        text: "Log In".tr,
                        onPressed: () {
                          AuthScreenController.isFirebaseLoginSuccess(false);
                          AuthScreenController.isApiLoginSuccess(false);
                          if (_formKey.currentState!.validate()) {
                            loading(true);
                            final List<TextEditingController> controllerList = [
                              emailController,
                              passwordController
                            ];
                            final List<String> fieldsName = [
                              'Email',
                              'Password'
                            ];
                            bool valid = validateMyFields(
                                context, controllerList, fieldsName);
                            if (!valid) {
                              loading(false);
                              return;
                            }
                            print(
                                'passwordController :: ${passwordController.text.length}');
                            if (passwordController.text.length < 6) {
                              loading(false);
                              return;
                            }

                            AuthScreenController.loginWithFirebase(
                                    context,
                                    emailController.text.trim(),
                                    passwordController.text.trim())
                                .then(
                              (value) {
                                if (value) {
                                  final body = {
                                    "email": emailController.text.trim(),
                                    "password": passwordController.text.trim()
                                  };
                                  AuthScreenController.login(context, body)
                                      .then((value) {
                                    AuthScreenController.nodeLogin(
                                            context, body)
                                        .then((value) {
                                      if (AuthScreenController
                                              .isFirebaseLoginSuccess.isTrue &&
                                          AuthScreenController
                                              .isApiLoginSuccess.isFalse) {
                                        final passwordBody = {
                                          "password":
                                              passwordController.text.trim()
                                        };
                                        AuthScreenController
                                                .updatePasswordFromApi(
                                                    context,
                                                    emailController.text.trim(),
                                                    passwordBody)
                                            .then(
                                          (value) {
                                            if (value) {
                                              final body = {
                                                "email":
                                                    emailController.text.trim(),
                                                "password": passwordController
                                                    .text
                                                    .trim()
                                              };
                                              AuthScreenController.login(
                                                      context, body)
                                                  .then((value) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) {
                                                      return NavigationPage();
                                                    },
                                                  ),
                                                );

                                                loading(false);
                                              });
                                            } else {
                                              loading(false);
                                            }
                                          },
                                        );
                                      } else {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return NavigationPage();
                                            },
                                          ),
                                        );

                                        loading(false);
                                      }
                                    });
                                  });
                                } else {
                                  loading(false);
                                }
                              },
                            );
                          }
                        }),
                    3.ph,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        2.pw,
                        InkWell(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return const CreateAccountScreen();
                            }));
                          },
                          child: Center(
                            child: Text(
                              'Create Account'.tr,
                              style: textStyle.button,
                            ),
                          ),
                        )
                      ],
                    ),
                    1.5.ph,
                    const Divider(
                      height: 2,
                      color: AppColors.black,
                    ),
                    2.ph,

                    //google login/signing
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: colorBorder,
                        ),
                        // boxShadow: [
                        //   BoxShadow(
                        //     color: Colors.black.withOpacity(0.3),
                        //     blurRadius: 4,
                        //     offset: const Offset(0, 2),
                        //   ),
                        // ],
                      ),
                      child: Material(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(50),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () async {
                            loading(true);
                            await AuthScreenController.signInWithGoogle()
                                .then((value) async {
                              await AuthScreenController.checkEmail(
                                      AuthScreenController.googleEmail.value)
                                  .then((value) async {
                                if (AuthScreenController.isCheckEmail.isTrue) {
                                  print("Google :: Login");
                                  final body = {
                                    "email":
                                        AuthScreenController.googleEmail.value,
                                    "password":
                                        AuthScreenController.googleUid.value
                                  };
                                  await AuthScreenController.login(
                                          context, body)
                                      .then((value) {
                                    nextPage(NavigationPage());
                                    loading(false);
                                  });
                                } else {
                                  print("Google :: SignUp");
                                  final body = {
                                    if (AuthScreenController
                                        .googleName.isNotEmpty)
                                      "name":
                                          AuthScreenController.googleName.value,
                                    if (AuthScreenController
                                        .googleEmail.isNotEmpty)
                                      "email": AuthScreenController
                                          .googleEmail.value,
                                    if (AuthScreenController
                                        .googleUid.isNotEmpty)
                                      "password":
                                          AuthScreenController.googleUid.value,
                                    if (AuthScreenController
                                        .googlePhoneNumber.isNotEmpty)
                                      "phone_number": AuthScreenController
                                          .googlePhoneNumber.value,
                                    "login_type": "1"
                                  };
                                  await AuthScreenController.createAccount(
                                          context, body)
                                      .then((value) async {
                                    final body = {
                                      "email": AuthScreenController
                                          .googleEmail.value,
                                      "password":
                                          AuthScreenController.googleUid.value
                                    };
                                    await AuthScreenController.login(
                                            context, body)
                                        .then((value) {
                                      nextPage(NavigationPage());
                                      loading(false);
                                    });
                                  });
                                }
                              });
                            });
                          },
                          splashColor: headingOrange,
                          borderRadius: BorderRadius.circular(50),
                          child: Container(
                            height: 48,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Image.asset(
                                    'images/google.png',
                                    width: 30,
                                    height: 30,
                                  ),
                                ),
                                1.pw,
                                Text(
                                  "Join with Google".tr,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    // color: primaryColor,
                                    color: ironColor,
                                    fontSize: 18,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    2.ph,
                    if (Platform.isIOS) //ios login/signing
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: colorBorder,
                          ),
                          // boxShadow: [
                          //   BoxShadow(
                          //     color: Colors.black.withOpacity(0.3),
                          //     blurRadius: 4,
                          //     offset: const Offset(0, 2),
                          //   ),
                          // ],
                        ),
                        child: Material(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(50),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () async {
                              AuthScreenController.signInWithApple()
                                  .then((value) {
                                loading(true);
                                print(
                                    "appleEmail :: ${AuthScreenController.appleEmail.value}");
                                AuthScreenController.checkEmail(
                                        AuthScreenController.appleEmail.value)
                                    .then((value) {
                                  if (AuthScreenController
                                      .isCheckEmail.isTrue) {
                                    print("Apple :: Login");
                                    final body = {
                                      "email":
                                          AuthScreenController.appleEmail.value,
                                      "password":
                                          AuthScreenController.appleUid.value
                                    };
                                    if (AuthScreenController
                                        .appleEmail.isNotEmpty) {
                                      AuthScreenController.login(context, body)
                                          .then((value) {
                                        if (value) {
                                          // nextPage(NavigationPage());
                                          Get.to(() => NavigationPage(),
                                              transition:
                                                  Transition.rightToLeft);

                                          loading(false);
                                        } else {
                                          loading(false);
                                        }
                                      });
                                    } else {
                                      loading(false);
                                      return;
                                    }
                                  } else {
                                    print("Apple :: SignUp");
                                    final body = {
                                      if (AuthScreenController
                                          .appleName.isNotEmpty)
                                        "name": AuthScreenController
                                            .appleName.value,
                                      if (AuthScreenController
                                          .appleEmail.isNotEmpty)
                                        "email": AuthScreenController
                                            .appleEmail.value,
                                      if (AuthScreenController
                                          .appleUid.isNotEmpty)
                                        "password":
                                            AuthScreenController.appleUid.value,
                                      if (AuthScreenController
                                          .applePhoneNumber.isNotEmpty)
                                        "phone_number": AuthScreenController
                                            .applePhoneNumber.value,
                                      "login_type": "2"
                                    };
                                    if (AuthScreenController
                                        .appleEmail.isNotEmpty) {
                                      AuthScreenController.createAccount(
                                              context, body)
                                          .then((value) {
                                        final body = {
                                          "email": AuthScreenController
                                              .appleEmail.value,
                                          "password": AuthScreenController
                                              .appleUid.value
                                        };
                                        AuthScreenController.login(
                                                context, body)
                                            .then((value) {
                                          if (value) {
                                            // nextPage(NavigationPage());
                                            Get.to(() => NavigationPage(),
                                                transition:
                                                    Transition.rightToLeft);
                                            loading(false);
                                          } else {
                                            loading(false);
                                          }
                                        });
                                      });
                                    } else {
                                      loading(false);
                                      return;
                                    }
                                  }
                                });
                              });
                            },
                            splashColor: headingOrange,
                            borderRadius: BorderRadius.circular(50),
                            child: Container(
                              height: 48,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Image.asset(
                                      'images/apple.png',
                                      width: 30,
                                      height: 30,
                                    ),
                                  ),
                                  1.pw,
                                  Text(
                                    "Join with Apple".tr,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      // color: primaryColor,
                                      color: ironColor,
                                      fontSize: 18,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    6.ph,
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  String? _errorTextpass;
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

  void _validatePassword(String value) {
    var passNonNullValue = value;
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
