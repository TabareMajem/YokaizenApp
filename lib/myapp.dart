// import 'package:flutter/material.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:get/get_navigation/src/root/get_material_app.dart';
// import 'package:yokai_quiz_app/util/constants.dart';
//
// import 'Widgets/splash_screen.dart';
// import 'global.dart';
// import 'language/app_localization.dart';
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     checkDebugMode();
//     return GetMaterialApp(
//       localizationsDelegates: const [
//         GlobalMaterialLocalizations.delegate,
//         GlobalWidgetsLocalizations.delegate,
//         GlobalCupertinoLocalizations.delegate,
//       ],
//       translations: AppLocalization(),
//       supportedLocales: const [
//         Locale('en'),
//         Locale('ja'),
//         Locale('ko'),
//       ],
//       locale: constants.locale,
//       fallbackLocale: const Locale('en'), // Fixed: Use English as fallback instead of Spanish
//       theme: ThemeData(useMaterial3: false),
//       debugShowCheckedModeBanner: false,
//       // color: appColor,
//       // home: TopicalExam_page(subjectName: "History",));
//       home: const SplashScreen(),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get.dart';
import 'package:yokai_quiz_app/util/constants.dart';

import 'Widgets/splash_screen.dart';
import 'global.dart';
import 'language/app_localization.dart';

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
        Locale('en', 'US'),  // Add country codes for better locale detection
        Locale('ja', 'JP'),
        Locale('ko', 'KR'),
      ],
      locale: constants.locale,
      fallbackLocale: const Locale('en', 'US'),

      // Add locale resolution callback for better locale handling
      localeResolutionCallback: (locale, supportedLocales) {
        print('MyApp: Device locale: $locale');
        print('MyApp: Supported locales: $supportedLocales');

        // Check if the current locale is supported
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            print('MyApp: Using locale: $supportedLocale');
            return supportedLocale;
          }
        }

        // If not supported, use fallback
        print('MyApp: Using fallback locale: ${supportedLocales.first}');
        return supportedLocales.first;
      },

      theme: ThemeData(useMaterial3: false),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}