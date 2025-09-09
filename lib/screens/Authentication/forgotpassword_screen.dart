import 'package:flutter/material.dart';
import 'package:yokai_quiz_app/Widgets/new_button.dart';
import 'package:yokai_quiz_app/global.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/const.dart';
import 'package:yokai_quiz_app/util/text_styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../Widgets/textfield.dart';
import '../create_account/confirmation_screen.dart';
import 'controller/auth_screen_controller.dart';

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
    super.initState();
    phoneNoController.clear();
  }

  String? studentId;
  String selectedCountryCode = '';
  bool _isLoading = false;
  String? _authProviderInfo;

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
                'We will help you recover your account. Enter your email address below.'
                    .tr,
                textAlign: TextAlign.center,
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
                        // Clear provider info when email changes
                        setState(() {
                          _authProviderInfo = null;
                        });
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
                    // Show authentication provider information
                    if (_authProviderInfo != null)
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 20,
                          top: 8,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _authProviderInfo!.contains('Google') 
                                ? Colors.blue.withOpacity(0.1)
                                : _authProviderInfo!.contains('Apple')
                                    ? Colors.black.withOpacity(0.1)
                                    : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _authProviderInfo!.contains('Google') 
                                  ? Colors.blue.withOpacity(0.3)
                                  : _authProviderInfo!.contains('Apple')
                                      ? Colors.black.withOpacity(0.3)
                                      : Colors.orange.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _authProviderInfo!.contains('Google') 
                                    ? Icons.account_circle
                                    : _authProviderInfo!.contains('Apple')
                                        ? Icons.apple
                                        : Icons.email,
                                color: _authProviderInfo!.contains('Google') 
                                    ? Colors.blue
                                    : _authProviderInfo!.contains('Apple')
                                        ? Colors.black
                                        : Colors.orange,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _authProviderInfo!,
                                  style: TextStyle(
                                    color: _authProviderInfo!.contains('Google') 
                                        ? Colors.blue.shade700
                                        : _authProviderInfo!.contains('Apple')
                                            ? Colors.black
                                            : Colors.orange.shade700,
                                    fontSize: 12,
                                    fontFamily: "Montserrat",
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
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
                    text: _isLoading ? "Checking...".tr : "Check Account".tr,
                    onPressed: _isLoading ? () {} : () {
                      _checkAccountAndHandleReset();
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

  Future<void> _checkAccountAndHandleReset() async {
    if (_errorTextEmail != null || emailController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
      _authProviderInfo = null;
    });

    try {
      final email = emailController.text.trim();
      
      // First, check if the user exists in Firebase and what provider they used
      final authProviderInfo = await _checkAuthProvider(email);
      
      if (authProviderInfo != null) {
        setState(() {
          _authProviderInfo = authProviderInfo;
        });

        // Show appropriate dialog based on provider
        await _showProviderSpecificDialog(authProviderInfo, email);
      } else {
        // User doesn't exist, show error
        showErrorMessage(
          "No account found with this email".tr,
          colorError
        );
      }
    } catch (e) {
      showErrorMessage(
        "An error occurred while checking your account. Please try again.".tr,
        colorError
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String?> _checkAuthProvider(String email) async {
    try {
      // Try to fetch user by email (this will work if user exists)
      final methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      
      if (methods.isNotEmpty) {
        if (methods.contains('google.com')) {
          return "This email is registered with a Google account";
        } else if (methods.contains('password')) {
          return "This email is registered with email/password";
        } else if (methods.contains('apple.com')) {
          return "This email is registered with an Apple account";
        } else {
          return "This account exists but uses a different sign-in method.";
        }
      }
      return null;
    } catch (e) {
      print("Error checking auth provider: $e");
      return null;
    }
  }

  Future<void> _showProviderSpecificDialog(String providerInfo, String email) async {
    if (providerInfo.contains('Google')) {
      // Show dialog for Google users
      await _showGoogleUserDialog(email);
    } else if (providerInfo.contains('email/password')) {
      // Proceed with password reset for email/password users
      await _proceedWithPasswordReset(email);
    } else if (providerInfo.contains('Apple')) {
      // Show dialog for Apple users
      await _showAppleUserDialog(email);
    } else {
      // Show generic dialog for other providers
      await _showGenericProviderDialog(providerInfo, email);
    }
  }

  Future<void> _showGoogleUserDialog(String email) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.account_circle, color: Colors.blue, size: 24),
              const SizedBox(width: 8),
              Text('Account type detected'.tr),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This email is registered with a Google account'.tr,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Text(
                'Please use Google Sign-In to access your account'.tr,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to login screen
              },
              child: Text('Go Back'.tr),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to login screen with Google sign-in option
                Navigator.of(context).pop();
                // You can add navigation to login screen here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text('Sign in with Google'.tr),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAppleUserDialog(String email) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.apple, color: Colors.black, size: 24),
              const SizedBox(width: 8),
              Text('Account type detected'.tr),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This email is registered with an Apple account'.tr,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Text(
                'Please use Apple Sign-In to access your account'.tr,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to login screen
              },
              child: Text('Go Back'.tr),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to login screen with Apple sign-in option
                Navigator.of(context).pop();
                // You can add navigation to login screen here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: Text('Sign in with Apple'.tr),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showGenericProviderDialog(String providerInfo, String email) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange, size: 24),
              const SizedBox(width: 8),
              Text('Account type detected'.tr),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your account was created using a different sign-in method.'.tr,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Text(
                'Please use the same sign-in method you used when creating your account.'.tr,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'.tr),
            ),
          ],
        );
      },
    );
  }

  Future<void> _proceedWithPasswordReset(String email) async {
    try {
      final success = await AuthScreenController.forgotPasswordWithFirebase(
        context, 
        email
      );
      
      if (success) {
        nextPage(
          ConfirmationScreen(
            title: 'Reset Link Sent !'.tr,
            email: email,
            message: 'Please check your registered email for the password reset link and steps. \n\nYou can log in with the new password once it has been reset. '.tr,
            buttonText: 'Log In'.tr,
          ),
        );
      }
    } catch (e) {
      showErrorMessage(
        "Failed to send reset email. Please try again.".tr,
        colorError
      );
    }
  }
}
