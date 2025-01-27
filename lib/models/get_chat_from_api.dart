// To parse this JSON data, do
//
//     final getChatFromApiByCharacterId = getChatFromApiByCharacterIdFromJson(jsonString);

import 'dart:convert';

GetChatFromApiByCharacterId getChatFromApiByCharacterIdFromJson(String str) => GetChatFromApiByCharacterId.fromJson(json.decode(str));

String getChatFromApiByCharacterIdToJson(GetChatFromApiByCharacterId data) => json.encode(data.toJson());

class GetChatFromApiByCharacterId {
  String? status;
  String? message;
  List<Datum>? data;
  String? prompt;
  List<String>? tags;
  dynamic summary;
  String? characterId;
  int? totalData;
  int? totalPages;
  int? currentPage;
  int? pageSize;

  GetChatFromApiByCharacterId({
    this.status,
    this.message,
    this.data,
    this.prompt,
    this.tags,
    this.summary,
    this.characterId,
    this.totalData,
    this.totalPages,
    this.currentPage,
    this.pageSize,
  });

  factory GetChatFromApiByCharacterId.fromJson(Map<String, dynamic> json) => GetChatFromApiByCharacterId(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    prompt: json["prompt"],
    tags: json["tags"] == null ? [] : List<String>.from(json["tags"]!.map((x) => x)),
    summary: json["summary"],
    characterId: json["character_id"],
    totalData: json["total_data"],
    totalPages: json["total_pages"],
    currentPage: json["current_page"],
    pageSize: json["page_size"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "prompt": prompt,
    "tags": tags == null ? [] : List<dynamic>.from(tags!.map((x) => x)),
    "summary": summary,
    "character_id": characterId,
    "total_data": totalData,
    "total_pages": totalPages,
    "current_page": currentPage,
    "page_size": pageSize,
  };
}

class Datum {
  String? userId;
  String? characterId;
  String? question;
  DateTime? updatedAt;
  int? id;
  String? answer;
  DateTime? createdAt;

  Datum({
    this.userId,
    this.characterId,
    this.question,
    this.updatedAt,
    this.id,
    this.answer,
    this.createdAt,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    userId: json["user_id"],
    characterId: json["character_id"],
    question: json["question"],
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    id: json["id"],
    answer: json["answer"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "character_id": characterId,
    "question": question,
    "updated_at": updatedAt?.toIso8601String(),
    "id": id,
    "answer": answer,
    "created_at": createdAt?.toIso8601String(),
  };
}
