// To parse this JSON data, do
//
//     final getActivityByChapterId = getActivityByChapterIdFromJson(jsonString);

import 'dart:convert';

GetActivityByChapterId getActivityByChapterIdFromJson(String str) =>
    GetActivityByChapterId.fromJson(json.decode(str));

String getActivityByChapterIdToJson(GetActivityByChapterId data) =>
    json.encode(data.toJson());

class GetActivityByChapterId {
  String? status;
  String? message;
  List<Datum>? data;

  GetActivityByChapterId({
    this.status,
    this.message,
    this.data,
  });

  factory GetActivityByChapterId.fromJson(Map<String, dynamic> json) =>
      GetActivityByChapterId(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
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
  });

  factory Detail.fromJson(Map<String, dynamic> json) => Detail(
        id: json["id"],
        activityId: json["activity_id"],
        srNo: json["sr_no"],
        question: json["question"],
        options: json["options"] == null
            ? []
            : List<String>.from(json["options"]!.map((x) => x)),
        explation: json["explation"],
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
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "activity_id": activityId,
        "sr_no": srNo,
        "question": question,
        "options":
            options == null ? [] : List<dynamic>.from(options!.map((x) => x)),
        "explation": explation,
        "image": image,
        "question_type": questionType,
        "answer_format": answerFormat,
        "correct_answer": correctAnswer,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
