import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:yokai_quiz_app/Widgets/new_button.dart';
import 'package:yokai_quiz_app/Widgets/progressBar.dart';
import 'package:yokai_quiz_app/Widgets/progressHud.dart';
import 'package:yokai_quiz_app/global.dart';
import 'package:yokai_quiz_app/screens/refer_and_earn/controller/refer_and_earn.dart';
import 'package:yokai_quiz_app/screens/challenge/view/challenge_screen.dart';
import 'package:yokai_quiz_app/screens/todo/controller/todo_controller.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/const.dart';
import 'package:yokai_quiz_app/util/text_styles.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  @override
  void initState() {
    super.initState();
    isLoading(true);
    TodoController.fetchTodoData().then((value) {
      ReferAndEarnController.createReferralCode().then((value) {
        isLoading(false);
      });
    });
  }

  RxBool isLoading = false.obs;
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return ProgressHUD(
        isLoading: isLoading.value,
        child:
        // Stack(
        //   children: [
            Scaffold(
              body: SingleChildScrollView(
                // Wrap everything in SingleChildScrollView
                child: Container(
                  padding: const EdgeInsets.only(top: 65, left: 20, right: 20),
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
                              "To Do List".tr,
                              style: AppTextStyle.normalBold20
                                  .copyWith(color: coral500),
                            ),
                          ],
                        ),
                      ),
                      5.ph, // Add spacing
                      _buildCategorySection(
                        "Share & Earn".tr,
                        TodoController.todoList
                            .where((task) => task['type'] == 'share')
                            .toList(),
                      ),
                      3.ph,
                      // _buildCategorySection(
                      //   "Invite to a Challenge".tr,
                      //   TodoController.todoList
                      //       .where((task) => task['type'] == 'invite')
                      //       .toList(),
                      // ),
                    ],
                  ),
                ),
              ),
            ),

            // Positioned.fill(
            //   child: BackdropFilter(
            //     filter:  ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            //     child: Container(
            //       color: Colors.black.withOpacity(0.2),
            //     ),
            //   ),
            // ),

        //   ],
        // ),
      );
    });
  }

  Widget _buildCategorySection(String title, List<Map> tasks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyle.normalBold18.copyWith(color: coral500),
        ),
        2.ph,
        ...tasks.map((task) => _buildTaskCard(task)).toList(),
      ],
    );
  }

  Widget _buildTaskCard(Map task) {
    final screenSize = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        if (task['type'] == "share") {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  child: Container(
                    height: 170,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          "Share and Earn".tr,
                          style: AppTextStyle.normalBold18
                              .copyWith(color: coral500),
                        ),
                        1.ph,
                        Text(
                          "Share your Yokai with your friends and family".tr,
                          textAlign: TextAlign.center,
                          style: AppTextStyle.normalSemiBold16
                              .copyWith(fontWeight: FontWeight.normal),
                        ),
                        1.ph,
                        const Spacer(),
                        CustomButton(
                          text: "Copy Referral".tr,
                          onPressed: () {
                            Clipboard.setData(ClipboardData(
                                    text: ReferAndEarnController
                                        .referralCode.value))
                                .then((_) {
                              showSucessMessage(
                                  "Share to friends and earn".tr, colorSuccess);
                            });
                          },
                          width: screenSize.width / 2,
                          height: 40,
                          textSize: 10,
                        )
                      ],
                    ),
                  ),
                );
              });
        }
        if (task['type'] == "invite") {
          // showDialog(
          //     context: context,
          //     builder: (BuildContext context) {
          //       return Dialog(
          //         child: Text("Invite to a Challenge".tr),
          //       );
          //     });
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChallengeScreen(),));
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: task['type'] == 'share'
                        ? const Color(0xFF1CB2F1)
                        : null,
                    gradient: task['type'] == 'invite'
                        ? const LinearGradient(
                            colors: [Color(0xFFC7611B), Color(0xFFFF9B57)],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          )
                        : null,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Image.asset(
                    task['type'] == "share"
                        ? "icons/share.png"
                        : "icons/sword.png",
                    height: 60,
                    width: 60,
                  ),
                ),
                const SizedBox(width: 8), // Use SizedBox instead of 1.pw
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task['title'],
                        style: AppTextStyle.normalBold16,
                      ),
                      const SizedBox(height: 4), // Use SizedBox instead of 1.ph
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Share the app with friends to earn".tr,
                              style: AppTextStyle.normalBold14.copyWith(
                                fontWeight: FontWeight.w400,
                                color: Colors.black38,
                              ),
                            ),
                            TextSpan(
                              text: "${task['badge']} ",
                              style: AppTextStyle.normalBold14.copyWith(
                                fontWeight: FontWeight.w400,
                                color: coral500,
                              ),
                            ),
                            TextSpan(
                              text: "badge and free membership.".tr,
                              style: AppTextStyle.normalBold14.copyWith(
                                fontWeight: FontWeight.w400,
                                color: Colors.black38,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ProgressBar(
              totalValue: task['isCompleted'],
              completedValue: task['isActive'],
            ),
            const SizedBox(height: 8),
            if (task['isCompleted'] == task['isActive'])
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: CustomButton(
                  text: 'Claim reward',
                  onPressed: () {},
                  textSize: 10,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
