import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can create a web app in the Firebase console and run "flutterfire configure"',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can create a macOS app in the Firebase console and run "flutterfire configure"',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can create a Windows app in the Firebase console and run "flutterfire configure"',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can create a Linux app in the Firebase console and run "flutterfire configure"',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBOcdRS_-X1dOZahOgdkJdPWxf12SAn_sA',
    appId: '1:543257928924:android:b374bd4fc856d39e08c019',
    messagingSenderId: '543257928924',
    projectId: 'yokaizen-43f63',
    storageBucket: 'yokaizen-43f63.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCDVaJnH_7Qi0_Ob6HWBokgULiFhncoJcM',
    appId: '1:543257928924:ios:a57cd5b2c552a99e08c019',
    messagingSenderId: '543257928924',
    projectId: 'yokaizen-43f63',
    storageBucket: 'yokaizen-43f63.firebasestorage.app',
    iosClientId: '543257928924-arjavjrr75g92c97sko40a8ce7ohv8a0.apps.googleusercontent.com',
    iosBundleId: 'com.yokaiquizzen.yokaiquizApp',
  );
}
