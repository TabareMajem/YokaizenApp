// To parse this JSON data, do
//
//     final getChapterByChapterId = getChapterByChapterIdFromJson(jsonString);

import 'dart:convert';

import 'package:yokai_quiz_app/util/constants.dart';

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
  String? storyName;
  String? name;
  String? japaneseName;
  String? chapterNo;
  String? chapterDocument;
  dynamic chapterDocumentJapanese;
  String? pdfType;
  DateTime? createdAt;
  DateTime? updatedAt;

  Data({
    this.storiesId,
    this.storyName,
    this.name,
    // this.japaneseName,
    this.chapterNo,
    this.chapterDocument,
    // this.chapterDocumentJapanese,
    this.pdfType,
    this.createdAt,
    this.updatedAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    storiesId: json["stories_id"],
    storyName: json["story_name"],
    name: constants.deviceLanguage=="en" ? json["name"] : fixEncoding(json["name"]),
    // japaneseName: json["japanese_name"] != null ? fixEncoding(json["japanese_name"]) : null,
    chapterNo: json["chapter_no"],
    chapterDocument: json["chapter_document"],
    // chapterDocumentJapanese: json["chapter_document_japanese"],
    pdfType: json["pdf_type"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "stories_id": storiesId,
    "story_name": storyName,
    "name": name,
    // "japanese_name" : japaneseName,
    "chapter_no": chapterNo,
    "chapter_document_english": chapterDocument,
    // "chapter_document_japanese": chapterDocumentJapanese,
    "pdf_type": pdfType,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

String fixEncoding(String encodedString) {
  return utf8.decode(encodedString.runes.toList());
}
