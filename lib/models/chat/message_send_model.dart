class MessageSendRes {
  bool? success;
  String? response;
  String? sessionId;

  MessageSendRes({this.success, this.response, this.sessionId});

  MessageSendRes.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    response = json['response'];
    sessionId = json['sessionId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['response'] = response;
    data['sessionId'] = sessionId;
    return data;
  }
}
