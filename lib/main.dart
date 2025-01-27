import 'dart:io';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:yokai_quiz_app/Widgets/splash_screen.dart';
import 'package:yokai_quiz_app/global.dart';
import 'package:yokai_quiz_app/language/app_localization.dart';
import 'package:yokai_quiz_app/util/constants.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
// SharedPreferences? prefs;
// const String appName = "B.AI";

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  prefs = await SharedPreferences.getInstance();
  await LineSDK.instance.setup('2006749396',universalLink: "https://admin.yokaizenteams.com/").then((_) {
    print('LineSDK Prepared');
  });
  
  if (Platform.isAndroid) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyDqtImJuX5KXz3woxkhpWTbTiTkU2J-W8U",
            projectId: "yokaizen-43f63",
            messagingSenderId: "543257928924",
            appId: "1:543257928924:android:b374bd4fc856d39e08c019"));
  } else {
    await Firebase.initializeApp();
  }
  prefs = await SharedPreferences.getInstance();

  await dotenv.load(fileName: '.env');

  runApp(const MyApp());
}

late SharedPreferences prefs;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    checkDebugMode();
    return GetMaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      translations: AppLocalization(),
      supportedLocales: const [
        Locale('en'),
        Locale('ja'),
        Locale('ko'),
      ],
      locale: constants.locale,
      fallbackLocale: const Locale('es', 'US'),
      theme: ThemeData(useMaterial3: false),
      debugShowCheckedModeBanner: false,
      // color: appColor,
      // home: TopicalExam_page(subjectName: "History",));
      home: const SplashScreen(),
    );
  }
}
