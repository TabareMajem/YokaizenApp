class MoodSummeryRes {
  String? status;
  String? message;
  List<Data>? data;

  MoodSummeryRes({this.status, this.message, this.data});

  MoodSummeryRes.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? date;
  double? averageMoodLevel;
  List<int>? moodGifs;

  Data({this.date, this.averageMoodLevel, this.moodGifs});

  Data.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    averageMoodLevel = json['average_mood_level'];
    moodGifs = json['mood_gifs'].cast<int>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    data['average_mood_level'] = averageMoodLevel;
    data['mood_gifs'] = moodGifs;
    return data;
  }
}
