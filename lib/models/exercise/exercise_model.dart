class ExercisesRes {
  List<Exercises> exercises=[];
  int? count;

  ExercisesRes({exercises, count});

  ExercisesRes.fromJson(Map<String, dynamic> json) {
    if (json['exercises'] != null) {
      exercises = <Exercises>[];
      json['exercises'].forEach((v) {
        exercises.add(Exercises.fromJson(v));
      });
    }
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (exercises.isNotEmpty) {
      data['exercises'] = exercises.map((v) => v.toJson()).toList();
    }
    data['count'] = count;
    return data;
  }
}

class Exercises {
  String? exerciseId;
  String? type;
  String? difficulty;
  String? title;
  String? category;
  String? description;
  List<Steps>? steps;
  int? duration;
  String? status;
  EmotionalState? emotionalState;
  String? startTime;
  dynamic completionTime;
  Metrics? metrics;
  dynamic feedback;
  dynamic thoughtRecords;
  String? created;
  String? lastUpdated;
  User? user;

  Exercises(
      {exerciseId,
      type,
      difficulty,
      title,
      category,
      description,
      steps,
      duration,
      status,
      emotionalState,
      startTime,
      completionTime,
      metrics,
      feedback,
      thoughtRecords,
      created,
      lastUpdated,
      user});

  Exercises.fromJson(Map<String, dynamic> json) {
    exerciseId = json['exerciseId'];
    type = json['type'];
    difficulty = json['difficulty'];
    title = json['title'];
    category = json['category'];
    description = json['description'];
    if (json['steps'] != null) {
      steps = <Steps>[];
      json['steps'].forEach((v) {
        steps!.add(Steps.fromJson(v));
      });
    }
    duration = json['duration'];
    status = json['status'];
    emotionalState = json['emotionalState'] != null
        ? EmotionalState.fromJson(json['emotionalState'])
        : null;
    startTime = json['startTime'];
    completionTime = json['completionTime'];
    metrics =
        json['metrics'] != null ? Metrics.fromJson(json['metrics']) : null;
    feedback = json['feedback'];
    thoughtRecords = json['thoughtRecords'];
    created = json['created'];
    lastUpdated = json['lastUpdated'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['exerciseId'] = exerciseId;
    data['type'] = type;
    data['difficulty'] = difficulty;
    data['title'] = title;
    data['category'] = category;
    data['description'] = description;
    if (steps != null) {
      data['steps'] = steps!.map((v) => v.toJson()).toList();
    }
    data['duration'] = duration;
    data['status'] = status;
    if (emotionalState != null) {
      data['emotionalState'] = emotionalState!.toJson();
    }
    data['startTime'] = startTime;
    data['completionTime'] = completionTime;
    if (metrics != null) {
      data['metrics'] = metrics!.toJson();
    }
    data['feedback'] = feedback;
    data['thoughtRecords'] = thoughtRecords;
    data['created'] = created;
    data['lastUpdated'] = lastUpdated;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}

class Steps {
  int? order;
  bool? completion;
  String? instruction;

  Steps({order, completion, instruction});

  Steps.fromJson(Map<String, dynamic> json) {
    order = json['order'];
    completion = json['completion'];
    instruction = json['instruction'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['order'] = order;
    data['completion'] = completion;
    data['instruction'] = instruction;
    return data;
  }
}

class EmotionalState {
  // Before? before;

  // EmotionalState({
  //   // before
  //   });

  EmotionalState.fromJson(Map<String, dynamic> json) {
    // before = json['before'] != null ? new Before.fromJson(json['before']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    // if (before != null) {
    //   data['before'] = before!.toJson();
    // }
    return data;
  }
}

// class Before {

// 	Before({});

// 	Before.fromJson(Map<String, dynamic> json) {
// 	}

// 	Map<String, dynamic> toJson() {
// 		final Map<String, dynamic> data = new Map<String, dynamic>();
// 		return data;
// 	}
// }

class Metrics {
  int? completion;
  int? engagement;
  int? effectiveness;

  Metrics({completion, engagement, effectiveness});

  Metrics.fromJson(Map<String, dynamic> json) {
    completion = json['completion'];
    engagement = json['engagement'];
    effectiveness = json['effectiveness'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['completion'] = completion;
    data['engagement'] = engagement;
    data['effectiveness'] = effectiveness;
    return data;
  }
}

class User {
  String? userId;
  String? displayName;
  String? email;
  String? phoneNumber;
  String? loginType;
  String? createdAt;
  String? lastActive;

  User(
      {userId,
      displayName,
      email,
      phoneNumber,
      loginType,
      createdAt,
      lastActive});

  User.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    displayName = json['displayName'];
    email = json['email'];
    phoneNumber = json['phoneNumber'];
    loginType = json['loginType'];
    createdAt = json['createdAt'];
    lastActive = json['lastActive'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['displayName'] = displayName;
    data['email'] = email;
    data['phoneNumber'] = phoneNumber;
    data['loginType'] = loginType;
    data['createdAt'] = createdAt;
    data['lastActive'] = lastActive;
    return data;
  }
}
