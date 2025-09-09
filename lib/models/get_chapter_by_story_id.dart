// To parse this JSON data, do
//
//     final getChapterByStoryId = getChapterByStoryIdFromJson(jsonString);

import 'dart:convert';

import 'package:yokai_quiz_app/util/constants.dart';

GetChapterByStoryId getChapterByStoryIdFromJson(String str) => GetChapterByStoryId.fromJson(json.decode(str));

String getChapterByStoryIdToJson(GetChapterByStoryId data) => json.encode(data.toJson());

class GetChapterByStoryId {
  String? status;
  String? message;
  Data? data;

  GetChapterByStoryId({
    this.status,
    this.message,
    this.data,
  });

  factory GetChapterByStoryId.fromJson(Map<String, dynamic> json) => GetChapterByStoryId(
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
  int? id;
  String? name;
  String? description;
  String? storiesImage;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<ChapterDatum>? chapterData;


  Data({
    this.id,
    this.name,
    this.description,
    this.storiesImage,
    this.createdAt,
    this.updatedAt,
    this.chapterData,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    name: json["name"],
    description: json["description"],
    storiesImage: json["stories_image"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    chapterData: json["chapter_data"] == null ? [] : List<ChapterDatum>.from(json["chapter_data"]!.map((x) => ChapterDatum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "stories_image": storiesImage,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "chapter_data": chapterData == null ? [] : List<dynamic>.from(chapterData!.map((x) => x.toJson())),
  };
}

class ChapterDatum {
  int? id;
  dynamic storiesId;
  String? name;
  String? chapterNo;
  String? chapterDocumentEnglish;
  String? chapterDocumentJapanese;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? activityStatus;
  String? readStatus;
    dynamic pdfType;

  ChapterDatum({
    this.id,
    this.storiesId,
    this.name,
    this.chapterNo,
    this.chapterDocumentEnglish,
    this.chapterDocumentJapanese,
    this.createdAt,
    this.updatedAt,
    this.activityStatus,
    this.readStatus,this.pdfType
  });

  factory ChapterDatum.fromJson(Map<String, dynamic> json) => ChapterDatum(
    id: json["id"],
    storiesId: json["stories_id"],
    name: constants.deviceLanguage == "en" ? json["name"] : json["japanese_name"],
    chapterNo: json["chapter_no"],
    chapterDocumentEnglish: json["chapter_document_english"],
    chapterDocumentJapanese: json["chapter_document_japanese"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    activityStatus: json["activity_status"],
    readStatus: json["read_status"],
    pdfType: json["pdf_type"],
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
    "activity_status": activityStatus,
    "read_status": readStatus,
    "pdf_type": pdfType,
  };
}
