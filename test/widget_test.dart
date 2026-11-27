import 'package:dharm_guru_shrinkhala/core/build_info.dart';
import 'package:dharm_guru_shrinkhala/core/navigation/app_shell.dart';
import 'package:dharm_guru_shrinkhala/screens/admin_screens.dart';
import 'package:dharm_guru_shrinkhala/screens/auth_screen.dart';
import 'package:dharm_guru_shrinkhala/screens/screens.dart';
import 'package:dharm_guru_shrinkhala/services/auth_service.dart';
import 'package:dharm_guru_shrinkhala/services/firestore_service.dart';
import 'package:dharm_guru_shrinkhala/widgets/kundli_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fake auth that never touches Firebase. The base constructor
/// takes no real FirebaseAuth, and every member used here is
/// overridden, so FirebaseAuth.instance is never reached.
class _FakeAuthService extends AuthService {
  _FakeAuthService({this.signedInValue = false});

  final bool signedInValue;
  String? lastResetEmail;
  String? lastSignedInEmail;

  @override
  Stream<bool> get signedIn => Stream.value(signedInValue);

  @override
  String? get currentUserId => signedInValue ? 'test-uid' : null;

  @override
  String? get currentUserEmail =>
      signedInValue ? 'owner@example.com' : null;

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    lastSignedInEmail = email;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    lastResetEmail = email;
  }
}

