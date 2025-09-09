// To parse this JSON data, do
//
//     final getActivityByChapterId = getActivityByChapterIdFromJson(jsonString);

/// get_activity_by_chapter_id.dart

import 'dart:convert';

GetActivityByChapterId getActivityByChapterIdFromJson(String str) =>
    GetActivityByChapterId.fromJson(json.decode(str));

String getActivityByChapterIdToJson(GetActivityByChapterId data) =>
    json.encode(data.toJson());

class GetActivityByChapterId {
  String? status;
  String? message;
  List<Datum>? data;
  List<QuizData>? quizzes;

  GetActivityByChapterId({
    this.status,
    this.message,
    this.data,
    this.quizzes,
  });

  factory GetActivityByChapterId.fromJson(Map<String, dynamic> json) =>
      GetActivityByChapterId(
        status: json["status"],
        message: json["message"],
        data: json["activities"] == null
            ? []
            : List<Datum>.from(json["activities"]!.map((x) => Datum.fromJson(x))),
        quizzes: json["quizzes"] == null
            ? []
            : List<QuizData>.from(json["quizzes"]!.map((x) => QuizData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "activities": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
    "quizzes": quizzes == null
        ? []
        : List<dynamic>.from(quizzes!.map((x) => x.toJson())),
  };
}

class Datum {
  int? id;
  dynamic storyId;
  String? storyName;
  dynamic chapterId;
  String? chapterName;
  String? chapterNo;
  String? title;
  dynamic time;
  String? shortDiscription;
  String? activityImage;
  String? documentEnglish;
  dynamic documentJapanese;
  String? characterName;
  String? characterImage;
  dynamic characterId;
  String? unlockedCharacterStatus;
  String? readStatus;
  dynamic readChapterCount;
  dynamic totalChapterCount;
  String? image;
  String? audio;
  String? endImage;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<Detail>? details;

  Datum({
    this.id,
    this.storyId,
    this.storyName,
    this.chapterId,
    this.chapterName,
    this.chapterNo,
    this.title,
    this.time,
    this.shortDiscription,
    this.activityImage,
    this.documentEnglish,
    this.documentJapanese,
    this.characterName,
    this.characterImage,
    this.characterId,
    this.unlockedCharacterStatus,
    this.readStatus,
    this.readChapterCount,
    this.totalChapterCount,
    this.image,
    this.audio,
    this.endImage,
    this.createdAt,
    this.updatedAt,
    this.details,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    storyId: json["story_id"],
    storyName: json["story_name"],
    chapterId: json["chapter_id"],
    chapterName: json["chapter_name"],
    chapterNo: json["chapter_no"],
    title: json["title"],
    time: json["time"],
    shortDiscription: json["short_discription"],
    activityImage: json["activity_image"],
    documentEnglish: json["document_english"],
    documentJapanese: json["document_japanese"],
    characterName: json["character_name"],
    characterImage: json["character_image"],
    characterId: json["character_id"],
    unlockedCharacterStatus: json["unlocked_character_status"],
    readStatus: json["read_status"],
    readChapterCount: json["read_chapter_count"],
    totalChapterCount: json["total_chapter_count"],
    image: json["image"],
    audio: json["audio"],
    endImage: json["end_image"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
    details: json["details"] == null
        ? []
        : List<Detail>.from(
        json["details"]!.map((x) => Detail.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "story_id": storyId,
    "story_name": storyName,
    "chapter_id": chapterId,
    "chapter_name": chapterName,
    "chapter_no": chapterNo,
    "title": title,
    "time": time,
    "short_discription": shortDiscription,
    "activity_image": activityImage,
    "document_english": documentEnglish,
    "document_japanese": documentJapanese,
    "character_name": characterName,
    "character_image": characterImage,
    "character_id": characterId,
    "unlocked_character_status": unlockedCharacterStatus,
    "read_status": readStatus,
    "read_chapter_count": readChapterCount,
    "total_chapter_count": totalChapterCount,
    "image": image,
    "audio": audio,
    "end_image": endImage,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "details": details == null
        ? []
        : List<dynamic>.from(details!.map((x) => x.toJson())),
  };
}

class Detail {
  int? id;
  dynamic activityId;
  dynamic srNo;
  String? question;
  List<String>? options;
  String? explation;
  dynamic image;
  String? correctAnswer;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? questionType;
  String? answerFormat;
  List<String>? subquestions;
  bool? hasSubquestions;

  Detail({
    this.id,
    this.activityId,
    this.srNo,
    this.question,
    this.options,
    this.explation,
    this.image,
    this.correctAnswer,
    this.createdAt,
    this.updatedAt,
    this.questionType,
    this.answerFormat,
    this.subquestions,
    this.hasSubquestions,
  });

  factory Detail.fromJson(Map<String, dynamic> json) => Detail(
    id: json["id"],
    activityId: json["activity_id"],
    srNo: json["sr_no"],
    question: json["question"],
    options: json["options"] == null
        ? []
        : List<String>.from(json["options"]!.map((x) => x)),
    explation: json["explanation"], // Note: fixed typo in field name
    image: json["image"],
    questionType: json["question_type"],
    answerFormat: json["answer_format"],
    correctAnswer: json["correct_answer"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
    subquestions: json["subquestions"] == null
        ? []
        : List<String>.from(json["subquestions"]!.map((x) => x)),
    hasSubquestions: json["has_subquestions"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "activity_id": activityId,
    "sr_no": srNo,
    "question": question,
    "options":
    options == null ? [] : List<dynamic>.from(options!.map((x) => x)),
    "explanation": explation,
    "image": image,
    "question_type": questionType,
    "answer_format": answerFormat,
    "correct_answer": correctAnswer,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "subquestions": subquestions == null
        ? []
        : List<dynamic>.from(subquestions!.map((x) => x)),
    "has_subquestions": hasSubquestions,
  };
}

// New Quiz-related models
class QuizData {
  String? quizType;
  Quiz? quiz;

  QuizData({
    this.quizType,
    this.quiz,
  });

  factory QuizData.fromJson(Map<String, dynamic> json) => QuizData(
        quizType: json["quiz_type"],
        quiz: json["quiz"] == null ? null : Quiz.fromJson(json["quiz"]),
      );

  Map<String, dynamic> toJson() => {
        "quiz_type": quizType,
        "quiz": quiz?.toJson(),
      };
}

class Quiz {
  int? id;
  String? title;
  String? description;
  List<Question>? questions;
  dynamic character;
  String? questionType;

  Quiz({
    this.id,
    this.title,
    this.description,
    this.questions,
    this.character,
    this.questionType,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) => Quiz(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        questions: json["questions"] == null
            ? []
            : List<Question>.from(
                json["questions"]!.map((x) => Question.fromJson(x))),
        character: json["character"],
        questionType: json["question_type"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "questions": questions == null
            ? []
            : List<dynamic>.from(questions!.map((x) => x.toJson())),
        "character": character,
        "question_type": questionType,
      };
}

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
