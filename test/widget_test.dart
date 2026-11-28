import 'dart:async';

import 'package:dharm_guru_shrinkhala/core/build_info.dart';
import 'package:dharm_guru_shrinkhala/core/navigation/app_shell.dart';
import 'package:dharm_guru_shrinkhala/models/kundli.dart';
import 'package:dharm_guru_shrinkhala/models/panchang.dart';
import 'package:dharm_guru_shrinkhala/screens/admin_screens.dart';
import 'package:dharm_guru_shrinkhala/screens/auth_screen.dart';
import 'package:dharm_guru_shrinkhala/screens/profile_form_screen.dart';
import 'package:dharm_guru_shrinkhala/screens/screens.dart';
import 'package:dharm_guru_shrinkhala/services/admin_seed_service.dart';
import 'package:dharm_guru_shrinkhala/services/astro.dart';
import 'package:dharm_guru_shrinkhala/services/auth_service.dart';
import 'package:dharm_guru_shrinkhala/services/chat_service.dart';
import 'package:dharm_guru_shrinkhala/services/firestore_service.dart';
import 'package:dharm_guru_shrinkhala/services/matching.dart';
import 'package:dharm_guru_shrinkhala/services/remedies_engine.dart';
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

/// Tap a birth picker field and accept its default with OK,
/// the way a user picks without choosing: the date picker
/// opens on 25 years ago today, the time picker on noon.
Future<void> _acceptPicker(
  WidgetTester tester,
  Finder field,
) async {
  await tester.tap(field);
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

/// Picked birth moment from a form date field and time
/// field, read back from the fields themselves, so the test
/// never assumes what the picker defaults to.
DateTime _pickedBirth(
  WidgetTester tester,
  int dateIndex,
  int timeIndex,
) {
  final String dateText =
      tester.widget<TextField>(find.byType(TextField).at(dateIndex))
          .controller!.text;
  final String timeText =
      tester.widget<TextField>(find.byType(TextField).at(timeIndex))
          .controller!.text;
  return parseBirthDateTime(dateText, timeText)!;
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
    expect(find.text('Namaste, Test User'), findsOneWidget);
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

  testWidgets('Chart shows the given kundli and all nine planets',
      (WidgetTester tester) async {
    const List<PlanetDetail> planets = <PlanetDetail>[
      PlanetDetail(
        name: 'Sun',
        rashi: 'Mesha',
        bhava: 'Bhava 1',
        degree: '01° 00′',
        swami: 'Mars',
        note: 'Sun in Mesha, Bhava 1.',
        longitude: 1.0,
      ),
      PlanetDetail(
        name: 'Moon',
        rashi: 'Vrishabha',
        bhava: 'Bhava 2',
        degree: '02° 00′',
        swami: 'Venus',
        note: 'Moon in Vrishabha, Bhava 2.',
        longitude: 32.0,
      ),
      PlanetDetail(
        name: 'Mars',
        rashi: 'Mithuna',
        bhava: 'Bhava 3',
        degree: '03° 00′',
        swami: 'Mercury',
        note: 'Mars in Mithuna, Bhava 3.',
        longitude: 63.0,
      ),
      PlanetDetail(
        name: 'Mercury',
        rashi: 'Karka',
        bhava: 'Bhava 4',
        degree: '04° 00′',
        swami: 'Moon',
        note: 'Mercury in Karka, Bhava 4.',
        longitude: 94.0,
      ),
      PlanetDetail(
        name: 'Jupiter',
        rashi: 'Simha',
        bhava: 'Bhava 5',
        degree: '05° 00′',
        swami: 'Sun',
        note: 'Jupiter in Simha, Bhava 5.',
        longitude: 125.0,
      ),
      PlanetDetail(
        name: 'Venus',
        rashi: 'Kanya',
        bhava: 'Bhava 6',
        degree: '06° 00′',
        swami: 'Mercury',
        note: 'Venus in Kanya, Bhava 6.',
        longitude: 156.0,
      ),
      PlanetDetail(
        name: 'Saturn',
        rashi: 'Tula',
        bhava: 'Bhava 7',
        degree: '07° 00′',
        swami: 'Venus',
        note: 'Saturn in Tula, Bhava 7.',
        longitude: 187.0,
      ),
      PlanetDetail(
        name: 'Rahu',
        rashi: 'Vrishchika',
        bhava: 'Bhava 8',
        degree: '08° 00′',
        swami: 'Mars',
        note: 'Rahu in Vrishchika, Bhava 8.',
        longitude: 218.0,
      ),
      PlanetDetail(
        name: 'Ketu',
        rashi: 'Dhanu',
        bhava: 'Bhava 9',
        degree: '09° 00′',
        swami: 'Jupiter',
        note: 'Ketu in Dhanu, Bhava 9.',
        longitude: 249.0,
      ),
    ];
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: KundliChart(
            birth: BirthDetails(
              name: 'Test User',
              dateOfBirth: '1 January 2000',
              timeOfBirth: '06:25 AM',
              placeOfBirth: 'Jaipur',
              rashi: 'Vrishabha',
              nakshatra: 'Rohini',
              tithiAtBirth: 'Shukla Pratipada',
            ),
            planets: planets,
            lagna: 'Mesha',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Mesha'), findsOneWidget);
    expect(find.text('Lagna Mesha'), findsOneWidget);
    expect(find.text('Lagna'), findsOneWidget);
    expect(find.text('As'), findsOneWidget);
    expect(find.text('Su'), findsOneWidget);
    expect(find.text('Mo'), findsOneWidget);
    expect(find.text('Ma'), findsOneWidget);
    expect(find.text('Me'), findsOneWidget);
    expect(find.text('Ju'), findsOneWidget);
    expect(find.text('Ve'), findsOneWidget);
    expect(find.text('Sa'), findsOneWidget);
    expect(find.text('Ra'), findsOneWidget);
    expect(find.text('Ke'), findsOneWidget);
    expect(find.text('Test User'), findsOneWidget);
  });

  testWidgets('Panchang shows the real computed values for today',
      (WidgetTester tester) async {
    final Panchang expected =
        PanchangCalculator.forDate(DateTime.now(), kDefaultPlace);
    await tester.pumpWidget(
      const MaterialApp(home: PanchangScreen()),
    );
    await tester.pumpAndSettle();
    expect(find.text(expected.dateLine), findsOneWidget);
    expect(find.text(expected.tithi), findsOneWidget);
    expect(find.text(expected.vaar), findsOneWidget);
    expect(find.text(expected.nakshatra), findsOneWidget);
    expect(find.text(expected.yoga), findsOneWidget);
    expect(find.text(expected.karana), findsOneWidget);
    expect(find.text(expected.sunrise), findsOneWidget);
    expect(find.text(expected.sunset), findsOneWidget);
    // The muhurat card sits below the fold, so the ListView only
    // builds it once scrolled into view.
    await tester.drag(find.byType(ListView), const Offset(0, -800));
    await tester.pumpAndSettle();
    expect(find.text(expected.shubhMuhurat), findsOneWidget);
    expect(find.text('Rahu Kaal'), findsOneWidget);
    expect(
      find.text('Sample data only. No real prediction.'),
      findsNothing,
    );
  });

  testWidgets('Kundli form without a birth time uses noon and says so',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: KundliInputScreen()),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'Test User');
    await _acceptPicker(tester, find.byType(TextField).at(1));
    await tester.enterText(
      find.byType(TextField).at(3),
      'Jaipur, Rajasthan',
    );
    await tester.tap(find.text('Show Kundli'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Birth time not known, so noon is used and the lagna is approximate.',
      ),
      findsOneWidget,
    );
    await tester.drag(find.byType(ListView), const Offset(0, -1200));
    await tester.pumpAndSettle();
    expect(find.text('See Planet Details'), findsOneWidget);
  });

  testWidgets('Kundli form with other birth details shows a real chart',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: KundliInputScreen()),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'Test User');
    await _acceptPicker(tester, find.byType(TextField).at(1));
    await _acceptPicker(tester, find.byType(TextField).at(2));
    await tester.enterText(
      find.byType(TextField).at(3),
      'Jaipur, Rajasthan',
    );
    // The picked values, read back from the fields: the
    // chart is calculated from exactly what the pickers
    // wrote, so the expected lagna and Moon rashi come
    // from the engine, not from a fixed date.
    final DateTime picked = _pickedBirth(tester, 1, 2);
    final KundliResult expected = KundliCalculator.calculate(
      birthLocal: picked,
      placeText: 'Jaipur, Rajasthan',
    );
    await tester.tap(find.text('Show Kundli'));
    await tester.pumpAndSettle();
    expect(find.text('Lagna ${expected.lagna}'), findsOneWidget);
    expect(find.text(expected.moonRashi), findsWidgets);
    expect(
      find.text(
        'Kundli calculation for these birth details is not ready yet. No chart is shown for them.',
      ),
      findsNothing,
    );
    expect(find.text('View sample kundli'), findsNothing);
    expect(
      find.text('Sample data only. No real prediction.'),
      findsNothing,
    );
  });

  testWidgets('Kundli form with picked details shows a real chart, never a sample chart',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: KundliInputScreen()),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'Test User');
    await _acceptPicker(tester, find.byType(TextField).at(1));
    await _acceptPicker(tester, find.byType(TextField).at(2));
    await tester.enterText(
      find.byType(TextField).at(3),
      'Jaipur, Rajasthan',
    );
    final DateTime picked = _pickedBirth(tester, 1, 2);
    final KundliResult expected = KundliCalculator.calculate(
      birthLocal: picked,
      placeText: 'Jaipur, Rajasthan',
    );
    await tester.tap(find.text('Show Kundli'));
    await tester.pumpAndSettle();
    // The chart is calculated from the picked birth
    // details, so the real lagna for those details shows
    // and the screen never marks it as sample.
    expect(find.text('Lagna ${expected.lagna}'), findsOneWidget);
    expect(find.text(expected.moonRashi), findsWidgets);
    expect(find.text('Lagna'), findsOneWidget);
    expect(
      find.text('Sample data only. No real prediction.'),
      findsNothing,
    );
    expect(find.text('Sample data'), findsNothing);
  });

  testWidgets('Kundli form picks date and time, never types them',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: KundliInputScreen()),
    );
    await tester.pumpAndSettle();
    // The date and time fields are pickers, not typing: no
    // keyboard opens, tapping the field opens the dialog.
    expect(
      tester.widget<TextField>(find.byType(TextField).at(1)).readOnly,
      isTrue,
    );
    expect(
      tester.widget<TextField>(find.byType(TextField).at(2)).readOnly,
      isTrue,
    );
    await tester.enterText(find.byType(TextField).at(0), 'Sunmughan Swamy');
    await tester.enterText(
      find.byType(TextField).at(3),
      'Durg, Chhattisgarh',
    );
    await tester.tap(find.byType(TextField).at(1));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(TextField).at(2));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show Kundli'));
    await tester.pumpAndSettle();
    // The picked values pass validation: the chart opens and
    // the "Enter a valid date and time." error never appears.
    expect(find.text('Enter a valid date and time.'), findsNothing);
    expect(find.byType(KundliChartScreen), findsOneWidget);
  });

  testWidgets('Matching calculates a real score from two real charts',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(home: MatchingScreen()),
    );
    await tester.pumpAndSettle();
    await _acceptPicker(tester, find.byType(TextField).at(1));
    await _acceptPicker(tester, find.byType(TextField).at(2));
    await tester.enterText(find.byType(TextField).at(3), 'Jaipur');
    // The second person picks a different day in the same
    // month, so the two charts differ and the score is a
    // real comparison, not two identical charts.
    await tester.tap(find.byType(TextField).at(5));
    await tester.pumpAndSettle();
    await tester.tap(find.text('15'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await _acceptPicker(tester, find.byType(TextField).at(6));
    await tester.enterText(find.byType(TextField).at(7), 'Jaipur, Rajasthan');
    final DateTime firstPicked = _pickedBirth(tester, 1, 2);
    final DateTime secondPicked = _pickedBirth(tester, 5, 6);
    await tester.tap(find.text('Calculate matching'));
    await tester.pumpAndSettle();
    final KundliResult first = KundliCalculator.calculate(
      birthLocal: firstPicked,
      placeText: 'Jaipur',
    );
    final KundliResult second = KundliCalculator.calculate(
      birthLocal: secondPicked,
      placeText: 'Jaipur, Rajasthan',
    );
    final MatchingResult expected = MatchingCalculator.calculate(
      first: first,
      second: second,
    );
    expect(find.text('Guna Milan Score'), findsOneWidget);
    expect(find.text(expected.totalText), findsOneWidget);
    expect(find.text(expected.verdict), findsOneWidget);
    for (final String label in <String>[
      'Varna', 'Vashya', 'Tara', 'Yoni',
      'Graha Maitri', 'Gana', 'Bhakoot', 'Nadi',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('Mangal Dosha'), findsNWidgets(2));
    expect(find.text('28 / 36'), findsNothing);
  });

  testWidgets('Remedies come from the real kundli and Mark as done persists',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: RemediesScreen(
          firestore: _FakeFirestore(),
          authService: _FakeAuthService(signedInValue: true),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final KundliResult kundli = KundliCalculator.calculate(
      birthLocal: DateTime(2000, 1, 15, 7, 30),
      placeText: 'Delhi, Delhi, India',
    );
    final List<dynamic> remedies = RemedyEngine.derive(
      kundli: kundli,
      birthLocal: DateTime(2000, 1, 15, 7, 30),
      asOf: DateTime.now(),
    );
    expect(remedies, isNotEmpty);
    for (final dynamic remedy in remedies) {
      expect(find.text(remedy.title), findsOneWidget);
    }
    final List<dynamic> doneRemedies =
        remedies.where((dynamic r) => r.action == 'done').toList();
    if (doneRemedies.isNotEmpty) {
      await tester.ensureVisible(find.text('Mark as done').first);
      await tester.tap(find.text('Mark as done').first);
      await tester.pumpAndSettle();
      expect(find.text('Done today'), findsOneWidget);
    } else {
      expect(find.text('Ask about this remedy'), findsOneWidget);
    }
  });

  testWidgets('Consult Chat opens a real chat room',
      (WidgetTester tester) async {
    final _FakeChatService chat = _FakeChatService();
    await tester.pumpWidget(
      MaterialApp(
        home: ConsultScreen(
          firestore: _FakeFirestore(),
          authService: _FakeAuthService(signedInValue: true),
          chatService: chat,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chat with the astrologer'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'No astrologer has joined yet. Your messages are saved here and the astrologer will reply once added.',
      ),
      findsOneWidget,
    );
    await tester.enterText(find.byType(TextField).first, 'Hello');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();
    expect(find.text('Hello'), findsOneWidget);
    expect(chat.sent.length, 1);
    expect(chat.sent.first.text, 'Hello');
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
                  'status': 'approved',
                  'chatAvailable': true,
                  'callAvailable': true,
                },
                <String, dynamic>{
                  'id': 'a2',
                  'name': 'New Guru',
                  'languages': 'Hindi',
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

  testWidgets(
      'Sign in links sit side by side on one row, Forgot password left',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: AuthScreen()),
    );
    await tester.pumpAndSettle();
    final Offset forgot =
        tester.getCenter(find.text('Forgot password?'));
    final Offset create = tester.getCenter(find.text('Create account'));
    expect(forgot.dy, moreOrLessEquals(create.dy, epsilon: 1));
    expect(forgot.dx, lessThan(create.dx));
    expect(
      tester.getSize(find.text('Forgot password?')).height,
      lessThanOrEqualTo(20),
    );
    expect(
      tester.getSize(find.text('Create account')).height,
      lessThanOrEqualTo(20),
    );
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
    expect(find.text('Namaste, Test User'), findsOneWidget);
    expect(
      find.text('Birth 15 January 2000, 07:30 AM, Delhi, Delhi, India.'),
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
    expect(find.text('Test User'), findsOneWidget);
    expect(find.text('Edit profile'), findsOneWidget);
    expect(find.text('Date of birth'), findsOneWidget);
    expect(find.text('15 January 2000'), findsOneWidget);
    expect(find.text('Delhi, Delhi, India'), findsOneWidget);
    expect(
      find.textContaining('Daily horoscope alert at 06:00 AM.'),
      findsOneWidget,
    );
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
    // No SnackBar assertion: pumpAndSettle advances fake time
    // past the SnackBar duration, so it is gone by the time the
    // test looks for it. The recorded save above is the proof.
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
        'name': 'Test User',
        'dateOfBirth': '2000-01-15',
        'timeOfBirth': '07:30',
        'birthCity': 'Delhi',
        'birthState': 'Delhi',
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
  Stream<List<Map<String, dynamic>>> watchDocs(String collection, {int limit = 100}) =>
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

/// Fake chat that keeps messages in memory, so the chat
/// screen can be pumped with no Firestore behind it.
class _FakeChatService extends ChatService {
  final List<ChatMessage> sent = <ChatMessage>[];
  final StreamController<List<ChatMessage>> _controller =
      StreamController<List<ChatMessage>>.broadcast();

  @override
  Stream<List<ChatMessage>> watchMessages(String chatId) async* {
    yield List<ChatMessage>.from(sent);
    yield* _controller.stream;
  }

  @override
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderRole,
    required String text,
    List<String>? participantIds,
  }) async {
    sent.add(
      ChatMessage(
        id: 'm${sent.length}',
        senderId: senderId,
        senderRole: senderRole,
        text: text.trim(),
      ),
    );
    _controller.add(List<ChatMessage>.from(sent));
  }
}
