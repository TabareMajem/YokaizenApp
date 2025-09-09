import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/const.dart';
import 'package:yokai_quiz_app/util/text_styles.dart';

import '../../../Widgets/second_custom_button.dart';

class CongratulationPage extends StatelessWidget {
  final String title;
  final String length;
  final String score;
  final Map<String, dynamic>? personalityInsights;

  const CongratulationPage({
    super.key,
    required this.title,
    required this.length,
    required this.score,
    this.personalityInsights,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Top image
                Image.asset(
                  'images/celebrate.png',
                  height: 200,
                  width: 200,
                ),

                const SizedBox(height: 24),

                // Congratulations text
                Text(
                  'Assessment Complete!',
                  style: AppTextStyle.normalBold20.copyWith(color: coral500),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                Text(
                  'Thank you for completing the $title assessment',
                  style: AppTextStyle.normalRegular16,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Results Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Results',
                        style: AppTextStyle.normalBold16.copyWith(color: coral500),
                      ),

                      const SizedBox(height: 16),

                      // If we have personality insights, display them
                      if (personalityInsights != null) ...[
                        ResultItem(
                          label: 'Primary Trait',
                          value: personalityInsights!['dominantStrength'] ?? 'Processing...',
                          color: const Color(0xFF6FD18C),
                        ),

                        const SizedBox(height: 12),

                        ResultItem(
                          label: 'Secondary Trait',
                          value: personalityInsights!['supportingStrength'] ?? 'Processing...',
                          color: const Color(0xFFEE9D1A),
                        ),
                      ] else ...[
                        // If not, just show a basic message
                        Text(
                          'Your results are being processed. Check your Personality Insights screen to see your detailed analysis.',
                          style: AppTextStyle.normalRegular14,
                        ),
                      ],

                      const SizedBox(height: 24),

                      Text(
                        'Thank you for taking this assessment. Your responses will help us provide you with more personalized content and experiences.',
                        style: AppTextStyle.normalRegular14.copyWith(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Back to Home Button
                SecondCustomButton(
                  onPressed: () {
                    // Navigate back to main screen
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  width: screenSize.width / 2,
                  iconSvgPath: 'icons/home.svg',
                  text: "Back to Home".tr,
                  textSize: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Helper widget for result items
class ResultItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const ResultItem({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 12,
          width: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}