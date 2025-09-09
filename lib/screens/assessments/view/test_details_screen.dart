// /// test_details_screen.dart
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:yokai_quiz_app/screens/assessments/view/assessments_screen.dart';
// import 'package:yokai_quiz_app/util/colors.dart';
// import 'package:yokai_quiz_app/util/const.dart';
// import 'package:yokai_quiz_app/util/custom_app_bar.dart';
//
// import '../../../Widgets/second_custom_button.dart';
// import '../../../api/database_api.dart';
// import '../../../global.dart';
// import '../../read/controller/read_controller.dart';
//
// class TestDetailsScreen extends StatefulWidget {
//   final String testName;
//   final String testImage;
//   final String testType;
//   final String testDescription;
//
//   const TestDetailsScreen({
//     super.key,
//     required this.testName,
//     required this.testImage,
//     required this.testType,
//     required this.testDescription,
//   });
//
//   @override
//   State<TestDetailsScreen> createState() => _TestDetailsScreenState();
// }
//
// class _TestDetailsScreenState extends State<TestDetailsScreen> {
//   RxBool isLoading = false.obs;
//   // Map to convert from display names to API quiz types
//   final Map<String, String> quizTypeMapping = {
//     'Bartle': 'bartle-test',
//     'EQ': 'eq',
//     'Big Five': 'big-five-personality',
//     'Mental Health': 'personality-assessment',
//     'Strength Values': 'values-strengths'
//   };
//
//   @override
//   void initState() {
//     super.initState();
//     fetchData();
//   }
//
//   fetchData() async {
//     isLoading(true);
//     await ReadController.getAllChapterByChapterId("53")
//         .then((value) async {
//       await ReadController.getActivityDetailsByChapterId("53").then(
//             (value) {
//           isLoading(false);
//         },
//       );
//     });
//   }
//
//   String getQuizTypeFromTestName() {
//     // Convert display test name to API quiz type
//     return quizTypeMapping[widget.testType] ?? 'personality-assessment';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Column(
//         children: [
//           Expanded(
//             child: SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     6.ph,
//                     CustomAppBar(
//                         title: widget.testName,
//                         isBackButton: true,
//                         isColor: false,
//                         onButtonPressed: () {
//                           Navigator.pop(context);
//                         }
//                     ),
//
//                     const SizedBox(height: 24),
//
//                     // Main Image
//                     Container(
//                       height: 200,
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(12),
//                         image: DecorationImage(
//                           image: AssetImage(widget.testImage),
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(height: 20),
//
//                     // Title
//                     Text(
//                       widget.testName,
//                       style: const TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.w600,
//                         color: Color(0xFF1F2937),
//                       ),
//                     ),
//
//                     const SizedBox(height: 20),
//
//                     // Info Cards Row
//                     SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: Row(
//                         children: [
//                           // Time Card
//                           Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(color: const Color(0xFFE5E7EB)),
//                             ),
//                             child: const Column(
//                               children: [
//                                 Text(
//                                   'Time',
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     color: Color(0xFF6B7280),
//                                   ),
//                                 ),
//                                 SizedBox(height: 4),
//                                 Text(
//                                   '20 Minutes',
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     color: Color(0xFFF97316),
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//
//                           const SizedBox(width: 12),
//
//                           // Type Card
//                           Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(color: const Color(0xFFE5E7EB)),
//                             ),
//                             child: Column(
//                               children: [
//                                 const Text(
//                                   'Type',
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     color: Color(0xFF6B7280),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   widget.testType,
//                                   style: const TextStyle(
//                                     fontSize: 14,
//                                     color: Color(0xFFF97316),
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//
//                           const SizedBox(width: 12),
//                         ],
//                       ),
//                     ),
//
//                     const SizedBox(height: 20),
//
//                     // Description
//                     Text(
//                       widget.testDescription,
//                       style: const TextStyle(
//                         fontSize: 14,
//                         color: Color(0xFF6B7280),
//                       ),
//                     ),
//
//                     const SizedBox(height: 24),
//
//                     // Chat with text
//                     const Text(
//                       'Complete this test to Know about your personality Traits',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Color(0xFFF97316),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           // Bottom Button
//           Padding(
//             padding: const EdgeInsets.all(20),
//             child: Obx(() => SecondCustomButton(
//               onPressed: isLoading.value ? null : () {
//                 // Get the correct quiz type from the mapping
//                 final quizType = getQuizTypeFromTestName();
//
//                 Navigator.of(context).push(MaterialPageRoute(
//                   builder: (context) => AssessmentsScreen(
//                     quizType: quizType,
//                     testName: widget.testName,
//                     testImage: widget.testImage,
//                   ),
//                 ));
//               },
//               width: screenSize.width / 2,
//               iconSvgPath: 'icons/arrowRight.svg',
//               text: "Start Assessment".tr,
//               textSize: 14,
//             )),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yokai_quiz_app/screens/assessments/controller/assessment_controller.dart';
import 'package:yokai_quiz_app/screens/assessments/view/assessments_screen.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/const.dart';
import 'package:yokai_quiz_app/util/custom_app_bar.dart';
import 'package:yokai_quiz_app/util/text_styles.dart';
import 'package:yokai_quiz_app/Widgets/second_custom_button.dart';

