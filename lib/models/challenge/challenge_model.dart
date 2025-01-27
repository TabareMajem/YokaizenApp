import 'package:yokai_quiz_app/models/get_all_stories.dart';
import 'package:yokai_quiz_app/util/constants.dart';

class ChallengeRes {
  String? status;
  String? message;
  List<ChallengeData>? data;

  ChallengeRes({status, message, data});

  ChallengeRes.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <ChallengeData>[];
      json['data'].forEach((v) {
        data!.add(ChallengeData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMain = <String, dynamic>{};
    dataMain['status'] = status;
    dataMain['message'] = message;
    if (data != null) {
      dataMain['data'] = data!.map((v) => v.toJson()).toList();
    }
    return dataMain;
  }
}

class ChallengeData {
  String? japaneseDescription;
  String? name;
  String? japaneseCriteria;
  int? badgeId;
  String? type;
  bool? isRewarded;
  String? japaneseName;
  String? description;
  String? criteria;
  int? reward;
  int? id;
  String? image;

  ChallengeData(
      {japaneseDescription,
      name,
      japaneseCriteria,
      badgeId,
      type,
      isRewarded,
      japaneseName,
      description,
      criteria,
      reward,
      id,
      image});

  ChallengeData.fromJson(Map<String, dynamic> json) {
    japaneseDescription = fixEncoding(json["japanese_description"]);
    name = constants.deviceLanguage == "en"
        ? fixEncoding(json["name"])
        : fixEncoding(json["japanese_name"]);
    image = json['image'];
    japaneseCriteria = json['japanese_criteria'];
    badgeId = json['badge_id'];
    type = json['type'];
    isRewarded = json['isRewarded'];
    japaneseName = fixEncoding(json["japanese_name"]);
    description = constants.deviceLanguage == "en"
        ? fixEncoding(json["description"])
        : fixEncoding(json["japanese_description"]);
    criteria = json['criteria'];
    reward = json['reward'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['japanese_description'] = japaneseDescription;
    data['name'] = name;
    data['image'] = image;
    data['japanese_criteria'] = japaneseCriteria;
    data['badge_id'] = badgeId;
    data['type'] = type;
    data['isRewarded'] = isRewarded;
    data['japanese_name'] = japaneseName;
    data['description'] = description;
    data['criteria'] = criteria;
    data['reward'] = reward;
    data['id'] = id;
    return data;
  }
}
