class ChatRes {
  bool? success;
  String? response;
  String? sessionId;
  String? timestamp;
  SessionData? sessionData;

  ChatRes({success, response, sessionId, timestamp, sessionData});

  ChatRes.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    response = json['response'];
    sessionId = json['sessionId'];
    timestamp = json['timestamp'];
    sessionData = json['sessionData'] != null
        ? SessionData.fromJson(json['sessionData'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['response'] = response;
    data['sessionId'] = sessionId;
    data['timestamp'] = timestamp;
    if (sessionData != null) {
      data['sessionData'] = sessionData!.toJson();
    }
    return data;
  }
}

class SessionData {
  List<Messages>? messages;
  // List<Null>? emotions;

  SessionData({messages, emotions});

  SessionData.fromJson(Map<String, dynamic> json) {
    if (json['messages'] != null) {
      messages = <Messages>[];
      json['messages'].forEach((v) {
        messages!.add(Messages.fromJson(v));
      });
    }
    // if (json['emotions'] != null) {
    // 	emotions = <Null>[];
    // 	json['emotions'].forEach((v) { emotions!.add( Null.fromJson(v)); });
    // }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (messages != null) {
      data['messages'] = messages!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class Messages {
  String? messageId;
  String? sessionId;
  String? role;
  String? content;
  Metadata? metadata;
  String? sentAt;
  bool? isProcessed;
  bool isMessageSend = false;
  String messageType = "TEXT";
  bool isLocalAudio = false;
  String duration="0";

  Messages(
      {messageId, sessionId, role, content, metadata, sentAt, isProcessed});

  Messages.fromJson(Map<String, dynamic> json) {
    messageId = json['messageId'];
    sessionId = json['sessionId'];
    role = json['role'];
    content = json['content'];
    metadata = json['metadata'] != null
        ? new Metadata.fromJson(json['metadata'])
        : null;
    sentAt = json['sentAt'];
    isProcessed = json['isProcessed'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['messageId'] = messageId;
    data['sessionId'] = sessionId;
    data['role'] = role;
    data['content'] = content;
    if (metadata != null) {
      data['metadata'] = metadata!.toJson();
    }
    data['sentAt'] = sentAt;
    data['isProcessed'] = isProcessed;
    return data;
  }
}

class Metadata {
  SessionContext? sessionContext;

  Metadata({sessionContext});

  Metadata.fromJson(Map<String, dynamic> json) {
    sessionContext = json['sessionContext'] != null
        ? new SessionContext.fromJson(json['sessionContext'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (sessionContext != null) {
      data['sessionContext'] = sessionContext!.toJson();
    }
    return data;
  }
}

class SessionContext {
  UserState? userState;
  // YokaiState? yokaiState;
  EnvironmentalFactors? environmentalFactors;

  SessionContext({userState, yokaiState, environmentalFactors});

  SessionContext.fromJson(Map<String, dynamic> json) {
    userState = json['userState'] != null
        ? UserState.fromJson(json['userState'])
        : null;
    // yokaiState = json['yokaiState'] != null ?  YokaiState.fromJson(json['yokaiState']) : null;
    environmentalFactors = json['environmentalFactors'] != null
        ? EnvironmentalFactors.fromJson(json['environmentalFactors'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (userState != null) {
      data['userState'] = userState!.toJson();
    }
    // if (yokaiState != null) {
    //   data['yokaiState'] = yokaiState!.toJson();
    // }
    if (environmentalFactors != null) {
      data['environmentalFactors'] = environmentalFactors!.toJson();
    }
    return data;
  }
}

class UserState {
  String? lastActivity;

  UserState({lastActivity});

  UserState.fromJson(Map<String, dynamic> json) {
    lastActivity = json['lastActivity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lastActivity'] = lastActivity;
    return data;
  }
}

// class YokaiState {

// 	YokaiState({});

// 	YokaiState.fromJson(Map<String, dynamic> json) {
// 	}

// 	Map<String, dynamic> toJson() {
// 		final Map<String, dynamic> data = new Map<String, dynamic>();
// 		return data;
// 	}
// }

class EnvironmentalFactors {
  String? timeOfDay;

  EnvironmentalFactors({timeOfDay});

  EnvironmentalFactors.fromJson(Map<String, dynamic> json) {
    timeOfDay = json['timeOfDay'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['timeOfDay'] = timeOfDay;
    return data;
  }
}
