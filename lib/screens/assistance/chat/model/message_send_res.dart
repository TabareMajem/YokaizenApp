/// messega_send_res

import '../../../../models/exercise/Exercise_model.dart';

class MessageSendRes {
  final bool success;
  final String response;
  final String sessionId;
  final String messageId;
  final EmotionalState emotionalState;
  final VideoData? video;

  MessageSendRes({
    required this.success,
    required this.response,
    required this.sessionId,
    required this.messageId,
    required this.emotionalState,
    this.video,
  });

  factory MessageSendRes.fromJson(Map<String, dynamic> json) {
    return MessageSendRes(
      success: json['success'] ?? false,
      response: json['response'] ?? '',
      sessionId: json['sessionId'] ?? '',
      messageId: json['messageId'] ?? '',
      emotionalState: EmotionalState.fromJson(json['emotionalState'] ?? {}),
      video: json['video'] != null ? VideoData.fromJson(json['video']) : null,
    );
  }
}

class VideoData {
  final String fileName;
  final String url;

  VideoData({
    required this.fileName,
    required this.url,
  });

  factory VideoData.fromJson(Map<String, dynamic> json) {
    return VideoData(
      fileName: json['fileName'] ?? '',
      url: json['url'] ?? '',
    );
  }
} 