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
    apiKey: 'AIzaSyBiKMz51QCmhmQ-ySRaUm1QzCstNQpfF0U',
    appId: '1:726546770167:web:5d175ab5e5290b9a0e0bf2',
    messagingSenderId: '726546770167',
    projectId: 'apisflutter-7925942',
    authDomain: 'apisflutter-7925942.firebaseapp.com',
    storageBucket: 'apisflutter-7925942.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBGZ7HqmgyRXEzoSEORs2lCS4NuEEsgnTM',
    appId: '1:726546770167:android:37a7984173168fd80e0bf2',
    messagingSenderId: '726546770167',
    projectId: 'apisflutter-7925942',
    storageBucket: 'apisflutter-7925942.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCQjerBMJ9KJuKG9Wq4NaYxLO-aNJftHWw',
    appId: '1:726546770167:ios:99981b2261e8fcf40e0bf2',
    messagingSenderId: '726546770167',
    projectId: 'apisflutter-7925942',
    storageBucket: 'apisflutter-7925942.appspot.com',
    androidClientId: '726546770167-f5cto7pu5ifoceqco3utbuinhim3k07i.apps.googleusercontent.com',
    iosClientId: '726546770167-diteg5f1serirdedi1c5g2pdord26bv4.apps.googleusercontent.com',
    iosBundleId: 'com.example.googleApisFlutter',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCQjerBMJ9KJuKG9Wq4NaYxLO-aNJftHWw',
    appId: '1:726546770167:ios:99981b2261e8fcf40e0bf2',
    messagingSenderId: '726546770167',
    projectId: 'apisflutter-7925942',
    storageBucket: 'apisflutter-7925942.appspot.com',
    androidClientId: '726546770167-f5cto7pu5ifoceqco3utbuinhim3k07i.apps.googleusercontent.com',
    iosClientId: '726546770167-diteg5f1serirdedi1c5g2pdord26bv4.apps.googleusercontent.com',
    iosBundleId: 'com.example.googleApisFlutter',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBiKMz51QCmhmQ-ySRaUm1QzCstNQpfF0U',
    appId: '1:726546770167:web:fcc6d22b49d4f86f0e0bf2',
    messagingSenderId: '726546770167',
    projectId: 'apisflutter-7925942',
    authDomain: 'apisflutter-7925942.firebaseapp.com',
    storageBucket: 'apisflutter-7925942.appspot.com',
  );

}