/// paywall_screen.dart

import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../services/purchase_service.dart';
import '../../config/revenue_cat_config.dart';
import '../../util/colors.dart';
import '../../util/text_styles.dart';
import '../../util/constants.dart';
import '../../global.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  static const String _tag = 'PaywallScreen';

  @override
  void initState() {
    super.initState();
    print('[$_tag] Initializing RevenueCat Localized PaywallScreen');
    print('[$_tag] Current device locale: ${Get.locale}');
    print('[$_tag] Current Localizations.localeOf: ${Localizations.localeOf(context)}');
    customPrint('Paywall Content - INITIALIZING PaywallScreen');
    customPrint('Paywall Content - Device locale: ${Get.locale}');
    customPrint('Paywall Content - Context locale: ${Localizations.localeOf(context)}');
    _initializePaywall();
  }

  Future<void> _initializePaywall() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      print('[$_tag] Checking RevenueCat configuration');

      // Ensure RevenueCat is initialized
      if (!RevenueCatConfig.isInitialized) {
        print('[$_tag] RevenueCat not initialized, initializing...');
        await RevenueCatConfig.init();
      }

      // Show the RevenueCat localized hosted paywall
      await _showLocalizedPaywall();

    } catch (e) {
      print('[$_tag] Error in initialization: $e');
      setState(() {
        _errorMessage = 'Unable to load subscription options. Please try again later.';
        _isLoading = false;
      });
    }
  }

  // Future<void> _showLocalizedPaywall() async {
  //   try {
  //     print('[$_tag] Attempting to show RevenueCat localized hosted paywall');
  //
  //     // Get all locale information for debugging
  //     final flutterLocale = Localizations.localeOf(context);
  //     final getXLocale = Get.locale;
  //     final constantsLocale = constants.locale;
  //
  //     print('[$_tag] Flutter Localizations.localeOf: ${flutterLocale.languageCode}_${flutterLocale.countryCode ?? 'null'}');
  //     print('[$_tag] GetX locale: ${getXLocale?.languageCode}_${getXLocale?.countryCode ?? 'null'}');
  //     print('[$_tag] Constants locale: ${constantsLocale.languageCode}_${constantsLocale.countryCode ?? 'null'}');
  //     print('[$_tag] Device language constant: ${constants.deviceLanguage}');
  //
  //     // Get offerings from RevenueCatConfig
  //     final offerings = await RevenueCatConfig.getOfferings();
  //
  //     if (offerings?.current == null) {
  //       setState(() {
  //         _errorMessage = 'Unable to load subscription options. Please try again later.';
  //         _isLoading = false;
  //       });
  //       print('[$_tag] No offerings available');
  //       return;
  //     }
  //
  //     // Force set locale before showing paywall if it's Japanese
  //     if (constants.deviceLanguage == "ja" || getXLocale?.languageCode == "ja") {
  //       print('[$_tag] Japanese detected - attempting to force Japanese locale');
  //
  //       // Try to set customer attributes to help RevenueCat with localization
  //       try {
  //         await Purchases.setAttributes({
  //           'language': 'ja',
  //           'locale': 'ja_JP',
  //           'preferred_language': 'Japanese',
  //           'device_locale': 'ja',
  //           'app_locale': 'ja'
  //         });
  //         print('[$_tag] Set RevenueCat attributes for Japanese locale');
  //
  //         // Try to invalidate and refresh offerings to get localized content
  //         try {
  //           await Purchases.invalidateCustomerInfoCache();
  //           print('[$_tag] Invalidated RevenueCat cache for fresh localized content');
  //         } catch (e) {
  //           print('[$_tag] Error invalidating cache: $e');
  //         }
  //
  //       } catch (e) {
  //         print('[$_tag] Error setting RevenueCat attributes: $e');
  //       }
  //
  //       // Also try using a temporary context with Japanese locale
  //       if (!mounted) return;
  //
  //       // Wait a moment to ensure attributes are processed
  //       await Future.delayed(Duration(milliseconds: 200));
  //     }
  //
  //     // Present the localized paywall using RevenueCat's UI
  //     print('[$_tag] About to present paywall with locale information:');
  //     print('[$_tag] - App context locale: ${Localizations.localeOf(context)}');
  //     print('[$_tag] - Expected language: ${constants.deviceLanguage}');
  //
  //     // Log customer info to see what RevenueCat knows about the user
  //     try {
  //       final customerInfo = await Purchases.getCustomerInfo();
  //       print('[$_tag] RevenueCat Customer Info:');
  //       print('[$_tag] - User ID: ${customerInfo.originalAppUserId}');
  //       print('[$_tag] - Active entitlements: ${customerInfo.entitlements.active.keys}');
  //
  //       // Check if we can see any locale-related info
  //       final offerings = await Purchases.getOfferings();
  //       print('[$_tag] Offerings info:');
  //       print('[$_tag] - Current offering: ${offerings.current?.identifier}');
  //       if (offerings.current != null) {
  //         print('[$_tag] - Packages available: ${offerings.current!.availablePackages.length}');
  //         for (var package in offerings.current!.availablePackages) {
  //           print('[$_tag]   - ${package.identifier}: ${package.storeProduct.title}');
  //           print('[$_tag]     Price: ${package.storeProduct.priceString}');
  //         }
  //       }
  //     } catch (e) {
  //       print('[$_tag] Error getting customer info: $e');
  //     }
  //
  //     final result = await RevenueCatUI.presentPaywall(
  //       offering: offerings!.current!,
  //       displayCloseButton: true,
  //     );
  //
  //     print('[$_tag] Paywall result: $result');
  //
  //     if (result == PaywallResult.purchased && mounted) {
  //       // Purchase was successful, return to previous screen
  //       Navigator.of(context).pop(true);
  //     } else if (result == PaywallResult.restored && mounted) {
  //       // Purchase was restored, return to previous screen
  //       Navigator.of(context).pop(true);
  //     } else {
  //       // Purchase was cancelled or failed
  //       if (mounted) {
  //         setState(() => _isLoading = false);
  //         // If user cancelled, just close the screen
  //         if (result == PaywallResult.cancelled) {
  //           Navigator.of(context).pop(false);
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     print('[$_tag] Error showing localized paywall: $e');
  //     if (mounted) {
  //       setState(() {
  //         _errorMessage = 'Unable to show subscription options. Please try again later.';
  //         _isLoading = false;
  //       });
  //     }
  //   }
  // }

  Future<void> _showLocalizedPaywall() async {
    try {
      customPrint('[$_tag] Attempting to show RevenueCat localized hosted paywall');

      // Get comprehensive locale information
      final flutterLocale = Localizations.localeOf(context);
      final getXLocale = Get.locale;
      final constantsLocale = constants.locale;

      customPrint('[$_tag] Comprehensive locale debugging:');
      customPrint('[$_tag] - Flutter context: ${flutterLocale.languageCode}_${flutterLocale.countryCode}');
      customPrint('[$_tag] - GetX current: ${getXLocale?.languageCode}_${getXLocale?.countryCode}');
      customPrint('[$_tag] - Constants: ${constantsLocale.languageCode}_${constantsLocale.countryCode}');
      customPrint('[$_tag] - Device language: ${constants.deviceLanguage}');

      // Determine the target locale (prioritize constants.locale)
      final targetLanguage = constantsLocale.languageCode;
      customPrint('[$_tag] Target language determined: $targetLanguage');

            // SAFE LOCALE UPDATE - Avoid fragment lifecycle conflicts
      customPrint('[$_tag] Updating RevenueCat locale to: $targetLanguage');
      customPrint('Paywall Content - SAFE LOCALE UPDATE: Setting to $targetLanguage');
      
      try {
        // Single, safe locale update
      await RevenueCatConfig.updateLocale(targetLanguage);

        // Reasonable wait without excessive calls
        customPrint('Paywall Content - PROCESSING: Waiting for locale update...');
        await Future.delayed(const Duration(milliseconds: 800));
        
      } catch (e) {
        customPrint('Paywall Content - ERROR in locale update: $e');
        // Continue anyway - don't let locale issues break the paywall
      }

      // Get fresh offerings with updated locale
      final offerings = await RevenueCatConfig.getOfferings(forceRefresh: true);

      if (offerings?.current == null) {
        setState(() {
          _errorMessage = 'Unable to load subscription options. Please try again later.';
          _isLoading = false;
        });
        customPrint('[$_tag] No offerings available');
        return;
      }

      customPrint('[$_tag] Offerings loaded successfully');
      customPrint('[$_tag] - Current offering: ${offerings!.current!.identifier}');
      customPrint('[$_tag] - Available packages: ${offerings.current!.availablePackages.length}');

      // Log package details to verify localization
      for (var package in offerings.current!.availablePackages) {
        customPrint('[$_tag] Package: ${package.identifier}');
        customPrint('[$_tag] - Product ID: ${package.storeProduct.identifier}');
        customPrint('[$_tag] - Title: ${package.storeProduct.title}');
        customPrint('[$_tag] - Price: ${package.storeProduct.priceString}');
        customPrint('[$_tag] - Description: ${package.storeProduct.description}');
      }

      // Present the localized paywall
      customPrint('[$_tag] Presenting paywall with locale: $targetLanguage');
      customPrint('Paywall Content - Presenting localized paywall with locale: $targetLanguage');
      customPrint('Paywall Content - Offering being presented: ${offerings.current!.identifier}');

      final result = await RevenueCatConfig.presentLocalizedPaywall(
        offering: offerings.current,
        displayCloseButton: true,
      );

      customPrint('[$_tag] Paywall result: $result');
      customPrint('Paywall Content - Paywall presentation result: $result');

      if (result == PaywallResult.purchased && mounted) {
        customPrint('[$_tag] Purchase successful - closing screen');
        customPrint('Paywall Content - PURCHASE SUCCESSFUL - closing screen');
        Navigator.of(context).pop(true);
      } else if (result == PaywallResult.restored && mounted) {
        customPrint('[$_tag] Purchase restored - closing screen');
        customPrint('Paywall Content - PURCHASE RESTORED - closing screen');
        Navigator.of(context).pop(true);
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
          if (result == PaywallResult.cancelled) {
            customPrint('[$_tag] Purchase cancelled - closing screen');
            customPrint('Paywall Content - PURCHASE CANCELLED - closing screen');
            Navigator.of(context).pop(false);
          }
        }
      }
    } catch (e) {
      customPrint('[$_tag] Error showing localized paywall: $e');
      customPrint('Paywall Content - ERROR showing localized paywall: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Unable to show subscription options. Please try again later.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _restorePurchases() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      customPrint('[$_tag] Attempting to restore purchases');
      final success = await PurchaseService.restorePurchases();

      if (success && mounted) {
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _errorMessage = 'No previous purchases found to restore';
          _isLoading = false;
        });
      }
    } catch (e) {
      customPrint('[$_tag] Error restoring purchases: $e');
      setState(() {
        _errorMessage = 'Restore failed. Please try again later.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Premium Features'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ElevatedButton(
                      onPressed: _initializePaywall,
                      child: Text('Try Again'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _restorePurchases,
                      child: Text('Restore Purchases'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}