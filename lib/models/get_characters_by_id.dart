// To parse this JSON data, do
//
//     final getCharactersById = getCharactersByIdFromJson(jsonString);

import 'dart:convert';

import 'package:yokai_quiz_app/util/constants.dart';

GetCharactersById getCharactersByIdFromJson(String str) =>
    GetCharactersById.fromJson(json.decode(str));

String getCharactersByIdToJson(GetCharactersById data) =>
    json.encode(data.toJson());

class GetCharactersById {
  String? status;
  String? message;
  Data? data;

  GetCharactersById({
    this.status,
    this.message,
    this.data,
  });

  factory GetCharactersById.fromJson(Map<String, dynamic> json) =>
      GetCharactersById(
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
  String? storiesId;
  String? link;
  String? introduction;
  String? characterImage;
  String? requirements;
  String? prompt;
  List<String>? tags;
  String? storyName;
  int? totalChapter;
  int? totalReadChapter;
  DateTime? createdAt;
  DateTime? updatedAt;

  Data({
    this.id,
    this.name,
    this.storiesId,
    this.link,
    this.introduction,
    this.characterImage,
    this.requirements,
    this.prompt,
    this.tags,
    this.storyName,
    this.totalChapter,
    this.totalReadChapter,
    this.createdAt,
    this.updatedAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        name: constants.deviceLanguage == "en"
            ? fixEncoding(json["name"])
            : fixEncoding(json["japanese_name"]),
        storiesId: json["stories_id"].toString(),
        link: json["link"],
        introduction: constants.deviceLanguage == "en"
            ? json["introduction"]
            : fixEncoding(json["japanese_introduction"]),
        characterImage: json["character_image"],
        requirements:constants.deviceLanguage == "en"
            ? json["requirements"]:fixEncoding(json["japanese_requirements"]),
        prompt: json["prompt"],
        tags: json["tags"] == null
            ? []
            : List<String>.from(json["tags"]!.map((x) => x)),
        storyName: json["story_name"],
        totalChapter: json["total_chapter"],
        totalReadChapter: json["total_read_chapter"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "stories_id": storiesId,
        "link": link,
        "introduction": introduction,
        "character_image": characterImage,
        "requirements": requirements,
        "prompt": prompt,
        "tags": tags == null ? [] : List<dynamic>.from(tags!.map((x) => x)),
        "story_name": storyName,
        "total_chapter": totalChapter,
        "total_read_chapter": totalReadChapter,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}

String fixEncoding(String encodedString) {
  return utf8.decode(encodedString.runes.toList());
}
