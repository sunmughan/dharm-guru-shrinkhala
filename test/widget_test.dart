import 'package:dharm_guru_shrinkhala/core/build_info.dart';
import 'package:dharm_guru_shrinkhala/core/navigation/app_shell.dart';
import 'package:dharm_guru_shrinkhala/screens/admin_screens.dart';
import 'package:dharm_guru_shrinkhala/screens/auth_screen.dart';
import 'package:dharm_guru_shrinkhala/screens/profile_form_screen.dart';
import 'package:dharm_guru_shrinkhala/screens/screens.dart';
import 'package:dharm_guru_shrinkhala/services/admin_seed_service.dart';
import 'package:dharm_guru_shrinkhala/services/auth_service.dart';
import 'package:dharm_guru_shrinkhala/services/firestore_service.dart';
import 'package:dharm_guru_shrinkhala/widgets/kundli_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Fake auth that never touches Firebase. The base constructor
/// takes no real FirebaseAuth, and every member used here is
/// overridden, so FirebaseAuth.instance is never reached.
class _FakeAuthService extends AuthService {
  _FakeAuthService({
    this.signedInValue = false,
    this.userEmail,
    this.hasGoogleValue = false,
    this.hasPasswordValue = true,
    this.throwLinkNeeded = false,
    this.signUpThrowsAlreadyInUse = false,
  });

  final bool signedInValue;
  final String? userEmail;
  final bool hasGoogleValue;
  final bool hasPasswordValue;
  final bool throwLinkNeeded;
  final bool signUpThrowsAlreadyInUse;
  String? lastResetEmail;
  String? lastSignedInEmail;
  String? lastSignedUpEmail;
  bool signOutCalled = false;
  bool linkPendingCalled = false;

  @override
  Stream<bool> get signedIn => Stream.value(signedInValue);

  @override
  String? get currentUserId => signedInValue ? 'test-uid' : null;

  @override
  String? get currentUserEmail =>
      signedInValue ? (userEmail ?? 'owner@example.com') : null;

  @override
  bool get currentUserHasGoogleProvider => hasGoogleValue;

