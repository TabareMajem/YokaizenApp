import 'package:flutter_line_sdk/flutter_line_sdk.dart';

class LineSDKConfig {
  static Future<void> init() async {
    try {
      // //   2006749396
      await LineSDK.instance.setup("2006306499");
      print("LineSDK Prepared");
    } catch (e) {
      print('LineSDK Initialization Error: $e');
    }
  }
}