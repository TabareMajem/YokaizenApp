/// revenue_cat_config.dart

import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../global.dart';

class RevenueCatConfig {
  static const String _tag = 'RevenueCatConfig';
  static bool _initialized = false;

  // Product IDs - Must match EXACTLY with App Store Connect and StoreKit config
  static const List<String> productIds = ['ykz_monthly', 'ykz_annual'];
  static const String entitlementId = 'premium';
  static const String offeringId = 'premium';

  // API Keys
  static const String _iosKey = 'appl_OedhtTWbqtevPtOieRVmbIQiLkm';
  static const String _androidKey = 'goog_NCaBKoodvajVnqnuaoobJUDnNnr';


  static Future<bool> init() async {
    if (_initialized) {
      debugPrint('[$_tag] RevenueCat already initialized');
      return true;
    }

    try {
      // Set debug log level for detailed logging in development
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
        debugPrint('[$_tag] Debug mode detected, setting LogLevel.debug');
      }

      // Get appropriate API key
      final apiKey = Platform.isAndroid ? _androidKey : _iosKey;
      debugPrint('[$_tag] Initializing with API key: $apiKey');

      // Create configuration
      final configuration = PurchasesConfiguration(apiKey);

      // iOS-specific configuration for testing
      if (Platform.isIOS && kDebugMode) {
        debugPrint('[$_tag] Configuring StoreKit 2 for iOS testing');
        configuration.storeKitVersion = StoreKitVersion.storeKit2;
        await Purchases.setSimulatesAskToBuyInSandbox(true);
      }

      // Configure RevenueCat with our settings
      await Purchases.configure(configuration);
      _initialized = true;

      // Set locale-specific attributes immediately after initialization
      await _setLocaleAttributes();

      // Log customer info
      try {
        final customerInfo = await Purchases.getCustomerInfo();
        debugPrint('[$_tag] RevenueCat customer ID: ${customerInfo.originalAppUserId}');

        // Check premium status
        final isPremium = customerInfo.entitlements.active.containsKey(entitlementId);
        debugPrint('[$_tag] Premium status: $isPremium');

        // Cache premium status
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isPremium', isPremium);
        debugPrint('[$_tag] Premium status cached: $isPremium');
      } catch (e) {
        debugPrint('[$_tag] Error getting customer info: $e');
      }

      // Verify products and offerings
      await _verifyProducts();
      await _verifyOfferings();

      return true;
    } catch (e) {
      debugPrint('[$_tag] RevenueCat initialization error: $e');
      return false;
    }
  }

  // Enhanced method to present paywall with content logging
  static Future<PaywallResult?> presentLocalizedPaywall({Offering? offering, bool displayCloseButton = true,}) async {
    try {
      debugPrint('[$_tag] ===== PRESENTING PAYWALL =====');

      // Get current locale info
      final currentLocale = Get.locale ?? const Locale('en', 'US');
      debugPrint('[$_tag] Current app locale: ${currentLocale.languageCode}_${currentLocale.countryCode}');
      customPrint('Paywall Content - PRESENTING WITH LOCALE: App locale is ${currentLocale.languageCode}_${currentLocale.countryCode}');

      // Update locale attributes before showing paywall
      customPrint('Paywall Content - LOCALE SYNC: Syncing app locale to RevenueCat...');
      await _setLocaleAttributes();

      // Verify locale was set correctly
      try {
        final customerInfo = await Purchases.getCustomerInfo();
        customPrint('Paywall Content - LOCALE VERIFICATION: RevenueCat customer info updated');
      } catch (e) {
        customPrint('Paywall Content - LOCALE ERROR: Failed to verify customer info: $e');
      }

      // Wait longer to ensure locale attributes are processed
      customPrint('Paywall Content - LOCALE PROCESSING: Waiting for RevenueCat to process locale...');
      await Future.delayed(const Duration(milliseconds: 800));

      // Get offerings if not provided
      final targetOffering = offering ?? (await getOfferings(forceRefresh: true))?.current;

      if (targetOffering == null) {
        debugPrint('[$_tag] No offering available for paywall');
        return null;
      }

      // LOG ALL PAYWALL CONTENT WITH SEARCH KEYWORD
      await _logPaywallContent(targetOffering);
      
      // Log additional paywall context
      await _logAdditionalPaywallContext();

      debugPrint('[$_tag] About to present paywall:');
      debugPrint('[$_tag] - Offering: ${targetOffering.identifier}');
      debugPrint('[$_tag] - Display close button: $displayCloseButton');
      debugPrint('[$_tag] - App locale: ${currentLocale.languageCode}_${currentLocale.countryCode}');

      // Present the paywall with Android lifecycle safety
      customPrint('Paywall Content - ===== SAFELY PRESENTING PAYWALL =====');
      customPrint('Paywall Content - Display Close Button: $displayCloseButton');
      
      debugPrint('[$_tag] ===== CALLING RevenueCatUI.presentPaywall with safety =====');
      
      try {
        // Add a small delay to ensure Android activity is in proper state
        await Future.delayed(const Duration(milliseconds: 100));
        
      final result = await RevenueCatUI.presentPaywall(
        offering: targetOffering,
        displayCloseButton: displayCloseButton,
      );

        customPrint('Paywall Content - PAYWALL RESULT: $result');
        debugPrint('[$_tag] Paywall result: $result');

      return result;
        
      } catch (e) {
        customPrint('Paywall Content - PAYWALL PRESENTATION ERROR: $e');
        debugPrint('[$_tag] Error presenting paywall: $e');
        
        // Return null on error instead of crashing
        return null;
      }

    } catch (e) {
      debugPrint('[$_tag] ===== ERROR PRESENTING PAYWALL =====');
      debugPrint('[$_tag] Error: $e');
      debugPrint('[$_tag] Error type: ${e.runtimeType}');
      if (e is PlatformException) {
        debugPrint('[$_tag] Platform error code: ${e.code}');
        debugPrint('[$_tag] Platform error message: ${e.message}');
        debugPrint('[$_tag] Platform error details: ${e.details}');
      }
      return null;
    }
  }

  // Method to log all paywall content with search keyword
  static Future<void> _logPaywallContent(Offering offering) async {
    try {
      customPrint('Paywall Content - ===== COMPLETE OFFERING CONTENT =====');
      customPrint('Paywall Content - Offering ID: ${offering.identifier}');
      customPrint('Paywall Content - Offering Description: ${offering.serverDescription}');
      customPrint('Paywall Content - Offering Metadata: ${offering.metadata}');
      
      // Try to extract more from offering metadata
      if (offering.metadata.isNotEmpty) {
        offering.metadata.forEach((key, value) {
          customPrint('Paywall Content - Offering Metadata[$key]: $value');
        });
      }

      for (int i = 0; i < offering.availablePackages.length; i++) {
        final package = offering.availablePackages[i];
        final product = package.storeProduct;

        customPrint('Paywall Content - ===== COMPLETE PACKAGE ${i + 1} CONTENT =====');
        customPrint('Paywall Content - Package ID: ${package.identifier}');
        customPrint('Paywall Content - Package Type: ${package.packageType}');
        customPrint('Paywall Content - Package toString: ${package.toString()}');
        
        customPrint('Paywall Content - ===== COMPLETE PRODUCT DETAILS =====');
        customPrint('Paywall Content - Product ID: ${product.identifier}');
        customPrint('Paywall Content - Product Title: ${product.title}');
        customPrint('Paywall Content - Product Description: ${product.description}');
        customPrint('Paywall Content - Product Price: ${product.priceString}');
        customPrint('Paywall Content - Product Price Decimal: ${product.price}');
        customPrint('Paywall Content - Product Currency: ${product.currencyCode}');
        customPrint('Paywall Content - Product Category: ${product.productCategory}');
        customPrint('Paywall Content - Product toString: ${product.toString()}');

        // Log detailed subscription information
        if (product.subscriptionPeriod != null) {
          customPrint('Paywall Content - ===== SUBSCRIPTION PERIOD DETAILS =====');
          customPrint('Paywall Content - Subscription Period: ${product.subscriptionPeriod}');
        }

        // Log detailed introductory pricing
        if (product.introductoryPrice != null) {
          final introPrice = product.introductoryPrice!;
          customPrint('Paywall Content - ===== INTRODUCTORY PRICE DETAILS =====');
          customPrint('Paywall Content - Intro Price String: ${introPrice.priceString}');
          customPrint('Paywall Content - Intro Price Decimal: ${introPrice.price}');
          customPrint('Paywall Content - Intro Price Cycles: ${introPrice.cycles}');
          customPrint('Paywall Content - Intro Price Period: ${introPrice.period}');
          customPrint('Paywall Content - Intro Price toString: ${introPrice.toString()}');
        }

        // Log all promotional offers with complete details
        try {
          final promotionalOffers = product.discounts;
          if (promotionalOffers != null && promotionalOffers.isNotEmpty) {
            customPrint('Paywall Content - ===== PROMOTIONAL OFFERS DETAILS =====');
            customPrint('Paywall Content - Promotional Offers Count: ${promotionalOffers.length}');
            
                         for (int j = 0; j < promotionalOffers.length; j++) {
              final offer = promotionalOffers[j];
               customPrint('Paywall Content - ===== PROMO OFFER ${j + 1} DETAILS =====');
               customPrint('Paywall Content - Promo Offer ID: ${offer.identifier}');
               customPrint('Paywall Content - Promo Price String: ${offer.priceString}');
               customPrint('Paywall Content - Promo Price Decimal: ${offer.price}');
               customPrint('Paywall Content - Promo Cycles: ${offer.cycles}');
               customPrint('Paywall Content - Promo Period: ${offer.period}');
               customPrint('Paywall Content - Promo toString: ${offer.toString()}');
            }
          } else {
            customPrint('Paywall Content - No promotional offers available');
          }
        } catch (e) {
          customPrint('Paywall Content - Error getting promotional offers: $e');
      }

        // Additional product information
        try {
          customPrint('Paywall Content - Platform: ${Platform.isIOS ? 'iOS' : 'Android'}');
        } catch (e) {
          customPrint('Paywall Content - Error getting platform details: $e');
        }

        // Log all available product properties using reflection-like approach
        try {
          final productMap = product.toJson();
          customPrint('Paywall Content - ===== ALL PRODUCT JSON DATA =====');
          productMap.forEach((key, value) {
            customPrint('Paywall Content - Product[$key]: $value');
          });
        } catch (e) {
          customPrint('Paywall Content - Error getting product JSON: $e');
        }
      }

      // Log comprehensive customer info
      try {
        final customerInfo = await Purchases.getCustomerInfo();
        customPrint('Paywall Content - ===== COMPLETE CUSTOMER CONTEXT =====');
        customPrint('Paywall Content - Customer ID: ${customerInfo.originalAppUserId}');
        customPrint('Paywall Content - Management URL: ${customerInfo.managementURL}');
        customPrint('Paywall Content - Original Purchase Date: ${customerInfo.originalPurchaseDate}');
        customPrint('Paywall Content - Latest Expiration Date: ${customerInfo.latestExpirationDate}');
        customPrint('Paywall Content - Request Date: ${customerInfo.requestDate}');
        customPrint('Paywall Content - First Seen: ${customerInfo.firstSeen}');
        customPrint('Paywall Content - Original Application Version: ${customerInfo.originalApplicationVersion}');

        // Log all entitlements with complete details
        customPrint('Paywall Content - ===== ALL ENTITLEMENTS =====');
        customerInfo.entitlements.all.forEach((key, entitlement) {
          customPrint('Paywall Content - Entitlement: $key');
          customPrint('Paywall Content - Entitlement Active: ${entitlement.isActive}');
          customPrint('Paywall Content - Entitlement Product: ${entitlement.productIdentifier}');
          customPrint('Paywall Content - Entitlement Expiration: ${entitlement.expirationDate}');
          customPrint('Paywall Content - Entitlement Purchase Date: ${entitlement.latestPurchaseDate}');
          customPrint('Paywall Content - Entitlement Original Purchase Date: ${entitlement.originalPurchaseDate}');
          customPrint('Paywall Content - Entitlement Store: ${entitlement.store}');
          customPrint('Paywall Content - Entitlement Will Renew: ${entitlement.willRenew}');
          customPrint('Paywall Content - Entitlement Period Type: ${entitlement.periodType}');
          customPrint('Paywall Content - Entitlement Is Sandbox: ${entitlement.isSandbox}');
          customPrint('Paywall Content - Entitlement Unsubscribe Detected: ${entitlement.unsubscribeDetectedAt}');
          customPrint('Paywall Content - Entitlement Billing Issues Detected: ${entitlement.billingIssueDetectedAt}');
        });

        // Log all active purchases
        customPrint('Paywall Content - ===== ALL ACTIVE PURCHASES =====');
        customerInfo.allPurchasedProductIdentifiers.forEach((productId) {
          customPrint('Paywall Content - Purchased Product ID: $productId');
        });

        // Log non-subscription purchases
        customPrint('Paywall Content - ===== NON-SUBSCRIPTION PURCHASES =====');
        customerInfo.nonSubscriptionTransactions.forEach((transaction) {
          customPrint('Paywall Content - Non-Sub Transaction ID: ${transaction.transactionIdentifier}');
          customPrint('Paywall Content - Non-Sub Product ID: ${transaction.productIdentifier}');
          customPrint('Paywall Content - Non-Sub Purchase Date: ${transaction.purchaseDate}');
        });

      } catch (e) {
        customPrint('Paywall Content - Error getting customer info: $e');
      }

      customPrint('Paywall Content - ===== END COMPLETE PAYWALL CONTENT =====');

    } catch (e) {
      customPrint('Paywall Content - Error logging paywall content: $e');
    }
  }

  // Method to log additional paywall context and environment
  static Future<void> _logAdditionalPaywallContext() async {
    try {
      customPrint('Paywall Content - ===== ADDITIONAL PAYWALL CONTEXT =====');
      
      // Log current locale and language settings
      final currentLocale = Get.locale ?? const Locale('en', 'US');
      customPrint('Paywall Content - App Locale: ${currentLocale.languageCode}_${currentLocale.countryCode}');
      customPrint('Paywall Content - Platform Locale: ${Platform.localeName}');
      
      // Log RevenueCat configuration state
      customPrint('Paywall Content - RevenueCat Initialized: $_initialized');
      customPrint('Paywall Content - Platform: ${Platform.isIOS ? 'iOS' : Platform.isAndroid ? 'Android' : 'Other'}');
      customPrint('Paywall Content - Debug Mode: ${kDebugMode}');
      
      // Try to get and log all available offerings (not just current)
      try {
        final allOfferings = await Purchases.getOfferings();
        customPrint('Paywall Content - ===== ALL AVAILABLE OFFERINGS =====');
        customPrint('Paywall Content - Total Offerings Count: ${allOfferings.all.length}');
        
        allOfferings.all.forEach((identifier, offering) {
          customPrint('Paywall Content - Offering Available: $identifier');
          customPrint('Paywall Content - Offering Description: ${offering.serverDescription}');
          customPrint('Paywall Content - Offering Package Count: ${offering.availablePackages.length}');
          
          // Log package identifiers for each offering
          for (var package in offering.availablePackages) {
            customPrint('Paywall Content - Package in $identifier: ${package.identifier}');
          }
        });
        
        if (allOfferings.current != null) {
          customPrint('Paywall Content - Current Offering ID: ${allOfferings.current!.identifier}');
        } else {
          customPrint('Paywall Content - No current offering set');
        }
      } catch (e) {
        customPrint('Paywall Content - Error getting all offerings: $e');
      }
      
      // Log app user ID and any custom attributes
      try {
        final appUserID = await Purchases.appUserID;
        customPrint('Paywall Content - App User ID: $appUserID');
      } catch (e) {
        customPrint('Paywall Content - Error getting app user ID: $e');
      }
      
      // Log attribution data if available
      try {
        final customerInfo = await Purchases.getCustomerInfo();
        customPrint('Paywall Content - ===== ATTRIBUTION DATA =====');
        
        // Try to access attribution data through customer info
        final customerInfoJson = customerInfo.toJson();
        if (customerInfoJson.containsKey('attribution')) {
          customPrint('Paywall Content - Attribution Data: ${customerInfoJson['attribution']}');
        } else {
          customPrint('Paywall Content - No attribution data available');
        }
      } catch (e) {
        customPrint('Paywall Content - Error getting attribution data: $e');
      }

      customPrint('Paywall Content - ===== END ADDITIONAL CONTEXT =====');

    } catch (e) {
      customPrint('Paywall Content - Error logging additional context: $e');
    }
  }

  // Verify that products can be fetched
  static Future<void> _verifyProducts() async {
    try {
      debugPrint('[$_tag] Verifying products are available...');
      debugPrint('[$_tag] Looking for products: ${productIds.join(", ")}');

      final products = await Purchases.getProducts(productIds);

      debugPrint('[$_tag] Products available from store: ${products.length}');
      if (products.isEmpty) {
        debugPrint('[$_tag] ⚠️ WARNING: No products available from App Store!');
        debugPrint('[$_tag] This is likely due to a configuration issue.');
        debugPrint('[$_tag] Check that your product IDs match in:');
        debugPrint('[$_tag] 1. App Store Connect');
        debugPrint('[$_tag] 2. RevenueCat dashboard');
        debugPrint('[$_tag] 3. StoreKit Configuration file');
        debugPrint('[$_tag] 4. Code (productIds constant)');

        // Log the current configuration
        debugPrint('[$_tag] Current configuration:');
        debugPrint('[$_tag] - Platform: ${Platform.isIOS ? 'iOS' : 'Android'}');
        debugPrint('[$_tag] - API Key: ${Platform.isIOS ? _iosKey : _androidKey}');
        debugPrint('[$_tag] - Debug Mode: $kDebugMode');
        if (Platform.isIOS && kDebugMode) {
          debugPrint('[$_tag] - StoreKit Version: StoreKit 2');
        }
      } else {
        debugPrint('[$_tag] ✅ Products found:');
        for (var product in products) {
          debugPrint('[$_tag] - ID: ${product.identifier}');
          debugPrint('[$_tag]   Price: ${product.priceString}');
          debugPrint('[$_tag]   Title: ${product.title}');
          debugPrint('[$_tag]   Description: ${product.description}');
        }
      }
    } catch (e) {
      debugPrint('[$_tag] ❌ Error verifying products: $e');
      if (e is PlatformException) {
        debugPrint('[$_tag] Error Code: ${e.code}');
        debugPrint('[$_tag] Message: ${e.message}');
        debugPrint('[$_tag] Details: ${e.details}');
      }
    }
  }

  // Verify offerings configuration
  static Future<void> _verifyOfferings() async {
    try {
      debugPrint('[$_tag] Verifying offerings configuration...');
      debugPrint('[$_tag] Looking for offering: $offeringId');

      final offerings = await Purchases.getOfferings();
      debugPrint('[$_tag] All available offerings: ${offerings.all.keys.join(", ")}');

      if (offerings.current == null) {
        debugPrint('[$_tag] ⚠️ WARNING: No current offering found!');
        debugPrint('[$_tag] Please check your RevenueCat dashboard:');
        debugPrint('[$_tag] 1. Go to Offerings section');
        debugPrint('[$_tag] 2. Create an offering named "$offeringId"');
        debugPrint('[$_tag] 3. Add products: ${productIds.join(", ")}');
        debugPrint('[$_tag] 4. Set this offering as "Current"');

        // Log all available offerings
        if (offerings.all.isNotEmpty) {
          debugPrint('[$_tag] Available offerings:');
          offerings.all.forEach((key, offering) {
            debugPrint('[$_tag] - Offering: $key');
            debugPrint('[$_tag]   Available packages: ${offering.availablePackages.length}');
            for (var package in offering.availablePackages) {
              debugPrint('[$_tag]   Package: ${package.identifier}');
              debugPrint('[$_tag]     Product: ${package.storeProduct.identifier}');
              debugPrint('[$_tag]     Price: ${package.storeProduct.priceString}');
            }
          });
        }
      } else {
        debugPrint('[$_tag] ✅ Current offering found: ${offerings.current!.identifier}');
        debugPrint('[$_tag] Available packages: ${offerings.current!.availablePackages.length}');

        for (var package in offerings.current!.availablePackages) {
          debugPrint('[$_tag] Package: ${package.identifier}');
          debugPrint('[$_tag] - Product: ${package.storeProduct.identifier}');
          debugPrint('[$_tag] - Price: ${package.storeProduct.priceString}');
          debugPrint('[$_tag] - Type: ${package.packageType}');
        }
      }
    } catch (e) {
      debugPrint('[$_tag] ❌ Error verifying offerings: $e');
      if (e is PlatformException) {
        debugPrint('[$_tag] Error Code: ${e.code}');
        debugPrint('[$_tag] Message: ${e.message}');
        debugPrint('[$_tag] Details: ${e.details}');
      }
    }
  }

  // Set locale attributes for RevenueCat
  static Future<void> _setLocaleAttributes() async {
    try {
      final currentLocale = Get.locale ?? const Locale('en', 'US');
      final languageCode = currentLocale.languageCode;
      final countryCode = currentLocale.countryCode ?? languageCode.toUpperCase();

      debugPrint('[$_tag] Setting locale attributes:');
      debugPrint('[$_tag] - Language: $languageCode');
      debugPrint('[$_tag] - Country: $countryCode');
      debugPrint('[$_tag] - Full locale: ${languageCode}_$countryCode');

      await Purchases.setAttributes({
        'language': languageCode,
        'locale': '${languageCode}_$countryCode',
        'preferred_language': _getLanguageName(languageCode),
        'device_locale': languageCode,
        'app_locale': languageCode,
        'supports_localization': 'true',
        'locale_set_at': DateTime.now().toIso8601String(),
      });

      debugPrint('[$_tag] Successfully set locale attributes for $languageCode');
    } catch (e) {
      debugPrint('[$_tag] Error setting locale attributes: $e');
    }
  }

  // Helper to get language name
  static String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'ja':
        return 'Japanese';
      case 'ko':
        return 'Korean';
      case 'en':
      default:
        return 'English';
    }
  }

  static Future<void> updateLocale(String languageCode) async {
    if (!_initialized) {
      debugPrint('[$_tag] RevenueCat not initialized, initializing...');
      await init();
    }

    try {
      customPrint('Paywall Content - ===== INTENSIVE LOCALE UPDATE DEBUG =====');
      customPrint('Paywall Content - Requested language: $languageCode');
      
      // Try multiple locale formats that RevenueCat might recognize
      final localeVariations = [
        languageCode,                                    // "ja"
        '${languageCode}_${languageCode.toUpperCase()}', // "ja_JA"  
        '${languageCode}_JP',                           // "ja_JP"
        languageCode == 'ja' ? 'ja_JP' : '${languageCode}_${languageCode.toUpperCase()}',
      ];

      for (String localeFormat in localeVariations) {
        customPrint('Paywall Content - Trying locale format: $localeFormat');
      }

      // Create comprehensive attributes with ALL possible locale formats
      final attributes = <String, String>{};
      
      // Standard attributes
      attributes.addAll({
        'language': languageCode,
        'locale': languageCode == 'ja' ? 'ja_JP' : '${languageCode}_${languageCode.toUpperCase()}',
        'preferred_language': _getLanguageName(languageCode),
        'device_locale': languageCode,
        'app_locale': languageCode,
        'locale_updated_at': DateTime.now().toIso8601String(),
      });

      // Add ALL possible locale variations RevenueCat might check
      final localeKeys = [
        'locale', 'language', 'app_language', 'user_language', 'device_language',
        'paywall_locale', 'paywall_language', 'subscription_locale', 'purchase_locale',
        'ui_locale', 'ui_language', 'display_locale', 'display_language',
        'system_locale', 'system_language', 'platform_locale', 'platform_language',
        'revenue_cat_locale', 'revenue_cat_language', 'rc_locale', 'rc_language'
      ];

      for (String key in localeKeys) {
        if (key.contains('language')) {
          attributes[key] = languageCode;
        } else {
          attributes[key] = languageCode == 'ja' ? 'ja_JP' : '${languageCode}_${languageCode.toUpperCase()}';
        }
      }

      customPrint('Paywall Content - Setting ${attributes.length} locale attributes');
      customPrint('Paywall Content - Key attributes: language=$languageCode, locale=${attributes['locale']}');

      // Set attributes once to avoid Android fragment conflicts
      customPrint('Paywall Content - Setting attributes (single attempt)');
      await Purchases.setAttributes(attributes);

      // Single cache invalidation to avoid lifecycle issues
      customPrint('Paywall Content - Cache invalidation (single attempt)');
      await Purchases.invalidateCustomerInfoCache();

      // Skip verification to avoid additional RevenueCat calls that might cause conflicts
      customPrint('Paywall Content - Locale update completed, skipping verification for stability');

      customPrint('Paywall Content - ===== LOCALE UPDATE COMPLETED =====');
      debugPrint('[$_tag] Successfully updated locale to $languageCode');
    } catch (e) {
      customPrint('Paywall Content - ERROR updating locale: $e');
      debugPrint('[$_tag] Error updating locale: $e');
    }
  }

  // Method to verify RevenueCat received our locale
  static Future<void> _verifyLocaleWasSet(String expectedLanguage) async {
    try {
      customPrint('Paywall Content - ===== VERIFYING LOCALE WAS SET =====');
      
      // Wait for RevenueCat to process
      await Future.delayed(const Duration(milliseconds: 500));
      
      final customerInfo = await Purchases.getCustomerInfo();
      customPrint('Paywall Content - Customer info retrieved for verification');
      
      // Try to get current attributes (this might not work directly but worth trying)
      final appUserID = await Purchases.appUserID;
      customPrint('Paywall Content - App User ID: $appUserID');
      
      // Get offerings to see if they're localized
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        customPrint('Paywall Content - ===== CHECKING OFFERING LOCALIZATION =====');
        customPrint('Paywall Content - Current offering: ${offerings.current!.identifier}');
        
        for (var package in offerings.current!.availablePackages) {
          customPrint('Paywall Content - VERIFICATION Package: ${package.identifier}');
          customPrint('Paywall Content - VERIFICATION Title: ${package.storeProduct.title}');
          customPrint('Paywall Content - VERIFICATION Description: ${package.storeProduct.description}');
          customPrint('Paywall Content - VERIFICATION Price: ${package.storeProduct.priceString}');
          
          // Check if title/description seems to be in Japanese
          final title = package.storeProduct.title;
          final hasJapanese = title.contains(RegExp(r'[あ-ん]|[ア-ン]|[一-龯]'));
          customPrint('Paywall Content - VERIFICATION Contains Japanese characters: $hasJapanese');
        }
      }
      
      customPrint('Paywall Content - ===== LOCALE VERIFICATION COMPLETED =====');
    } catch (e) {
      customPrint('Paywall Content - ERROR verifying locale: $e');
    }
  }

  // Get offerings with locale refresh
  static Future<Offerings?> getOfferings({bool forceRefresh = false}) async {
    if (!_initialized) {
      debugPrint('[$_tag] RevenueCat not initialized, initializing...');
      await init();
    }

    try {
      // If force refresh or locale change, update attributes
      if (forceRefresh) {
        await _setLocaleAttributes();
        await Future.delayed(const Duration(milliseconds: 500)); // Wait for processing
      }

      debugPrint('[$_tag] Fetching offerings from RevenueCat...');
      final offerings = await Purchases.getOfferings();

      if (offerings.current != null) {
        debugPrint('[$_tag] Successfully fetched offerings:');
        debugPrint('[$_tag] - Current offering: ${offerings.current!.identifier}');
        debugPrint('[$_tag] - Available packages: ${offerings.current!.availablePackages.length}');

        // Sort packages to prioritize annual subscriptions first
        final sortedPackages = offerings.current!.availablePackages.toList();
        sortedPackages.sort((a, b) {
          if (a.packageType == PackageType.annual && b.packageType != PackageType.annual) return -1;
          if (b.packageType == PackageType.annual && a.packageType != PackageType.annual) return 1;
          return 0;
        });

        for (var package in sortedPackages) {
          debugPrint('[$_tag] Package: ${package.identifier}, Product: ${package.storeProduct.identifier}, Type: ${package.packageType}');
          debugPrint('[$_tag] - Price: ${package.storeProduct.priceString}');
          debugPrint('[$_tag] - Title: ${package.storeProduct.title}');
        }
      } else {
        debugPrint('[$_tag] No current offering found.');
        if (offerings.all.isNotEmpty) {
          debugPrint('[$_tag] Available offerings: ${offerings.all.keys.join(", ")}');
        }
      }

      return offerings;
    } catch (e) {
      debugPrint('[$_tag] Error fetching offerings: $e');
      return null;
    }
  }

  // // Get offerings with detailed logging and locale support
  // static Future<Offerings?> getOfferings() async {
  //   if (!_initialized) {
  //     debugPrint('[$_tag] RevenueCat not initialized, initializing...');
  //     await init();
  //   }
  //
  //   try {
  //     debugPrint('[$_tag] Fetching offerings from RevenueCat...');
  //     final offerings = await Purchases.getOfferings();
  //
  //     if (offerings.current != null) {
  //       debugPrint('[$_tag] Successfully fetched offerings:');
  //       debugPrint('[$_tag] - Current offering: ${offerings.current!.identifier}');
  //       debugPrint('[$_tag] - Available packages: ${offerings.current!.availablePackages.length}');
  //
  //       // Sort packages to prioritize annual subscriptions first
  //       final sortedPackages = offerings.current!.availablePackages.toList();
  //       sortedPackages.sort((a, b) {
  //         // Annual packages first, then monthly
  //         if (a.packageType == PackageType.annual && b.packageType != PackageType.annual) return -1;
  //         if (b.packageType == PackageType.annual && a.packageType != PackageType.annual) return 1;
  //         return 0;
  //       });
  //
  //       for (var package in sortedPackages) {
  //         debugPrint('[$_tag] Package: ${package.identifier}, Product: ${package.storeProduct.identifier}, Type: ${package.packageType}');
  //         debugPrint('[$_tag] - Price: ${package.storeProduct.priceString}');
  //       }
  //     } else {
  //       debugPrint('[$_tag] No current offering found.');
  //       if (offerings.all.isNotEmpty) {
  //         debugPrint('[$_tag] Available offerings: ${offerings.all.keys.join(", ")}');
  //         debugPrint('[$_tag] Please set one of these offerings as current in RevenueCat dashboard');
  //       } else {
  //         debugPrint('[$_tag] No offerings available at all.');
  //         debugPrint('[$_tag] Please create an offering named "$offeringId" in RevenueCat dashboard');
  //       }
  //     }
  //
  //     return offerings;
  //   } catch (e) {
  //     debugPrint('[$_tag] Error fetching offerings: $e');
  //     if (e is PlatformException) {
  //       debugPrint('[$_tag] Error Code: ${e.code}');
  //       debugPrint('[$_tag] Message: ${e.message}');
  //       debugPrint('[$_tag] Details: ${e.details}');
  //     }
  //     return null;
  //   }
  // }

  // Force show paywall for testing and review

  static Future<void> forceShowPaywall() async {
    if (!_initialized) {
      debugPrint('[$_tag] RevenueCat not initialized, initializing...');
      await init();
    }

    try {
      debugPrint('[$_tag] Forcing paywall display for testing...');

      // Get offerings
      final offerings = await getOfferings();
      if (offerings == null) {
        debugPrint('[$_tag] No offerings available to show paywall');
        return;
      }

      // Show paywall
      await RevenueCatUI.presentPaywall(
        offering: offerings.current!,
        displayCloseButton: true,
      );
    } catch (e) {
      debugPrint('[$_tag] Error showing paywall: $e');
    }
  }

  // Check if RevenueCat is initialized
  static bool get isInitialized => _initialized;

}
