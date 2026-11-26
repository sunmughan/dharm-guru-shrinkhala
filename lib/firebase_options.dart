// Placeholder Firebase configuration for Dharm Guru Shrinkhala.
// Real values come from the Firebase console only. See FIREBASE-SETUP.md.
// This file is tracked in git with placeholder values. It is NOT
// gitignored. Run flutterfire configure to replace the placeholders
// with generated values. Do not invent values by hand.
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
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError('Platform not configured for Firebase.');
    }
  }

  // Replace every placeholder below with the generated values.
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'WEB_API_KEY_PLACEHOLDER',
    appId: 'WEB_APP_ID_PLACEHOLDER',
    messagingSenderId: 'MESSAGING_SENDER_ID_PLACEHOLDER',
    projectId: 'PROJECT_ID_PLACEHOLDER',
    authDomain: 'AUTH_DOMAIN_PLACEHOLDER',
    storageBucket: 'STORAGE_BUCKET_PLACEHOLDER',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'ANDROID_API_KEY_PLACEHOLDER',
    appId: 'ANDROID_APP_ID_PLACEHOLDER',
    messagingSenderId: 'MESSAGING_SENDER_ID_PLACEHOLDER',
    projectId: 'PROJECT_ID_PLACEHOLDER',
    storageBucket: 'STORAGE_BUCKET_PLACEHOLDER',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'IOS_API_KEY_PLACEHOLDER',
    appId: 'IOS_APP_ID_PLACEHOLDER',
    messagingSenderId: 'MESSAGING_SENDER_ID_PLACEHOLDER',
    projectId: 'PROJECT_ID_PLACEHOLDER',
    storageBucket: 'STORAGE_BUCKET_PLACEHOLDER',
    iosBundleId: 'IOS_BUNDLE_ID_PLACEHOLDER',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'MACOS_API_KEY_PLACEHOLDER',
    appId: 'MACOS_APP_ID_PLACEHOLDER',
    messagingSenderId: 'MESSAGING_SENDER_ID_PLACEHOLDER',
    projectId: 'PROJECT_ID_PLACEHOLDER',
    storageBucket: 'STORAGE_BUCKET_PLACEHOLDER',
    iosBundleId: 'MACOS_BUNDLE_ID_PLACEHOLDER',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'WINDOWS_API_KEY_PLACEHOLDER',
    appId: 'WINDOWS_APP_ID_PLACEHOLDER',
    messagingSenderId: 'MESSAGING_SENDER_ID_PLACEHOLDER',
    projectId: 'PROJECT_ID_PLACEHOLDER',
    storageBucket: 'STORAGE_BUCKET_PLACEHOLDER',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'LINUX_API_KEY_PLACEHOLDER',
    appId: 'LINUX_APP_ID_PLACEHOLDER',
    messagingSenderId: 'MESSAGING_SENDER_ID_PLACEHOLDER',
    projectId: 'PROJECT_ID_PLACEHOLDER',
    storageBucket: 'STORAGE_BUCKET_PLACEHOLDER',
  );
}
