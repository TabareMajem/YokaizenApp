import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:yokai_quiz_app/global.dart';
import 'package:yokai_quiz_app/screens/read/view/start_activity_page.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/const.dart';
import 'package:get/get.dart';
import '../../../util/text_styles.dart';
import '../controller/question_page.dart';

class QuizPage extends StatefulWidget {
  String chapterId;
  String chapter;

  QuizPage({super.key, required this.chapterId, required this.chapter});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorWhite,
      body: Padding(
        padding: const EdgeInsets.only(bottom: 16, top: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                right: 15,
                left: 15,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      // ReadController.singleChild(true);

                      // ReadController.scrollToTopSingleChild();
                      nextPageOff(
                          context,
                          StartActivityPage(
                              chapter: widget.chapter,
                              chapterId: widget.chapterId));
                      // Get.back();
                    },
                    child: SvgPicture.asset(
                      'icons/arrowLeft.svg',
                      height: 35,
                      width: 35,
                    ),
                  ),
                  1.pw,
                  Text(
                    'Healthy Coping Mechanisms Quiz'.tr,
                    style: AppTextStyle.normalBold16.copyWith(color: coral500),
                  ),
                ],
              ),
            ),
            2.ph,
            Expanded(
              child: Question(
                chapterId: widget.chapterId,
                reviewTest: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
