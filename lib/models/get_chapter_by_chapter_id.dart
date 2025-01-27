// To parse this JSON data, do
//
//     final getChapterByChapterId = getChapterByChapterIdFromJson(jsonString);

import 'dart:convert';

GetChapterByChapterId getChapterByChapterIdFromJson(String str) => GetChapterByChapterId.fromJson(json.decode(str));

String getChapterByChapterIdToJson(GetChapterByChapterId data) => json.encode(data.toJson());

class GetChapterByChapterId {
  String? status;
  String? message;
  Data? data;

  GetChapterByChapterId({
    this.status,
    this.message,
    this.data,
  });

  factory GetChapterByChapterId.fromJson(Map<String, dynamic> json) => GetChapterByChapterId(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  dynamic storiesId;
  String? name;
  String? chapterNo;
  String? chapterDocumentEnglish;
  dynamic chapterDocumentJapanese;
  DateTime? createdAt;
  DateTime? updatedAt;

  Data({
    this.storiesId,
    this.name,
    this.chapterNo,
    this.chapterDocumentEnglish,
    this.chapterDocumentJapanese,
    this.createdAt,
    this.updatedAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    storiesId: json["stories_id"],
    name: json["name"],
    chapterNo: json["chapter_no"],
    chapterDocumentEnglish: json["chapter_document_english"],
    chapterDocumentJapanese: json["chapter_document_japanese"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "stories_id": storiesId,
    "name": name,
    "chapter_no": chapterNo,
    "chapter_document_english": chapterDocumentEnglish,
    "chapter_document_japanese": chapterDocumentJapanese,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
