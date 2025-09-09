/// login_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:yokai_quiz_app/Widgets/new_button.dart';
import 'package:yokai_quiz_app/Widgets/progressHud.dart';
import 'package:yokai_quiz_app/util/const.dart';
import 'package:yokai_quiz_app/util/constants.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';

import '../../Widgets/textfield.dart';
import '../../api/local_storage.dart';
import '../../config/app_tracking_config.dart';
import '../../global.dart';
import '../../main.dart';
import '../../util/colors.dart';
import '../../util/text_styles.dart';
import '../create_account/create_account_screen.dart';
import '../navigation/view/navigation.dart';
import 'controller/auth_screen_controller.dart';
import 'forgotpassword_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

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
    AppTrackingConfig.initPlugin();
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
          body: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width / 20,
            ),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: screenWidth / 3.5,
                            right: screenWidth / 3.5,
                            top: screenHeight / 15),
                        child: Image.asset('images/appLogo_yokai.png', height: 90, width: 90,),
                      ),
                    ),
                    SizedBox(
                      height: screenHeight / 40,
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
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: greyborder),
                      ),
                      hintStyle: AppTextStyle.normalRegular10
                          .copyWith(color: hintText),
                      border: InputBorder.none,
                    ),
                    if (_errorTextEmail != null)
                      // Padding(
                      //   padding: const EdgeInsets.only(
                      //     left: 20,
                      //     top: 3,
                      //   ),
                      //   child: Text(
                      //     _errorTextEmail!,
                      //     style: const TextStyle(
                      //         color: Colors.red,
                      //         fontSize: 10,
                      //         fontFamily: "Montserrat"),
                      //   ),
                      // ),
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
                      height: 40,
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

                    // LINE Login Button
                    // Container(
                    //   width: double.infinity,
                    //   decoration: BoxDecoration(
                    //     borderRadius: BorderRadius.circular(50),
                    //     border: Border.all(
                    //       color: colorBorder,
                    //     ),
                    //   ),
                    //   child: Material(
                    //     color: AppColors.white,
                    //     borderRadius: BorderRadius.circular(50),
                    //     clipBehavior: Clip.antiAlias,
                    //     child: InkWell(
                    //       onTap: _handleLineLogin,
                    //       splashColor: headingOrange,
                    //       borderRadius: BorderRadius.circular(50),
                    //       child: Container(
                    //         height: 48,
                    //         child: Row(
                    //           mainAxisAlignment: MainAxisAlignment.center,
                    //           children: [
                    //             Padding(
                    //               padding: const EdgeInsets.only(left: 10),
                    //               child: Image.asset(
                    //                 'images/line_logo.png',
                    //                 width: 30,
                    //                 height: 30,
                    //               ),
                    //             ),
                    //             1.pw,
                    //             Text(
                    //               "Join with Line".tr,
                    //               textAlign: TextAlign.center,
                    //               style: const TextStyle(
                    //                 // color: primaryColor,
                    //                 color: ironColor,
                    //                 fontSize: 18,
                    //                 fontFamily: 'Montserrat',
                    //                 fontWeight: FontWeight.w700,
                    //                 letterSpacing: 0.18,
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),

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
                            try {
                              print("Initiating Google Sign-In process");
                              final result = await AuthScreenController.signInWithGoogle(context);
                              
                              if (result["success"] == true) {
                                print("Google Sign-In successful, checking email");
                                
                                if (AuthScreenController.googleEmail.value.isEmpty) {
                                  print("Error: Google email is empty after successful sign-in");
                                  showErrorMessage("Failed to get email from Google", colorError);
                                  loading(false);
                                  return;
                                }
                                
                                await AuthScreenController.checkEmail(AuthScreenController.googleEmail.value)
                                    .then((value) async {
                                  if (AuthScreenController.isCheckEmail.isTrue) {
                                    print("Email exists, proceeding with login");
                                    final body = {
                                      "email": AuthScreenController.googleEmail.value,
                                      "password": AuthScreenController.googleUid.value
                                    };
                                    
                                    try {
                                      bool loginSuccess = await AuthScreenController.login(context, body);
                                      if (loginSuccess) {
                                        print("Login successful, initiating node login");
                                        await AuthScreenController.nodeLoginGoogle(context);
                                        nextPage(NavigationPage());
                                      } else {
                                        print("Login failed");
                                        showErrorMessage("Login failed", colorError);
                                      }
                                    } catch (e) {
                                      print("Error during login: $e");
                                      showErrorMessage("Error during login: $e", colorError);
                                    }
                                  } else {
                                    print("Email doesn't exist, proceeding with signup");
                                    final body = {
                                      if (AuthScreenController.googleName.isNotEmpty)
                                        "name": AuthScreenController.googleName.value,
                                      if (AuthScreenController.googleEmail.isNotEmpty)
                                        "email": AuthScreenController.googleEmail.value,
                                      if (AuthScreenController.googleUid.isNotEmpty)
                                        "password": AuthScreenController.googleUid.value,
                                      if (AuthScreenController.googlePhoneNumber.isNotEmpty)
                                        "phone_number": AuthScreenController.googlePhoneNumber.value,
                                      "login_type": "google"
                                    };

                                    try {
                                      bool signupSuccess = await AuthScreenController.createAccount(context, body);
                                      if (signupSuccess) {
                                        final loginBody = {
                                          "email": AuthScreenController.googleEmail.value,
                                          "password": AuthScreenController.googleUid.value
                                        };
                                        
                                        bool loginSuccess = await AuthScreenController.login(context, loginBody);
                                        if (loginSuccess) {
                                          print("Login after signup successful");
                                          await AuthScreenController.nodeLoginGoogle(context);
                                          nextPage(NavigationPage());
                                        } else {
                                          print("Login after signup failed");
                                          showErrorMessage("Login failed after account creation", colorError);
                                        }
                                      } else {
                                        print("Signup failed");
                                        showErrorMessage("Account creation failed", colorError);
                                      }
                                    } catch (e) {
                                      print("Error during signup: $e");
                                      showErrorMessage("Error during signup: $e", colorError);
                                    }
                                  }
                                }).catchError((error) {
                                  print("Error checking email: $error");
                                  showErrorMessage("Error checking email: $error", colorError);
                                });
                              } else {
                                print("Google Sign-In failed: ${result["message"]}");
                                showErrorMessage("Google Sign-In failed: ${result["message"]}", colorError);
                              }
                            } catch (e) {
                              print("Exception in Google Sign-In flow: $e");
                              showErrorMessage("Error during Google Sign-In: $e", colorError);
                            } finally {
                              loading(false);
                            }
                          },
                          splashColor: headingOrange,
                          borderRadius: BorderRadius.circular(50),
                          child: Container(
                            height: 40,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Image.asset(
                                    'images/google.png',
                                    width: 23,
                                    height: 23,
                                  ),
                                ),
                                1.pw,
                                Text(
                                  "Join with Google".tr,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    // color: primaryColor,
                                    color: ironColor,
                                    fontSize: 17,
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
                              try {
                                loading(true);
                                await AuthScreenController.signInWithApple();
                                
                                print("appleEmail :: ${AuthScreenController.appleEmail.value}");
                                print("appleName :: ${AuthScreenController.appleName.value}");
                                print("appleUid :: ${AuthScreenController.appleUid.value}");
                                
                                // Check if we have at least UID (essential for authentication)
                                if (AuthScreenController.appleUid.value.isEmpty) {
                                  loading(false);
                                  Get.snackbar(
                                    "Error".tr,
                                    "Apple Sign-In failed. Please try again.".tr,
                                    backgroundColor: colorError,
                                    colorText: Colors.white,
                                  );
                                  return;
                                }
                                
                                // Handle case where email is not provided (normal for subsequent Apple Sign-Ins)
                                String emailToCheck = AuthScreenController.appleEmail.value;
                                if (emailToCheck.isEmpty) {
                                  print("No email provided by Apple (normal for subsequent sign-ins)");
                                  print("Attempting to find existing account by Apple UID: ${AuthScreenController.appleUid.value}");
                                  
                                  // Try to login first using Apple UID as this might be a returning user
                                  try {
                                    final nodeSuccess = await AuthScreenController.nodeLoginApple(context);
                                    if (nodeSuccess) {
                                      loading(false);
                                      Get.offAll(() => NavigationPage(index: 0));
                                      return;
                                    }
                                  } catch (e) {
                                    print("Node login failed, will try creating account: $e");
                                  }
                                  
                                  // If login failed, this might be a new user, so create account
                                  final body = {
                                    if (AuthScreenController.appleName.isNotEmpty)
                                      "name": AuthScreenController.appleName.value ?? ' ',
                                    if (AuthScreenController.appleUid.isNotEmpty)
                                      "password": AuthScreenController.appleUid.value,
                                    "login_type": "apple",
                                    "apple_uid": AuthScreenController.appleUid.value,
                                  };
                                  
                                  print("Creating Apple account without email, body: $body");
                                  
                                  try {
                                    final success = await AuthScreenController.createAccount(context, body);
                                    if (success) {
                                      final nodeSuccess = await AuthScreenController.nodeLoginApple(context);
                                      if (nodeSuccess) {
                                        loading(false);
                                        Get.offAll(() => NavigationPage(index: 0));
                                      } else {
                                        loading(false);
                                        Get.snackbar(
                                          "Error".tr,
                                          "Account created but login failed. Please try logging in manually.".tr,
                                          backgroundColor: colorError,
                                          colorText: Colors.white,
                                        );
                                      }
                                    } else {
                                      loading(false);
                                    }
                                  } catch (e) {
                                    loading(false);
                                    Get.snackbar(
                                      "Error".tr,
                                      "Account creation failed: ${e.toString()}".tr,
                                      backgroundColor: colorError,
                                      colorText: Colors.white,
                                    );
                                  }
                                  return;
                                }
                                
                                // If we have email, proceed with normal flow
                                AuthScreenController.checkEmail(emailToCheck).then((value) {
                                  if (AuthScreenController.isCheckEmail.isTrue) {
                                    print("Apple :: Login");
                                    final body = {
                                      "email": AuthScreenController.appleEmail.value,
                                      "password": AuthScreenController.appleUid.value
                                    };
                                    
                                    if (AuthScreenController.appleEmail.isNotEmpty) {
                                      AuthScreenController.login(context, body).then((value) {
                                        if (value) {
                                          AuthScreenController.nodeLoginApple(context);
                                          Get.to(() => NavigationPage(), transition: Transition.rightToLeft);
                                          loading(false);
                                        } else {
                                          loading(false);
                                        }
                                      });
                                    } else {
                                      loading(false);
                                    }
                                  } else {
                                    print("Apple :: SignUp");
                                    final body = {
                                      if (AuthScreenController.appleName.isNotEmpty)
                                        "name": AuthScreenController.appleName.value,
                                      if (AuthScreenController.appleEmail.isNotEmpty)
                                        "email": AuthScreenController.appleEmail.value,
                                      if (AuthScreenController.appleUid.isNotEmpty)
                                        "password": AuthScreenController.appleUid.value,
                                      "login_type": "apple"
                                    };
                                    print("Apple signup with email, body: $body");
                                    
                                    AuthScreenController.createAccount(context, body).then((value) {
                                      if (value) {
                                        AuthScreenController.nodeLoginApple(context);
                                        Get.to(() => NavigationPage(), transition: Transition.rightToLeft);
                                        loading(false);
                                      } else {
                                        loading(false);
                                      }
                                    });
                                  }
                                }).catchError((error) {
                                  loading(false);
                                  print("Email check error: $error");
                                  Get.snackbar(
                                    "Error".tr,
                                    "Failed to verify email. Please check your internet connection.".tr,
                                    backgroundColor: colorError,
                                    colorText: Colors.white,
                                  );
                                });
                                
                              } catch (e) {
                                loading(false);
                                print("Apple Sign-In error: $e");
                                Get.snackbar(
                                  "Error".tr,
                                  e.toString().replaceAll('Exception: ', ''),
                                  backgroundColor: colorError,
                                  colorText: Colors.white,
                                );
                              }
                            },
                            splashColor: headingOrange,
                            borderRadius: BorderRadius.circular(50),
                            child: Container(
                              height: 40,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Image.asset(
                                      'images/apple.png',
                                      width: 23,
                                      height: 23,
                                    ),
                                  ),
                                  1.pw,
                                  Text(
                                    "Join with Apple".tr,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      // color: primaryColor,
                                      color: ironColor,
                                      fontSize: 17,
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

  Future<void> _handleLineLogin() async {
    try {
      final result = await LineSDK.instance.login(
          scopes: ['profile', 'openid', 'email']
      ).then((value) {
        print("_handleLineLogin login value : ${value.data}");
        final profile = value.userProfile!;
        String email = "${profile.userId}@yokailine.com";
        String password = profile.userId.trim();
        String name = profile.displayName.trim();
        String phoneNumber = profile.displayName.trim().replaceAll(RegExp(r'[^0-9]'), '').substring(0, 10);

        final body = {
          "name": name,
          "email": email,
          "password": password,
          "phone_number": phoneNumber,
          "login_type": "user"
        };

        print("_handleLineLogin got invoked and received the response body : $body");

        // AuthScreenController.signUpWithFirebase(context, email, password).then((value) {
        //     if (value) {
        //       AuthScreenController.createAccount(
        //           context, body)
        //           .then((value) {
        //         final bodyData = {
        //           "name": name,
        //           "displayName": name,
        //           "yokaiName": name,
        //           "email": email,
        //           "password": password,
        //           "phoneNumber": phoneNumber,
        //           "loginType": "email"
        //         };
        //         AuthScreenController.nodeCreateAccount(context, bodyData).then((value) {});
        //
        //         final body = {
        //           "email": email,
        //           "password": password
        //         };
        //
        //         if (value) {
        //           AuthScreenController.login(context, body)
        //               .then((value) {
        //             if (value) {
        //               prefs.setString(LocalStorage.email, email);
        //               prefs.setString(LocalStorage.username, name);
        //               prefs.setString(LocalStorage.phonenumber, phoneNumber);
        //               nextPage(
        //                 ConfirmationScreen(
        //                   title: 'Account Created!'.tr,
        //                   message:
        //                   // 'We've sent you an email to confirm the details of your account.',
        //                   '',
        //                   buttonText: 'Start Reading'.tr,
        //                 ),
        //               );
        //               loading(false);
        //             } else {
        //               loading(false);
        //             }
        //           });
        //         } else {
        //           loading(false);
        //         }
        //       });
        //     } else {
        //       showErrorMessage(
        //           "Something went wrong".tr, colorError);
        //       loading(false);
        //     }
        //   },
        // );
        //

      },);

      print("_handleLineLogin result data : ${result.data}"
          "\nresult userProfile : ${result.userProfile}");

      if (result.userProfile != null) {
        final profile = result.userProfile!;
        final body = {
          // "email": profile.email ?? '',
          "name": profile.displayName,
          "line_id": profile.userId,
          "avatar": profile.pictureUrl ?? '',
          "email" : profile.userId
        };

        print("_handleLineLogin got invoked line credentials body : ${body}"
            "\nand profile data : ${profile.data}");

        // Call your backend API to create/login user
        await AuthScreenController.handleLineLogin(context, body);
      }
    } catch (e) {
      print('Line Login Error: $e');
      Get.snackbar(
        'Error',
        'Failed to login with LINE',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
