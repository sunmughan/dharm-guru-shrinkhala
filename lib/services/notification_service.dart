import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'firestore_service.dart';

/// Push notifications through Firebase Cloud Messaging.
/// The token is stored on the signed in user document under
/// fcmTokens, so the backend can target that user. The user
/// document rule allows a user to write only their own
/// document, so a token can never land on another user.
/// Permission is never requested here: the system dialog must
/// not appear at app open. The main screen asks once, with a
/// reason, through FirebaseService, and then calls initialise
/// with the signed in uid.
/// Delivery itself is not done from the app: sending needs
/// the Firebase console composer or a Cloud Function, and
/// neither exists yet. See docs/phase11/notifications_status.md.
class NotificationService {
  NotificationService._();

  /// Fetches the FCM token, stores it for the signed in user
  /// when a uid is given and the user authorised notifications,
  /// and keeps it current through the token refresh stream.
  /// The token fetch alone never prompts, so the authorisation
  /// check is what decides storage: a user who tapped Not now
  /// gets no stored token. A token failure never throws: the
  /// app works without push, and the failure is only logged.
  /// onMessage only logs in debug, foreground messages do not
  /// create an inbox entry yet.
  static Future<void> initialise({
    String? uid,
    FirestoreService? firestore,
  }) async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;
    try {
      final String? token = await messaging.getToken();
      if (uid != null &&
          token != null &&
          await _authorised(messaging)) {
        await storeToken(uid: uid, token: token, firestore: firestore);
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('FCM token fetch failed: $error');
      }
    }
    FirebaseMessaging.onTokenRefresh.listen((String newToken) async {
      if (uid == null) return;
      try {
        if (!await _authorised(messaging)) return;
        await storeToken(uid: uid, token: newToken, firestore: firestore);
      } catch (error) {
        if (kDebugMode) {
          debugPrint('FCM token refresh store failed: $error');
        }
      }
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        debugPrint('FCM message received: ${message.messageId}');
      }
    });
  }

  /// True when notifications are authorised on this device.
  /// Provisional authorisation counts: the system delivers
  /// quietly and the user can turn it off.
  static Future<bool> _authorised(FirebaseMessaging messaging) async {
    final NotificationSettings settings =
        await messaging.getNotificationSettings();
    return settings.authorizationStatus ==
            AuthorizationStatus.authorized ||
        settings.authorizationStatus ==
            AuthorizationStatus.provisional;
  }

  /// Stores one token on the user document. Empty uid or
  /// empty token stores nothing.
  static Future<void> storeToken({
    required String uid,
    required String token,
    FirestoreService? firestore,
  }) async {
    if (uid.isEmpty || token.isEmpty) return;
    final FirestoreService service = firestore ?? FirestoreService();
    await service.saveUserProfile(
      uid: uid,
      data: <String, Object?>{
        'fcmTokens': FieldValue.arrayUnion(<String>[token]),
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      },
    );
  }

  /// Removes one token from the user document, for sign out.
  /// Empty uid or empty token removes nothing.
  static Future<void> removeToken({
    required String uid,
    required String token,
    FirestoreService? firestore,
  }) async {
    if (uid.isEmpty || token.isEmpty) return;
    final FirestoreService service = firestore ?? FirestoreService();
    await service.saveUserProfile(
      uid: uid,
      data: <String, Object?>{
        'fcmTokens': FieldValue.arrayRemove(<String>[token]),
      },
    );
  }
}
