class AssessmentResult {
  String? assessmentType;
  int? id;
  // Scores? scores;
  RadarData? radarData;
  int? userId;
  int? quizId;
  List<Responses>? responses;
  Insights? insights;

  AssessmentResult(
      {assessmentType,
      id,
      // scores,
      radarData,
      userId,
      quizId,
      responses,
      insights});

  AssessmentResult.fromJson(Map<String, dynamic> json) {
    assessmentType = json['assesment_type'];
    id = json['id'];
    // scores =
    //     json['scores'] != null ? new Scores.fromJson(json['scores']) : null;
    radarData = json['radar_data'] != null
        ? new RadarData.fromJson(json['radar_data'])
        : null;
    userId = json['user_id'];
    quizId = json['quiz_id'];
    if (json['responses'] != null) {
      responses = <Responses>[];
      json['responses'].forEach((v) {
        responses!.add(new Responses.fromJson(v));
      });
    }
    insights = json['insights'] != null
        ? new Insights.fromJson(json['insights'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['assesment_type'] = assessmentType;
    data['id'] = id;
    // if (scores != null) {
    //   data['scores'] = scores!.toJson();
    // }
    if (radarData != null) {
      data['radar_data'] = radarData!.toJson();
    }
    data['user_id'] = userId;
    data['quiz_id'] = quizId;
    if (responses != null) {
      data['responses'] = responses!.map((v) => v.toJson()).toList();
    }
    if (insights != null) {
      data['insights'] = insights!.toJson();
    }
    return data;
  }
}

class Scores {
  double? achiever;
  int? explorer;
  int? socializer;
  int? killer;

  Scores({achiever, explorer, socializer, killer});

  Scores.fromJson(Map<String, dynamic> json) {
    achiever = json['Achiever'];
    explorer = json['Explorer'];
    socializer = json['Socializer'];
    killer = json['Killer'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Achiever'] = achiever;
    data['Explorer'] = explorer;
    data['Socializer'] = socializer;
    data['Killer'] = killer;
    return data;
  }
}

class RadarData {
  List<String>? categories;
  List<double>? values;

  RadarData({categories, values});

  RadarData.fromJson(Map<String, dynamic> json) {
    categories = json['categories'].cast<String>();
    values = json['values'].cast<double>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['categories'] = categories;
    data['values'] = values;
    return data;
  }
}

class Responses {
  int? questionIndex;
  int? selectedAnswer;
  List<int>? selectedAnswers;
  String? answerText;
  String? interactionPrompt;

  Responses(
      {questionIndex,
      selectedAnswer,
      selectedAnswers,
      answerText,
      interactionPrompt});

  Responses.fromJson(Map<String, dynamic> json) {
    questionIndex = json['question_index'];
    selectedAnswer = json['selected_answer'];
    selectedAnswers = json['selected_answers'].cast<int>();
    answerText = json['answer_text'];
    interactionPrompt = json['interaction_prompt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['question_index'] = questionIndex;
    data['selected_answer'] = selectedAnswer;
    data['selected_answers'] = selectedAnswers;
    data['answer_text'] = answerText;
    data['interaction_prompt'] = interactionPrompt;
    return data;
  }
}

class Insights {
  String? dominantStrength;
  String? dominantDescription;
  String? supportingStrength;
  String? supportingDescription;
  String? developmentAreas;

  Insights(
      {dominantStrength,
      dominantDescription,
      supportingStrength,
      supportingDescription,
      developmentAreas});

  Insights.fromJson(Map<String, dynamic> json) {
    dominantStrength = json['dominant_strength'];
    dominantDescription = json['dominant_description'];
    supportingStrength = json['supporting_strength'];
    supportingDescription = json['supporting_description'];
    developmentAreas = json['development_areas'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['dominant_strength'] = dominantStrength;
    data['dominant_description'] = dominantDescription;
    data['supporting_strength'] = supportingStrength;
    data['supporting_description'] = supportingDescription;
    data['development_areas'] = developmentAreas;
    return data;
  }
}
