// To parse this JSON data, do
//
//     final getLastReadChapter = getLastReadChapterFromJson(jsonString);

import 'dart:convert';

GetLastReadChapter getLastReadChapterFromJson(String str) => GetLastReadChapter.fromJson(json.decode(str));

String getLastReadChapterToJson(GetLastReadChapter data) => json.encode(data.toJson());

class GetLastReadChapter {
  String? status;
  String? message;
  List<Datum>? data;

  GetLastReadChapter({
    this.status,
    this.message,
    this.data,
  });

  factory GetLastReadChapter.fromJson(Map<String, dynamic> json) => GetLastReadChapter(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  int? id;
  String? storiesId;
  String? name;
  String? chapterNo;
  String? chapterDocumentEnglish;
  String? chapterDocumentJapanese;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? storyName;
  String? storyImage;
  String? activityStatus;
  String? readStatus;
  DateTime? readDate;

  Datum({
    this.id,
    this.storiesId,
    this.name,
    this.chapterNo,
    this.chapterDocumentEnglish,
    this.chapterDocumentJapanese,
    this.createdAt,
    this.updatedAt,
    this.storyName,
    this.storyImage,
    this.activityStatus,
    this.readStatus,
    this.readDate,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    storiesId: json["stories_id"],
    name: json["name"],
    chapterNo: json["chapter_no"],
    chapterDocumentEnglish: json["chapter_document_english"],
    chapterDocumentJapanese: json["chapter_document_japanese"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    storyName: json["story_name"],
    storyImage: json["story_image"],
    activityStatus: json["activity_status"],
    readStatus: json["read_status"],
    readDate: json["read_date"] == null ? null : DateTime.parse(json["read_date"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "stories_id": storiesId,
    "name": name,
    "chapter_no": chapterNo,
    "chapter_document_english": chapterDocumentEnglish,
    "chapter_document_japanese": chapterDocumentJapanese,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "story_name": storyName,
    "story_image": storyImage,
    "activity_status": activityStatus,
    "read_status": readStatus,
    "read_date": "${readDate!.year.toString().padLeft(4, '0')}-${readDate!.month.toString().padLeft(2, '0')}-${readDate!.day.toString().padLeft(2, '0')}",
  };
}
