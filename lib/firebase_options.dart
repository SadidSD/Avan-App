// File generated for AVAN Firebase configuration across platforms.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDDt-V-0QJ_Z_Z79SNkS-1w9AmwL00Cz_A',
    appId: '1:659993815762:web:453139c26e31d33b1b9b0b',
    messagingSenderId: '659993815762',
    projectId: 'avan-7231e',
    authDomain: 'avan-7231e.firebaseapp.com',
    storageBucket: 'avan-7231e.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDDt-V-0QJ_Z_Z79SNkS-1w9AmwL00Cz_A',
    appId: '1:659993815762:android:453139c26e31d33b1b9b0b',
    messagingSenderId: '659993815762',
    projectId: 'avan-7231e',
    storageBucket: 'avan-7231e.firebasestorage.app',
  );
}
