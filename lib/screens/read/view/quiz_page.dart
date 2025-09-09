/// quiz_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:yokai_quiz_app/global.dart';
import 'package:yokai_quiz_app/screens/read/view/start_activity_page.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/const.dart';
import 'package:get/get.dart';
import '../../../util/text_styles.dart';
import 'question_screen.dart';

class QuizPage extends StatefulWidget {
  String chapterId;
  String chapter;
  String title;

  QuizPage({super.key, required this.chapterId, required this.chapter, required this.title});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorWhite,
      body: SafeArea(  // Added SafeArea instead of manual padding
        child: Column(// This Column is important as a Flex widget
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Padding(
              padding: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        nextPageOff(
                            context,
                            StartActivityPage(
                                chapter: widget.chapter,
                                chapterId: widget.chapterId));
                      },
                      child: SvgPicture.asset(
                        'icons/arrowLeft.svg',
                        height: 35,
                        width: 35,
                      ),
                    ),
                    const SizedBox(width: 10),  // Replace custom spacing
                    Text(
                      widget.title,
                      style: AppTextStyle.normalBold16.copyWith(color: coral500),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 2),  // Replace custom spacing
            // Content section
            Expanded(  // This Expanded is properly inside a Column
              child: QuestionScreen(
                chapterId: widget.chapterId,
                reviewTest: false,
                title: widget.title,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