import '../../personality/view/personality_screen.dart';

class TestDetailsScreen extends StatefulWidget {
  final String testName;
  final String testImage;
  final String testType;
  final String testDescription;

  const TestDetailsScreen({
    Key? key,
    required this.testName,
    required this.testImage,
    required this.testType,
    required this.testDescription,
  }) : super(key: key);

  @override
  State<TestDetailsScreen> createState() => _TestDetailsScreenState();
}

class _TestDetailsScreenState extends State<TestDetailsScreen> {
  bool isLoading = false;
  String quizType = '';

  @override
  void initState() {
    super.initState();

    // Map the test name to the quiz type parameter for the API
    _mapTestNameToQuizType();
  }

  void _mapTestNameToQuizType() {
    // Map test names to quiz types with more flexible matching
    if (widget.testName.contains('Bartle') || widget.testName.contains('バートル')) {
      quizType = 'bartle-test';
    } else if (widget.testName.contains('Emotional') || widget.testName.contains('感情')) {
      quizType = 'eq';
    } else if (widget.testName.toLowerCase().contains('big five') || 
               widget.testName.contains('ビッグファイブ') || 
               widget.testName.contains('ビッグ5') ||
               widget.testName.contains('ビッグ・ファイブ')) {
      quizType = 'big-five-personality';
    } else if (widget.testName.contains('Mental Health') || widget.testName.contains('メンタルヘルス')) {
      quizType = 'personality-assessment';
    } else if (widget.testName.contains('Values') || widget.testName.contains('価値観')) {
      quizType = 'values-strengths';
    }

    // If no match found by name, try matching by type
    if (quizType.isEmpty) {
      switch (widget.testType.toLowerCase()) {
        case 'personality type':
        case 'パーソナリティタイプ':
          quizType = 'bartle-test';
          break;
        case 'eq assessment':
        case 'eq評価':
          quizType = 'eq';
          break;
        case 'personality traits':
        case 'パーソナリティ特性':
          quizType = 'big-five-personality';
          break;
        case 'mental wellness':
        case 'メンタルウェルネス':
          quizType = 'personality-assessment';
          break;
        case 'character strengths':
        case 'キャラクター強み':
          quizType = 'values-strengths';
          break;
      }
    }
    
    print('Mapped test name "${widget.testName}" (type: ${widget.testType}) to quiz type: $quizType'); // Debug log
  }

  Future<void> _startAssessment() async {
    if (quizType.isEmpty) {
      print('Warning: Could not determine quiz type for "${widget.testName}" (${widget.testType})');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final result = await AssessmentController.fetchQuizByType(quizType);

      if (result && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AssessmentsScreen(
              quizType: quizType,
              testName: widget.testName,
              testImage: widget.testImage,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error starting assessment: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomAppBar(
                  title: "Assessment Details".tr,
                  isBackButton: true,
                  isColor: false,
                  // onButtonPressed: () => Navigator.pop(context),
                  onButtonPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const PersonalityScreen(),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Test image
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

                const SizedBox(height: 20),

                // Test name and type
                Text(
                  widget.testName,
                  style: AppTextStyle.normalBold14.copyWith(
                    color: headingColour,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  widget.testType,
                  style: AppTextStyle.normalRegular14.copyWith(
                    color: Colors.grey[600],
                  ),
                ),

                const SizedBox(height: 16),

                // Description divider
                Divider(color: Colors.grey[300], thickness: 1),

                const SizedBox(height: 16),

                // About this assessment
                Text(
                  "About this assessment".tr,
                  style: AppTextStyle.normalBold16.copyWith(
                    color: headingColour,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  widget.testDescription,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: Colors.grey[800],
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 24),

                // Test details
                _buildDetailItem(
                  "Format".tr,
                  "Multiple-choice questions based on realistic scenarios".tr,
                  Icons.format_list_bulleted,
                ),

                _buildDetailItem(
                  "Time Required".tr,
                  "Approximately 5-10 minutes".tr,
                  Icons.timer,
                ),

                _buildDetailItem(
                  "Privacy".tr,
                  "Your results are private and only visible to you".tr,
                  Icons.lock,
                ),

                const SizedBox(height: 40),

                // Start button
                Center(
                  child: SecondCustomButton(
                    onPressed: _startAssessment,
                    width: screenSize.width / 1.5,
                    iconSvgPath: 'icons/arrowRight.svg',
                    text: "Begin Assessment".tr,
                    textSize: 16,
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3E8FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF7C3AED)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}