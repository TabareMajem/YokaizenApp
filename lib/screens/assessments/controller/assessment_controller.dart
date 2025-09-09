import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:yokai_quiz_app/api/database_api.dart';
import 'package:yokai_quiz_app/api/local_storage.dart';
import 'package:yokai_quiz_app/global.dart';
import 'package:yokai_quiz_app/main.dart';
import 'package:yokai_quiz_app/screens/assessments/model/assessment_model.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/constants.dart';
import 'package:yokai_quiz_app/screens/Authentication/controller/auth_screen_controller.dart';

class AssessmentController extends GetxController {
  static RxBool isLoading = true.obs;
  static RxList<AssessmentModel> quizData = <AssessmentModel>[].obs;
  static Rx<AssessmentModel?> currentQuiz = Rx<AssessmentModel?>(null);

  // List of quiz types that match the API endpoints
  static const List<String> quizTypes = [
    "bartle-test",
    "eq",
    "big-five-personality",
    "personality-assessment",
    "values-strengths"
  ];

  // Method to fetch quiz by type
  static Future<bool> fetchQuizByType(String quizType) async {
    isLoading(true);

    if (!quizTypes.contains(quizType)) {
      isLoading(false);
      return false;
    }

    final headers = {
      "Content-Type": "application/json",
      "UserToken": prefs.getString(LocalStorage.token).toString(),
      "Accept-Language": constants.deviceLanguage,
    };

    final String url = '${DatabaseApi.getAssessments}/$quizType';
    customPrint("fetchQuizByType url :: $url");

    try {
      return await http.get(Uri.parse(url), headers: headers).then((value) async {
        final result = utf8.decode(value.bodyBytes, allowMalformed: true);
        customPrint("fetchQuizByType response :: $result");

        final jsonData = json.decode(result);

        if (jsonData is! List || jsonData.isEmpty) {
          showErrorMessage("No quiz data found for this type", colorError);
          isLoading(false);
          return false;
        }

        // Parse the response and store in the controller
        quizData.value = quizModelFromJson(result);

        // Set the current quiz to the first quiz in the list
        if (quizData.isNotEmpty) {
          currentQuiz.value = quizData.first;
        }

        isLoading(false);
        return true;
      });
    } catch (e) {
      customPrint("fetchQuizByType error :: $e");
      showErrorMessage("Failed to load quiz data. Please try again.", colorError);
      isLoading(false);
      return false;
    }
  }

  // Method to convert the quiz model to Question objects for the assessment screen
  static List<Question> convertToQuestions() {
    if (currentQuiz.value == null || currentQuiz.value!.questions == null) {
      return [];
    }

    return currentQuiz.value!.questions!.map((q) {
      // For Big Five personality questions that might not have options
      List<String>? options = q.options;

      // If no options are provided (like in Big Five test), create default Likert scale options
      if ((options == null || options.isEmpty) && currentQuiz.value!.quizType == 'big-five-personality') {
        options = [
          "Strongly Disagree",
          "Disagree",
          "Neutral",
          "Agree",
          "Strongly Agree"
        ];

        // Use Japanese options if the device language is set to Japanese
        if (constants.deviceLanguage == 'ja') {
          options = [
            "全く同意しない",
            "同意しない",
            "どちらでもない",
            "同意する",
            "強く同意する"
          ];
        }
      }

      return Question(
        question: q.question,
        scenario: q.scenario,
        options: options,
        category: q.category,
        imagePrompt: q.imagePrompt,
        personalityTrait: q.personalityTrait,
        reverseScored: q.reverseScored,
        bartleType: q.bartleType,
      );
    }).toList();
  }

  // Map quiz types to quiz IDs for API submission
  static final Map<String, int> quizTypeToId = {
    'bartle-test': 1,
    'big-five-personality': 2,
    'personality-assessment': 3,
    'eq': 4,
    'values-strengths': 5,
  };

  // Method to submit assessment answers to the API
  static Future<bool> submitAssessment(String quizType, List<Map<String, dynamic>> answers) async {
    try {
      final userId = AuthScreenController.getProfileModel.value.user?.userId ?? 1;
      
      // Get quiz ID based on quiz type
      final quizId = quizTypeToId[quizType] ?? 0;
      
      if (quizId == 0) {
        customPrint("Invalid quiz type: $quizType");
        return false;
      }

      // Prepare API call
      final url = Uri.parse('${DatabaseApi.submitAssessments}?quiz_id=$quizId&user_id=$userId');
      final headers = {
        "accept": "application/json",
        "Content-Type": "application/json",
        // "UserToken": prefs.getString(LocalStorage.token).toString(),
        // "Accept-Language": constants.deviceLanguage,
      };

      customPrint("Submitting assessment to: $url");
      customPrint("Headers: $headers");
      customPrint("Payload: ${json.encode(answers)}");

      // Make API call
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(answers),
      );

      customPrint("Response status code: ${response.statusCode}");
      customPrint("Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        customPrint("Assessment submitted successfully");
        return true;
      } else {
        customPrint("Failed to submit assessment: ${response.statusCode} - ${response.body}");
        
        // Try to parse error response for more details
        try {
          final errorJson = json.decode(response.body);
          customPrint("Error details: $errorJson");
        } catch (e) {
          customPrint("Could not parse error response: $e");
        }
        
        return false;
      }
    } catch (e) {
      customPrint("Error submitting assessment: $e");
      return false;
    }
  }
}

// This class replicates the Question class structure from get_activity_by_chapter_id.dart
// to ensure compatibility with the AssessmentsScreen
class Question {
  String? question;
  String? scenario;
  List<String>? options;
  String? category;
  String? imagePrompt;
  String? personalityTrait;
  bool? reverseScored;
  String? bartleType;

  Question({
    this.question,
    this.scenario,
    this.options,
    this.category,
    this.imagePrompt,
    this.personalityTrait,
    this.reverseScored,
    this.bartleType,
  });

  factory Question.fromJson(Map<String, dynamic> json) => Question(
    question: json["question"],
    scenario: json["scenario"],
    options: json["options"] == null
        ? []
        : List<String>.from(json["options"]!.map((x) => x)),
    category: json["category"],
    imagePrompt: json["image_prompt"],
    personalityTrait: json["personality_trait"],
    reverseScored: json["reverse_scored"],
    bartleType: json["bartle_type"],
  );

  Map<String, dynamic> toJson() => {
    "question": question,
    "scenario": scenario,
    "options":
    options == null ? [] : List<dynamic>.from(options!.map((x) => x)),
    "category": category,
    "image_prompt": imagePrompt,
    "personality_trait": personalityTrait,
    "reverse_scored": reverseScored,
    "bartle_type": bartleType,
  };
}