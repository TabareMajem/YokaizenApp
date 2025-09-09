library my_prj.globals;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../main.dart';

const double defaultPadding = 8;

// class constants {
//   static String? appYokaiPath;
//   static String selectedYokai = "tanuki";
//   static String deviceLanguage = "en";
//   static String lineChanelID = "en";
//   // static Locale locale = const Locale("en"); // Fixed: Remove country code to match app_localization.dart
//   static double radius = 12;
//   // static double buttonRadius = 28.r;
//   static double thickness = 2;
//   static final borderRadius = BorderRadius.circular(radius);
//   // static final buttonBorderRadius = BorderRadius.circular(buttonRadius);
//   static const defaultPadding = 12.0;
//   static String flutterLongText =
//       "Miusov, as a man man of breeding and deilcacy, could "
//       "not but feel some inwrd qualms, when he reached the Father Superior's with "
//       "Ivan: he felt ashamed of havin lost his temper. He felt that he ought to "
//       "have disdaimed that despicable wretch, Fyodor Pavlovitch, too much to have "
//       "been upset by him in Father Zossima's cell, and so to have "
//       "forgotten himself.";
//   static String flutterShortText =
//       "Note that UltimateSpell displays the text in the "
//       "dialog box sentence-by-sentence just like Microsoft Word.";
//
//
//   static Locale get locale {
//     final savedLanguage = prefs?.getString('language') ?? 'en';
//     switch (savedLanguage) {
//       case 'ja':
//         return const Locale('ja', 'JP');
//       case 'ko':
//         return const Locale('ko', 'KR');
//       case 'en':
//       default:
//         return const Locale('en', 'US');
//     }
//   }
//
//
//   static String get deviceCountry {
//     return locale.countryCode ?? '';
//   }
//
//   static String get fullLocaleString {
//     return '${locale.languageCode}_${locale.countryCode}';
//   }
//
//   // Method to change language and update GetX locale
//   static Future<void> changeLanguage(String languageCode) async {
//     await prefs?.setString('language', languageCode);
//
//     Locale newLocale;
//     switch (languageCode) {
//       case 'ja':
//         newLocale = const Locale('ja', 'JP');
//         break;
//       case 'ko':
//         newLocale = const Locale('ko', 'KR');
//         break;
//       case 'en':
//       default:
//         newLocale = const Locale('en', 'US');
//         break;
//     }
//
//     // Update GetX locale
//     Get.updateLocale(newLocale);
//
//     // Force RevenueCat to refresh with new locale
//     await _updateRevenueCatLocale(languageCode);
//   }
//
//   // Helper method to update RevenueCat locale
//   static Future<void> _updateRevenueCatLocale(String languageCode) async {
//     try {
//       await Purchases.setAttributes({
//         'language': languageCode,
//         'locale': '${languageCode}_${languageCode.toUpperCase()}',
//         'preferred_language': languageCode == 'ja' ? 'Japanese' :
//         languageCode == 'ko' ? 'Korean' : 'English',
//         'device_locale': languageCode,
//         'app_locale': languageCode,
//         'last_locale_update': DateTime.now().toIso8601String(),
//       });
//
//       // Invalidate cache to force fresh localized content
//       await Purchases.invalidateCustomerInfoCache();
//
//       print('Constants: Updated RevenueCat locale to $languageCode');
//     } catch (e) {
//       print('Constants: Error updating RevenueCat locale: $e');
//     }
//   }
// }

class constants {
  static String? appYokaiPath;
  static String selectedYokai = "tanuki";
  static String lineChanelID = "en";
  static double radius = 12;
  static double thickness = 2;
  static final borderRadius = BorderRadius.circular(radius);
  static const defaultPadding = 12.0;
  static String flutterLongText =
      "Miusov, as a man man of breeding and deilcacy, could "
      "not but feel some inwrd qualms, when he reached the Father Superior's with "
      "Ivan: he felt ashamed of havin lost his temper. He felt that he ought to "
      "have disdaimed that despicable wretch, Fyodor Pavlovitch, too much to have "
      "been upset by him in Father Zossima's cell, and so to have "
      "forgotten himself.";
  static String flutterShortText =
      "Note that UltimateSpell displays the text in the "
      "dialog box sentence-by-sentence just like Microsoft Word.";

