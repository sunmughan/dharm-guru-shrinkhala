import 'package:material_ui/material_ui.dart';

import '../theme/design_tokens.dart';
import '../../screens/auth_screen.dart';
import '../../screens/screens.dart';
import '../../services/auth_service.dart';

/// Bottom tab navigation shell.
/// Tabs in fixed order: Home, Kundli, Panchang, Consult, Profile.
/// Kundli tab opens the birth details form first, then the chart.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  void _goToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = <Widget>[
      HomeScreen(onOpenTab: _goToTab),
      const KundliInputScreen(),
      const PanchangScreen(),
      const ConsultScreen(),
      const ProfileScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _goToTab,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_on),
            label: 'Kundli',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Panchang',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Consult',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/// Root widget. Shows splash, then the auth gate, then onboarding,
/// then the tab shell. Signed out users see only the sign in
/// screen: no kundli, matching, remedies or any other screen opens
/// without a signed in user. Set showSplash false in tests to skip
/// the splash screen. Pass authService in tests to fake the stream.
class DharmGuruApp extends StatefulWidget {
  const DharmGuruApp({
    super.key,
    this.firebaseReady = true,
    this.showSplash = true,
    this.authService,
  });

  final bool firebaseReady;
  final bool showSplash;
  final AuthService? authService;

  @override
  State<DharmGuruApp> createState() => _DharmGuruAppState();
}

class _DharmGuruAppState extends State<DharmGuruApp> {
  bool _splashDone = false;
  bool _onboardingDone = false;
  late final AuthService _auth = widget.authService ?? AuthService();
  late final Stream<bool> _signedIn = _auth.signedIn;

  @override
  void initState() {
    super.initState();
    _splashDone = !widget.showSplash;
  }

  MaterialApp _app({required Widget home}) {
    return MaterialApp(
      title: 'Dharm Guru Shrinkhala',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: home,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.firebaseReady) {
      return _app(home: const _FirebaseSetupNeededScreen());
    }
    if (!_splashDone) {
      return _app(
        home: SplashScreen(
          onDone: () => setState(() => _splashDone = true),
        ),
      );
    }
    return StreamBuilder<bool>(
      stream: _signedIn,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (!snapshot.hasData) {
          return _app(
            home: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        if (snapshot.data == false) {
          return _app(home: AuthScreen(authService: _auth));
        }
        if (!_onboardingDone) {
          return _app(
            home: OnboardingScreen(
              onDone: () => setState(() => _onboardingDone = true),
            ),
          );
        }
        return _app(home: const AppShell());
      },
    );
  }
}

class _FirebaseSetupNeededScreen extends StatelessWidget {
  const _FirebaseSetupNeededScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dharm Guru Shrinkhala')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Firebase is not configured yet.',
              style: AppTextStyles.themed(context, AppTextStyles.title),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'See FIREBASE-SETUP.md for the console steps, then run flutterfire configure.',
              style: AppTextStyles.themed(context, AppTextStyles.body),
            ),
          ],
        ),
      ),
    );
  }
}
