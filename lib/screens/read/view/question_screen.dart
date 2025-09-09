/// question_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yokai_quiz_app/screens/read/controller/read_controller.dart';
import 'package:yokai_quiz_app/screens/read/view/stam_page.dart';
import 'package:yokai_quiz_app/util/const.dart';
import '../../../Widgets/confirmation_box.dart';
import '../../../Widgets/new_button.dart';
import '../../../Widgets/progressHud.dart';
import '../../../Widgets/second_custom_button.dart';
import '../../../api/database_api.dart';
import '../../../global.dart';
import '../../../util/colors.dart';
import '../../../util/text_styles.dart';
import 'congratulation_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({
    super.key,
    this.subId = "",
    required this.reviewTest,
    this.examType,
    this.title = '',
    this.chapterId = '',
    this.microNotesId = '',
  });

  final bool reviewTest;
  final String title;
  final String subId;
  final String chapterId;
  final String? examType;
  final String microNotesId;

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  int seconds = 1800;
  int minute = 0;
  int second = 0;
  int totalDuration = 30 * 60;
  int score = 0;
  double progressValue = 0.0;
  Timer? timer;
  int currentIndex = -1;
  double tap = 0.0;
  List<Color> col = [];
  List multiColor = [];
  RxBool isLoading = true.obs;
  PageController pageController = PageController();
  List<int> alreadyChecked = [];
  List<bool> isExplanation = [];
  final ScrollController _scrollController = ScrollController();
  bool _isQuestionSticky = false;
  
  // Track reordered items per ordering question
  Map<int, List<String>> reorderedOptions = {};
  
  // Track multi-drag selections for drag and drop questions
  Map<int, Map<int, int>> multiDragSelections = {};

  @override
  void initState() {
    super.initState();
    customPrint("Micronotes Id question page:: ${widget.microNotesId}");
    fetchExamDetails();
    customPrint('listofcolor::$multiColor');
    isLoading(false);
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.offset > 60 && !_isQuestionSticky) {
      setState(() {
        _isQuestionSticky = true;
      });
    } else if (_scrollController.offset <= 60 && _isQuestionSticky) {
      setState(() {
        _isQuestionSticky = false;
      });
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    _scrollController.dispose();
    if (timer != null) {
      timer!.cancel();
    }
    super.dispose();
  }

  Future<void> fetchExamDetails() async {
    try {
      questions.clear();
      options.clear();
      image.clear();
      correctAnswers.clear();
      isExplanation.clear();

      if (!widget.reviewTest) {
        userSelectedAnswer.clear();
        ansIndex.clear();
      }

      final activityData = ReadController.getActivityByChapterId.value.data;

      if (activityData != null && activityData.isNotEmpty) {
        final details = activityData[0].details;

        if (details != null) {
          for (var data in details) {
            final decodedQuestion = data.question;
            questions.add(decodedQuestion!);

            final nonEmptyOptions = (data.options ?? [])
                .where((option) => option.isNotEmpty)
                .toList();

            if (nonEmptyOptions.isNotEmpty) {
              options.add(nonEmptyOptions
                  .map((option) => option)
                  .toList());
            }

            image.add(activityData[0].activityImage ?? []);
            correctAnswers.add(data.correctAnswer!);
          }

          setState(() {
            isExplanation = List.generate(details.length, (_) => false);
          });

          customPrint("questions :: $questions");
          customPrint("options :: $options");
          customPrint("correctAnswers :: $correctAnswers");
          customPrint("ansIndex :: $ansIndex");

          userSelectedOptions = List.filled(options.length, null);
          customPrint("userSelectedOptions :: $userSelectedOptions");
        }
      }

      isLoading(false);
    } catch (e) {
      showErrorMessage("Error: $e", errorColor);
      isLoading(false);
    }
  }

  void checkAnswer(int questionIndex, int selectedIndex) {
    if (widget.reviewTest) return;

    if (questionIndex >= options.length ||
        selectedIndex >= options[questionIndex].length ||
        questionIndex >= correctAnswers.length) {
      customPrint(
          "Invalid indices - question: $questionIndex, selected: $selectedIndex");
      return;
    }

    userSelectedAnswer.add(options[questionIndex][selectedIndex]);
    customPrint("userSelectedAnswer :: $userSelectedAnswer");

    bool isCorrect = options[questionIndex][selectedIndex].trim() ==
        correctAnswers[questionIndex].trim();

    if (!alreadyChecked.contains(questionIndex)) {
      alreadyChecked.add(questionIndex);

      if (isCorrect) {
        setState(() {
          score++;
          customPrint("score :: $score");
        });
      }
    }

    Color userSelectedColor = isCorrect ? rightAns : wrongAns;
    Map<String, dynamic> mapColors = {
      'index': selectedIndex,
      'color': userSelectedColor,
    };

    ansIndex.add(mapColors);
    setState(() {});
  }

  void onNextButtonPressed(int index) {
    customPrint("Next Button got invoked for question $index");
    final activityData = ReadController.getActivityByChapterId.value.data;

    if (activityData == null || activityData.isEmpty) {
      showErrorMessage("No activity data available", errorColor);
      return;
    }

    final details = activityData[0].details;
    if (details == null) {
      showErrorMessage("No details available", errorColor);
      return;
    }

    final totalQuestions = details.length;
    final isLastQuestion = index == totalQuestions - 1;
    customPrint("onNextButtonPressed: totalQuestions=$totalQuestions, isLastQuestion=$isLastQuestion");

    if (widget.reviewTest) {
      if (!isLastQuestion) {
        tap++;
        pageController.jumpToPage(index + 1);
      } else {
        _navigateToNextScreen();
      }
      return;
    }

    final currentQuestionType = details[index].questionType;

    switch (currentQuestionType) {
      case "MCQ":
        if (!alreadyChecked.contains(index) && currentIndex == -1) {
          showErrorMessage('Please Select One Option'.tr, errorColor);
          return;
        }
        if (!alreadyChecked.contains(index)) {
          checkAnswer(index, currentIndex);
        }
        break;

      case "Drag & Drop":
        if (!multiDragSelections.containsKey(index) ||
            multiDragSelections[index]!.isEmpty) {
          showErrorMessage('Please match at least one item'.tr, errorColor);
          return;
        }
        _checkMultiDragAnswers(index);
        break;

      case "Matching":
        if (!multiDragSelections.containsKey(index) ||
            multiDragSelections[index]!.isEmpty) {
          showErrorMessage('Please match at least one item'.tr, errorColor);
          return;
        }
        _checkMultiDragAnswers(index);
        break;

      case "Ordering":
        // For ordering questions, we need to check if user has made any reordering
        if (!reorderedOptions.containsKey(index)) {
          // If no reordering was done, initialize with original order
          reorderedOptions[index] = List<String>.from(options[index]);
        }
        
        // For ordering questions, don't immediately lock them - allow continued editing
        // We'll check the answer only on final submission
        customPrint("Ordering question $index: allowing continued editing");
        break;
    }

    if (isLastQuestion) {
      // Show confirmation dialog for the last question
      customPrint("Reached last question, showing submitMcq dialog");
      submitMcq();
    } else {
      tap++;
      setState(() {
        currentIndex = -1;
        isExplanation[index] = false;
        // Reset scroll position for next question
        _scrollController.animateTo(0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
        _isQuestionSticky = false;
      });
      pageController.jumpToPage(index + 1);
    }
  }

  void _checkMultiDragAnswers(int questionIndex) {
    if (alreadyChecked.contains(questionIndex)) return;
    alreadyChecked.add(questionIndex);

    final selections = multiDragSelections[questionIndex]!;
    if (selections.isEmpty) return;
    bool isAnyCorrect = false;

    // Check each selection against the correct answer
    for (final entry in selections.entries) {
      final optionIndex = entry.value;
      if (optionIndex < options[questionIndex].length) {
        final selectedOption = options[questionIndex][optionIndex];
        if (selectedOption.trim() == correctAnswers[questionIndex].trim()) {
          isAnyCorrect = true;
          break;
        }
      }
    }

    // Update score if any match is correct
    if (isAnyCorrect) {
      setState(() {
        score++;
        customPrint("Score updated to: $score");
      });
    }

    // For compatibility with existing code, add to ansIndex using first selection
    if (selections.isNotEmpty) {
      final firstEntry = selections.entries.first;
      Color resultColor = isAnyCorrect ? rightAns : wrongAns;

      Map<String, dynamic> mapColors = {
        'index': firstEntry.value,
        'color': resultColor,
      };

      ansIndex.add(mapColors);
    }
  }

  void _checkOrderingAnswer(int questionIndex) {
    if (alreadyChecked.contains(questionIndex)) return;
    alreadyChecked.add(questionIndex);

    // Get the user's reordered list
    final userOrder = reorderedOptions[questionIndex] ?? options[questionIndex];
    
    // For now, let's assume the correct answer format is a comma-separated string of correct order
    // You may need to adjust this based on how your backend provides the correct answer
    final correctOrderString = correctAnswers[questionIndex];
    
    customPrint("Checking ordering answer for question $questionIndex");
    customPrint("User order: $userOrder");
    customPrint("Correct answer: $correctOrderString");
    
    bool isCorrect = false;
    
    // Try to match the user's order with the correct answer
    // This assumes the correct answer is provided as the correctly ordered list
    // You may need to adjust this logic based on your backend format
    try {
      // Join user's reordered list and compare with correct answer
      final userOrderString = userOrder.join('|'); // Use pipe separator
      final correctOrderFormatted = correctOrderString.replaceAll(', ', '|');
      
      isCorrect = userOrderString.toLowerCase().trim() == correctOrderFormatted.toLowerCase().trim();
      
      // Alternative: if correct answer is provided as indices (e.g., "1,3,0,2")
      if (!isCorrect && correctOrderString.contains(',')) {
        final correctIndices = correctOrderString.split(',').map((s) => int.tryParse(s.trim()) ?? 0).toList();
        if (correctIndices.length == userOrder.length) {
          // Check if user's order matches the correct order based on original indices
          bool allMatch = true;
          for (int i = 0; i < userOrder.length; i++) {
            final correctIndex = correctIndices[i];
            if (correctIndex < options[questionIndex].length && 
                userOrder[i] != options[questionIndex][correctIndex]) {
              allMatch = false;
              break;
            }
          }
          isCorrect = allMatch;
        }
      }
    } catch (e) {
      customPrint("Error checking ordering answer: $e");
      isCorrect = false;
    }

    // Update score if correct
    if (isCorrect) {
      setState(() {
        score++;
        customPrint("Ordering answer correct! Score updated to: $score");
      });
    } else {
      customPrint("Ordering answer incorrect.");
    }

    // Store result for display (using index 0 as placeholder for ordering questions)
    Color resultColor = isCorrect ? rightAns : wrongAns;
    Map<String, dynamic> mapColors = {
      'index': 0, // Placeholder index for ordering questions
      'color': resultColor,
    };

    ansIndex.add(mapColors);
    userSelectedAnswer.add(userOrder.join(', ')); // Store user's order as string
  }

  Future<void> _checkAllOrderingQuestionsOnSubmit() async {
    customPrint("Checking all ordering questions on final submit");
    
    final activityData = ReadController.getActivityByChapterId.value.data;
    if (activityData == null || activityData.isEmpty) return;

    final details = activityData[0].details;
    if (details == null) return;

    // Check all ordering questions that exist in reorderedOptions
    for (int questionIndex = 0; questionIndex < details.length; questionIndex++) {
      final questionDetail = details[questionIndex];
      
      // Only check ordering questions that haven't been checked yet
      if (questionDetail.questionType == "Ordering" && 
          !alreadyChecked.contains(questionIndex) &&
          reorderedOptions.containsKey(questionIndex)) {
        
        customPrint("Final submission: checking ordering question $questionIndex");
        _checkOrderingAnswer(questionIndex);
      }
    }
    
    customPrint("Final score after checking all ordering questions: $score");
  }

  void _navigateToNextScreen() {
    final activityData = ReadController.getActivityByChapterId.value.data;
    if (activityData == null || activityData.isEmpty) return;

    // Navigate directly to CongratulationPage
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CongratulationPage(
              length: (activityData[0].details?.length ?? 0).toString(),
              score: score.toString(),
              title: widget.title,
            ),
      ),
    );
  }

  bool _isNullOrEmpty(String? value) {
    return value == null || value.isEmpty || value == "null";
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery
        .of(context)
        .size;

    return WillPopScope(
      onWillPop: () async => false,
      child: Obx(() {
        return ProgressHUD(
          isLoading: isLoading.value,
          child: Scaffold(
            body: Column(
              children: [
                // Sticky question header when scrolling (only visible when sticky)
                if (_isQuestionSticky)
                  _buildStickyQuestionHeader(),

                // Main content area (scrollable)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    child: PageView.builder(
                        controller: pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: ReadController.getActivityByChapterId
                            .value.data?[0].details?.length ?? 0,
                        itemBuilder: (context, index) {
                          return _buildQuestionContent(
                              context, index, screenSize);
                        }
                    ),
                  ),
                ),

                // Fixed navigation buttons at bottom
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 8, horizontal: 12),
                  child: _buildNavigationButtons(
                      pageController.hasClients
                          ? pageController.page?.toInt() ?? 0
                          : 0,
                      screenSize
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStickyQuestionHeader() {
    final index = pageController.hasClients
        ? pageController.page?.toInt() ?? 0
        : 0;
    final activityData = ReadController.getActivityByChapterId.value.data;
    if (activityData == null || activityData.isEmpty) return SizedBox.shrink();

    final details = activityData[0].details;
    if (details == null || index >= details.length) return SizedBox.shrink();

    final questionDetail = details[index];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.white,
      width: double.infinity,
      child: Text(
        '${index + 1}. ${questionDetail.question}',
        style: AppTextStyle.normalSemiBold14.copyWith(color: queGrey),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  String updateImageUrl(String imageUrl) {
    if (imageUrl.startsWith("/uploads")) {
      return "https://api.yokaizen.com$imageUrl";
    } else if (imageUrl.contains("api.yokai.jp")) {
      return imageUrl.replaceFirst("api.yokai.jp", "api.yokaizen.com");
    }
    return imageUrl;
  }

  Widget _buildQuestionContent(BuildContext context, int index, Size screenSize) {
    final activityData = ReadController.getActivityByChapterId.value.data;
    if (activityData == null || activityData.isEmpty) {
      return const Center(child: Text("No data available"));
    }

    final details = activityData[0].details;
    if (details == null || index >= details.length) {
      return const Center(child: Text("Question not available"));
    }

    final questionDetail = details[index];

    final imageUrl = questionDetail.image;
    final updatedImageUrl = !_isNullOrEmpty(imageUrl)
        ? updateImageUrl(imageUrl)
        : null;

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Question text
        SliverToBoxAdapter(
          child: isExplanation[index]
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question title in explanation mode
              Text(
                '${index + 1}. ${questionDetail.question}',
                style: AppTextStyle.normalSemiBold15.copyWith(color: queGrey),
              ),
              SizedBox(height: 16),
            ],
          )
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${index + 1}. ${questionDetail.question}',
                style: AppTextStyle.normalSemiBold15.copyWith(color: queGrey),
              ),
              SizedBox(height: 8),

              // Question image if available
              if (updatedImageUrl != null)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: updatedImageUrl,
                      fit: BoxFit.fill,
                      height: MediaQuery
                          .of(context)
                          .size
                          .height / 5,
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      placeholder: (context, url) =>
                      const Center(
                        child: SizedBox(
                          height: 30,
                          width: 30,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          Container(
                            decoration: const BoxDecoration(
                                color: AppColors.red),
                            child: const Icon(
                              Icons.error_outline,
                              color: AppColors.black,
                            ),
                          ),
                    ),
                  ),
                ),
              SizedBox(height: 8),
            ],
          ),
        ),

        // Options list (only shown when not viewing explanation)
        SliverToBoxAdapter(
          child: !isExplanation[index] && index < options.length
              ? _buildOptionsList(index)
              : SizedBox.shrink(),
        ),

        // Explanation text
        SliverToBoxAdapter(
          child: isExplanation[index]
              ? Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColorLite.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: primaryColor.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                        Icons.lightbulb_outline, color: primaryColor, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "Explanation:".tr,
                      style: AppTextStyle.normalBold14.copyWith(
                          color: primaryColor),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  questionDetail.explation ?? "No explanation available",
                  style: AppTextStyle.normalRegular14.copyWith(color: queGrey),
                ),
              ],
            ),
          )
              : SizedBox.shrink(),
        ),

        // Explanation toggle button
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    isExplanation[index] = !isExplanation[index];
                  });
                },
                icon: Icon(
                  isExplanation[index] ? Icons.visibility_off : Icons
                      .info_outline,
                  color: Colors.white,
                  size: 18,
                ),
                label: Text(
                  isExplanation[index]
                      ? 'Hide Explanation'.tr
                      : 'Show Explanation'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Bottom padding
        SliverToBoxAdapter(
          child: SizedBox(height: 12),
        ),
      ],
    );
  }

  Widget _buildOptionsList(int index) {
    if (index >= options.length) {
      print("Index out of bounds: $index >= ${options.length}");
      return Container();
    }

    final activityData = ReadController.getActivityByChapterId.value.data;
    if (activityData == null || activityData.isEmpty) {
      print("No activity data available");
      return Container();
    }

    final details = activityData[0].details;
    if (details == null || details.isEmpty || index >= details.length) {
      print("No details available or index out of bounds");
      return Container();
    }

    final questionType = details[index].questionType;
    print("Question type for index $index: $questionType");

    switch (questionType) {
      case "MCQ":
        return mcqOptions(index);
      case "Drag & Drop":
        return multiDragOptions(index);
      case "Matching":
        print("Rendering matching question");
        return completeSentenceOptions(index);
      case "Ordering":
        return rearrangeOptions(index);
      default:
        print("Unknown question type: $questionType");
        return Container();
    }
  }

  // Widget mcqOptions(int index) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       ListView.builder(
  //         physics: const NeverScrollableScrollPhysics(),
  //         shrinkWrap: true,
  //         itemCount: options[index].length,
  //         itemBuilder: (context, listIndex) {
  //           // Determine if this option is selected
  //           bool isSelected = false;
  //           Color optionColor = const Color(0xffEEF9FF);
  //           Color borderColor = indigo300;
  //           Color backgroundColor = colorWhite;
  //           if (widget.reviewTest) {
  //             // Review mode coloring logic
  //             if (ansIndex.isNotEmpty && index < ansIndex.length &&
  //                 ansIndex[index]['index'] == listIndex) {
  //               borderColor = ansIndex[index]['color'];
  //               backgroundColor = ansIndex[index]['color'].withOpacity(0.05);
  //               isSelected = true;
  //             } else if (index < correctAnswers.length &&
  //                 options[index][listIndex] == correctAnswers[index]) {
  //               borderColor = rightAns;
  //               backgroundColor = rightAns.withOpacity(0.05);
  //             }
  //           } else {
  //             // Active test mode
  //             if (alreadyChecked.contains(index)) {
  //               // This question has already been answered
  //               for (var ans in ansIndex) {
  //                 if (ans['index'] == listIndex &&
  //                     ansIndex.indexOf(ans) == alreadyChecked.indexOf(index)) {
  //                   isSelected = true;
  //                   borderColor = ans['color'];
  //                   backgroundColor = ans['color'].withOpacity(0.05);
  //                   break;
  //                 }
  //               }
  //             } else {
  //               // Question not yet answered - use current selection
  //               isSelected = currentIndex == listIndex;
  //               if (isSelected) {
  //                 borderColor = primaryColor;
  //                 backgroundColor = primaryColorLite.withOpacity(0.3);
  //               }
  //             }
  //           }
  //           return Container(
  //             padding: const EdgeInsets.symmetric(vertical: 6.0),
  //             child: GestureDetector(
  //               onTap: () {
  //                 if (!widget.reviewTest && !alreadyChecked.contains(index)) {
  //                   setState(() {
  //                     currentIndex = listIndex;
  //                   });
  //                 }
  //               },
  //               child: Container(
  //                 decoration: BoxDecoration(
  //                   borderRadius: BorderRadius.circular(8),
  //                   border: Border.all(color: borderColor, width: 1.5),
  //                   color: backgroundColor,
  //                 ),
  //                 child: Container(
  //                   padding: const EdgeInsets.symmetric(
  //                       horizontal: 12.0, vertical: 2.0),
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       // Option letter indicator
  //                       Container(
  //                         width: 24,
  //                         height: 24,
  //                         margin: const EdgeInsets.symmetric(vertical: 8.0),
  //                         decoration: BoxDecoration(
  //                           shape: BoxShape.circle,
  //                           color: isSelected ? indigo700 : const Color(
  //                               0xFFECF0FF),
  //                           border: isSelected ? null : Border.all(
  //                               color: indigo300, width: 1),
  //                         ),
  //                         child: Center(
  //                           child: Text(
  //                             String.fromCharCode(65 + listIndex), // A, B, C, D
  //                             style: TextStyle(
  //                               color: isSelected ? Colors.white : indigo700,
  //                               fontWeight: FontWeight.bold,
  //                               fontSize: 12,
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                       // Option text
  //                       Expanded(
  //                         child: Padding(
  //                           padding: const EdgeInsets.symmetric(
  //                               horizontal: 16.0, vertical: 10.0),
  //                           child: Text(
  //                             options[index][listIndex],
  //                             style: TextStyle(
  //                               color: isSelected ? indigo700 : const Color(
  //                                   0xFF122E59),
  //                               fontSize: 13,
  //                               fontFamily: 'Montserrat',
  //                               fontWeight: isSelected
  //                                   ? FontWeight.w600
  //                                   : FontWeight.w500,
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                       // Radio button - smaller touch target
  //                       Transform.scale(
  //                         scale: 0.9,
  //                         child: Radio(
  //                           activeColor: primaryColor,
  //                           value: listIndex,
  //                           groupValue: isSelected ? listIndex : currentIndex,
  //                           onChanged: (!widget.reviewTest &&
  //                               !alreadyChecked.contains(index))
  //                               ? (value) {
  //                             setState(() {
  //                               currentIndex = value as int;
  //                             });
  //                           }
  //                               : null,
  //                           materialTapTargetSize: MaterialTapTargetSize
  //                               .shrinkWrap,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           );
  //         },
  //       ),
  //       // Helper text - smaller and more compact
  //       if (!widget.reviewTest && !alreadyChecked.contains(index))
  //         Padding(
  //           padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
  //           child: Text(
  //             'Tap an option to select your answer.'.tr,
  //             style: TextStyle(
  //               color: Colors.grey[600],
  //               fontSize: 11,
  //               fontStyle: FontStyle.italic,
  //             ),
  //           ),
  //         ),
  //     ],
  //   );
  // }

  Widget mcqOptions(int index) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: options[index].length,
        itemBuilder: (context, listIndex) {
          // Determine if this option is selected
          bool isSelected = false;
          Color optionColor = const Color(0xffEEF9FF);
          Color borderColor = indigo300;
          Color backgroundColor = colorWhite;

          // Determine if editing should be allowed
          bool isEditingAllowed = !widget.reviewTest; // Allow editing unless in review mode

          if (widget.reviewTest) {
            // Review mode coloring logic
            if (ansIndex.isNotEmpty && index < ansIndex.length &&
                ansIndex[index]['index'] == listIndex) {
              borderColor = ansIndex[index]['color'];
              backgroundColor = ansIndex[index]['color'].withOpacity(0.05);
              isSelected = true;
            } else if (index < correctAnswers.length &&
                options[index][listIndex] == correctAnswers[index]) {
              borderColor = rightAns;
              backgroundColor = rightAns.withOpacity(0.05);
            }
          } else {
            // Active test mode
            if (alreadyChecked.contains(index)) {
              // This question has already been answered, but we still allow editing
              // Show the previously selected answer
              for (var ans in ansIndex) {
                if (ans['index'] == listIndex &&
                    ansIndex.indexOf(ans) == alreadyChecked.indexOf(index)) {
                  isSelected = true;
                  borderColor = ans['color'];
                  backgroundColor = ans['color'].withOpacity(0.05);
                  break;
                }
              }
              
              // Also check if this is the current selection (for when user changes their mind)
              if (currentIndex == listIndex) {
                isSelected = true;
                borderColor = primaryColor;
                backgroundColor = primaryColorLite.withOpacity(0.3);
              }
            } else {
              // Question not yet answered - use current selection
              isSelected = currentIndex == listIndex;
              if (isSelected) {
                borderColor = primaryColor;
                backgroundColor = primaryColorLite.withOpacity(0.3);
              }
            }
          }

          return Container(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: GestureDetector(
              onTap: () {
                if (isEditingAllowed) {
                  setState(() {
                    currentIndex = listIndex;
                    
                    // If this question was already answered, we need to update the answer
                    if (alreadyChecked.contains(index)) {
                      // Find and update the existing answer in ansIndex
                      int answerIndex = alreadyChecked.indexOf(index);
                      if (answerIndex < ansIndex.length) {
                        // Update the existing answer
                        bool isCorrect = options[index][listIndex].trim() == correctAnswers[index].trim();
                        Color userSelectedColor = isCorrect ? rightAns : wrongAns;
                        
                        ansIndex[answerIndex] = {
                          'index': listIndex,
                          'color': userSelectedColor,
                        };
                        
                        // Update userSelectedAnswer if it exists
                        if (answerIndex < userSelectedAnswer.length) {
                          userSelectedAnswer[answerIndex] = options[index][listIndex];
                        }
                      }
                    }
                  });
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor, width: 1.5),
                  color: backgroundColor,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Option letter indicator
                      Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? indigo700 : const Color(0xFFECF0FF),
                          border: isSelected ? null : Border.all(color: indigo300, width: 1),
                        ),
                        child: Center(
                          child: Text(
                            String.fromCharCode(65 + listIndex), // A, B, C, D
                            style: TextStyle(
                              color: isSelected ? Colors.white : indigo700,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),

                      // Option text
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 10.0),
                          child: Text(
                            options[index][listIndex],
                            style: TextStyle(
                              color: isSelected ? indigo700 : const Color(0xFF122E59),
                              fontSize: 13,
                              fontFamily: 'Montserrat',
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      // Radio button - smaller touch target
                      Transform.scale(
                        scale: 0.9,
                        child: Radio(
                          activeColor: primaryColor,
                          value: listIndex,
                          groupValue: isSelected ? listIndex : null,
                          onChanged: isEditingAllowed
                              ? (value) {
                            setState(() {
                              currentIndex = value as int;
                              
                              // If this question was already answered, update the answer
                              if (alreadyChecked.contains(index)) {
                                int answerIndex = alreadyChecked.indexOf(index);
                                if (answerIndex < ansIndex.length) {
                                  bool isCorrect = options[index][listIndex].trim() == correctAnswers[index].trim();
                                  Color userSelectedColor = isCorrect ? rightAns : wrongAns;
                                  
                                  ansIndex[answerIndex] = {
                                    'index': listIndex,
                                    'color': userSelectedColor,
                                  };
                                  
                                  if (answerIndex < userSelectedAnswer.length) {
                                    userSelectedAnswer[answerIndex] = options[index][listIndex];
                                  }
                                }
                              }
                            });
                          }
                              : null,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),

      // Helper text - smaller and more compact
      if (!widget.reviewTest)
        Padding(
          padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
          child: Text(
            'Tap an option to select your answer.'.tr,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
    ],
  );
}

  Widget multiDragOptions(int index) {
    if (!multiDragSelections.containsKey(index)) {
      multiDragSelections[index] = {};
    }
    return StatefulBuilder(
        builder: (context, setInnerState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(
                        options[index].length,
                            (optionIndex) {
                          final emotion = options[index][optionIndex];

                          // Check if this emotion is already used
                          bool isUsed = multiDragSelections[index]!.values.contains(optionIndex);

                          // In review mode or if already answered, show all options normally
                          bool isDraggable = !widget.reviewTest && !alreadyChecked.contains(index) && !isUsed;

                          return Draggable<Map<String, dynamic>>(
                            // Only allow dragging if not used, not in review, and question not answered
                            maxSimultaneousDrags: isDraggable ? 1 : 0,

                            // Data to pass when dragged
                            data: {
                              'questionIndex': index,
                              'optionIndex': optionIndex,
                              'emotion': emotion,
                            },

                            // What is shown while dragging
                            feedback: Material(
                              elevation: 3.0,
                              borderRadius: BorderRadius.circular(5),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: primaryColorLite,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  emotion,
                                  style: const TextStyle(
                                    color: primaryColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),

                            // What's shown in the original place while dragging
                            childWhenDragging: Opacity(
                              opacity: 0.5,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[400]!),
                                ),
                                child: Text(
                                  emotion,
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),

                            // The normal widget when not dragging
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isUsed ? Colors.grey[200] : colorWhite,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isUsed ? Colors.grey[400]! : primaryColor,
                                  width: 1.2,
                                ),
                              ),
                              child: Text(
                                emotion,
                                style: TextStyle(
                                  color: isUsed ? Colors.grey[500] : primaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),

              // Drop zones section with better spacing
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 4.0),
                child: Text(
                  'Drop zones:'.tr,
                  style: TextStyle(
                    color: queGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Drop zones with improved spacing
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Column(
                  children: List.generate(
                    4, // Four drop zones as shown in the image
                        (dropIndex) {
                      String dropLabel = String.fromCharCode(65 + dropIndex); // A, B, C, D

                      // Check if this drop zone has a selection
                      final hasSelection = multiDragSelections[index]!.containsKey(dropIndex);
                      final selectedOptionIndex = hasSelection ? multiDragSelections[index]![dropIndex] : null;
                      final selectedEmotion = selectedOptionIndex != null &&
                          selectedOptionIndex < options[index].length
                          ? options[index][selectedOptionIndex]
                          : null;

                      // For review mode, determine if answer is correct
                      Color? borderColor;
                      if (widget.reviewTest && hasSelection && selectedEmotion != null) {
                        // Simple check - you may need to adjust based on your answer format
                        final isCorrect = selectedEmotion.trim() == correctAnswers[index].trim();
                        borderColor = isCorrect ? rightAns : wrongAns;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Row(
                          children: [
                            // Circle with letter
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFFECF0FF),
                                shape: BoxShape.circle,
                                border: Border.all(color: indigo300, width: 1.2),
                              ),
                              child: Center(
                                child: Text(
                                  dropLabel,
                                  style: TextStyle(
                                    color: indigo700,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            // Drop container
                            Expanded(
                              child: DragTarget<Map<String, dynamic>>(
                                onWillAccept: (data) {
                                  // Only accept if not in review mode and question not answered
                                  return !widget.reviewTest && !alreadyChecked.contains(index);
                                },
                                onAccept: (data) {
                                  if (!widget.reviewTest && !alreadyChecked.contains(index)) {
                                    setInnerState(() {
                                      // Update the inner state (StatefulBuilder)
                                      multiDragSelections[index]![dropIndex] = data['optionIndex'];
                                    });

                                    // Also update the parent state
                                    setState(() {
                                      // This ensures the parent widget rebuilds too
                                      // For compatibility with existing code, set currentIndex
                                      currentIndex = data['optionIndex'];
                                    });
                                  }
                                },
                                builder: (context, candidateData, rejectedData) {
                                  return Container(
                                    height: 44,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: borderColor ??
                                            (candidateData.isNotEmpty ? primaryColor : Colors.grey[300]!),
                                        width: candidateData.isNotEmpty || borderColor != null ? 1.5 : 1.0,
                                      ),
                                      color: hasSelection ? const Color(0xFFF9FBFF) : Colors.white,
                                    ),
                                    child: hasSelection && selectedEmotion != null
                                        ? Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              selectedEmotion,
                                              style: TextStyle(
                                                color: indigo700,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (!widget.reviewTest && !alreadyChecked.contains(index))
                                            GestureDetector(
                                              onTap: () {
                                                setInnerState(() {
                                                  // Remove from the inner state
                                                  multiDragSelections[index]!.remove(dropIndex);
                                                });

                                                // Also update the parent state
                                                setState(() {
                                                  // This ensures the parent widget rebuilds
                                                });
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(3),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFEEF2FF),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  Icons.close,
                                                  color: indigo700,
                                                  size: 14,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    )
                                        : Row(
                                      children: [
                                        const SizedBox(width: 12),
                                        Icon(
                                          Icons.add_circle_outline,
                                          color: indigo300,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Drag & drop here'.tr,
                                          style: TextStyle(
                                            color: indigo300,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Helper text at the bottom - more compact
              if (!widget.reviewTest && !alreadyChecked.contains(index))
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                  child: Text(
                    'Drag emotions to match them with the correct drop zones'.tr,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          );
        }
    );
  }

  Widget completeSentenceOptions(int index) {
    final activityData = ReadController.getActivityByChapterId.value.data;
    if (activityData == null || activityData.isEmpty) return Container();

    final details = activityData[0].details;
    if (details == null || details.isEmpty) return Container();

    final currentQuestion = details[index];
    if (currentQuestion.questionType != "Matching" ||
        currentQuestion.options == null ||
        currentQuestion.subquestions == null) {
      return Container();
    }

    if (!multiDragSelections.containsKey(index)) {
      multiDragSelections[index] = {};
    }

    return StatefulBuilder(
      builder: (context, setInnerState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Replace fixed height container with a Wrap widget
            Container(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: List.generate(
                  currentQuestion.options!.length,
                      (optionIndex) {
                    final option = currentQuestion.options?[optionIndex];
                    if (option == null || option.isEmpty) return Container();

                    bool isUsed = multiDragSelections[index]!.values.contains(optionIndex);
                    bool isDraggable = !widget.reviewTest && !alreadyChecked.contains(index) && !isUsed;

                    return Draggable<Map<String, dynamic>>(
                      maxSimultaneousDrags: isDraggable ? 1 : 0,
                      data: {
                        'questionIndex': index,
                        'optionIndex': optionIndex,
                        'text': option,
                      },
                      feedback: Material(
                        elevation: 3.0,
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: primaryColorLite,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            option,
                            style: const TextStyle(
                              color: primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey[400]!),
                          ),
                          child: Text(
                            option,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isUsed ? Colors.grey[400]! : primaryColor,
                            width: 1.0,
                          ),
                          color: isUsed ? Colors.grey[100] : Colors.white,
                        ),
                        child: Text(
                          option,
                          style: TextStyle(
                            color: isUsed ? Colors.grey[500] : primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Drop zones remain the same but with reduced sizes
            ...List.generate(
              currentQuestion.subquestions!.length,
                  (subIndex) {
                final subquestion = currentQuestion.subquestions![subIndex];

                // Check if this drop zone has a selection
                final hasSelection = multiDragSelections[index]!.containsKey(subIndex);
                final selectedOptionIndex = hasSelection ? multiDragSelections[index]![subIndex] : null;
                final selectedText = selectedOptionIndex != null &&
                    selectedOptionIndex < currentQuestion.options!.length
                    ? currentQuestion.options![selectedOptionIndex]
                    : null;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Circle with letter
                      Container(
                        width: 28,
                        height: 28,
                        margin: const EdgeInsets.only(right: 8.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFEEF2FF),
                        ),
                        child: Center(
                          child: Text(
                            String.fromCharCode(65 + subIndex),
                            style: const TextStyle(
                              color: Color(0xFF122E59),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      // Subquestion text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subquestion,
                              style: AppTextStyle.normalSemiBold12.copyWith(color: queGrey),
                            ),
                            const SizedBox(height: 6),
                            // Drop zone
                            DragTarget<Map<String, dynamic>>(
                              onWillAccept: (data) => !widget.reviewTest && !alreadyChecked.contains(index),
                              onAccept: (data) {
                                if (!widget.reviewTest && !alreadyChecked.contains(index)) {
                                  setInnerState(() {
                                    multiDragSelections[index]![subIndex] = data['optionIndex'];
                                  });
                                  setState(() {
                                    currentIndex = data['optionIndex'];
                                  });
                                }
                              },
                              builder: (context, candidateData, rejectedData) {
                                return Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: candidateData.isNotEmpty ? primaryColor : Colors.grey[300]!,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: hasSelection && selectedText != null
                                      ? Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            selectedText,
                                            style: const TextStyle(
                                              color: Color(0xFF122E59),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ),
                                        if (!widget.reviewTest && !alreadyChecked.contains(index))
                                          GestureDetector(
                                            onTap: () {
                                              setInnerState(() {
                                                multiDragSelections[index]!.remove(subIndex);
                                              });
                                              setState(() {});
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 6.0),
                                              child: Icon(
                                                Icons.close,
                                                color: Colors.grey[400],
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  )
                                      : Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add, color: Colors.grey[400], size: 16),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Drag & drop here'.tr,
                                          style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget rearrangeOptions(int index) {
    // Debug logging to identify issues
    customPrint('=== REARRANGE OPTIONS DEBUG ===');
    customPrint('Question index: $index');
    customPrint('widget.reviewTest: ${widget.reviewTest}');
    customPrint('alreadyChecked contains $index: ${alreadyChecked.contains(index)}');
    customPrint('reorderedOptions.containsKey($index): ${reorderedOptions.containsKey(index)}');
    customPrint('options[$index] length: ${index < options.length ? options[index].length : "INDEX OUT OF BOUNDS"}');
    
    // Initialize reordered options for this question if not already done
    if (!reorderedOptions.containsKey(index)) {
      if (index < options.length) {
        reorderedOptions[index] = List<String>.from(options[index]);
        customPrint('Initialized reorderedOptions for question $index: ${reorderedOptions[index]}');
      } else {
        customPrint('ERROR: options index $index is out of bounds!');
        return Container(child: Text('Error: Invalid question index'));
      }
    }

    // Get the current reordered list for this question
    final currentOrderedList = reorderedOptions[index]!;
    customPrint('Current ordered list: $currentOrderedList');
    customPrint('Drag enabled (!widget.reviewTest): ${!widget.reviewTest}');

    // Create fixed letter labels (A, B, C, D)
    final List<String> fixedLabels = List.generate(
      currentOrderedList.length,
      (i) => String.fromCharCode(65 + i), // A, B, C, D
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.transparent,
          ),
          child: ReorderableListView(
            buildDefaultDragHandles: false,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(
              currentOrderedList.length,
              (listIndex) {
                bool isSelected = false;
                Color borderColor = indigo300;
                Color backgroundColor = colorWhite;

                // Handle review mode coloring for ordering questions
                if (widget.reviewTest) {
                  // For ordering questions, show overall result coloring
                  if (ansIndex.isNotEmpty && index < ansIndex.length) {
                    // All items in the ordering question get the same color based on overall correctness
                    borderColor = ansIndex[index]['color'];
                    backgroundColor = ansIndex[index]['color'].withOpacity(0.1);
                    
                    // Show a visual indicator for the overall result
                    if (listIndex == 0) { // Only show on first item to avoid repetition
                      isSelected = true;
                    }
                  }
                }

                return Padding(
                  key: Key('reorder_${index}_${listIndex}_${currentOrderedList[listIndex]}'),
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: ReorderableDragStartListener(
                    index: listIndex,
                    enabled: true, // Allow reordering for ordering questions until review mode
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderColor, width: 1.2),
                        color: backgroundColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            offset: const Offset(0, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Drag Handle - show for ordering questions when not in review mode
                          if (!widget.reviewTest) ...[
                            Container(
                              padding: const EdgeInsets.all(12.0),
                              child: Icon(
                                Icons.drag_indicator,
                                color: Colors.grey[500],
                                size: 20,
                              ),
                            ),
                          ] else ...[
                            // Debug: This should not show if drag handle is missing
                            Container(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                'R',
                                style: TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            ),
                          ],

                          // Letter indicator (A, B, C, D) - always fixed position
                          Container(
                            width: 35,
                            height: 35,
                            margin: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFEEF2FF),
                              border: Border.all(color: indigo300, width: 1),
                            ),
                            child: Center(
                              child: Text(
                                fixedLabels[listIndex], // Fixed position label
                                style: TextStyle(
                                  color: indigo700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),

                          // Option text - this is what gets reordered
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12.0,
                                horizontal: 8.0,
                              ),
                              child: Text(
                                currentOrderedList[listIndex], // Use current reordered content
                                style: TextStyle(
                                  color: const Color(0xFF122E59),
                                  fontSize: 13,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ),

                          // Visual indicator for draggable items
                          if (!widget.reviewTest)
                            Container(
                              padding: const EdgeInsets.all(12.0),
                              child: Icon(
                                Icons.more_vert,
                                color: Colors.grey[400],
                                size: 16,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            onReorder: (oldIndex, newIndex) {
              if (!widget.reviewTest) {
                setState(() {
                  // Adjust newIndex for the standard Flutter ReorderableListView behavior
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }

                  // Reorder the actual content
                  final String movedItem = reorderedOptions[index]!.removeAt(oldIndex);
                  reorderedOptions[index]!.insert(newIndex, movedItem);

                  // Debug logging to see the reordering
                  customPrint('Reordered question $index: ${reorderedOptions[index]}');
                });
              }
            },
          ),
        ),

        // Instruction text
        if (!widget.reviewTest)
          Padding(
            padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
            child: Text(
              'Drag and drop to arrange the steps in the correct order.'.tr,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),


      ],
    );
  }

  Widget _buildNavigationButtons(int index, Size screenSize) {
    final activityData = ReadController.getActivityByChapterId.value.data;

    // Get total questions count
    final totalQuestions = activityData?[0].details?.length ?? 0;
    final isFirstQuestion = index == 0;
    final isLastQuestion = index == totalQuestions - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous button
          CustomButton(
            onPressed: isFirstQuestion
                ? () {} // Empty function for first question instead of null
                : () {
              setState(() {
                // If going back to a previous question, restore its state
                if (index - 1 < ansIndex.length) {
                  currentIndex = ansIndex[index - 1]['index'];
                } else {
                  currentIndex = -1;
                }

                // Reset explanation for previous question
                if (index - 1 < isExplanation.length) {
                  isExplanation[index - 1] = false;
                }

                // Reset scroll position for previous question
                _scrollController.animateTo(0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
                _isQuestionSticky = false;
              });

              pageController.jumpToPage(index - 1);
            },
            text: 'Previous'.tr,
            colorText: isFirstQuestion ? Colors.grey : primaryColor,
            textSize: 13,
            iconSvgPath: 'icons/arrowLeft.svg',
            colorSvg: isFirstQuestion ? Colors.grey : primaryColor,
            color: isFirstQuestion ? Colors.grey.withOpacity(0.2) : indigo50,
            border: Border.all(
                color: isFirstQuestion ? Colors.grey.withOpacity(0.5) : indigo700
            ),
            width: screenSize.width / 2.6,
            mainAxisAlignment: MainAxisAlignment.center,
          ),

          // Next button
          SecondCustomButton(
            onPressed: () {
              customPrint("Next/Finish button pressed - index: $index, isLastQuestion: $isLastQuestion");
              onNextButtonPressed(index);
            },
            width: screenSize.width / 2.6,
            iconSvgPath: isLastQuestion ? 'icons/arrowRight.svg' : 'icons/arrowRight.svg',
            text: isLastQuestion ? "Finish".tr : "Next".tr,
            textSize: 13,
          ),
        ],
      ),
    );
  }

  Future<void> submitMcq() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          title: "End Test?".tr,
          content: Text(
            'Are you sure you want to end this test?\nYou will not be able to change answers once you \npress Confirm'.tr,
            style: const TextStyle(
              color: Color(0xFF637577),
              fontSize: 13,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w400,
            ),
          ),
          cancelButtonText: 'Cancel'.tr,
          confirmButtonText: 'Confirm'.tr,
          onCancel: () {
            Navigator.pop(context);
          },
          displayIcon: false,
          customImageAsset: 'icons/appLogo.png',
          onConfirm: () async {
            customPrint("inside onConfirm button got pressed\n");
            
            // Check all ordering questions that haven't been checked yet
            await _checkAllOrderingQuestionsOnSubmit();
            
            bool pass = (score >= (0.6 * (ReadController.getActivityByChapterId.value.data?[0].details?.length ?? 0)));
            Navigator.pop(context);
            customPrint("onConfirm pass : $pass\n");
            // Get character ID from the activity data
            final activityData = ReadController.getActivityByChapterId.value.data;
            if (activityData != null && activityData.isNotEmpty) {
              final characterId = activityData[0].characterId?.toString() ?? '';
              customPrint("onConfirm inside if\n");
              if (characterId.isNotEmpty) {
                customPrint("Attempting to unlock character ID: $characterId");
                
                // Call the unlock character API
                final success = await ReadController.unlockCharacter(characterId);
                
                if (success) {
                  customPrint("Character unlock successful for ID: $characterId");
                } else {
                  customPrint("Character unlock failed for ID: $characterId");
                }
              } else {
                customPrint("No character ID found in activity data");
              }
            }
            
            // Navigate to congratulation page regardless of unlock result
            Get.to(() => CongratulationPage(
                  length: (ReadController.getActivityByChapterId.value.data?[0].details?.length ?? 0).toString(),
                  score: score.toString(),
                  title: widget.title,
                ));
          },
        );
      },
    );
  }
}