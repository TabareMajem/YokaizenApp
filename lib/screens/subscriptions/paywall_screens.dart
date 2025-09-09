// /// paywall_screen.dart
//
// import 'package:flutter/material.dart';
// import 'package:purchases_flutter/purchases_flutter.dart';
// import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
// import 'package:get/get.dart';
// import '../../services/purchase_service.dart';
//
// class PaywallScreen extends StatefulWidget {
//   final String yokaiType;
//   final String yokaiName;
//
//   const PaywallScreen({
//     Key? key,
//     required this.yokaiType,
//     required this.yokaiName,
//   }) : super(key: key);
//
//   @override
//   State<PaywallScreen> createState() => _PaywallScreenState();
// }
//
// class _PaywallScreenState extends State<PaywallScreen> {
//   bool _isLoading = true;
//   String _errorMessage = '';
//   static const String _tag = 'PaywallScreen';
//   List<StoreProduct> _products = [];
//   Offerings? _offerings;
//   bool _isTestMode = true;
//
//   @override
//   void initState() {
//     super.initState();
//     print('[$_tag] Initializing PaywallScreen');
//     _initializePaywall();
//   }
//
//   Future<void> _initializePaywall() async {
//     if (!mounted) return;
//
//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//     });
//
//     try {
//       print('[$_tag] Checking RevenueCat configuration');
//       final isConfigured = await Purchases.isConfigured;
//       print('[$_tag] RevenueCat configured: $isConfigured');
//
//       if (!isConfigured) {
//         print('[$_tag] Initializing RevenueCat');
//         await PurchaseService.initPlatformState();
//       }
//
//       // Always try to get offerings and show the RevenueCat hosted paywall
//       print('[$_tag] Fetching offerings');
//       try {
//         _offerings = await Purchases.getOfferings();
//         print('[$_tag] Offerings fetched. Current offering: ${_offerings?.current?.identifier}');
//         print('[$_tag] Available offerings: ${_offerings?.all.keys.join(", ")}');
//
//         // Always attempt to show the RevenueCat hosted paywall
//         await _showPaywall();
//         return;
//       } catch (e) {
//         print('[$_tag] Error fetching offerings: $e');
//         setState(() {
//           _errorMessage = 'Unable to load subscription options. Please try again later.';
//           _isLoading = false;
//         });
//       }
//
//     } catch (e) {
//       print('[$_tag] Error in initialization: $e');
//       setState(() {
//         _errorMessage = 'Unable to load subscription options. Please try again later.';
//         _isLoading = false;
//       });
//     }
//   }
//
//   Future<void> _showPaywall() async {
//     try {
//       print('[$_tag] Attempting to show paywall');
//
//       // Always try to show the RevenueCat hosted paywall
//       if (_offerings?.current != null) {
//         print('[$_tag] Showing RevenueCatUI paywall');
//
//         // Use the RevenueCatUI to present the paywall
//         final result = await RevenueCatUI.presentPaywall(
//           offering: _offerings!.current!,
//           displayCloseButton: true,
//         );
//
//         print('[$_tag] Paywall result: $result');
//
//         // Check if purchase was successful
//         final customerInfo = await Purchases.getCustomerInfo();
//         final isPremium = customerInfo.entitlements.active.containsKey('premium');
//         print('[$_tag] Premium status after paywall: $isPremium');
//
//         if (isPremium && mounted) {
//           Navigator.of(context).pop(true);
//           return;
//         }
//       } else {
//         print('[$_tag] No current offering available for RevenueCatUI paywall');
//         setState(() {
//           _errorMessage = 'Unable to load subscription options. Please try again later.';
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       print('[$_tag] Error showing paywall: $e');
//       setState(() {
//         _errorMessage = 'Unable to show subscription options. Please try again later.';
//         _isLoading = false;
//       });
//     }
//   }
//
//   Future<void> _restorePurchases() async {
//     if (!mounted) return;
//
//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//     });
//
//     try {
//       print('[$_tag] Attempting to restore purchases');
//       final customerInfo = await Purchases.restorePurchases();
//       print('[$_tag] Restore result: ${customerInfo.entitlements.active}');
//
//       if (customerInfo.entitlements.active.isNotEmpty) {
//         print('[$_tag] Purchases restored successfully');
//         if (mounted) {
//           Navigator.of(context).pop(true);
//         }
//       } else {
//         print('[$_tag] No purchases to restore');
//         setState(() {
//           _errorMessage = 'No previous purchases found to restore';
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       print('[$_tag] Error restoring purchases: $e');
//       setState(() {
//         _errorMessage = 'Restore failed. Please try again later.';
//         _isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     print('[$_tag] Building PaywallScreen widget');
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         actions: [
//           TextButton(
//             onPressed: _isLoading ? null : _restorePurchases,
//             child: Text(
//               'Restore'.tr,
//               style: TextStyle(
//                   color: _isLoading ? Colors.grey : const Color(0xFFEF5A20)
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator(color: Color(0xFFEF5A20)))
//           : _errorMessage.isNotEmpty
//               ? _buildErrorView()
//               : Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         'Loading subscription options...'.tr,
//                         style: const TextStyle(fontSize: 16),
//                       ),
//                       const SizedBox(height: 20),
//                       ElevatedButton(
//                         onPressed: _initializePaywall,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFFEF5A20),
//                         ),
//                         child: Text('Retry'.tr),
//                       ),
//                     ],
//                   ),
//                 ),
//     );
//   }
//
//   Widget _buildErrorView() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 32.0),
//             child: Text(
//               _errorMessage,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontSize: 16,
//                 color: Colors.red,
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: _initializePaywall,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFEF5A20),
//             ),
//             child: Text('Retry'.tr),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSubscriptionView() {
//     // If in test mode and no real products, show mock subscription options
//     if (_isTestMode && _products.isEmpty) {
//       return _buildMockSubscriptionView();
//     }
//
//     // If we have real products, show them
//     if (_products.isNotEmpty) {
//       return _buildRealSubscriptionView();
//     }
//
//     // Fallback - should not reach here normally
//     return Center(
//       child: Text('No subscription options available'.tr),
//     );
//   }
//
//   Widget _buildMockSubscriptionView() {
//     return SingleChildScrollView(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             const SizedBox(height: 20),
//             Text(
//               'Upgrade to Yokaizen Premium'.tr,
//               style: const TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF6B46C1),
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Unlock all features and get unlimited access'.tr,
//               style: const TextStyle(
//                 fontSize: 16,
//                 color: Colors.black87,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 30),
//
//             // Mock subscription cards
//             _buildSubscriptionCard(
//               title: 'Monthly Premium'.tr,
//               price: '\$9.99',
//               period: 'per month'.tr,
//               isPopular: false,
//               onTap: () => _handleMockPurchase('monthly'),
//             ),
//
//             const SizedBox(height: 16),
//
//             _buildSubscriptionCard(
//               title: 'Annual Premium'.tr,
//               price: '\$59.99',
//               period: 'per year'.tr,
//               isPopular: true,
//               savings: '50% savings'.tr,
//               onTap: () => _handleMockPurchase('annual'),
//             ),
//
//             const SizedBox(height: 30),
//
//             // Features list
//             ..._buildFeaturesList(),
//
//             const SizedBox(height: 20),
//
//             Text(
//               'This is a test mode. In production, real subscription options will be available.'.tr,
//               style: const TextStyle(
//                 fontSize: 12,
//                 color: Colors.grey,
//                 fontStyle: FontStyle.italic,
//               ),
//               textAlign: TextAlign.center,
//             ),
//
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildRealSubscriptionView() {
//     return ListView(
//       padding: const EdgeInsets.all(16),
//       children: [
//         Text(
//           'Choose your subscription'.tr,
//           style: const TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//             color: Color(0xFF6B46C1),
//           ),
//           textAlign: TextAlign.center,
//         ),
//         const SizedBox(height: 24),
//         ..._products.map((product) => Card(
//           elevation: 4,
//           margin: const EdgeInsets.only(bottom: 16),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: InkWell(
//             onTap: () => _purchaseProduct(product),
//             borderRadius: BorderRadius.circular(12),
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     product.title,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     product.description,
//                     style: const TextStyle(
//                       fontSize: 14,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         product.priceString,
//                         style: const TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xFFEF5A20),
//                         ),
//                       ),
//                       const Icon(
//                         Icons.arrow_forward_ios,
//                         size: 16,
//                         color: Colors.grey,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         )).toList(),
//
//         const SizedBox(height: 24),
//
//         // Features list
//         ..._buildFeaturesList(),
//       ],
//     );
//   }
//
//   List<Widget> _buildFeaturesList() {
//     final features = [
//       'Unlimited access to all Yokai spirits'.tr,
//       'Advanced personality insights'.tr,
//       'Premium badges and rewards'.tr,
//       'Ad-free experience'.tr,
//       'Priority support'.tr,
//     ];
//
//     return [
//       const SizedBox(height: 16),
//       Text(
//         'Premium Features'.tr,
//         style: const TextStyle(
//           fontSize: 18,
//           fontWeight: FontWeight.bold,
//         ),
//         textAlign: TextAlign.center,
//       ),
//       const SizedBox(height: 16),
//       ...features.map((feature) => Padding(
//         padding: const EdgeInsets.only(bottom: 12),
//         child: Row(
//           children: [
//             const Icon(
//               Icons.check_circle,
//               color: Color(0xFF6B46C1),
//               size: 20,
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 feature,
//                 style: const TextStyle(fontSize: 14),
//               ),
//             ),
//           ],
//         ),
//       )).toList(),
//     ];
//   }
//
//   Widget _buildSubscriptionCard({
//     required String title,
//     required String price,
//     required String period,
//     required bool isPopular,
//     String? savings,
//     required Function() onTap,
//   }) {
//     return Stack(
//       clipBehavior: Clip.none,
//       children: [
//         Card(
//           elevation: 4,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//             side: isPopular
//                 ? const BorderSide(color: Color(0xFFEF5A20), width: 2)
//                 : BorderSide.none,
//           ),
//           child: InkWell(
//             onTap: onTap,
//             borderRadius: BorderRadius.circular(12),
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 children: [
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         price,
//                         style: const TextStyle(
//                           fontSize: 28,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xFFEF5A20),
//                         ),
//                       ),
//                     ],
//                   ),
//                   Text(
//                     period,
//                     style: const TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey,
//                     ),
//                   ),
//                   if (savings != null) ...[
//                     const SizedBox(height: 8),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 8,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFFFF3E0),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Text(
//                         savings,
//                         style: const TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xFFEF5A20),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           ),
//         ),
//         if (isPopular)
//           Positioned(
//             top: -10,
//             right: -10,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFEF5A20),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Text(
//                 'Best Value'.tr,
//                 style: const TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//       ],
//     );
//   }
//
//   Future<void> _purchaseProduct(StoreProduct product) async {
//     setState(() => _isLoading = true);
//
//     try {
//       print('[$_tag] Attempting to purchase: ${product.identifier}');
//       final result = await Purchases.purchaseProduct(product.identifier);
//       print('[$_tag] Purchase result: $result');
//
//       if (mounted) {
//         Navigator.of(context).pop(true);
//       }
//     } catch (e) {
//       print('[$_tag] Purchase error: $e');
//       setState(() {
//         _isLoading = false;
//         _errorMessage = 'Purchase failed. Please try again.';
//       });
//     }
//   }
//
//   void _handleMockPurchase(String plan) {
//     // In a real app, this would initiate the purchase flow
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Test Mode'.tr),
//         content: Text(
//           'This is a test version. In the production app, this would initiate a real purchase for the $plan plan.'.tr,
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: Text('OK'.tr),
//           ),
//         ],
//       ),
//     );
//   }
// }