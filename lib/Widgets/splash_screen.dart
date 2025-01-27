import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yokai_quiz_app/screens/Authentication/login_screen.dart';
import 'package:yokai_quiz_app/screens/Settings/view/language_page.dart';
import 'package:yokai_quiz_app/util/constants.dart';
import '../api/local_storage.dart';
import '../main.dart';
import '../screens/navigation/view/navigation.dart';
import 'package:permission_handler/permission_handler.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    _navigateToNextScreen();
    super.initState();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2));

    final pref = await SharedPreferences.getInstance();
    constants.appYokaiPath = pref.getString('yokaiImage');

    bool isLoggedIn = prefs.getBool(LocalStorage.isLogin) ?? false;

    print("isLogin :: ${prefs.getBool(LocalStorage.isLogin)}");
    print("isLoggedIn :: $isLoggedIn");
    // isLoggedIn
    //     ? Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
    //         builder: (context) {
    //           return NavigationPage();
    //         },
    //       ), (route) => false)
    //     :
    // bool firstRun = await IsFirstRun.isFirstRun();
    await [
      Permission.storage,
      Permission.notification,
      Permission.camera,
      Permission.microphone,
    ].request();
    if (prefs.getBool(LocalStorage.isLogin) == false) {
      Get.to(
        () => const LanguageSetting(
          isFromSplashScreen: true,
        ),
      );
    } else {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
        builder: (context) {
          return (prefs.getBool(LocalStorage.isLogin) == true)
              ? NavigationPage()
              : LoginScreen();
        },
      ), (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF413B45),
              Color(0xFF1D1B26),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Image.asset('images/applogoBig_yokai.png'),
        ),
      ),
    );
  }
}
