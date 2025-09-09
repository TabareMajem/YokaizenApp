// // badge_screen.dart -->

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yokai_quiz_app/screens/badges/controller/badge_controller.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/const.dart';
import 'package:yokai_quiz_app/util/custom_app_bar.dart';
import 'package:yokai_quiz_app/util/text_styles.dart';

import '../model/badge_response.dart';

class BadgeScreen extends StatefulWidget {
  const BadgeScreen({super.key});

  @override
  State<BadgeScreen> createState() => _BadgeScreenState();
}

class _BadgeScreenState extends State<BadgeScreen> {
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;

  @override
  void initState() {
    super.initState();
    isLoading(true);
    fetchData();
  }

  Future<void> fetchData() async {
    print("Badges Screen fetchData got invoked");
    try {
      isLoading(true);
      hasError(false);
      final success = await BadgeController.fetchAllBadges();
      if (!success) {
        hasError(true);
      }
    } catch (e) {
      print("Error fetching badges: $e");
      hasError(true);
    } finally {
      isLoading(false);
    }
  }

  List<BadgeResponse> getBadgesByCategory(String criteria) {
    return BadgeController.badges
        .where((badge) => badge.criteria.toLowerCase().contains(criteria.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Failed to load badges'.tr,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(84, 3, 117, 1),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: fetchData,
                  child: Text('Retry'.tr),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                CustomAppBar(
                  title: "Badges".tr,
                  isBackButton: true,
                  isColor: false,
                  onButtonPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildBadgeCategory(
                      title: "Share the app with your friends:",
                      badges: getBadgesByCategory("app shar"),
                    ),
                    buildBadgeCategory(
                      title: "Chat regularly:",
                      badges: getBadgesByCategory("chat"),
                    ),
                    buildBadgeCategory(
                      title: "Complete Story Arc:",
                      badges: getBadgesByCategory("story"),
                    ),
                    buildBadgeCategory(
                      title: "Engage with Mental Health Activities:",
                      badges: getBadgesByCategory("mindful"),
                    ),
                    buildBadgeCategory(
                      title: "Just show up on Yokaizen:",
                      badges: getBadgesByCategory("streak daily login"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget buildBadgeCategory({required String title, required List<BadgeResponse> badges,}) {
    if (badges.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(84, 3, 117, 1),
          ),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.8,
          ),
          itemCount: badges.length,
          itemBuilder: (context, index) {
            final badge = badges[index];
            return GestureDetector(
              onTap: () => _showBadgeDetails(context, badge),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            badge.image,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.error),
                              );
                            },
                          ),
                        ),
                        if (!badge.isUserRewarded)
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.black.withOpacity(0.5),
                            ),
                            child: const Icon(
                              Icons.lock,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    badge.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color.fromRGBO(155, 26, 214, 1),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  void _showBadgeDetails(BuildContext context, BadgeResponse badge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(badge.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.network(
                  badge.image,
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.error),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text(badge.description),
              const SizedBox(height: 8),
              Text('Criteria: ${badge.criteria}'),
              if (badge.stepCount > 0) ...[
                const SizedBox(height: 8),
                Text('Steps required: ${badge.stepCount}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'.tr),
          ),
        ],
      ),
    );
  }
}

//
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:get/get.dart';
// import 'package:yokai_quiz_app/screens/badges/controller/badge_controller.dart';
// import 'package:yokai_quiz_app/util/colors.dart';
// import 'package:yokai_quiz_app/util/const.dart';
// import 'package:yokai_quiz_app/util/custom_app_bar.dart';
// import 'package:yokai_quiz_app/util/text_styles.dart';
//
// class BadgeScreen extends StatefulWidget {
//   const BadgeScreen({super.key});
//
//   @override
//   State<BadgeScreen> createState() => _BadgeScreenState();
// }
//
// class _BadgeScreenState extends State<BadgeScreen> {
//   @override
//   void initState() {
//     super.initState();
//     isLoading(true);
//     fetchData();
//   }
//
//   fetchData() async {
//     print("Badges Screen fetchData got invoked");
//     await BadgeController.fetchAllBadges().then((value) {
//       isLoading(false);
//     });
//   }
//
//   RxBool isLoading = false.obs;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Container(
//           padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               CustomAppBar(
//                   title: "Badges",
//                   isBackButton: true,
//                   isColor: false,
//                   onButtonPressed: () {
//                     Navigator.pop(context);
//                   }
//               ),
//               3.ph,
//               buildBadgeCategory(
//                 title: "Share the app with your friends:".tr,
//                 category: "share".tr,
//               ),
//               3.ph,
//               buildBadgeCategory(
//                 title: "Chat regularly:".tr,
//                 category: "chat".tr,
//               ),
//               3.ph,
//               buildBadgeCategory(
//                 title: "Engage with Mental Health Activities:".tr,
//                 category: "mentality",
//               ),
//               3.ph,
//               buildBadgeCategory(
//                 title: "Complete Story Arcs:".tr,
//                 category: "arcs".tr,
//               ),
//               3.ph,
//               buildBadgeCategory(
//                 title: "Just show up on Yokaizen:".tr,
//                 category: "showup".tr,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget buildBadgeCategory({required String title, required String category}) {
//     final badges = BadgeController.badges
//         .where((badge) => badge['type'] == category)
//         .toList();
//
//     if (badges.isEmpty) {
//       return const SizedBox.shrink();
//     }
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: AppTextStyle.normalBold16,
//         ),
//         2.ph,
//         GridView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 3,
//             childAspectRatio: 0.9,
//             crossAxisSpacing: 10,
//             mainAxisSpacing: 10,
//           ),
//           itemCount: badges.length,
//           itemBuilder: (context, index) {
//             final badge = badges[index];
//             return Column(
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(20),
//                   child: Image.asset(
//                     badge['icon'],
//                     width: 70, // Set a fixed width for the icon
//                     height: 70,
//                   ),
//                 ),
//                 1.ph,
//                 Text(
//                   badge['name'],
//                   style: AppTextStyle.normalBold14.copyWith(
//                     fontSize: 12,
//                     color: indigo700,
//                   ),
//                   overflow: TextOverflow.ellipsis, // Truncate if too long
//                 ),
//               ],
//             );
//           },
//         ),
//       ],
//     );
//   }
// }