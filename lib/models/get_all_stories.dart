// To parse this JSON data, do
//
//     final getAllStory = getAllStoryFromJson(jsonString);

import 'dart:convert';

import 'package:yokai_quiz_app/util/constants.dart';

GetAllStory getAllStoryFromJson(String str) =>
    GetAllStory.fromJson(json.decode(str));

String getAllStoryToJson(GetAllStory data) => json.encode(data.toJson());

class GetAllStory {
  String? status;
  String? message;
  List<Datum>? data;

  GetAllStory({
    this.status,
    this.message,
    this.data,
  });

  factory GetAllStory.fromJson(Map<String, dynamic> json) => GetAllStory(
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
  String? discription;
  String? name;
  int? id;
  DateTime? updatedAt;
  String? storiesImage;
  DateTime? createdAt;

  Datum({
    this.discription,
    this.name,
    this.id,
    this.updatedAt,
    this.storiesImage,
    this.createdAt,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        discription: constants.deviceLanguage == "en"
            ? json["description"]
            : fixEncoding(json["japanese_description"]),
        name: constants.deviceLanguage == "en"
            ? json["name"]
            : fixEncoding(json["japanese_name"]),
        id: json["id"],
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        storiesImage: json["stories_image"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "discription": discription,
        "name": name,
        "id": id,
        "updated_at": updatedAt?.toIso8601String(),
        "stories_image": storiesImage,
        "created_at": createdAt?.toIso8601String(),
      };
}

String fixEncoding(String encodedString) {
  return utf8.decode(encodedString.runes.toList());
}