  @override
  bool get currentUserHasPasswordProvider => hasPasswordValue;

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    lastSignedInEmail = email;
  }

  @override
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (signUpThrowsAlreadyInUse) {
      throw FirebaseAuthException(code: 'email-already-in-use');
    }
    lastSignedUpEmail = email;
  }

  @override
  Future<void> signInWithGoogle() async {
    if (throwLinkNeeded) {
      throw GoogleLinkNeededException('someone@example.com');
    }
  }

  @override
  Future<void> linkPendingGoogleCredential() async {
    linkPendingCalled = true;
  }

  @override
  Future<void> signOut() async {
    signOutCalled = true;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    lastResetEmail = email;
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('App shows onboarding on first launch',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      DharmGuruApp(
        showSplash: false,
        firebaseReady: true,
        authService: _FakeAuthService(signedInValue: true),
        firestoreService: _FakeFirestore(),
        onboardingSeen: false,
        askNotifications: false,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Know your stars in one minute'), findsOneWidget);
    expect(find.text('Step one'), findsOneWidget);
    expect(
      find.text(
          'Share your birth details once and your kundli stays saved forever.'),
      findsOneWidget,
    );
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Begin My Journey'), findsOneWidget);
    expect(find.text('I Have an Account'), findsOneWidget);
    // Skip moves to the tab shell for a signed in user, never
    // past the auth gate on its own. The fake FirestoreService
    // keeps the shell off real Firebase while it is pumped.
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(find.text('Namaste, Aarav Sharma'), findsOneWidget);
  });

  testWidgets('Onboarding Skip goes to sign in when signed out',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      DharmGuruApp(
        showSplash: false,
        firebaseReady: true,
        authService: _FakeAuthService(),
        onboardingSeen: false,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Know your stars in one minute'), findsOneWidget);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Know your stars in one minute'), findsNothing);
  });

  testWidgets('Onboarding Begin moves through the three steps',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      DharmGuruApp(
        showSplash: false,
        firebaseReady: true,
        authService: _FakeAuthService(),
        onboardingSeen: false,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Step one'), findsOneWidget);
    await tester.tap(find.text('Begin My Journey'));
    await tester.pumpAndSettle();
    expect(find.text('Step two'), findsOneWidget);
    expect(
      find.text(
          'Read your horoscope and panchang every morning with one tap.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Begin My Journey'));
    await tester.pumpAndSettle();
    expect(find.text('Step three'), findsOneWidget);
    expect(
      find.text(
          'Talk to an astrologer live when you want a human answer.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Begin My Journey'));
    await tester.pumpAndSettle();
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('Onboarding seen in prefs skips to sign in',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(
        <String, Object>{'onboarding_seen': true});
    await tester.pumpWidget(
      DharmGuruApp(
        showSplash: false,
        firebaseReady: true,
        authService: _FakeAuthService(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Know your stars in one minute'), findsNothing);
  });

  testWidgets('Signed out app shows only the sign in screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      DharmGuruApp(
        showSplash: false,
        firebaseReady: true,
        authService: _FakeAuthService(),
        onboardingSeen: true,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Know your stars in one minute'), findsNothing);
    expect(find.text('Home'), findsNothing);
    expect(find.text('Kundli'), findsNothing);
  });

  testWidgets('Splash shows the build stamp and developer credit',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: SplashScreen(onDone: () {})),
    );
    await tester.pump();
    expect(find.text(kBuildStamp), findsOneWidget);
    expect(
      find.text('Developed by Codeair Software Solutions'),
      findsOneWidget,
    );
    expect(find.text('Dharm Guru'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('Admin splash shows and advances to sign in',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      DharmGuruAdminApp(
        firebaseReady: true,
        authService: _FakeAuthService(),
      ),
    );
    await tester.pump();
    expect(find.text('Dharm Guru'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);
    expect(
      find.text('Developed by Codeair Software Solutions'),
      findsOneWidget,
    );
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Sign in'), findsOneWidget);
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

  testWidgets('Setup screen shows the init error when given',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const DharmGuruApp(
        showSplash: false,
        firebaseReady: false,
        firebaseError: 'PlatformException(core, no app, null, null)',
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Firebase is not configured yet.'), findsOneWidget);
    expect(find.text('Start error:'), findsOneWidget);
    expect(
      find.text('PlatformException(core, no app, null, null)'),
      findsOneWidget,
    );
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

  testWidgets('Admin setup screen shows the init error when given',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const DharmGuruAdminApp(
        firebaseReady: false,
        firebaseError: 'PlatformException(core, no app, null, null)',
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Firebase is not configured yet.'), findsOneWidget);
    expect(find.text('Start error:'), findsOneWidget);
    expect(
      find.text('PlatformException(core, no app, null, null)'),
      findsOneWidget,
    );
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
        showSplash: false,
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
        showSplash: false,
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

  testWidgets('Create account screen shows Continue with Google',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: AuthScreen()),
    );
    await tester.pumpAndSettle();
    expect(find.text('Continue with Google'), findsOneWidget);
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    expect(find.text('Continue with Google'), findsOneWidget);
  });

  testWidgets('Google sign in with an existing email asks for the password',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AuthScreen(
          authService: _FakeAuthService(throwLinkNeeded: true),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'An account already exists for this email. Sign in with your password once to link Google to it.',
      ),
      findsOneWidget,
    );
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller?.text,
      'someone@example.com',
    );
  });

  testWidgets('Home shows the saved profile name and birth line',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          onOpenTab: (_) {},
          firestore: _FakeFirestore(),
          authService: _FakeAuthService(signedInValue: true),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Namaste, Aarav Sharma'), findsOneWidget);
    expect(
      find.text('Birth 14 March 1998, 06:25 AM, Jaipur, Rajasthan, India.'),
      findsOneWidget,
    );
  });

  testWidgets('Home with no profile asks to complete it',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(onOpenTab: (_) {}),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Namaste'), findsOneWidget);
    expect(find.text('Complete your profile'), findsOneWidget);
  });

  testWidgets('Profile screen shows the saved details and Edit profile',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ProfileScreen(
          firestore: _FakeFirestore(),
          authService: _FakeAuthService(signedInValue: true),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Aarav Sharma'), findsOneWidget);
    expect(find.text('Edit profile'), findsOneWidget);
    expect(find.text('Date of birth'), findsOneWidget);
    expect(find.text('14 March 1998'), findsOneWidget);
    expect(find.text('Jaipur, Rajasthan, India'), findsOneWidget);
    expect(find.text('Daily horoscope alert at 06:00 AM.'), findsOneWidget);
  });

  testWidgets('Profile form saves the entered details',
      (WidgetTester tester) async {
    // The form is taller than the default test viewport, so
    // make the surface tall enough that every field and the
    // Save button are built at once, with no scrolling.
    tester.view.physicalSize = const Size(800, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final _FakeFirestore firestore = _FakeFirestore();
    await tester.pumpWidget(
      MaterialApp(
        home: ProfileFormScreen(
          authService: _FakeAuthService(signedInValue: true),
          firestoreService: firestore,
        ),
      ),
    );
    await tester.pumpAndSettle();
    // No name yet: the form refuses to save.
    await tester.tap(find.text('Save profile'));
    await tester.pumpAndSettle();
    expect(find.text('Enter your full name.'), findsOneWidget);
    expect(firestore.lastSavedProfile, isNull);
    // Fill the required fields: name, date of birth, birth city.
    // TextField order in the form: name, occupation, date of
    // birth, time of birth, city, state, country, phone, alert
    // time. So the date field is at index 2, the city at 4.
    await tester.enterText(find.byType(TextField).at(0), 'Test User');
    await tester.tap(find.byType(TextField).at(2));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(4), 'Jaipur');
    await tester.tap(find.text('Save profile'));
    await tester.pumpAndSettle();
    expect(firestore.lastSavedProfile, isNotNull);
    expect(firestore.lastSavedProfile!['name'], 'Test User');
    expect(firestore.lastSavedProfile!['birthCity'], 'Jaipur');
    expect(firestore.lastSavedProfile!['dateOfBirth'], isNotNull);
    expect(find.text('Profile saved.'), findsOneWidget);
  });

  testWidgets('Admin account screen shows change email and change password',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: AdminAccountScreen(
              firestore: _FakeFirestore(),
              auth: _FakeAuthService(
                signedInValue: true,
                hasGoogleValue: false,
                hasPasswordValue: true,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Account'), findsOneWidget);
    expect(
      find.text('Signed in as owner@example.com. Role: owner.'),
      findsOneWidget,
    );
    expect(find.text('Link Google account'), findsOneWidget);
    expect(find.text('Change email'), findsOneWidget);
    // 'Change password' is both the section title and the
    // button that submits the change.
    expect(find.text('Change password'), findsNWidgets(2));
    expect(
      find.widgetWithText(ElevatedButton, 'Change password'),
      findsOneWidget,
    );
    expect(find.text('Current password'), findsWidgets);
  });

  testWidgets('Admin gate allows the default admin email without a document',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      DharmGuruAdminApp(
        showSplash: false,
        authService: _FakeAuthService(
          signedInValue: true,
          userEmail: 'admin@gmail.com',
        ),
        firestoreService: _FakeFirestore(admin: false),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Users'), findsOneWidget);
  });

  testWidgets('Admin gate allows a Google account that signs in to the admin app',
      (WidgetTester tester) async {
    final _FakeFirestore firestore = _FakeFirestore(admin: false);
    await tester.pumpWidget(
      DharmGuruAdminApp(
        showSplash: false,
        authService: _FakeAuthService(
          signedInValue: true,
          hasGoogleValue: true,
        ),
        firestoreService: firestore,
      ),
    );
    await tester.pumpAndSettle();
    expect(firestore.lastEnsuredAdminUid, 'test-uid');
    expect(find.text('Users'), findsOneWidget);
  });

  test('Admin seed creates the default admin once', () async {
    final _FakeAuthService auth = _FakeAuthService(signedInValue: true);
    final _FakeFirestore firestore = _FakeFirestore();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('admin_seed_attempted_v1');
    await AdminSeedService.ensureDefaultAdmin(
      auth: auth,
      firestore: firestore,
      prefs: prefs,
    );
    expect(auth.lastSignedUpEmail, 'admin@gmail.com');
    expect(firestore.lastEnsuredAdminUid, 'test-uid');
    expect(auth.signOutCalled, isTrue);
    expect(prefs.getBool('admin_seed_attempted_v1'), isTrue);
    // A second run does nothing: the flag is set.
    auth.lastSignedUpEmail = null;
    firestore.lastEnsuredAdminUid = null;
    await AdminSeedService.ensureDefaultAdmin(
      auth: auth,
      firestore: firestore,
      prefs: prefs,
    );
    expect(auth.lastSignedUpEmail, isNull);
    expect(firestore.lastEnsuredAdminUid, isNull);
  });

  test('Admin seed does nothing new when the account already exists',
      () async {
    final _FakeAuthService auth = _FakeAuthService(
      signedInValue: true,
      signUpThrowsAlreadyInUse: true,
    );
    final _FakeFirestore firestore = _FakeFirestore();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('admin_seed_attempted_v1');
    await AdminSeedService.ensureDefaultAdmin(
      auth: auth,
      firestore: firestore,
      prefs: prefs,
    );
    expect(firestore.lastEnsuredAdminUid, isNull);
    expect(auth.signOutCalled, isFalse);
    expect(prefs.getBool('admin_seed_attempted_v1'), isTrue);
  });

  test('plainError explains the Google link case', () {
    expect(
      AuthService.plainError(GoogleLinkNeededException('x@y.com')),
      contains('link Google'),
    );
    expect(
      AuthService.plainError(
        FirebaseAuthException(
          code: 'account-exists-with-different-credential',
        ),
      ),
      contains('link Google'),
    );
    expect(
      AuthService.plainError(
        FirebaseAuthException(code: 'requires-recent-login'),
      ),
      contains('sign out and sign in again'),
    );
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
  Map<String, Object?>? lastSavedProfile;
  String? lastEnsuredAdminUid;

  /// Set by ensureAdminDoc, so the fake gate can allow a Google
  /// account that just got its owner record, like the real gate.
  bool adminGranted = false;

  @override
  Future<bool> isAdmin(String uid) async => admin || adminGranted;

  @override
  Future<Map<String, dynamic>?> getUserProfile(String uid) async =>
      <String, dynamic>{
        'name': 'Aarav Sharma',
        'dateOfBirth': '1998-03-14',
        'timeOfBirth': '06:25',
        'birthCity': 'Jaipur',
        'birthState': 'Rajasthan',
        'birthCountry': 'India',
      };

  @override
  Future<void> saveUserProfile({
    required String uid,
    required Map<String, Object?> data,
  }) async {
    lastSavedProfile = data;
  }

  @override
  Future<void> ensureAdminDoc(String uid, String email) async {
    lastEnsuredAdminUid = uid;
    adminGranted = true;
  }

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
