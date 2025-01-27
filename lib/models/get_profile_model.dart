// To parse this JSON data, do
//
//     final getUserProfile = getUserProfileFromJson(jsonString);

import 'dart:convert';

GetUserProfile getUserProfileFromJson(String str) => GetUserProfile.fromJson(json.decode(str));

String getUserProfileToJson(GetUserProfile data) => json.encode(data.toJson());

class GetUserProfile {
  String? status;
  String? message;
  User? user;

  GetUserProfile({
    this.status,
    this.message,
    this.user,
  });

  factory GetUserProfile.fromJson(Map<String, dynamic> json) => GetUserProfile(
    status: json["status"],
    message: json["message"],
    user: json["user"] == null ? null : User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "user": user?.toJson(),
  };
}

class User {
  int? userId;
  String? email;
  String? name;
  String? password;
  dynamic phoneNumber;
  String? accountStatus;
  String? loginType;
  DateTime? expireSessionToken;
  DateTime? lastSessionTime;
  String? sessionToken;
  DateTime? createdAt;
  DateTime? updatedAt;

  User({
    this.userId,
    this.email,
    this.name,
    this.password,
    this.phoneNumber,
    this.accountStatus,
    this.loginType,
    this.expireSessionToken,
    this.lastSessionTime,
    this.sessionToken,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    userId: json["user_id"],
    email: json["email"],
    name: json["name"],
    password: json["password"],
    phoneNumber: json["phone_number"],
    accountStatus: json["account_status"],
    loginType: json["login_type"],
    expireSessionToken: json["expire_session_token"] == null ? null : DateTime.parse(json["expire_session_token"]),
    lastSessionTime: json["last_session_time"] == null ? null : DateTime.parse(json["last_session_time"]),
    sessionToken: json["session_token"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "email": email,
    "name": name,
    "password": password,
    "phone_number": phoneNumber,
    "account_status": accountStatus,
    "login_type": loginType,
    "expire_session_token": expireSessionToken?.toIso8601String(),
    "last_session_time": lastSessionTime?.toIso8601String(),
    "session_token": sessionToken,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
