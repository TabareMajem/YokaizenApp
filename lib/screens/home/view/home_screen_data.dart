class HomeScreenData {
  final dynamic lastReadChapter;
  final dynamic authData;
  final dynamic challengeData;
  final String deviceId;
  final String deviceName;
  final String ipAddress;

  HomeScreenData({
    this.lastReadChapter,
    this.authData,
    this.challengeData,
    required this.deviceId,
    required this.deviceName,
    required this.ipAddress,
  });
}