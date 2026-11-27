import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Push notifications through Firebase Cloud Messaging.
/// Token is logged in debug only. Storing the token against the
/// user document is a later phase task.
/// Permission is never requested here: the system dialog must
/// not appear at app open. The main screen asks once, with a
/// reason, through FirebaseService.
class NotificationService {
  NotificationService._();

  static Future<void> initialise() async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;
    final String? token = await messaging.getToken();
    if (kDebugMode) {
      debugPrint('FCM token present: ${token != null}');
    }
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        debugPrint('FCM message received: ${message.messageId}');
      }
    });
  }
}
