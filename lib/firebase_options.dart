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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyD3erKGWIyAB-LgUo3yh5_eB6kYvRmlUOM',
    appId: '1:654346860165:web:e4328890d7c89ea0875bec',
    messagingSenderId: '654346860165',
    projectId: 'is767-2024-final',
    authDomain: 'is767-2024-final.firebaseapp.com',
    storageBucket: 'is767-2024-final.firebasestorage.app',
    measurementId: 'G-QX0JWMRE6L',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB8J5YQKVL9G7UPcNwNJW5zBC4ZiCf3oY4',
    appId: '1:654346860165:android:af9f6cc715d0fef7875bec',
    messagingSenderId: '654346860165',
    projectId: 'is767-2024-final',
    storageBucket: 'is767-2024-final.firebasestorage.app',
  );

}