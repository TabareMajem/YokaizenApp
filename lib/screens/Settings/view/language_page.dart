// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
// import 'package:purchases_flutter/purchases_flutter.dart';
// import 'package:yokai_quiz_app/Widgets/new_button.dart';
// import 'package:yokai_quiz_app/Widgets/splash_screen.dart';
// import 'package:yokai_quiz_app/screens/Authentication/login_screen.dart';
// import 'package:yokai_quiz_app/screens/Settings/controller/setting_controller.dart';
// import 'package:yokai_quiz_app/util/colors.dart';
// import 'package:yokai_quiz_app/util/const.dart';
// import 'package:yokai_quiz_app/util/constants.dart';
// import 'package:yokai_quiz_app/util/text_styles.dart';
//
// class LanguageSetting extends StatefulWidget {
//   final bool? isFromSplashScreen;
//   const LanguageSetting({super.key, this.isFromSplashScreen});
//
//   @override
//   State<LanguageSetting> createState() => _LanguageSettingState();
// }
//
// class _LanguageSettingState extends State<LanguageSetting> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         // Replaced with SingleChildScrollView for scrolling behavior
//         child: Container(
//           padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               GestureDetector(
//                 onTap: () {
//                   Navigator.pop(context);
//                 },
//                 child: Row(
//                   children: [
//                     SvgPicture.asset('icons/arrowLeft.svg'),
//                     Text(
//                       "Language".tr,
//                       style:
//                           AppTextStyle.normalBold20.copyWith(color: coral500),
//                     ),
//                   ],
//                 ),
//               ),
//               3.ph,
//               Text('Suggested'.tr, style: AppTextStyle.normalBold16),
//               2.ph,
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     "English (UK)".tr,
//                     style: AppTextStyle.normalBold14
//                         .copyWith(fontWeight: FontWeight.normal),
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       constants.deviceLanguage = "en";
//                       constants.locale = const Locale('en'); // Fixed: Update constants.locale too
//                       Get.updateLocale(
//                         const Locale('en'),
//                       );
//                       SettingController.prilmaryLanguage.value = "English (UK)";
//                       Get.to(() => const SplashScreen());
//                     },
//                     child: Container(
//                       margin: const EdgeInsets.symmetric(vertical: 5),
//                       width: 20,
//                       height: 20,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(
//                           color: indigo700,
//                           width: SettingController.prilmaryLanguage.value ==
//                                   "English (UK)"
//                               ? 4.0
//                               : 1.0,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               3.ph,
//               Text('Other'.tr, style: AppTextStyle.normalBold16),
//               2.ph,
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     "Japanese".tr,
//                     style: AppTextStyle.normalBold14
//                         .copyWith(fontWeight: FontWeight.normal),
//                   ),
//                   GestureDetector(
//                     onTap: () async {
//                       print('🌐 Switching to Japanese...');
//                       SettingController.prilmaryLanguage.value = "Japanese";
//                       constants.deviceLanguage = "ja";
//                       constants.locale = const Locale('ja');
//
//                       // Update GetX locale
//                       Get.updateLocale(const Locale('ja'));
//
//                       // Wait a moment for locale to update
//                       await Future.delayed(Duration(milliseconds: 100));
//
//                       // Debug locale information
//                       print('🌐 Language switched to Japanese');
//                       print('🌐 GetX locale: ${Get.locale}');
//                       print('🌐 Constants locale: ${constants.locale}');
//                       print('🌐 Device language: ${constants.deviceLanguage}');
//
//                       // Force update RevenueCat locale attributes if initialized
//                       try {
//                         if (await Purchases.isConfigured) {
//                           await Purchases.setAttributes({
//                             'language': 'ja',
//                             'locale': 'ja_JP',
//                             'app_language': 'Japanese',
//                             'locale_switched': DateTime.now().toIso8601String()
//                           });
//                           print('🌐 Updated RevenueCat attributes for Japanese');
//                         }
//                       } catch (e) {
//                         print('🌐 Error updating RevenueCat attributes: $e');
//                       }
//
//                       Get.to(() => const SplashScreen());
//                     },
//                     child: Container(
//                       margin: const EdgeInsets.symmetric(vertical: 5),
//                       width: 20,
//                       height: 20,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(
//                           color: indigo700,
//                           width: SettingController.prilmaryLanguage.value ==
//                                   "Japanese"
//                               ? 4.0
//                               : 1.0,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               // 2.ph,
//               // Row(
//               //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               //   children: [
//               //     Text(
//               //       "Korean".tr,
//               //       style: AppTextStyle.normalBold14
//               //           .copyWith(fontWeight: FontWeight.normal),
//               //     ),
//               //     GestureDetector(
//               //       onTap: () {
//               //         SettingController.prilmaryLanguage.value = "Korean";
//
//               //         constants.deviceLanguage = "ko";
//               //         Get.updateLocale(
//               //           const Locale('ko'),
//               //         );
//
//               //         Get.to(() => const SplashScreen());
//               //       },
//               //       child: Container(
//               //         margin: const EdgeInsets.symmetric(vertical: 5),
//               //         width: 20,
//               //         height: 20,
//               //         decoration: BoxDecoration(
//               //           borderRadius: BorderRadius.circular(20),
//               //           border: Border.all(
//               //             color: indigo700,
//               //             width: SettingController.prilmaryLanguage.value ==
//               //                     "Korean"
//               //                 ? 4.0
//               //                 : 1.0,
//               //           ),
//               //         ),
//               //       ),
//               //     ),
//               //   ],
//               // ),
//               10.ph,
//               CustomButton(
//                 text: "Continue".tr,
//                 textSize: 16,
//                 onPressed: () {
//                   if (widget.isFromSplashScreen == true) {
//                     Get.to(() => LoginScreen());
//                   } else {
//                     Navigator.pop(context);
//                   }
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:yokai_quiz_app/Widgets/new_button.dart';
import 'package:yokai_quiz_app/Widgets/splash_screen.dart';
import 'package:yokai_quiz_app/screens/Authentication/login_screen.dart';
import 'package:yokai_quiz_app/screens/Settings/controller/setting_controller.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/const.dart';
import 'package:yokai_quiz_app/util/constants.dart';
import 'package:yokai_quiz_app/util/text_styles.dart';
import 'package:yokai_quiz_app/global.dart';
import 'package:yokai_quiz_app/config/revenue_cat_config.dart';

