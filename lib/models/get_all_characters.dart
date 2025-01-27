// To parse this JSON data, do
//
//     final getAllCharacters = getAllCharactersFromJson(jsonString);

import 'dart:convert';

GetAllCharacters getAllCharactersFromJson(String str) =>
    GetAllCharacters.fromJson(json.decode(str));

String getAllCharactersToJson(GetAllCharacters data) =>
    json.encode(data.toJson());

class GetAllCharacters {
  String? status;
  String? message;
  List<Datum>? data;

  GetAllCharacters({
    this.status,
    this.message,
    this.data,
  });

  factory GetAllCharacters.fromJson(Map<String, dynamic> json) =>
      GetAllCharacters(
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
  String? prompt;
  String? name;
  dynamic storiesId;
  String? introducation;
  String? characterImage;
  DateTime? createdAt;
  DateTime? updatedAt;

  Datum({
    this.id,
    this.prompt,
    this.name,
    this.storiesId,
    this.introducation,
    this.characterImage,
    this.createdAt,
    this.updatedAt,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        prompt: json["prompt"],
        name: json["name"],
        storiesId: json["stories_id"],
        introducation: json["introducation"],
        characterImage: json["character_image"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "prompt": prompt,
        "name": name,
        "stories_id": storiesId,
        "introducation": introducation,
        "character_image": characterImage,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
