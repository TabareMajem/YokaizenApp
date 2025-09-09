import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/revenue_cat_config.dart';
import '../global.dart';
import '../main.dart';

class LanguageManager {
  static const String _tag = 'LanguageManager';

  // Change language and update all related services
  static Future<void> changeLanguage(String languageCode) async {
    try {
      print('[$_tag] Changing language to: $languageCode');

      // 1. Save to SharedPreferences
      await prefs.setString('language', languageCode);

      // 2. Create appropriate locale
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

      // 3. Update GetX locale
      Get.updateLocale(newLocale);
      print('[$_tag] Updated GetX locale to: ${newLocale.languageCode}_${newLocale.countryCode}');

      // 4. Update RevenueCat locale
      await RevenueCatConfig.updateLocale(languageCode);
      print('[$_tag] Updated RevenueCat locale to: $languageCode');

      // 5. Wait a moment for all updates to process
      await Future.delayed(const Duration(milliseconds: 300));

      print('[$_tag] Language change completed successfully');

    } catch (e) {
      print('[$_tag] Error changing language: $e');
    }
  }

  // Get current language
  static String getCurrentLanguage() {
    return prefs.getString('language') ?? 'en';
  }

  // Get current locale
  static Locale getCurrentLocale() {
    final languageCode = getCurrentLanguage();
    switch (languageCode) {
      case 'ja':
        return const Locale('ja', 'JP');
      case 'ko':
        return const Locale('ko', 'KR');
      case 'en':
      default:
        return const Locale('en', 'US');
    }
  }

  // Check if a language is supported
  static bool isLanguageSupported(String languageCode) {
    return ['en', 'ja', 'ko'].contains(languageCode);
  }

  // Get all supported languages
  static List<Map<String, String>> getSupportedLanguages() {
    return [
      {'code': 'en', 'name': 'English', 'nativeName': 'English'},
      {'code': 'ja', 'name': 'Japanese', 'nativeName': '日本語'},
      {'code': 'ko', 'name': 'Korean', 'nativeName': '한국어'},
    ];
  }
}