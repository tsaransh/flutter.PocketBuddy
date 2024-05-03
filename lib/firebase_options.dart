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
        return macos;
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAdwijfGOsE3Ge8kdX-jx5pIh1Fsl8-cIk',
    appId: '1:43724375884:android:2eecb91d3528b02b75b1e9',
    messagingSenderId: '43724375884',
    projectId: 'pocket-buddy-954e6',
    storageBucket: 'pocket-buddy-954e6.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD0wsWWTpWvKWZzhuf8uxKVfBJ0bC-vNM4',
    appId: '1:43724375884:ios:6f11983e8b4f03ea75b1e9',
    messagingSenderId: '43724375884',
    projectId: 'pocket-buddy-954e6',
    storageBucket: 'pocket-buddy-954e6.appspot.com',
    androidClientId: '43724375884-cvp8276hbcq8gbjkprjdso9514gk1khu.apps.googleusercontent.com',
    iosClientId: '43724375884-f6650nmf6pru174ttak74h6h3960codm.apps.googleusercontent.com',
    iosBundleId: 'com.example.pocketBuddyNew',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBrt1Os7Byjrixk8VLkhHNVDKJHBwp9QGo',
    appId: '1:43724375884:web:0ddd3d33d47a07bb75b1e9',
    messagingSenderId: '43724375884',
    projectId: 'pocket-buddy-954e6',
    authDomain: 'pocket-buddy-954e6.firebaseapp.com',
    storageBucket: 'pocket-buddy-954e6.appspot.com',
    measurementId: 'G-GWVYSCWD1S',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD0wsWWTpWvKWZzhuf8uxKVfBJ0bC-vNM4',
    appId: '1:43724375884:ios:6f11983e8b4f03ea75b1e9',
    messagingSenderId: '43724375884',
    projectId: 'pocket-buddy-954e6',
    storageBucket: 'pocket-buddy-954e6.appspot.com',
    androidClientId: '43724375884-cvp8276hbcq8gbjkprjdso9514gk1khu.apps.googleusercontent.com',
    iosClientId: '43724375884-f6650nmf6pru174ttak74h6h3960codm.apps.googleusercontent.com',
    iosBundleId: 'com.example.pocketBuddyNew',
  );

}