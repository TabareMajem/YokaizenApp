class ComplementRes {
  String? status;
  String? message;
  List<ComplementData> data=[];

  ComplementRes({this.status, this.message, data});

  ComplementRes.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <ComplementData>[];
      json['data'].forEach((v) {
        data.add( ComplementData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> userData = <String, dynamic>{};
    userData['status'] = status;
    userData['message'] = message;
    if (data.isNotEmpty) {
      userData['data'] =data.map((v) => v.toJson()).toList();
    }
    return userData;
  }
}

class ComplementData {
  String? questionText;
  String? complimentImage;
  String? questionImage;
  String? story;
  // Null? japaneseVersion;
  int? id;
  String? complimentText;
  String? complimentName;
  String? complimentDescription;
  int? activityId;
  // Null? koreanVersion;

  ComplementData(
      {this.questionText,
      this.complimentImage,
      this.questionImage,
      this.story,
      // this.japaneseVersion,
      this.id,
      this.complimentText,
      this.complimentName,
      this.complimentDescription,
      this.activityId,
      // this.koreanVersion,
      });

  ComplementData.fromJson(Map<String, dynamic> json) {
    questionText = json['question_text'];
    complimentImage = json['compliment_image'];
    questionImage = json['question_image'];
    story = json['story'];
    // japaneseVersion = json['japanese_version'];
    id = json['id'];
    complimentText = json['compliment_text'];
    complimentName = json['compliment_name'];
    complimentDescription = json['compliment_description'];
    activityId = json['activity_id'];
    // koreanVersion = json['korean_version'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['question_text'] = questionText;
    data['compliment_image'] =complimentImage;
    data['question_image'] = questionImage;
    data['story'] = story;
    // data['japanese_version'] = this.japaneseVersion;
    data['id'] = id;
    data['compliment_text'] = complimentText;
    data['compliment_name'] = complimentName;
    data['compliment_description'] =complimentDescription;
    data['activity_id'] = activityId;
    // data['korean_version'] = this.koreanVersion;
    return data;
  }
}
