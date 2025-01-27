// To parse this JSON data, do
//
//     final getUnlockAllCharacters = getUnlockAllCharactersFromJson(jsonString);

import 'dart:convert';

GetUnlockAllCharacters getUnlockAllCharactersFromJson(String str) => GetUnlockAllCharacters.fromJson(json.decode(str));

String getUnlockAllCharactersToJson(GetUnlockAllCharacters data) => json.encode(data.toJson());

class GetUnlockAllCharacters {
  String? status;
  String? message;
  List<Datum>? data;

  GetUnlockAllCharacters({
    this.status,
    this.message,
    this.data,
  });

  factory GetUnlockAllCharacters.fromJson(Map<String, dynamic> json) => GetUnlockAllCharacters(
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
  String? prompt;
  String? name;
  String? storiesId;
  String? link;
  String? introducation;
  String? characterImage;
  String? requirements;
  String? latestMessage;
  DateTime? lastMessageTime;
  String? tags;
  DateTime? createdAt;
  DateTime? updatedAt;

  Datum({
    this.id,
    this.prompt,
    this.name,
    this.storiesId,
    this.link,
    this.introducation,
    this.characterImage,
    this.requirements,
    this.latestMessage,
    this.lastMessageTime,
    this.tags,
    this.createdAt,
    this.updatedAt,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    prompt: json["prompt"],
    name: json["name"],
    storiesId: json["stories_id"],
    link: json["link"],
    introducation: json["introducation"],
    characterImage: json["character_image"],
    requirements: json["requirements"],
    latestMessage: json["latest_message"],
    lastMessageTime: json["last_message_time"] == null ? null : DateTime.parse(json["last_message_time"]),
    tags: json["tags"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "prompt": prompt,
    "name": name,
    "stories_id": storiesId,
    "link": link,
    "introducation": introducation,
    "character_image": characterImage,
    "requirements": requirements,
    "latest_message": latestMessage,
    "last_message_time": lastMessageTime?.toIso8601String(),
    "tags": tags,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
