// // screens/yokai_tutorial_view.dart
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../../../../../services/purchase_service.dart';
// import '../../../../subscriptions/paywall_screens.dart';
//
// class YokaiTutorialView extends StatelessWidget {
//   final String yokaiType;
//   final String yokaiName;
//   final Function(String, String) onConfirm;
//
//   const YokaiTutorialView({
//     Key? key,
//     required this.yokaiType,
//     required this.yokaiName,
//     required this.onConfirm,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 24),
//       child: Column(
//         children: [
//           Expanded(
//             child: SingleChildScrollView(
//               child: Column(
//                 children: [
//                   const SizedBox(height: 20),
//                   // Yokai image
//                   Container(
//                     height: 180,
//                     width: 180,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       border: Border.all(
//                         color: const Color(0xFFEF5A20),
//                         width: 4,
//                       ),
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(90),
//                       child: Image.asset(
//                         'gif/${yokaiType}1.gif',
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   // Yokai name
//                   Text(
//                     yokaiName,
//                     style: GoogleFonts.montserrat(
//                       fontSize: 28,
//                       fontWeight: FontWeight.bold,
//                       color: const Color(0xFF444C5C),
//                     ),
//                   ),
//                   const SizedBox(height: 32),
//                   // Tutorial sections
//                   _buildTutorialItem(
//                     title: 'Talk with Your Yokai'.tr,
//                     description: 'Your Yokai companion is always ready to talk and help you with your emotions.'.tr,
//                     icon: Icons.chat_bubble_outline,
//                   ),
//                   _buildTutorialItem(
//                     title: 'Track Your Progress'.tr,
//                     description: 'Monitor your emotional growth and learning journey with detailed progress tracking.'.tr,
//                     icon: Icons.trending_up,
//                   ),
//                   _buildTutorialItem(
//                     title: 'Learn and Grow'.tr,
//                     description: 'Develop emotional intelligence and coping skills through fun interactions.'.tr,
//                     icon: Icons.school_outlined,
//                   ),
//                   _buildTutorialItem(
//                     title: 'Daily Companion'.tr,
//                     description: 'Your Yokai will be with you every day to support your emotional wellbeing.'.tr,
//                     icon: Icons.calendar_today,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),
//           // Continue button
//           _buildContinueButton(context),
//           const SizedBox(height: 24),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTutorialItem({
//     required String title,
//     required String description,
//     required IconData icon,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 24.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: const Color(0xFFFFF2ED),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(
//               icon,
//               color: const Color(0xFFEF5A20),
//               size: 24,
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: GoogleFonts.montserrat(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                     color: const Color(0xFF444C5C),
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   description,
//                   style: GoogleFonts.montserrat(
//                     fontSize: 14,
//                     color: Colors.grey[600],
//                     height: 1.5,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildContinueButton(BuildContext context) {
//     return GestureDetector(
//       onTap: () async {
//         final isPremium = await PurchaseService.hasPremiumAccess();
//
//         if (isPremium) {
//           // User is premium, proceed directly
//           onConfirm(yokaiType, yokaiName);
//           Get.back(result: 1);
//         } else {
//           // Show paywall
//           final result = await Get.to<bool>(
//                 () => PaywallScreen(
//               yokaiType: yokaiType,
//               yokaiName: yokaiName,
//             ),
//           );
//
//           if (result == true) {
//             // Purchase was successful
//             onConfirm(yokaiType, yokaiName);
//             Get.back(result: 1);
//           }
//         }
//       },
//       child: Container(
//         width: MediaQuery.of(context).size.width,
//         height: 50,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(10),
//           color: const Color(0xFFEF5A20),
//         ),
//         alignment: Alignment.center,
//         child: Text(
//           "Continue".tr,
//           style: GoogleFonts.montserrat(
//             fontSize: 16,
//             color: Colors.white,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ),
//     );
//   }
// }