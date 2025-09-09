import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/text_styles.dart';
import 'package:yokai_quiz_app/util/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomLocalizedPaywall extends StatefulWidget {
  const CustomLocalizedPaywall({Key? key}) : super(key: key);

  @override
  State<CustomLocalizedPaywall> createState() => _CustomLocalizedPaywallState();
}

class _CustomLocalizedPaywallState extends State<CustomLocalizedPaywall> {
  Offerings? offerings;
  bool isLoading = true;
  String errorMessage = '';
  Package? selectedPackage;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final result = await Purchases.getOfferings();

      setState(() {
        offerings = result;
        isLoading = false;
        // Auto-select annual package by default
        if (result.current?.availablePackages.isNotEmpty == true) {
          selectedPackage = result.current!.availablePackages
              .firstWhere(
                (package) => package.packageType == PackageType.annual,
            orElse: () => result.current!.availablePackages.first,
          );
        }
      });
    } catch (e) {
      print('Error loading offerings: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Unable to load subscription options. Please try again later.'.tr;
      });
    }
  }

  Future<void> _purchasePackage(Package package) async {
    try {
      setState(() => isLoading = true);

      final result = await Purchases.purchasePackage(package);

      if (result.entitlements.active.containsKey('premium')) {
        // Save premium status
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isPremium', true);

        // Return success
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      print('Purchase error: $e');
      setState(() => isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase failed. Please try again.'.tr),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _restorePurchases() async {
    try {
      setState(() => isLoading = true);

      final result = await Purchases.restorePurchases();

      if (result.entitlements.active.containsKey('premium')) {
        // Save premium status
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isPremium', true);

        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        setState(() => isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No previous purchases found to restore'.tr),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      print('Restore error: $e');
      setState(() => isLoading = false);
    }
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTextStyle.normalBold14.copyWith(
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageOption(Package package) {
    final isSelected = selectedPackage?.identifier == package.identifier;
    final isAnnual = package.packageType == PackageType.annual;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPackage = package;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? coral500 : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? coral500.withOpacity(0.1) : Colors.white,
        ),
        child: Row(
          children: [
            // Radio button
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? coral500 : Colors.grey.shade400,
                  width: 2,
                ),
                color: isSelected ? coral500 : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            SizedBox(width: 12),

            // Package details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        isAnnual
                            ? 'Yokaizen Premium - Yearly'.tr
                            : 'Yokaizen Premium - Monthly'.tr,
                        style: AppTextStyle.normalBold16.copyWith(
                          color: isSelected ? coral500 : Colors.black,
                        ),
                      ),
                      if (isAnnual) ...[
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Save'.tr + ' 50%', // Calculate actual savings
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    package.storeProduct.priceString,
                    style: AppTextStyle.normalBold14.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: Text(
          'Premium Features'.tr,
          style: AppTextStyle.normalBold20.copyWith(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: coral500))
          : errorMessage.isNotEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadOfferings,
              child: Text('Try Again'.tr),
            ),
          ],
        ),
      )
          : offerings?.current == null
          ? Center(
        child: Text(
          'No subscription options available'.tr,
          style: TextStyle(fontSize: 16),
        ),
      )
          : SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header
            Text(
              'Join today, cancel anytime!'.tr,
              style: AppTextStyle.normalBold24.copyWith(
                color: coral500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Start FREE, cancel anytime!'.tr,
              style: AppTextStyle.normalBold16.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),

            // Features section
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'All Access Features:'.tr,
                    style: AppTextStyle.normalBold18.copyWith(
                      color: coral500,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Unlock unlimited access to your personal Yokai Companion, the full Manga & Anime library, and advanced mood tracking.'.tr,
                    style: AppTextStyle.normalBold14.copyWith(
                      fontWeight: FontWeight.normal,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildFeatureItem('Unlock full access'.tr),
                  _buildFeatureItem('Try for yourself'.tr),
                  _buildFeatureItem('Free'.tr + ' 7-day trial'),
                ],
              ),
            ),

            SizedBox(height: 30),

            // Package options
            Text(
              'Choose Your Plan'.tr,
              style: AppTextStyle.normalBold18.copyWith(
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),

            ...offerings!.current!.availablePackages
                .map((package) => _buildPackageOption(package))
                .toList(),

            SizedBox(height: 30),

            // Continue button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: selectedPackage != null
                    ? () => _purchasePackage(selectedPackage!)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: coral500,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  'Continue'.tr,
                  style: AppTextStyle.normalBold18.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),

            // Trial info
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'Day 5:'.tr,
                    style: AppTextStyle.normalBold14.copyWith(
                      color: Colors.blue.shade700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'We\'ll send you an email reminder that your free trial is ending soon'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Day 7:'.tr,
                    style: AppTextStyle.normalBold14.copyWith(
                      color: Colors.blue.shade700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'You\'ll be charged after your 7-day free trial. Cancel anytime before it ends to avoid charges.'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Footer links
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    // Open Terms of Use
                  },
                  child: Text(
                    'Terms of Use'.tr,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Open Privacy Policy
                  },
                  child: Text(
                    'Privacy Policy'.tr,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),

            TextButton(
              onPressed: _restorePurchases,
              child: Text(
                'Restore purchases'.tr,
                style: TextStyle(
                  color: coral500,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}