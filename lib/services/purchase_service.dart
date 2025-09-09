/// purchase_service.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yokai_quiz_app/global.dart';
import 'package:yokai_quiz_app/util/constants.dart';
import '../screens/subscriptions/custom_localized_paywall.dart';
import '../screens/subscriptions/paywall_screen.dart';
import 'package:flutter/foundation.dart';
import '../config/revenue_cat_config.dart';

class PurchaseService {
  static const String _premiumEntitlementKey = 'premium';
  static const int _maxRetries = 3;
  static const String _tag = 'PurchaseService';

  // Initialize RevenueCat with proper configurations
  static Future<void> initPlatformState() async {
    if (!RevenueCatConfig.isInitialized) {
      await RevenueCatConfig.init();
    }
  }

  // Fetch available offerings with retry
  static Future<Offerings?> getOfferings() async {
    return await RevenueCatConfig.getOfferings();
  }

  // Purchase a package
  static Future<bool> purchasePackage(Package package) async {
    try {
      print('[$_tag] Attempting to purchase: ${package.identifier}');

      // In debug mode, allow bypassing actual purchase for testing
      if (kDebugMode && !_isPhysicalDevice()) {
        print('[$_tag] DEBUG MODE: Simulating successful purchase');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isPremium', true);
        return true;
      }

      final purchaseResult = await Purchases.purchasePackage(package);
      final isPremium = purchaseResult.entitlements.active.containsKey(_premiumEntitlementKey);

      print('[$_tag] Purchase successful. Premium: $isPremium');

      if (isPremium) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isPremium', true);
      }

      return isPremium;
    } catch (e) {
      if (e is PlatformException && e.code == 'purchase_cancelled') {
        print('[$_tag] Purchase cancelled by user');
      } else {
        print('[$_tag] Error during purchase: $e');
        if (e is PlatformException) {
          print('[$_tag] Error Code: ${e.code}');
          print('[$_tag] Message: ${e.message}');
          print('[$_tag] Details: ${e.details}');
        }
      }
      return false;
    }
  }

  // Check if the user has premium access
  static Future<bool> hasPremiumAccess() async {
    try {
      // First check shared preferences
      final prefs = await SharedPreferences.getInstance();
      bool isPremium = prefs.getBool('isPremium') ?? false;

      if (isPremium) return true;

      // If not in shared preferences, check RevenueCat
      try {
        final customerInfo = await Purchases.getCustomerInfo();
        isPremium = customerInfo.entitlements.active.containsKey(_premiumEntitlementKey);

        // Cache the result
        await prefs.setBool('isPremium', isPremium);
        return isPremium;
      } catch (e) {
        print('[$_tag] Error checking premium status: $e');
        // If we get a configuration error, allow access in debug mode
        if (kDebugMode) {
          print('[$_tag] Debug mode: Allowing premium access');
          return true;
        }
      }

      return false;
    } catch (e) {
      print('[$_tag] Error in hasPremiumAccess: $e');
      // In debug mode, allow access even if there's an error
      if (kDebugMode) {
        print('[$_tag] Debug mode: Allowing premium access due to error');
        return true;
      }
      return false;
    }
  }

  // Restore previous purchases
  static Future<bool> restorePurchases() async {
    try {
      print('[$_tag] Restoring purchases');
      final customerInfo = await Purchases.restorePurchases();
      final isPremium = customerInfo.entitlements.active.containsKey(_premiumEntitlementKey);

      print('[$_tag] Restored purchases. Premium: $isPremium');

      if (isPremium) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isPremium', true);
      }

      return isPremium;
    } catch (e) {
      print('[$_tag] Error restoring purchases: $e');
      return false;
    }
  }

  static Future<bool> showHostedPaywall(BuildContext context) async {
    try {
      print('[$_tag] Starting simple hosted paywall presentation');

      final targetLanguage = constants.locale.languageCode;
      print('[$_tag] App language: $targetLanguage');

      // SAFE locale update without excessive verification
      customPrint('Paywall Content - PURCHASE SERVICE: Updating locale to $targetLanguage');
      
      try {
      await RevenueCatConfig.updateLocale(targetLanguage);
        customPrint('Paywall Content - PURCHASE SERVICE: Locale update completed');
      } catch (e) {
        customPrint('Paywall Content - PURCHASE SERVICE: Locale update error: $e');
        // Continue anyway - don't let locale issues break the flow
      }

      // Get offerings with detailed logging
      final offerings = await RevenueCatConfig.getOfferings(forceRefresh: true);

      if (offerings?.current == null) {
        print('[$_tag] No current offering available');
        customPrint('Paywall Content - ERROR: No current offering available');
        throw Exception('No current offering available');
      }

      customPrint('Paywall Content - About to present RevenueCat hosted paywall');
      customPrint('Paywall Content - Current offering: ${offerings!.current!.identifier}');
      customPrint('Paywall Content - Available packages count: ${offerings.current!.availablePackages.length}');
      
      // Log package details before showing paywall
      for (var package in offerings.current!.availablePackages) {
        customPrint('Paywall Content - Package about to show: ${package.identifier}');
        customPrint('Paywall Content - Product ID: ${package.storeProduct.identifier}');
        customPrint('Paywall Content - Product title: ${package.storeProduct.title}');
        customPrint('Paywall Content - Product price: ${package.storeProduct.priceString}');
      }

      print('[$_tag] Presenting RevenueCat hosted paywall');

      customPrint('Paywall Content - Starting paywall presentation');

      PaywallResult? result;
      
      try {
        // Add small delay to ensure Android activity is ready
        await Future.delayed(const Duration(milliseconds: 100));
        
        result = await RevenueCatUI.presentPaywall(
        offering: offerings?.current!,
        displayCloseButton: true,
      );

        customPrint('Paywall Content - Paywall result: $result');
      print('[$_tag] Paywall result: $result');
        
      } catch (e) {
        customPrint('Paywall Content - Paywall presentation error: $e');
        print('[$_tag] Error presenting paywall: $e');
        
        // If paywall crashes, return false to handle gracefully
        return false;
      }

      if (result == PaywallResult.purchased || result == PaywallResult.restored) {
        print('[$_tag] Purchase/Restore successful');
        customPrint('Paywall Content - PURCHASE SUCCESS: ${result == PaywallResult.purchased ? "PURCHASED" : "RESTORED"}');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isPremium', true);
        return true;
      } else if (result == PaywallResult.cancelled) {
        print('[$_tag] Purchase cancelled by user');
        customPrint('Paywall Content - PURCHASE CANCELLED by user');
      } else {
        print('[$_tag] Purchase ended with result: $result');
        customPrint('Paywall Content - PURCHASE ENDED with result: $result');
      }

      return false;

    } catch (e) {
      print('[$_tag] Error showing hosted paywall: $e');
      customPrint('Paywall Content - ERROR showing hosted paywall: $e');

      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'.tr),
            content: Text(
              'Unable to load subscription options. Please try again later.'.tr,
              style: const TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'.tr),
              ),
            ],
          ),
        );
      }

      return false;
    }
  }

  // // Show RevenueCat's hosted paywall
  // static Future<bool> showHostedPaywall(BuildContext context) async {
  //   try {
  //     print('[$_tag] Starting hosted paywall presentation');
  //
  //     // Get the current offering
  //     final offerings = await getOfferings();
  //
  //     if (offerings?.current == null) {
  //       print('[$_tag] No current offering available');
  //       throw Exception('No current offering available');
  //     }
  //
  //     print("offering current : ${ offerings!.current!}");
  //
  //     // Present the hosted paywall with the current offering
  //     print('[$_tag] Presenting hosted paywall...');
  //     var result;
  //     try{
  //       final locale = constants.locale;
  //       result = await RevenueCatUI.presentPaywall(
  //         offering: offerings!.current!,
  //       );
  //       customPrint("showHostedPaywall got invoked results are : $result");
  //     } catch (ex, s) {
  //       debugPrint("this is the error : $ex &&&& $s");
  //     }
  //
  //
  //     print('[$_tag] Paywall presentation completed with result: $result');
  //
  //     if (result == PaywallResult.purchased) {
  //       print('[$_tag] Purchase successful');
  //       // Update premium status
  //       final prefs = await SharedPreferences.getInstance();
  //       await prefs.setBool('isPremium', true);
  //       return true;
  //     } else if (result == PaywallResult.restored) {
  //       print('[$_tag] Purchase restored successfully');
  //       // Update premium status
  //       final prefs = await SharedPreferences.getInstance();
  //       await prefs.setBool('isPremium', true);
  //       return true;
  //     } else if (result == PaywallResult.cancelled) {
  //       print('[$_tag] Purchase cancelled by user');
  //     } else {
  //       print('[$_tag] Purchase ended with result: $result');
  //     }
  //
  //     return false;
  //   } catch (e) {
  //     print('[$_tag] Error showing hosted paywall: $e');
  //
  //     // Show user-friendly error message
  //     if (context.mounted) {
  //       await showDialog(
  //         context: context,
  //         builder: (context) => AlertDialog(
  //           title: Text('Error'.tr),
  //           content: Text(
  //             'Unable to load subscription options. Please try again later.'.tr,
  //             style: const TextStyle(fontSize: 16),
  //           ),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.of(context).pop(),
  //               child: Text('OK'.tr),
  //             ),
  //           ],
  //         ),
  //       );
  //     }
  //
  //     return false;
  //   }
  // }

  // Check if running on a physical device

  static bool _isPhysicalDevice() {
    try {
      return defaultTargetPlatform == TargetPlatform.iOS
          ? !Platform.environment.containsKey('SIMULATOR_DEVICE_NAME')
          : defaultTargetPlatform == TargetPlatform.android
          ? !Platform.environment.containsKey('ANDROID_EMU')
          : true;
    } catch (e) {
      return true; // Default to assuming it's a physical device
    }
  }
}