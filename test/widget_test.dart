import 'package:dharm_guru_shrinkhala/core/navigation/app_shell.dart';
import 'package:dharm_guru_shrinkhala/screens/auth_screen.dart';
import 'package:dharm_guru_shrinkhala/screens/screens.dart';
import 'package:dharm_guru_shrinkhala/services/auth_service.dart';
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
        const FirebaseAuthException(code: 'invalid-credential'),
      ),
      'The email or password is wrong. Try again or reset your password.',
    );
    expect(
      AuthService.plainError(
        const FirebaseAuthException(code: 'email-already-in-use'),
      ),
      'An account already exists for that email. Sign in instead.',
    );
    expect(
      AuthService.plainError(
        const FirebaseAuthException(code: 'operation-not-allowed'),
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
}
