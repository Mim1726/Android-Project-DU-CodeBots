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
        return windows;
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
    apiKey: 'AIzaSyBK8dujcl9Nz_H3JtwjZpX8fmQIZ3DRAY0',
    appId: '1:328941637152:web:797fc2346e46de237cb645',
    messagingSenderId: '328941637152',
    projectId: 'project-9e115',
    authDomain: 'project-9e115.firebaseapp.com',
    storageBucket: 'project-9e115.firebasestorage.app',
    measurementId: 'G-CVHCV944V7',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDKjB1RtYxyTawWiC_BTHc9FcESB1bPxRo',
    appId: '1:328941637152:android:e057aa34df831f917cb645',
    messagingSenderId: '328941637152',
    projectId: 'project-9e115',
    storageBucket: 'project-9e115.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDyPO2IMgZWWON6FkHiP4OgUqbjrmGm1y4',
    appId: '1:328941637152:ios:af77de9762f09c7a7cb645',
    messagingSenderId: '328941637152',
    projectId: 'project-9e115',
    storageBucket: 'project-9e115.firebasestorage.app',
    iosBundleId: 'com.example.android',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDyPO2IMgZWWON6FkHiP4OgUqbjrmGm1y4',
    appId: '1:328941637152:ios:af77de9762f09c7a7cb645',
    messagingSenderId: '328941637152',
    projectId: 'project-9e115',
    storageBucket: 'project-9e115.firebasestorage.app',
    iosBundleId: 'com.example.android',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBK8dujcl9Nz_H3JtwjZpX8fmQIZ3DRAY0',
    appId: '1:328941637152:web:196182de4504536c7cb645',
    messagingSenderId: '328941637152',
    projectId: 'project-9e115',
    authDomain: 'project-9e115.firebaseapp.com',
    storageBucket: 'project-9e115.firebasestorage.app',
    measurementId: 'G-JDGC2SS8XC',
  );
}
