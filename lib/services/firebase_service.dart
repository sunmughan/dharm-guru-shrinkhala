import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';

/// Firebase bootstrap. Direct Flutter to Firebase, no backend.
/// Call once from main before runApp. Only a failure of
/// Firebase.initializeApp itself throws and shows the setup
/// screen in main. Crashlytics, Remote Config and Messaging are
/// optional steps: each runs on its own and a failure there only
/// logs and continues, so a slow network on first launch no longer
/// looks like a missing Firebase configuration.
class FirebaseService {
  FirebaseService._();

  /// The stage and error text of the last failed initialise, shown
  /// on the setup screen so the phone itself names the failing
  /// call. Only set when initialise throws.
  static String? lastInitStage;
  static String? lastInitError;

  static FirebaseAnalytics get analytics => FirebaseAnalytics.instance;

  static Future<void> initialise() async {
    lastInitStage = 'initializeApp';
    lastInitError = null;
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (error, stack) {
      lastInitError =
          '$error\n${stack.toString().split('\n').take(6).join('\n')}';
      rethrow;
    }
    await _runOptional(_configureCrashlytics);
    await _runOptional(_configureRemoteConfig);
    await _runOptional(_configureMessaging);
  }

  // One optional step that must never kill the app. Remote Config
  // fetch and the Messaging token both need the network, and both
  // throw on a slow or missing connection.
  static Future<void> _runOptional(Future<void> Function() step) async {
    try {
      await step();
    } catch (error) {
      debugPrint('Firebase optional setup failed: $error');
    }
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
