import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:yokai_quiz_app/Widgets/new_button.dart';
import 'package:yokai_quiz_app/Widgets/progressHud.dart';
import 'package:yokai_quiz_app/api/local_storage.dart';
import 'package:yokai_quiz_app/main.dart';
import 'package:yokai_quiz_app/screens/Authentication/login_screen.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/const.dart';
import 'package:yokai_quiz_app/util/constants.dart';

import '../../Widgets/textfield.dart';
import '../../global.dart';
import '../../util/text_styles.dart';
import '../Authentication/controller/auth_screen_controller.dart';
import 'confirmation_screen.dart';
import 'controller/create_account_controller.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccountScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
  }

  // final FirebaseAuth _auth = FirebaseAuth.instance;
  // final GoogleSignIn _googleSignIn = GoogleSignIn();
  //
  // Future<void> signInWithGoogle() async {
  //   try {
  //     final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
  //     if (googleUser == null) {
  //       // The user canceled the sign-in
  //       print('The user canceled the sign-in');
  //       return;
  //     }
  //     final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  //     final AuthCredential credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );
  //
  //     final UserCredential userCredential = await _auth.signInWithCredential(credential);
  //     final User? user = userCredential.user;
  //
  //     if (user != null) {
  //       print('Signed in as ${user.displayName}');
  //     }
  //   } catch (e) {
  //     print('Error signing in with Google: $e');
  //   }
  // }
  ///

  bool setobscureText = true;

  final List<String> school = <String>[
    "Select".tr,
    "APS".tr,
    "AFS".tr,
    "DAV".tr,
  ];
  String selectedSchool = "Select";
  final List<String> grade = <String>[
    "Select grade".tr,
    "Standard 1".tr,
    "Standard 2".tr,
    "Standard 3".tr,
    "Standard 4".tr,
    "Standard 5".tr,
    "Standard 6".tr,
    "Standard 7".tr,
    "Form 1".tr,
    "Form 2".tr,
    "Form 3".tr,
    "Form 4".tr,
    // "Grade 12",
  ];
  String selectedGrade = "Select grade".tr;
  RxBool loading = false.obs;
  final _alphaOnlyFormatter =
      FilteringTextInputFormatter(RegExp(r'[a-zA-Z\s]'), allow: true);

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
                horizontal: MediaQuery.of(context).size.width / 15,
              ),
              child: Column(
                children: <Widget>[
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: screenWidth / 3.5,
                          right: screenWidth / 3.5,
                          top: screenHeight / 13),
                      child: Container(
                        // width: 150,
                        width: screenWidth / 1.6,
                        // height: 95,
                        height: screenHeight / 8.1,
                        // decoration: const BoxDecoration(
                        //   image: DecorationImage(
                        //     image: AssetImage('images/appLogo_small.png'),
                        //     // fit: BoxFit.cover,
                        //   ),
                        // ),
                        child: Image.asset('images/appLogo_yokai.png'),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight / 30),
                  Center(
                      child: Text(
                    'Create Account'.tr,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.normalBold22
                        .copyWith(color: headingOrange),
                  )),
                  2.ph,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Name'.tr,
                                style: AppTextStyle.normalRegular14
                                    .copyWith(color: labelColor),
                              ),
                              0.5.ph,
                              TextFeildStyle(
                                onChanged: (value) {
                                  _validateName(value);
                                },
                                controller: AuthController.nameController,
                                hintText: 'Enter Name'.tr,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(color: greyborder),
                                ),
                                inputFormatters: [_alphaOnlyFormatter],
                                hintStyle: AppTextStyle.normalRegular10
                                    .copyWith(color: hintText),
                                border: InputBorder.none,
                              ),
                              if (_errorText != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 20,
                                    top: 3,
                                  ),
                                  child: Text(
                                    _errorText!,
                                    style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                        fontFamily: "Montserrat"),
                                  ),
                                ),
                              2.5.ph,
                              Text(
                                'Email'.tr,
                                style: AppTextStyle.normalRegular14
                                    .copyWith(color: labelColor),
                              ),
                              0.5.ph,
                              TextFeildStyle(
                                hintText: 'Enter email'.tr,
                                controller: AuthController.emailController,
                                onChanged: (p0) {
                                  validateEmail(p0);
                                },
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
                                        fontSize: 12,
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
                                hintText: '●●●●●●●',
                                onChanged: (p0) {
                                  _validatePassword(p0);
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
                                        ? "icons/closepasswordeye_icon.svg"
                                        : "icons/password.svg",
                                    color: primaryColor,
                                  ),
                                ),
                                textAlignVertical: TextAlignVertical.center,
                                controller: AuthController.passwordController,
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
                                        fontSize: 12,
                                        fontFamily: "Montserrat"),
                                  ),
                                ),
                              2.5.ph,
                              Text(
                                'Phone No.'.tr,
                                style: AppTextStyle.normalRegular14
                                    .copyWith(color: labelColor),
                              ),
                              0.5.ph,
                              IntlPhoneField(
                                initialCountryCode: 'JP',
                                disableLengthCheck: true,
                                controller: AuthController.numberController,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.only(
                                      left: 12, right: 10),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: greyborder),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: greyborder),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: greyborder),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  hintStyle: AppTextStyle.normalRegular14
                                      .copyWith(color: hintColor),
                                  labelStyle: AppTextStyle.normalRegular14
                                      .copyWith(color: textColor),
                                  border: OutlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: greyborder),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9]')),
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                keyboardType: TextInputType.phone,
                                languageCode: "en",
                                onChanged: (phone) {
                                  _validatePhoneNumber(phone.number);
                                  setState(() {});
                                  print(phone.completeNumber);
                                  print("phone error :: $_errorphone");
                                  AuthController.countryCodeController =
                                      phone.countryCode;
                                },
                                onCountryChanged: (country) {
                                  setState(() {
                                    AuthController.countryCodeController =
                                        country.code.toString();
                                  });
                                },
                              ),
                              Builder(
                                builder: (BuildContext context) {
                                  if (_errorphone != null) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20, top: 3),
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
                              2.5.ph,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: constants.defaultPadding * 2,
                      ),

                      CustomButton(
                        text: "Create Account !".tr,
                        // onPressed: () async {
                        //   loading(true);
                        //   final List<TextEditingController> controllerList = [
                        //     AuthController.nameController,
                        //     AuthController.emailController,
                        //     AuthController.passwordController,
                        //     AuthController.numberController,
                        //   ];
                        //   final List<String> fieldsName = [
                        //     'Name',
                        //     'Email',
                        //     'Password',
                        //     'Number'
                        //   ];
                        //   bool valid = validateMyFields(
                        //       context, controllerList, fieldsName);
                        //   if (!valid) {
                        //     loading(false);
                        //     return;
                        //   }
                        //   print(
                        //       'passwordController :: ${AuthController.passwordController.text.length}');
                        //   if (AuthController.passwordController.text.length <
                        //       6) {
                        //     showErrorMessage(
                        //         'Password must be between 6 and 10 characters long'
                        //             .tr,
                        //         colorError);
                        //     loading(false);
                        //     return;
                        //   }
                        //   final body = {
                        //     "name": AuthController.nameController.text.trim(),
                        //     "email": AuthController.emailController.text.trim(),
                        //     "password":
                        //         AuthController.passwordController.text.trim(),
                        //     "phone_number":
                        //         "${AuthController.countryCodeController} ${AuthController.numberController.text.trim()}",
                        //     "login_type": "user"
                        //   };
                        //   AuthScreenController.signUpWithFirebase(
                        //           context,
                        //           AuthController.emailController.text.trim(),
                        //           AuthController.passwordController.text.trim())
                        //       .then(
                        //     (value) {
                        //       if (value=="true") {
                        //         AuthScreenController.createAccount(
                        //                 context, body)
                        //             .then((value) {
                        //           final bodyData = {
                        //             "name": AuthController.nameController.text
                        //                 .trim(),
                        //             "displayName": AuthController
                        //                 .nameController.text
                        //                 .trim(),
                        //             "yokaiName": AuthController
                        //                 .nameController.text
                        //                 .trim(),
                        //             "email": AuthController.emailController.text
                        //                 .trim(),
                        //             "password": AuthController
                        //                 .passwordController.text
                        //                 .trim(),
                        //             "phoneNumber": AuthController
                        //                 .numberController.text
                        //                 .trim(),
                        //             "loginType": "email"
                        //           };
                        //           AuthScreenController.nodeCreateAccount(
                        //                   context, bodyData)
                        //               .then((value) {});
                        //           final body = {
                        //             "email": AuthController.emailController.text,
                        //             "password": AuthController.passwordController.text
                        //           };
                        //
                        //           if (value) {
                        //             AuthScreenController.login(context, body)
                        //                 .then((value) {
                        //               if (value) {
                        //                 prefs.setString(LocalStorage.email, AuthController.emailController.text);
                        //                 prefs.setString(LocalStorage.username, AuthController.nameController.text);
                        //                 prefs.setString(LocalStorage.phonenumber, AuthController.numberController.text);
                        //                 customPrint("create account screen successfully logged in till flask");
                        //                 AuthScreenController.nodeLogin(context, body).then((value) {
                        //                   nextPage(
                        //                     ConfirmationScreen(
                        //                       title: 'Account Created!'.tr,
                        //                       message:
                        //                       // 'We’ve sent you an email to confirm the details of your account.',
                        //                       '',
                        //                       buttonText: 'Start Reading'.tr,
                        //                     ),
                        //                   );
                        //                 });
                        //                 AuthController.nameController.clear();
                        //                 AuthController.emailController.clear();
                        //                 AuthController.passwordController
                        //                     .clear();
                        //                 AuthController.numberController.clear();
                        //                 loading(false);
                        //               } else {
                        //                 loading(false);
                        //               }
                        //             });
                        //           } else {
                        //             loading(false);
                        //           }
                        //         });
                        //       } else {
                        //         if(value.toString().contains("The email address is already in use by another account")) {
                        //           showErrorMessage("$value".tr, colorError);
                        //         } else {
                        //           showErrorMessage("$value".tr, colorError);
                        //         }
                        //
                        //         loading(false);
                        //       }
                        //     },
                        //   );
                        // },
                        onPressed: () async {
                          loading(true);
                          final List<TextEditingController> controllerList = [
                            AuthController.nameController,
                            AuthController.emailController,
                            AuthController.passwordController,
                            AuthController.numberController,
                          ];
                          final List<String> fieldsName = [
                            'Name',
                            'Email',
                            'Password',
                            'Number'
                          ];
                          bool valid = validateMyFields(
                              context, controllerList, fieldsName);
                          if (!valid) {
                            loading(false);
                            return;
                          }
                          print(
                              'passwordController :: ${AuthController.passwordController.text.length}');
                          if (AuthController.passwordController.text.length <
                              6) {
                            showErrorMessage(
                                'Password must be between 6 and 10 characters long'
                                    .tr,
                                colorError);
                            loading(false);
                            return;
                          }
                          final body = {
                            "name": AuthController.nameController.text.trim(),
                            "email": AuthController.emailController.text.trim(),
                            "password":
                            AuthController.passwordController.text.trim(),
                            "phone_number":
                            "${AuthController.countryCodeController} ${AuthController.numberController.text.trim()}",
                            "login_type": "user"
                          };


                          AuthScreenController.createAccount(
                              context, body)
                              .then((value) {
                                if(value) {
                                  final bodyData = {
                                    "name": AuthController.nameController.text
                                        .trim(),
                                    "displayName": AuthController
                                        .nameController.text
                                        .trim(),
                                    "yokaiName": AuthController
                                        .nameController.text
                                        .trim(),
                                    "email": AuthController.emailController.text
                                        .trim(),
                                    "password": AuthController
                                        .passwordController.text
                                        .trim(),
                                    "phoneNumber": AuthController
                                        .numberController.text
                                        .trim(),
                                    "loginType": "email"
                                  };
                                  AuthScreenController.nodeCreateAccount(
                                      context, bodyData)
                                      .then((value) {
                                    AuthScreenController.signUpWithFirebase(
                                        context, AuthController.emailController.text.trim(),
                                        AuthController.passwordController.text.trim()).then((value) {
                                      if (value=="true") {
                                        final body = {
                                          "email": AuthController.emailController.text,
                                          "password": AuthController.passwordController.text
                                        };
                                        AuthScreenController.login(context, body)
                                            .then((value) {
                                          if (value) {
                                            prefs.setString(LocalStorage.email, AuthController.emailController.text);
                                            prefs.setString(LocalStorage.username, AuthController.nameController.text);
                                            prefs.setString(LocalStorage.phonenumber, AuthController.numberController.text);
                                            customPrint("create account screen successfully logged in till flask");
                                            AuthScreenController.nodeLogin(context, body).then((value) {
                                              nextPage(
                                                ConfirmationScreen(
                                                  title: 'Account Created!'.tr,
                                                  message:
                                                  // 'We’ve sent you an email to confirm the details of your account.',
                                                  '',
                                                  buttonText: 'Start Reading'.tr,
                                                ),
                                              );
                                            });
                                            AuthController.nameController.clear();
                                            AuthController.emailController.clear();
                                            AuthController.passwordController
                                                .clear();
                                            AuthController.numberController.clear();
                                            loading(false);
                                          } else {
                                            loading(false);
                                          }
                                        });

                                      } else {
                                        if(value.toString().contains("The email address is already in use by another account")) {
                                          showErrorMessage("$value".tr, colorError);
                                        } else {
                                          showErrorMessage("$value".tr, colorError);
                                        }
                                        loading(false);
                                      }
                                    });
                                  });
                                }
                                else {
                                  loading(false);
                                }
                          });


                        },
                      ),

                      const SizedBox(
                        height: constants.defaultPadding * 1.5,
                      ),
                      const Divider(),
                      2.pw,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account!".tr,
                            style: AppTextStyle.normalRegular14
                                .copyWith(color: colorSubHeadingText),
                          ),
                          1.pw,
                          InkWell(
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return LoginScreen();
                              }));
                            },
                            child: Center(
                              child: Text(
                                'Log In'.tr,
                                style: textStyle.button,
                              ),
                            ),
                          ),
                        ],
                      ),
                      4.ph,
                      // 4.ph,
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  ///
  String? _errorTextpass;
  String? _errorTextEmail;
  String? _errorText;

  String? _errorphone;

  void _validatePhoneNumber(String phoneNumber) {
    if (phoneNumber.length < 9) {
      setState(() {
        _errorphone = 'Enter a valid number'.tr;
      });
    } else {
      setState(() {
        _errorphone = null;
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

  void _validateName(String value) {
    var nameNonNullValue = value.trim();
    if (nameNonNullValue.isEmpty) {
      setState(() {
        _errorText = "Name is required".tr;
      });
    } else if (containsNumbers(value)) {
      setState(() {
        _errorText = "Don't allow numbers".tr;
      });
    } else {
      setState(() {
        _errorText = null;
      });
    }
  }

  bool containsNumbers(String value) {
    return value.contains(RegExp(r'[0-9]'));
  }

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
