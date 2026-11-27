import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/admin_config.dart';
import 'auth_service.dart';
import 'firestore_service.dart';

/// Seeds the default admin account on first launch of the admin
/// app. Creates admin@gmail.com with its default password through
/// Firebase Auth when it does not exist yet, writes the owner
/// record for it, then signs out again so the sign in screen
/// still shows. The seed runs once per install and never blocks
/// the app: any failure only logs and the app starts normally.
/// Sign in itself always checks the password against Firebase,
/// so this is not a bypass. Change the default password from
/// the admin Account screen after the first sign in.
class AdminSeedService {
  AdminSeedService._();

  static const String _seededKey = 'admin_seed_attempted_v1';

  static Future<void> ensureDefaultAdmin({
    AuthService? auth,
    FirestoreService? firestore,
    SharedPreferences? prefs,
  }) async {
    final SharedPreferences store =
        prefs ?? await SharedPreferences.getInstance();
    if (store.getBool(_seededKey) == true) {
      return;
    }
    final AuthService authService = auth ?? AuthService();
    final FirestoreService firestoreService =
        firestore ?? FirestoreService();
    bool created = false;
    try {
      await authService.signUpWithEmailAndPassword(
        email: kDefaultAdminEmail,
        password: kDefaultAdminPassword,
      );
      created = true;
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        // The account already exists. Nothing to create.
        await store.setBool(_seededKey, true);
        return;
      }
      // Network or console failure: do not mark seeded, so the
      // next launch tries again.
      debugPrint('Admin seed failed: $error');
      return;
    } catch (error) {
      debugPrint('Admin seed failed: $error');
      return;
    }
    if (created) {
      try {
        final String? uid = authService.currentUserId;
        if (uid != null) {
          await firestoreService.ensureAdminDoc(uid, kDefaultAdminEmail);
        }
      } catch (error) {
        // The admin gate also accepts the seeded email itself,
        // so a failed document write does not lock the owner out.
        debugPrint('Admin seed document failed: $error');
      }
      await authService.signOut();
    }
    await store.setBool(_seededKey, true);
  }
}
