import 'dart:async';

import 'package:dharm_guru_shrinkhala/screens/admin_screens.dart';
import 'package:dharm_guru_shrinkhala/services/auth_service.dart';
import 'package:dharm_guru_shrinkhala/services/firestore_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' as mui;

/// A signed in Google account. The gate must create its admin
/// record and let it in, or show an honest error, never a
/// spinner that never ends.
class _GoogleAuth extends AuthService {
  @override
  Stream<bool> get signedIn => Stream<bool>.value(true);

  @override
  String? get currentUserId => 'google-uid';

  @override
  String? get currentUserEmail => 'owner@gmail.com';

  @override
  bool get currentUserHasGoogleProvider => true;

  @override
  bool get currentUserHasPasswordProvider => false;
}

/// Firestore that fails the owner record write, like a rules
/// denial or a dropped connection on the phone.
class _WriteFailsFirestore extends FirestoreService {
  @override
  Future<void> ensureAdminDoc(String uid, String email) async {
    throw StateError('PERMISSION_DENIED');
  }

  @override
  Future<bool> isAdminUser({required String uid, String? email}) async =>
      false;
}

/// Firestore that writes the record fine but fails the access
/// read.
class _ReadFailsFirestore extends FirestoreService {
  @override
  Future<void> ensureAdminDoc(String uid, String email) async {}

  @override
  Future<bool> isAdminUser({required String uid, String? email}) async {
    throw StateError('UNAVAILABLE');
  }
}

/// Firestore that never answers, like a stalled read on a bad
/// connection. The gate must time out, not spin forever.
class _HangingFirestore extends FirestoreService {
  @override
  Future<void> ensureAdminDoc(String uid, String email) =>
      Completer<void>().future;

  @override
  Future<bool> isAdminUser({required String uid, String? email}) =>
      Completer<bool>().future;
}

/// Firestore that fails the first write, then works. Proves
/// the Try again button runs the check again.
class _FailOnceFirestore extends FirestoreService {
  bool _failed = false;
  bool adminGranted = false;

  @override
  Future<void> ensureAdminDoc(String uid, String email) async {
    if (!_failed) {
      _failed = true;
      throw StateError('UNAVAILABLE');
    }
    adminGranted = true;
  }

  @override
  Future<bool> isAdmin(String uid) async => adminGranted;

  @override
  Future<bool> isAdminUser({required String uid, String? email}) async =>
      adminGranted;

  @override
  Stream<List<Map<String, dynamic>>> watchDocs(String collection) =>
      Stream<List<Map<String, dynamic>>>.value(
        <Map<String, dynamic>>[],
      );
}

void main() {
  group('Admin gate after Google sign in', () {
    testWidgets('shows an error, not a spinner, when the admin record write fails',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        DharmGuruAdminApp(
          showSplash: false,
          authService: _GoogleAuth(),
          firestoreService: _WriteFailsFirestore(),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Could not open the admin panel.'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Could not create your admin record'),
        findsOneWidget,
      );
      expect(find.byType(mui.CircularProgressIndicator), findsNothing);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('shows an error when the access check fails',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        DharmGuruAdminApp(
          showSplash: false,
          authService: _GoogleAuth(),
          firestoreService: _ReadFailsFirestore(),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Could not open the admin panel.'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Could not check your admin access'),
        findsOneWidget,
      );
      expect(find.byType(mui.CircularProgressIndicator), findsNothing);
    });

    testWidgets('times out instead of spinning forever on a stalled read',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        DharmGuruAdminApp(
          showSplash: false,
          authService: _GoogleAuth(),
          firestoreService: _HangingFirestore(),
        ),
      );
      await tester.pump();
      expect(find.byType(mui.CircularProgressIndicator), findsOneWidget);
      await tester.pump(const Duration(seconds: 21));
      await tester.pump();
      expect(
        find.text('Could not open the admin panel.'),
        findsOneWidget,
      );
      expect(find.textContaining('timed out'), findsOneWidget);
      expect(find.byType(mui.CircularProgressIndicator), findsNothing);
    });

    testWidgets('Try again runs the check again and lets the owner in',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        DharmGuruAdminApp(
          showSplash: false,
          authService: _GoogleAuth(),
          firestoreService: _FailOnceFirestore(),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Could not open the admin panel.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.text('Users'), findsOneWidget);
      expect(find.text('Astrologers'), findsOneWidget);
    });
  });
}
