import 'dart:convert';

// Model for quiz list response
List<AssessmentModel> quizModelFromJson(String str) =>
    List<AssessmentModel>.from(json.decode(str).map((x) => AssessmentModel.fromJson(x)));

String quizModelToJson(List<AssessmentModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AssessmentModel {
  final int? id;
  final String? quizType;
  final String? title;
  final String? description;
  final List<QuizQuestion>? questions;
  final dynamic character;
  final String? questionType;

  AssessmentModel({
    this.id,
    this.quizType,
    this.title,
    this.description,
    this.questions,
    this.character,
    this.questionType,
  });

  factory AssessmentModel.fromJson(Map<String, dynamic> json) => AssessmentModel(
    id: json["id"],
    quizType: json["quiz_type"],
    title: json["title"],
    description: json["description"],
    questions: json["questions"] == null
        ? []
        : List<QuizQuestion>.from(
        json["questions"]!.map((x) => QuizQuestion.fromJson(x))),
    character: json["character"],
    questionType: json["question_type"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "quiz_type": quizType,
    "title": title,
    "description": description,
    "questions": questions == null
        ? []
        : List<dynamic>.from(questions!.map((x) => x.toJson())),
    "character": character,
    "question_type": questionType,
  };
}

class QuizQuestion {
  final String? question;
  final String? scenario;
  final List<String>? options;
  final String? category;
  final String? imagePrompt;
  final String? personalityTrait;
  final bool? reverseScored;
  final String? bartleType;
  final String? correctAnswer;
  final String? lineFriend;

  QuizQuestion({
    this.question,
    this.scenario,
    this.options,
    this.category,
    this.imagePrompt,
    this.personalityTrait,
    this.reverseScored,
    this.bartleType,
    this.correctAnswer,
    this.lineFriend,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
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
    correctAnswer: json["correct_answer"],
    lineFriend: json["line_friend"],
  );

  Map<String, dynamic> toJson() => {
    "question": question,
    "scenario": scenario,
    "options": options == null
        ? []
        : List<dynamic>.from(options!.map((x) => x)),
    "category": category,
    "image_prompt": imagePrompt,
    "personality_trait": personalityTrait,
    "reverse_scored": reverseScored,
    "bartle_type": bartleType,
    "correct_answer": correctAnswer,
    "line_friend": lineFriend,
  };
}