void main() {
  testWidgets('App shows onboarding when splash is skipped',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      DharmGuruApp(
        showSplash: false,
        firebaseReady: true,
        authService: _FakeAuthService(signedInValue: true),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Enter birth details'), findsOneWidget);
    expect(find.text('Welcome'), findsOneWidget);
  });

  testWidgets('Signed out app shows only the sign in screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      DharmGuruApp(
        showSplash: false,
        firebaseReady: true,
        authService: _FakeAuthService(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Welcome'), findsNothing);
    expect(find.text('Enter birth details'), findsNothing);
    expect(find.text('Home'), findsNothing);
    expect(find.text('Kundli'), findsNothing);
  });

  testWidgets('Splash shows the build stamp',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      DharmGuruApp(
        showSplash: true,
        firebaseReady: true,
        authService: _FakeAuthService(),
      ),
    );
    await tester.pump();
    expect(find.text(kBuildStamp), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('Setup screen shows the build stamp',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const DharmGuruApp(
        showSplash: false,
        firebaseReady: false,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Firebase is not configured yet.'), findsOneWidget);
    expect(find.text(kBuildStamp), findsOneWidget);
  });

  testWidgets('Admin setup screen shows the build stamp',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const DharmGuruAdminApp(firebaseReady: false),
    );
    await tester.pumpAndSettle();
    expect(find.text('Firebase is not configured yet.'), findsOneWidget);
    expect(find.text(kBuildStamp), findsOneWidget);
  });

  testWidgets('Sign in rejects a bad email before calling auth',
      (WidgetTester tester) async {
    final _FakeAuthService fake = _FakeAuthService();
    await tester.pumpWidget(
      MaterialApp(home: AuthScreen(authService: fake)),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField).at(0),
      'not-an-email',
    );
    await tester.enterText(find.byType(TextField).at(1), '123456');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();
    expect(
      find.text('Enter a valid email address, like name@example.com.'),
      findsOneWidget,
    );
    expect(fake.lastSignedInEmail, isNull);
  });

  testWidgets('Sign in rejects a short password before calling auth',
      (WidgetTester tester) async {
    final _FakeAuthService fake = _FakeAuthService();
    await tester.pumpWidget(
      MaterialApp(home: AuthScreen(authService: fake)),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField).at(0),
      'a@b.com',
    );
    await tester.enterText(find.byType(TextField).at(1), '123');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();
    expect(
      find.text('Password must be at least 6 characters.'),
      findsOneWidget,
    );
    expect(fake.lastSignedInEmail, isNull);
  });

  testWidgets('Forgot password sends the reset email and confirms',
      (WidgetTester tester) async {
    final _FakeAuthService fake = _FakeAuthService();
    await tester.pumpWidget(
      MaterialApp(home: AuthScreen(authService: fake)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'a@b.com');
    await tester.tap(find.text('Send reset link'));
    await tester.pumpAndSettle();
    expect(fake.lastResetEmail, 'a@b.com');
    expect(
      find.text(
        'Reset link sent to a@b.com. Open your email, tap the link, and set a new password. Then sign in with the new password.',
      ),
      findsOneWidget,
    );
  });

  test('Email validation accepts a plain address and rejects junk', () {
    expect(validateEmail('a@b.com'), isNull);
    expect(validateEmail('name@example.com'), isNull);
    expect(validateEmail('no-at-sign'), isNotNull);
    expect(validateEmail('a@b'), isNotNull);
    expect(validateEmail(''), isNotNull);
  });

  test('Password validation needs at least 6 characters', () {
    expect(validatePassword('12345'), isNotNull);
    expect(validatePassword('123456'), isNull);
  });

  test('Auth errors map to plain words, never raw codes', () {
    expect(
      AuthService.plainError(
        FirebaseAuthException(code: 'invalid-credential'),
      ),
      'The email or password is wrong. Try again or reset your password.',
    );
    expect(
      AuthService.plainError(
        FirebaseAuthException(code: 'email-already-in-use'),
      ),
      'An account already exists for that email. Sign in instead.',
    );
    expect(
      AuthService.plainError(
        FirebaseAuthException(code: 'operation-not-allowed'),
      ),
      'Email sign in is not switched on yet. Ask the app team to enable it.',
    );
  });

  testWidgets('Chart shows lagna rashi and all nine planets',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: KundliChart()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Meena'), findsOneWidget);
    expect(find.text('Lagna'), findsOneWidget);
    expect(find.text('As'), findsOneWidget);
    expect(find.text('Su'), findsOneWidget);
    expect(find.text('Mo'), findsOneWidget);
    expect(find.text('Ma'), findsOneWidget);
    expect(find.text('Me'), findsOneWidget);
    expect(find.text('Ju'), findsOneWidget);
    expect(find.text('Ve'), findsOneWidget);
    expect(find.text('Ra'), findsOneWidget);
    expect(find.text('Ke'), findsOneWidget);
    expect(find.text('+1'), findsOneWidget);
  });

  testWidgets('Panchang shows the exact spec values on Saturday',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: PanchangScreen()),
    );
    await tester.pumpAndSettle();
    expect(find.text('Saturday, Jaipur'), findsOneWidget);
    expect(find.text('Shukla Panchami'), findsOneWidget);
    expect(find.text('Shanivaar'), findsOneWidget);
    expect(find.text('Rohini till 04:12 PM'), findsOneWidget);
    expect(find.text('Siddhi'), findsOneWidget);
    expect(find.text('Bava'), findsOneWidget);
    expect(find.text('06:48 AM'), findsOneWidget);
    expect(find.text('05:52 PM'), findsOneWidget);
    // The muhurat card sits below the fold, so the ListView only
    // builds it once scrolled into view.
    await tester.drag(find.byType(ListView), const Offset(0, -800));
    await tester.pumpAndSettle();
    expect(find.text('09:42 AM to 11:15 AM'), findsOneWidget);
    expect(find.text('04:30 PM to 06:05 PM'), findsOneWidget);
    expect(find.text('Rahu Kaal'), findsOneWidget);
  });

  testWidgets('Kundli form with other birth details shows not ready',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: KundliInputScreen()),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField).at(1),
      '1 January 2000',
    );
    await tester.tap(find.text('Show Kundli'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Kundli calculation for these birth details is not ready yet. No chart is shown for them.',
      ),
      findsOneWidget,
    );
    expect(find.text('View sample kundli'), findsOneWidget);
  });

  testWidgets('Kundli form with sample details shows the sample chart',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: KundliInputScreen()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show Kundli'));
    await tester.pumpAndSettle();
    expect(find.text('Meena'), findsOneWidget);
    expect(find.text('Lagna'), findsOneWidget);
  });

  testWidgets('Matching New match clears the second person',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: MatchingScreen()),
    );
    await tester.pumpAndSettle();
    expect(find.text('28 / 36'), findsOneWidget);
    await tester.tap(find.text('New match'));
    await tester.pumpAndSettle();
    expect(find.text('Add second kundli'), findsOneWidget);
    expect(find.text('28 / 36'), findsNothing);
  });

  testWidgets('Remedies Mark as done flips to Done today',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: RemediesScreen()),
    );
    await tester.pumpAndSettle();
    expect(find.text('For weak Sun'), findsOneWidget);
    await tester.tap(find.text('Mark as done').first);
    await tester.pumpAndSettle();
    expect(find.text('Done today'), findsOneWidget);
  });

  testWidgets('Consult Chat tile says it is not ready yet',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: ConsultScreen()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chat'));
    await tester.pump();
    expect(find.text('Live chat is not ready yet.'), findsOneWidget);
  });

  testWidgets('Admin gate denies a signed in non owner',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      DharmGuruAdminApp(
        authService: _FakeAuthService(signedInValue: true),
        firestoreService: _FakeFirestore(admin: false),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('You do not have admin access.'),
      findsOneWidget,
    );
    expect(find.text('Users'), findsNothing);
  });

  testWidgets('Admin gate allows the owner to the dashboard',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      DharmGuruAdminApp(
        authService: _FakeAuthService(signedInValue: true),
        firestoreService: _FakeFirestore(admin: true),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Users'), findsOneWidget);
    expect(find.text('Astrologers'), findsOneWidget);
  });

  testWidgets('Admin astrologers list shows approved and waiting',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AstrologersScreen(
            firestore: _FakeFirestore(
              docs: <String, List<Map<String, dynamic>>>{
                'astrologers': <Map<String, dynamic>>[
                  <String, dynamic>{
                    'id': 'a1',
                    'name': 'Guru Dev',
                    'languages': 'Hindi, English',
                    'bio': 'Vedic astrologer.',
                    'rate': 'Rs 99/min',
                    'status': 'approved',
                    'chatAvailable': true,
                    'callAvailable': true,
                  },
                  <String, dynamic>{
                    'id': 'a2',
                    'name': 'New Guru',
                    'languages': 'Hindi',
                    'bio': 'New here.',
                    'rate': '',
                    'status': 'waiting',
                    'chatAvailable': true,
                    'callAvailable': false,
                  },
                ],
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Guru Dev'), findsOneWidget);
    expect(find.text('New Guru'), findsOneWidget);
    // Approve lives in the detail dialog, not in the list row.
    await tester.tap(find.text('View').last);
    await tester.pumpAndSettle();
    expect(find.text('Approve'), findsOneWidget);
    expect(find.text('New Guru'), findsWidgets);
  });

  testWidgets('Admin daily content shows empty states with no docs',
      (WidgetTester tester) async {
    // The shell shows every admin screen inside a scroll view,
    // so the test pumps it the same way.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: DailyContentScreen(firestore: _FakeFirestore()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    // Horoscope tab: one card per rashi, each with no content.
    expect(find.text('No content yet.'), findsNWidgets(12));
    expect(find.text('Mesha'), findsOneWidget);
    // Panchang tab: the form opens with empty fields.
    await tester.tap(find.text('Panchang'));
    await tester.pumpAndSettle();
    expect(find.text('Tithi'), findsOneWidget);
    expect(find.text('City'), findsOneWidget);
  });

  testWidgets('User horoscope shows the published admin content',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HoroscopeScreen(
          firestore: _FakeFirestore(
            docs: <String, List<Map<String, dynamic>>>{
              'horoscopes': <Map<String, dynamic>>[
                <String, dynamic>{
                  'id': 'h1',
                  'rashi': 'Kanya',
                  'date': '2026-11-27',
                  'summary': 'A strong day for money talks.',
                  'career': 'Good progress.',
                  'money': 'Steady.',
                  'health': 'Take rest.',
                  'love': 'Warm.',
                  'luckyNumber': '5',
                  'luckyColour': 'Green',
                  'status': 'published',
                },
              ],
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Rashi: Kanya'), findsOneWidget);
    expect(find.text('A strong day for money talks.'), findsOneWidget);
    expect(
      find.text(
        'No horoscope prediction is shown in Phase 1. Content is published from the admin panel in a later phase.',
      ),
      findsNothing,
    );
  });

  testWidgets('User consult lists only approved astrologers',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ConsultScreen(
          firestore: _FakeFirestore(
            docs: <String, List<Map<String, dynamic>>>{
              'astrologers': <Map<String, dynamic>>[
                <String, dynamic>{
                  'id': 'a1',
                  'name': 'Guru Dev',
                  'languages': 'Hindi, English',
                  'rate': 'Rs 99/min',
                  'status': 'approved',
                  'chatAvailable': true,
                  'callAvailable': true,
                },
                <String, dynamic>{
                  'id': 'a2',
                  'name': 'New Guru',
                  'languages': 'Hindi',
                  'rate': '',
                  'status': 'waiting',
                  'chatAvailable': true,
                  'callAvailable': false,
                },
              ],
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Guru Dev'), findsOneWidget);
    expect(find.text('New Guru'), findsNothing);
  });
}

/// Fake Firestore that never touches Firebase. Every method the
/// screens use is overridden, so no real Firestore object is
/// needed.
class _FakeFirestore extends FirestoreService {
  _FakeFirestore({
    this.admin = false,
    this.docs = const <String, List<Map<String, dynamic>>>{},
  });

  final bool admin;
  final Map<String, List<Map<String, dynamic>>> docs;

  @override
  Future<bool> isAdmin(String uid) async => admin;

  @override
  Stream<List<Map<String, dynamic>>> watchDocs(String collection) =>
      Stream<List<Map<String, dynamic>>>.value(
        docs[collection] ?? <Map<String, dynamic>>[],
      );

  @override
  Future<void> saveDoc(
    String collection,
    String id,
    Map<String, Object?> data, {
    bool isNew = false,
  }) async {}

  @override
  Future<void> deleteDoc(String collection, String id) async {}
}
