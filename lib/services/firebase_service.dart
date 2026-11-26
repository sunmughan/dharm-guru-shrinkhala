import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';

/// Firebase bootstrap. Direct Flutter to Firebase, no backend.
/// Call once from main before runApp. If Firebase is not yet
/// configured, initialise throws and main shows the setup message.
class FirebaseService {
  FirebaseService._();

  static FirebaseAnalytics get analytics => FirebaseAnalytics.instance;

  static Future<void> initialise() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await _configureCrashlytics();
    await _configureRemoteConfig();
    await _configureMessaging();
  }

  static Future<void> _configureCrashlytics() async {
    FlutterError.onError =
        FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  static Future<void> _configureRemoteConfig() async {
    final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );
    await remoteConfig.setDefaults(<String, Object>{
      'premium_enabled': false,
      'live_consult_enabled': false,
    });
    await remoteConfig.fetchAndActivate();
  }

  static Future<void> _configureMessaging() async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();
    await messaging.getToken();
  }
}
