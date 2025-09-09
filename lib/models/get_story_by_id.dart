// To parse this JSON data, do
//
//     final getStoryById = getStoryByIdFromJson(jsonString);

import 'dart:convert';

import 'package:yokai_quiz_app/util/constants.dart';

GetStoryById getStoryByIdFromJson(String str) => GetStoryById.fromJson(json.decode(str));

String getStoryByIdToJson(GetStoryById data) => json.encode(data.toJson());

class GetStoryById {
  String? status;
  String? message;
  Data? data;

  GetStoryById({
    this.status,
    this.message,
    this.data,
  });

  factory GetStoryById.fromJson(Map<String, dynamic> json) => GetStoryById(
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
  String? name;
  String? discription;
  String? storiesImage;
  int? chapterCount;
  int? activityCount;
  String? charcter;
  String? charcterImage;
  DateTime? createdAt;
  DateTime? updatedAt;

  Data({
    this.name,
    this.discription,
    this.storiesImage,
    this.chapterCount,
    this.activityCount,
    this.charcter,
    this.charcterImage,
    this.createdAt,
    this.updatedAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    name: constants.deviceLanguage=="en" ? json["name"] : json["japanese_name"],
    discription: constants.deviceLanguage=="en" ? json["discription"] : json["japanese_description"],
    storiesImage: json["stories_image"],
    chapterCount: json["chapter_count"],
    activityCount: json["activity_count"],
    charcter: json["charcter"],
    charcterImage: json["charcter_image"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "discription": discription,
    "stories_image": storiesImage,
    "chapter_count": chapterCount,
    "activity_count": activityCount,
    "charcter": charcter,
    "charcter_image": charcterImage,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}