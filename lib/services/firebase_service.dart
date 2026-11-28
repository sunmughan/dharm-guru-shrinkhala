import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../firebase_options.dart';

/// SharedPreferences key that remembers the notification prompt
/// was shown once, so the main screen never asks twice.
const String kNotificationPromptKey = 'notification_prompt_shown';

/// Firebase bootstrap. Direct Flutter to Firebase, no backend.
/// Call once from main before runApp. Only a failure of
/// Firebase.initializeApp itself throws and shows the setup
/// screen in main. Remote Config and Messaging are
/// optional steps: each runs on its own and a failure there only
/// logs and continues, so a slow network on first launch no longer
/// looks like a missing Firebase configuration.
///
/// Notification permission is NEVER asked here. The system
/// dialog used to fire during initialise, before the splash
/// screen even loaded. It now fires only once, from the main
/// screen, after onboarding and sign in, through
/// requestNotificationPermissionOnce.
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
    unawaited(_runOptional(_configureRemoteConfig));
    unawaited(_runOptional(_configureMessaging));
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

  static Future<void> _configureRemoteConfig() async {
    final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );
    await remoteConfig.setDefaults(<String, Object>{
      'live_consult_enabled': false,
    });
    await remoteConfig.fetchAndActivate();
  }

  static Future<void> _configureMessaging() async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;
    // No requestPermission here on purpose: the dialog must not
    // appear at app open. The token fetch alone never prompts.
    await messaging.getToken();
  }

  /// The raw system notification permission dialog. Call it only
  /// from a screen the user is already looking at, with a reason
  /// shown first, never at startup.
  static Future<NotificationSettings> requestNotificationPermission() {
    return FirebaseMessaging.instance.requestPermission();
  }

  /// True when the one time main screen prompt was already shown.
  static Future<bool> notificationPromptShown() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(kNotificationPromptKey) == true;
  }

  /// Marks the one time main screen prompt as shown without
  /// asking, used when the user taps Not now.
  static Future<void> markNotificationPromptShown() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kNotificationPromptKey, true);
  }

  /// Asks for notification permission once per install. Returns
  /// false when it was already asked before. The caller shows
  /// the reason first and only calls this when the user agrees.
  static Future<bool> requestNotificationPermissionOnce() async {
    if (await notificationPromptShown()) {
      return false;
    }
    await requestNotificationPermission();
    await markNotificationPromptShown();
    return true;
  }
}
