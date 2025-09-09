/// assessments_screen.dart

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yokai_quiz_app/global.dart';
import 'package:yokai_quiz_app/screens/assessments/controller/assessment_controller.dart';
import 'package:yokai_quiz_app/screens/personality/view/personality_screen.dart';
import 'package:yokai_quiz_app/util/custom_app_bar.dart';
import 'package:yokai_quiz_app/Widgets/new_button.dart';
import 'package:yokai_quiz_app/Widgets/second_custom_button.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/text_styles.dart';
import 'package:yokai_quiz_app/util/central_intelligence_example.dart';


class AssessmentsScreen extends StatefulWidget {
  final String quizType;
  final String testName;
  final String testImage;

  const AssessmentsScreen({
    super.key,
    required this.quizType,
    required this.testName,
    required this.testImage,
  });

  @override
  State<AssessmentsScreen> createState() => _AssessmentsScreenState();
}

class _AssessmentsScreenState extends State<AssessmentsScreen> {
  int currentQuestionIndex = 0;
  int? selectedOptionIndex;
  List<Question> questions = [];
  bool isLoading = true;
  bool isSubmitting = false;
  List<int> userAnswers = [];
  
  // List to store user answers in the required format for API submission
  List<Map<String, dynamic>> userAnswersForSubmission = [];

  // Map quiz types to quiz IDs for API submission
  final Map<String, int> quizTypeToId = {
    'bartle-test': 1,
    'big-five-personality': 2,
    'personality-assessment': 3,
    'eq': 4,
    'values-strengths': 5,
  };

  @override
  void initState() {
    super.initState();
    loadQuizData();
  }