  // Get/Set device language
  static String get deviceLanguage {
    return prefs.getString('language') ?? 'en';
  }

  static set deviceLanguage(String value) {
    prefs.setString('language', value);
    print('Constants: deviceLanguage set to $value');
  }

  // Get locale based on saved language
  static Locale get locale {
    final savedLanguage = deviceLanguage;
    switch (savedLanguage) {
      case 'ja':
        return const Locale('ja', 'JP');
      case 'ko':
        return const Locale('ko', 'KR');
      case 'en':
      default:
        return const Locale('en', 'US');
    }
  }

  static String get deviceCountry {
    return locale.countryCode ?? '';
  }

  static String get fullLocaleString {
    return '${locale.languageCode}_${locale.countryCode}';
  }

  // Method to change language and update everything
  static Future<void> changeLanguage(String languageCode) async {
    try {
      print('Constants: Changing language to $languageCode');

      // 1. Save to SharedPreferences
      await prefs.setString('language', languageCode);

      // 2. Update deviceLanguage
      deviceLanguage = languageCode;

      // 3. Create new locale
      Locale newLocale;
      switch (languageCode) {
        case 'ja':
          newLocale = const Locale('ja', 'JP');
          break;
        case 'ko':
          newLocale = const Locale('ko', 'KR');
          break;
        case 'en':
        default:
          newLocale = const Locale('en', 'US');
          break;
      }

      // 4. Update GetX locale
      Get.updateLocale(newLocale);
      print('Constants: Updated GetX locale to $newLocale');

      // 5. Update RevenueCat locale
      await _updateRevenueCatLocale(languageCode);

    } catch (e) {
      print('Constants: Error changing language: $e');
    }
  }

  // Helper method to update RevenueCat locale
  static Future<void> _updateRevenueCatLocale(String languageCode) async {
    try {
      print('Constants: Updating RevenueCat locale to $languageCode');

      await Purchases.setAttributes({
        'language': languageCode,
        'locale': '${languageCode}_${languageCode.toUpperCase()}',
        'preferred_language': languageCode == 'ja' ? 'Japanese' :
        languageCode == 'ko' ? 'Korean' : 'English',
        'device_locale': languageCode,
        'app_locale': languageCode,
        'user_language_preference': languageCode,
        'paywall_language': languageCode,
        'last_locale_update': DateTime.now().toIso8601String(),
      });

      // Invalidate cache to force fresh localized content
      await Purchases.invalidateCustomerInfoCache();

      print('Constants: Successfully updated RevenueCat locale to $languageCode');
    } catch (e) {
      print('Constants: Error updating RevenueCat locale: $e');
    }
  }
}

const String termsConditionUrl =
    "https://xpertsolutions.online/playnamic/terms.php";
const String contactUsUrl =
    "https://xpertsolutions.online/playnamic/contactus.php";
const String privacyPolicyUrl =
    "https://xpertsolutions.online/playnamic/privacypolicy.php";

const String authKey =
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c";

class TrueCaller {
  static const String appKey = "19ws300cadc7ed1984f99bde51e159d0c8a47";
  static const String fingerprint = "4fd9bd7f72ba76921406b50d9b5b047f46fcba06";
}

const String favPopupText =
    "I would like to receive commercial communications from the club with"
    "offers and news. I undersatand that my personal data will be"
    "communicated to Boca Village for the managemment of the reservation.this "
    "being the legal basis for the execution of the service provision contract."
    "i will be able to exercise my rights,among others,of access,rectification "
    "and suppression by contacting the sports installation.";