class LanguageSetting extends StatefulWidget {
  final bool? isFromSplashScreen;
  const LanguageSetting({super.key, this.isFromSplashScreen});

  @override
  State<LanguageSetting> createState() => _LanguageSettingState();
}

class _LanguageSettingState extends State<LanguageSetting> {
  bool _isUpdating = false;

  // Method to change language using nuclear approach
  Future<void> _changeLanguage(String languageCode, String languageName) async {
    if (_isUpdating) return;

    setState(() {
      _isUpdating = true;
    });

    try {

      // 1. Update SettingController
      SettingController.prilmaryLanguage.value = languageName;

      // 2. Use constants.changeLanguage which handles everything
      await constants.changeLanguage(languageCode);

      // 3. NUCLEAR OPTION: Force native Android locale change immediately
      try {
        const platform = MethodChannel('yokai_quiz_app/locale');
        final localeString = languageCode == 'ja' ? 'ja_JP' :
        languageCode == 'ko' ? 'ko_KR' : 'en_US';

        // Force it multiple times
        for (int i = 0; i < 3; i++) {
          await platform.invokeMethod('setLocale', {'locale': localeString});
          await Future.delayed(const Duration(milliseconds: 200));
        }

        print('🌐 ☢️ Forced native locale change to $localeString');
      } catch (e) {
        print('🌐 ☢️ Native locale change failed: $e');
      }

      // 4. Enhanced RevenueCat attributes for better locale detection
      try {
        if (await Purchases.isConfigured) {
          // Nuclear RevenueCat attribute setting
          final Map<String, String> nuclearAttributes = {};

          // Base attributes
          nuclearAttributes.addAll({
            'language': languageCode,
            'locale': '${languageCode}_${languageCode.toUpperCase()}',
            'app_language': languageName,
            'preferred_language': languageName,
            'user_selected_language': languageCode,
            'paywall_locale': languageCode,
            'ui_language': languageCode,
            'device_locale': languageCode,
            'system_locale': languageCode,
            'platform_locale': languageCode,
            'native_locale': languageCode,
            'forced_locale': languageCode,
            'override_locale': languageCode,
            'nuclear_locale_change': 'true',
            'locale_changed_at': DateTime.now().toIso8601String(),
          });

          // Add 50+ variations to overwhelm RevenueCat's detection
          final prefixes = ['user_', 'app_', 'device_', 'system_', 'platform_', 'ui_', 'display_', 'paywall_', 'subscription_', 'revenue_cat_'];
          final suffixes = ['language', 'locale', 'code', 'preference'];

          for (String prefix in prefixes) {
            for (String suffix in suffixes) {
              if (suffix.contains('language')) {
                nuclearAttributes['$prefix$suffix'] = languageCode;
              } else {
                nuclearAttributes['$prefix$suffix'] = '${languageCode}_${languageCode.toUpperCase()}';
              }
            }
          }

          // Set attributes multiple times
          for (int i = 0; i < 3; i++) {
            await Purchases.setAttributes(nuclearAttributes);
            await Purchases.invalidateCustomerInfoCache();
            await Future.delayed(const Duration(milliseconds: 300));
          }

          print('🌐 ☢️ Set ${nuclearAttributes.length} NUCLEAR RevenueCat attributes');
        }
      } catch (e) {
        print('🌐 ☢️ Error setting nuclear RevenueCat attributes: $e');
      }

      // 5. Wait for all updates to process
      await Future.delayed(const Duration(milliseconds: 1000));


      // 7. Navigate with complete refresh
      Get.offAll(() => const SplashScreen());

    } catch (e) {
      print('🌐 ☢️ Error in nuclear language change: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get current language for UI state
    final currentLanguage = constants.deviceLanguage;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Row(
                  children: [
                    SvgPicture.asset('icons/arrowLeft.svg'),
                    Text(
                      "Language".tr,
                      style: AppTextStyle.normalBold20.copyWith(color: coral500),
                    ),
                  ],
                ),
              ),
              3.ph,

              // Show loading indicator if updating
              if (_isUpdating)
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ],
                  ),
                ),

              Text('Suggested'.tr, style: AppTextStyle.normalBold16),
              2.ph,

              // English Option
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "English (UK)".tr,
                    style: AppTextStyle.normalBold14.copyWith(
                      fontWeight: FontWeight.normal,
                      color: _isUpdating ? Colors.grey : null,
                    ),
                  ),
                  GestureDetector(
                    onTap: _isUpdating ? null : () => _changeLanguage("en", "English (UK)"),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _isUpdating ? Colors.grey : indigo700,
                          width: (currentLanguage == "en" ||
                              SettingController.prilmaryLanguage.value == "English (UK)")
                              ? 4.0
                              : 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              3.ph,
              Text('Other'.tr, style: AppTextStyle.normalBold16),
              2.ph,

              // Japanese Option
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Japanese".tr,
                    style: AppTextStyle.normalBold14.copyWith(
                      fontWeight: FontWeight.normal,
                      color: _isUpdating ? Colors.grey : null,
                    ),
                  ),
                  GestureDetector(
                    onTap: _isUpdating ? null : () => _changeLanguage("ja", "Japanese"),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _isUpdating ? Colors.grey : indigo700,
                          width: (currentLanguage == "ja" ||
                              SettingController.prilmaryLanguage.value == "Japanese")
                              ? 4.0
                              : 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              10.ph,
              CustomButton(
                text: "Continue".tr,
                textSize: 16,
                onPressed: () {
                  if (_isUpdating) return; // Early return if updating

                  if (widget.isFromSplashScreen == true) {
                    Get.to(() => LoginScreen());
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}