  Future<void> loadQuizData() async {
    setState(() => isLoading = true);

    try {
      // Check if quiz data is already loaded in controller
      if (AssessmentController.currentQuiz.value == null) {
        await AssessmentController.fetchQuizByType(widget.quizType);
      }

      // Get questions from the controller
      questions = AssessmentController.convertToQuestions();

      if (questions.isNotEmpty) {
        userAnswers = List<int>.filled(questions.length, -1);
        print('Loaded ${questions.length} questions for ${widget.quizType}');
      } else {
        print('No questions found for ${widget.quizType}');
      }
    } catch (e) {
      print('Error loading quiz data: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void handleNextQuestion() {
    if (selectedOptionIndex != null) {
      // Save the answer
      userAnswers[currentQuestionIndex] = selectedOptionIndex!;
      
      // Create answer object for API submission
      final answerObject = {
        "question_index": currentQuestionIndex,
        "selected_answer": selectedOptionIndex,
        "selected_answers": [selectedOptionIndex],
        "answer_text": questions[currentQuestionIndex].options?[selectedOptionIndex!] ?? "",
        "interaction_prompt": ""
      };
      
      // Check if we're updating an existing answer or adding a new one
      bool answerExists = false;
      for (int i = 0; i < userAnswersForSubmission.length; i++) {
        if (userAnswersForSubmission[i]["question_index"] == currentQuestionIndex) {
          userAnswersForSubmission[i] = answerObject;
          answerExists = true;
          break;
        }
      }
      
      if (!answerExists) {
        userAnswersForSubmission.add(answerObject);
      }

      if (currentQuestionIndex < questions.length - 1) {
        setState(() {
          currentQuestionIndex++;
          // Set the previously saved answer for this question if it exists
          selectedOptionIndex = userAnswers[currentQuestionIndex] != -1
              ? userAnswers[currentQuestionIndex]
              : null;
        });
      } else {
        // Submit results and show completion dialog
        customPrint("handleNextQuestion print userAnswersForSubmission : $userAnswersForSubmission");
        submitAssessment();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an option to continue'.tr)),
      );
    }
  }

  void handlePreviousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
        // Set the previously saved answer for this question
        selectedOptionIndex = userAnswers[currentQuestionIndex] != -1
            ? userAnswers[currentQuestionIndex]
            : null;
      });
    } else {
      showExitConfirmationDialog();
    }
  }

  Future<void> submitAssessment() async {
    setState(() {
      isSubmitting = true;
    });

    try {
      // Use the controller method to submit the assessment
      final result = await AssessmentController.submitAssessment(
        widget.quizType, 
        userAnswersForSubmission
      );

      if (result) {
        // 🎯 INTEGRATE WITH CENTRAL INTELLIGENCE
        try {
          // Calculate score based on answers (simplified calculation)
          int score = _calculateScore();
          
          // Report to Central Intelligence
          await _reportToCentralIntelligence(score);
          
          customPrint("✅ Assessment data sent to Central Intelligence");
        } catch (e) {
          customPrint("⚠️ Central Intelligence integration failed: $e");
          // Continue with normal flow even if CI fails
        }
        
        showCompletionDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit assessment. Please try again.'.tr)),
        );
      }
    } catch (e) {
      customPrint("Error submitting assessment: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit assessment. Please try again.'.tr)),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  /// 🎯 Central Intelligence Integration
  Future<void> _reportToCentralIntelligence(int score) async {
    try {
      // Import this at the top of the file:
      // import '../../../util/central_intelligence_example.dart';
      
      await CentralIntelligenceExample.integrateQuizCompletion(
        quizId: widget.quizType,
        score: score,
        answers: userAnswersForSubmission.map((a) => a['selected_answer'].toString()).toList(),
        quizType: widget.quizType,
      );
    } catch (e) {
      customPrint("Error reporting to Central Intelligence: $e");
    }
  }

  /// Calculate score based on user answers
  int _calculateScore() {
    // Simple scoring: assume correct answers for demo
    // In real implementation, this would compare with correct answers
    int correctAnswers = 0;
    for (var answer in userAnswersForSubmission) {
      if (answer['selected_answer'] != null) {
        correctAnswers++;
      }
    }
    
    // Convert to percentage
    if (questions.isNotEmpty) {
      return ((correctAnswers / questions.length) * 100).round();
    }
    return 0;
  }

  void showExitConfirmationDialog() {
    final screenSize = MediaQuery.of(context).size;
    
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15)
          ),
          child: Container(
            width: MediaQuery.of(context).size.width / 1.4,
            height: MediaQuery.of(context).size.height / 3,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [
                BoxShadow(
                  offset: const Offset(12, 26),
                  blurRadius: 50,
                  spreadRadius: 0,
                  color: Colors.grey.withOpacity(.1)
                ),
              ]
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  "images/appLogo_yokai.png",
                  height: 50,
                  width: 55,
                ),
                const SizedBox(height: 15),
                Text(
                  "Exit Assessment?".tr,
                  style: AppTextStyle.normalBold20.copyWith(color: includedColor),
                ),
                const SizedBox(height: 3.5),
                Text(
                  "Are you sure you want to quit? If you quit, you'll have to start from question 1 again.".tr,
                  style: AppTextStyle.normalRegular14.copyWith(color: bordertext),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SecondCustomButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                        Navigator.of(context).pop(); // Return to previous screen
                      },
                      width: screenSize.width / 4,
                      text: "Quit".tr,
                      textSize: 14,
                    ),
                    CustomButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                      },
                      text: 'Cancel'.tr,
                      colorText: ironColor,
                      textSize: 14,
                      color: indigo50,
                      border: Border.all(color: colorBorder),
                      width: screenSize.width / 4,
                      mainAxisAlignment: MainAxisAlignment.center,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  // void showCompletionDialog() {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) => AlertDialog(
  //       title: Text('${widget.testName.tr} ${'Completed'.tr}'),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text('Thank you for completing the assessment!'.tr),
  //           const SizedBox(height: 8),
  //           Text(
  //             'Your responses have been recorded and your profile will be updated with the results.'.tr,
  //             style: TextStyle(
  //               fontSize: 14,
  //               color: Colors.grey[600],
  //             ),
  //           ),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () {
  //             Navigator.of(context).pop();
  //             Navigator.of(context).push(MaterialPageRoute(builder: (context) => PersonalityScreen(),));
  //           },
  //           child: Text('Done'.tr),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Container(
        color: Colors.black.withOpacity(0.7),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: 400, // Maximum width for the dialog
                  minWidth: 280, // Minimum width for the dialog
                ),
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Stack(
                    children: [
                      // Content
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: coral500.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_circle_outline_rounded,
                              size: 40,
                              color: coral500,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            '${widget.testName.tr} ${'Completed'.tr}',
                            style: AppTextStyle.normalBold20.copyWith(
                              color: coral500,
                              fontSize: 24,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Thank you for completing the assessment!'.tr,
                            textAlign: TextAlign.center,
                            style: AppTextStyle.normalBold14.copyWith(
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your responses have been recorded and your profile will be updated with the results.'.tr,
                            textAlign: TextAlign.center,
                            style: AppTextStyle.normalRegular14.copyWith(
                              color: Colors.black54,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();

                                // Navigator.of(context).pushReplacement(
                                //   MaterialPageRoute(
                                //     builder: (context) => const PersonalityScreen(),
                                //   ),
                                // );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: coral500,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Done'.tr,
                                style: AppTextStyle.normalBold16.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    if (isLoading || isSubmitting) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                isSubmitting ? 'Submitting your answers'.tr : 'Loading questions'.tr,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    if (questions.isEmpty) {
      return Scaffold(
        body: Center(child: Text('${'No questions available for'.tr} ${widget.testName.tr}')),
      );
    }

    final Question currentQuestion = questions[currentQuestionIndex];
    final List<String> options = currentQuestion.options ?? [];

    return WillPopScope(
      onWillPop: () async {
        showExitConfirmationDialog();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomAppBar(
                          title: widget.testName,
                          isBackButton: true,
                          isColor: false,
                          onButtonPressed: () => showExitConfirmationDialog(),
                        ),

                        const SizedBox(height: 24),

                        // Progress indicator
                        LinearProgressIndicator(
                          value: (currentQuestionIndex + 1) / questions.length,
                          backgroundColor: const Color(0xFFE5E7EB),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7C3AED)),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            '${'Question'.tr} ${currentQuestionIndex + 1} ${'of'.tr} ${questions.length}',
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 14,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Question text
                        Text(
                          currentQuestion.question ?? '',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4A4A4A),
                          ),
                        ),

                        // Scenario text if available
                        if (currentQuestion.scenario != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            currentQuestion.scenario!,
                            style: const TextStyle(
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),

                        // Question image
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: AssetImage(widget.testImage),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Options list
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (context, index) {
                            final isSelected = index == selectedOptionIndex;
                            final letters = ['A', 'B', 'C', 'D', 'E'];

                            return GestureDetector(
                              onTap: () {
                                setState(() => selectedOptionIndex = index);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected ? const Color(0xFF7C3AED) : const Color(0xFFD1D5DB),
                                      width: 1.5,
                                    ),
                                    color: isSelected ? const Color(0xFFF3E8FF) : Colors.white,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          width: 28,
                                          height: 28,
                                          margin: const EdgeInsets.symmetric(vertical: 12.0),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isSelected ? const Color(0xFF7C3AED) : const Color(0xFFECF0FF),
                                            border: isSelected ? null : Border.all(color: const Color(0xFFD1D5DB)),
                                          ),
                                          child: Center(
                                            child: Text(
                                              index < letters.length ? letters[index] : (index + 1).toString(),
                                              style: TextStyle(
                                                color: isSelected ? Colors.white : const Color(0xFF122E59),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 14.0),
                                            child: Text(
                                              options[index],
                                              style: TextStyle(
                                                color: const Color(0xFF122E59),
                                                fontSize: 14,
                                                fontFamily: 'Montserrat',
                                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Radio(
                                          activeColor: const Color(0xFF7C3AED),
                                          value: index,
                                          groupValue: selectedOptionIndex,
                                          onChanged: (value) {
                                            setState(() => selectedOptionIndex = value as int);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                          child: Text(
                            'Tap an option to select your answer.'.tr,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Navigation Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomButton(
                              text: 'Previous'.tr,
                              onPressed: handlePreviousQuestion,
                              colorText: primaryColor,
                              textSize: 14,
                              iconSvgPath: 'icons/arrowLeft.svg',
                              colorSvg: primaryColor,
                              color: indigo50,
                              border: Border.all(color: indigo700),
                              width: screenSize.width / 2.5,
                              mainAxisAlignment: MainAxisAlignment.center,
                            ),

                            SecondCustomButton(
                              onPressed: handleNextQuestion,
                              width: screenSize.width / 2.5,
                              iconSvgPath: 'icons/arrowRight.svg',
                              text: currentQuestionIndex == questions.length - 1 ? "Finish".tr : "Next".tr,
                              textSize: 14,
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:yokai_quiz_app/util/const.dart';
// import 'package:yokai_quiz_app/util/custom_app_bar.dart';
//
// import '../../../Widgets/new_button.dart';
// import '../../../Widgets/second_custom_button.dart';
// import '../../../util/colors.dart';
// import '../../read/controller/read_controller.dart';
// import '../../../models/get_activty_by_chapter_id.dart';
//
// class AssessmentsScreen extends StatefulWidget {
//   final String quizType;
//   final String testName;
//   final String testImage;
//
//   const AssessmentsScreen({
//     super.key,
//     required this.quizType,
//     required this.testName,
//     required this.testImage,
//   });
//
//   @override
//   State<AssessmentsScreen> createState() => _AssessmentsScreenState();
// }
//
// class _AssessmentsScreenState extends State<AssessmentsScreen> {
//   int currentQuestionIndex = 0;
//   int? selectedOptionIndex;
//   List<Question> questions = [];
//   bool isLoading = true;
//   List<int> userAnswers = [];
//
//   @override
//   void initState() {
//     super.initState();
//     fetchQuizData();
//   }
//
//   Future<void> fetchQuizData() async {
//     setState(() => isLoading = true);
//
//     try {
//       // Fetch data from API
//       await ReadController.getAllChapterByChapterId("53");
//       final activityResponse = await ReadController.getActivityDetailsByChapterId("53");
//
//       if (activityResponse) {
//         final quizzes = ReadController.getActivityByChapterId.value.quizzes ?? [];
//
//         print('Looking for quiz type: ${widget.quizType}');
//
//         // Find the quiz that matches the selected quiz type
//         for (var quiz in quizzes) {
//           if (quiz.quizType == widget.quizType) {
//             if (quiz.quiz?.questions != null) {
//               questions = quiz.quiz!.questions!;
//               userAnswers = List<int>.filled(questions.length, -1);
//               print('Found ${questions.length} questions for ${widget.quizType}');
//               break;
//             }
//           }
//         }
//       }
//     } catch (e) {
//       print('Error fetching quiz data: $e');
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }
//
//   void handleNextQuestion() {
//     if (selectedOptionIndex != null) {
//       // Save the answer
//       userAnswers[currentQuestionIndex] = selectedOptionIndex!;
//
//       if (currentQuestionIndex < questions.length - 1) {
//         setState(() {
//           currentQuestionIndex++;
//           // Set the previously saved answer for this question if it exists
//           selectedOptionIndex = userAnswers[currentQuestionIndex] != -1
//               ? userAnswers[currentQuestionIndex]
//               : null;
//         });
//       } else {
//         // Calculate results and navigate to results screen
//         calculateAndShowResults();
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select an option to continue')),
//       );
//     }
//   }
//
//   void handlePreviousQuestion() {
//     if (currentQuestionIndex > 0) {
//       setState(() {
//         currentQuestionIndex--;
//         // Set the previously saved answer for this question
//         selectedOptionIndex = userAnswers[currentQuestionIndex] != -1
//             ? userAnswers[currentQuestionIndex]
//             : null;
//       });
//     } else {
//       Navigator.pop(context);
//     }
//   }
//
//   void calculateAndShowResults() {
//     // For now, just show completion message
//     // TODO: Implement proper scoring based on quiz type
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('${widget.testName} Complete'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Thank you for completing the assessment!'),
//             const SizedBox(height: 8),
//             Text(
//               'Your responses have been recorded.',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey[600],
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               Navigator.of(context).pop(); // Return to previous screen
//             },
//             child: const Text('Done'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//
//     if (isLoading) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     if (questions.isEmpty) {
//       return Scaffold(
//         body: Center(child: Text('No questions available for ${widget.testName}')),
//       );
//     }
//
//     final Question currentQuestion = questions[currentQuestionIndex];
//     final List<String> options = currentQuestion.options ?? [];
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       CustomAppBar(
//                         title: widget.testName,
//                         isBackButton: true,
//                         isColor: false,
//                         onButtonPressed: () => Navigator.pop(context),
//                       ),
//
//                       const SizedBox(height: 24),
//
//                       // Progress indicator
//                       LinearProgressIndicator(
//                         value: (currentQuestionIndex + 1) / questions.length,
//                         backgroundColor: const Color(0xFFE5E7EB),
//                         valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7C3AED)),
//                       ),
//
//                       Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 8.0),
//                         child: Text(
//                           'Question ${currentQuestionIndex + 1} of ${questions.length}',
//                           style: const TextStyle(
//                             color: Color(0xFF6B7280),
//                             fontSize: 14,
//                           ),
//                         ),
//                       ),
//
//                       const SizedBox(height: 16),
//
//                       // Question text
//                       Text(
//                         currentQuestion.question ?? '',
//                         style: const TextStyle(
//                           fontSize: 17,
//                           fontWeight: FontWeight.w600,
//                           color: Color(0xFF4A4A4A),
//                         ),
//                       ),
//
//                       // Scenario text if available
//                       if (currentQuestion.scenario != null) ...[
//                         const SizedBox(height: 8),
//                         Text(
//                           currentQuestion.scenario!,
//                           style: const TextStyle(
//                             fontSize: 15,
//                             fontStyle: FontStyle.italic,
//                             color: Color(0xFF6B7280),
//                           ),
//                         ),
//                       ],
//
//                       const SizedBox(height: 16),
//
//                       // Question image
//                       Container(
//                         height: 200,
//                         width: double.infinity,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(12),
//                           image: DecorationImage(
//                             image: AssetImage(widget.testImage),
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       ),
//
//                       const SizedBox(height: 32),
//
//                       // Options list
//                       ListView.builder(
//                         physics: const NeverScrollableScrollPhysics(),
//                         shrinkWrap: true,
//                         itemCount: options.length,
//                         itemBuilder: (context, index) {
//                           final isSelected = index == selectedOptionIndex;
//                           final letters = ['A', 'B', 'C', 'D'];
//
//                           return GestureDetector(
//                             onTap: () {
//                               setState(() => selectedOptionIndex = index);
//                             },
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(vertical: 8.0),
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(10),
//                                   border: Border.all(
//                                     color: isSelected ? const Color(0xFF7C3AED) : const Color(0xFFD1D5DB),
//                                     width: 1.5,
//                                   ),
//                                   color: isSelected ? const Color(0xFFF3E8FF) : Colors.white,
//                                 ),
//                                 child: Container(
//                                   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Container(
//                                         width: 28,
//                                         height: 28,
//                                         margin: const EdgeInsets.symmetric(vertical: 12.0),
//                                         decoration: BoxDecoration(
//                                           shape: BoxShape.circle,
//                                           color: isSelected ? const Color(0xFF7C3AED) : const Color(0xFFECF0FF),
//                                           border: isSelected ? null : Border.all(color: const Color(0xFFD1D5DB)),
//                                         ),
//                                         child: Center(
//                                           child: Text(
//                                             letters[index],
//                                             style: TextStyle(
//                                               color: isSelected ? Colors.white : const Color(0xFF122E59),
//                                               fontWeight: FontWeight.bold,
//                                               fontSize: 14,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                       Expanded(
//                                         child: Padding(
//                                           padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 14.0),
//                                           child: Text(
//                                             options[index],
//                                             style: TextStyle(
//                                               color: const Color(0xFF122E59),
//                                               fontSize: 14,
//                                               fontFamily: 'Montserrat',
//                                               fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                       Radio(
//                                         activeColor: const Color(0xFF7C3AED),
//                                         value: index,
//                                         groupValue: selectedOptionIndex,
//                                         onChanged: (value) {
//                                           setState(() => selectedOptionIndex = value as int);
//                                         },
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//
//                       Padding(
//                         padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
//                         child: Text(
//                           'Tap an option to select your answer.',
//                           style: TextStyle(
//                             color: Colors.grey[600],
//                             fontSize: 12,
//                             fontStyle: FontStyle.italic,
//                           ),
//                         ),
//                       ),
//
//                       const SizedBox(height: 40),
//
//                       // Navigation Buttons
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           CustomButton(
//                             text: 'Previous'.tr,
//                             onPressed: handlePreviousQuestion,
//                             colorText: primaryColor,
//                             textSize: 14,
//                             iconSvgPath: 'icons/arrowLeft.svg',
//                             colorSvg: primaryColor,
//                             color: indigo50,
//                             border: Border.all(color: indigo700),
//                             width: screenSize.width / 2.5,
//                             mainAxisAlignment: MainAxisAlignment.center,
//                           ),
//
//                           SecondCustomButton(
//                             onPressed: handleNextQuestion,
//                             width: screenSize.width / 2.5,
//                             iconSvgPath: 'icons/arrowRight.svg',
//                             text: currentQuestionIndex == questions.length - 1 ? "Finish".tr : "Next".tr,
//                             textSize: 14,
//                           ),
//                         ],
//                       ),
//
//                       const SizedBox(height: 20),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }