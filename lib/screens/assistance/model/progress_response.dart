import 'package:yokai_quiz_app/global.dart';

class ProgressResponse {
  bool? success;
  ProgressData? data;

  ProgressResponse({this.success, this.data});

  ProgressResponse.fromJson(Map<String, dynamic> json) {
    customPrint("fromJson started");
    success = json['success'];
    data = json['data'] != null ? ProgressData.fromJson(json['data']) : null;
    customPrint("fromJson completed without error");
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class ProgressData {
  ProgressCategory? sel;
  ProgressCategory? cbt;
  Overview? overview;

  ProgressData({this.sel, this.cbt, this.overview});

  ProgressData.fromJson(Map<String, dynamic> json) {
    sel = json['SEL'] != null ? ProgressCategory.fromJson(json['SEL']) : null;
    cbt = json['CBT'] != null ? ProgressCategory.fromJson(json['CBT']) : null;
    overview = json['Overview'] != null ? Overview.fromJson(json['Overview']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (sel != null) {
      data['SEL'] = sel!.toJson();
    }
    if (cbt != null) {
      data['CBT'] = cbt!.toJson();
    }
    if (overview != null) {
      data['Overview'] = overview!.toJson();
    }
    return data;
  }
}

class ProgressCategory {
  double? overallProgress;
  Map<String, double>? categories;

  ProgressCategory({this.overallProgress, this.categories});

  ProgressCategory.fromJson(Map<String, dynamic> json) {
    overallProgress = json['overallProgress']?.toDouble();
    if (json['categories'] != null) {
      categories = {};
      json['categories'].forEach((key, value) {
        categories![key] = (value is int) ? value.toDouble() : value;
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['overallProgress'] = overallProgress;
    data['categories'] = categories;
    return data;
  }
}

class Overview {
  Map<String, double>? categories;
  Map<String, String>? translations;

  Overview({this.categories, this.translations});

  Overview.fromJson(Map<String, dynamic> json) {
    if (json['categories'] != null) {
      categories = {};
      json['categories'].forEach((key, value) {
        categories![key] = (value is int) ? value.toDouble() : value;
      });
    }
    if (json['translations'] != null) {
      translations = {};
      json['translations'].forEach((key, value) {
        translations![key] = value;
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['categories'] = categories;
    data['translations'] = translations;
    return data;
  }
}
