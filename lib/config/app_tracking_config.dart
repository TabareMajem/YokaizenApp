import 'package:app_tracking_transparency/app_tracking_transparency.dart';


class AppTrackingConfig {

  static Future<void> initPlugin() async {
    // Wait for the app to be fully initialized
    await Future.delayed(const Duration(milliseconds: 200));

    // Get tracking status
    final status = await AppTrackingTransparency.trackingAuthorizationStatus;

    // If not determined, request permission
    if (status == TrackingStatus.notDetermined) {
      // Show a custom explanation dialog before the system prompt if desired
      // await showCustomTrackingDialog(context);

      // Request system permission
      await AppTrackingTransparency.requestTrackingAuthorization();
    }
  }
}

