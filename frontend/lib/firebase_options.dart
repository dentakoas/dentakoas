// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBFyQGhVNTAmdgC6-1VFOtnOFCXkgNLNmo',
    appId: '1:32327803117:web:76ce162f76f4de37be6ce4',
    messagingSenderId: '32327803117',
    projectId: 'ta-dentakoas-73626',
    authDomain: 'ta-dentakoas-73626.firebaseapp.com',
    storageBucket: 'ta-dentakoas-73626.firebasestorage.app',
    measurementId: 'G-V7J8CH1WSY',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDt4x8WK99EBw1T4_lQBsCVtYJko5_oIFA',
    appId: '1:32327803117:android:c3d28dbe4aa4a4bbbe6ce4',
    messagingSenderId: '32327803117',
    projectId: 'ta-dentakoas-73626',
    storageBucket: 'ta-dentakoas-73626.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD0uLU_Fdyw8MVbYHf1QG6-zZ1vMG9xjlE',
    appId: '1:32327803117:ios:35bbb736b2000825be6ce4',
    messagingSenderId: '32327803117',
    projectId: 'ta-dentakoas-73626',
    storageBucket: 'ta-dentakoas-73626.firebasestorage.app',
    androidClientId:
        '32327803117-anqq7kasfpgkq8mptuf2vo3pn9autlgg.apps.googleusercontent.com',
    iosClientId:
        '32327803117-v1smdefgi2qdneobft1acnjelk1v5l6u.apps.googleusercontent.com',
    iosBundleId: 'com.example.dentaKoas',
  );
}
