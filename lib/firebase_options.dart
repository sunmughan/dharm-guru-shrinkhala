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

  // Android and iOS values come from google-services.json and
// GoogleService-Info.plist. Web, macOS, Windows and Linux have
// no app registered yet, so they stay placeholders.
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'WEB_API_KEY_PLACEHOLDER',
    appId: 'WEB_APP_ID_PLACEHOLDER',
    messagingSenderId: 'MESSAGING_SENDER_ID_PLACEHOLDER',
    projectId: 'PROJECT_ID_PLACEHOLDER',
    authDomain: 'AUTH_DOMAIN_PLACEHOLDER',
    storageBucket: 'STORAGE_BUCKET_PLACEHOLDER',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBp0Ae4dgQE3GTsHz73OxhNDV0ndIBpDLo',
    appId: '1:987289079284:android:913871be9f5be889143da1',
    messagingSenderId: '987289079284',
    projectId: 'dharm-guru-shrinkhala',
    storageBucket: 'dharm-guru-shrinkhala.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCuxtfLnWAKSS710aRkWRUzyjtR5cmi0IY',
    appId: '1:987289079284:ios:7cea32f975fc66fc143da1',
    messagingSenderId: '987289079284',
    projectId: 'dharm-guru-shrinkhala',
    storageBucket: 'dharm-guru-shrinkhala.firebasestorage.app',
    iosBundleId: 'com.codeair.dharmgurushrinkhala',
    iosClientId: '987289079284-3m55jp1guo9vmkce2k4a40flm2r6fmfn.apps.googleusercontent.com',
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
