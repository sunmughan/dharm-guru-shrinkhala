import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../build_info.dart';
import '../theme/design_tokens.dart';
import '../../screens/auth_screen.dart';
import '../../screens/screens.dart';
import '../../services/auth_service.dart';
import '../../services/firebase_service.dart';
import '../../services/firestore_service.dart';

/// SharedPreferences key that remembers the user saw onboarding.
/// Once set, onboarding never shows again on that phone.
const String kOnboardingSeenKey = 'onboarding_seen';

/// Bottom tab navigation shell.
/// Tabs in fixed order: Home, Kundli, Panchang, Consult, Profile.
/// Kundli tab opens the birth details form first, then the chart.
class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    this.firestoreService,
    this.authService,
    this.askNotifications = true,
  });

  /// Firestore service for the tabs. Null in production, where a
  /// real one is created. Tests pass a fake so no Firebase call
  /// runs while the app is pumped without Firebase initialised.
  final FirestoreService? firestoreService;

  /// Auth service for the tabs. Null in production, where a real
  /// one is created. Tests pass a fake.
  final AuthService? authService;

  /// False in tests, so the one time notification dialog never
  /// opens while the shell is pumped. True in production.
  final bool askNotifications;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  // One shared Firestore service for every tab, so the admin
  // published content reaches Home, Panchang, Consult and Profile
  // through the same live streams.
  late final FirestoreService _firestore =
      widget.firestoreService ?? FirestoreService();
  late final AuthService _auth = widget.authService ?? AuthService();

  @override
  void initState() {
    super.initState();
    // The notification permission dialog appears here and only
    // here: on the main screen, after onboarding and sign in,
    // once per install, with the reason shown first. Never at
    // app open, never during splash or onboarding.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _askNotificationPermissionOnce();
    });
  }

  Future<void> _askNotificationPermissionOnce() async {
    if (!widget.askNotifications) {
      return;
    }
    if (await FirebaseService.notificationPromptShown()) {
      return;
    }
    if (!mounted) {
      return;
    }
    final bool? allow = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Daily horoscope alerts'),
          content: const Text(
            'Allow notifications to get your daily horoscope alert at 06:00 AM. You can change this later in Profile.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Not now'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Allow notifications'),
            ),
          ],
        );
      },
    );
    if (allow == true) {
      await FirebaseService.requestNotificationPermissionOnce();
    } else {
      await FirebaseService.markNotificationPromptShown();
    }
  }

  void _goToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = <Widget>[
      HomeScreen(
        onOpenTab: _goToTab,
        firestore: _firestore,
        authService: _auth,
      ),
      KundliInputScreen(firestore: _firestore, authService: _auth),
      PanchangScreen(firestore: _firestore),
      ConsultScreen(firestore: _firestore),
      ProfileScreen(firestore: _firestore, authService: _auth),
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

/// Root widget. Shows splash, then onboarding on the first
/// launch only, then the auth gate, then the tab shell. Signed
/// out users see only the sign in screen: no kundli, matching,
/// remedies or any other screen opens without a signed in user.
/// Onboarding never breaks the gate: Skip and Begin both land
/// on the sign in screen, and the tab shell still needs a
/// signed in user. Set showSplash false in tests to skip the
/// splash screen. Pass authService in tests to fake the stream.
/// Pass firestoreService in tests to fake Firestore, so the tab
/// shell never touches real Firebase while it is pumped.
/// Pass onboardingSeen in tests to skip the SharedPreferences
/// read.
class DharmGuruApp extends StatefulWidget {
  const DharmGuruApp({
    super.key,
    this.firebaseReady = true,
    this.firebaseError,
    this.showSplash = true,
    this.authService,
    this.firestoreService,
    this.onboardingSeen,
    this.askNotifications = true,
  });

  final bool firebaseReady;

  /// The init error text, shown on the setup screen when Firebase
  /// failed to initialise, so the phone names the failing call.
  final String? firebaseError;
  final bool showSplash;
  final AuthService? authService;
  final FirestoreService? firestoreService;

  /// First launch flag. Null in production, where it is read
  /// from SharedPreferences. Tests pass it in directly.
  final bool? onboardingSeen;

  /// False in tests, so the one time notification dialog never
  /// opens while the app is pumped. True in production.
  final bool askNotifications;

  @override
  State<DharmGuruApp> createState() => _DharmGuruAppState();
}

class _DharmGuruAppState extends State<DharmGuruApp> {
  bool _splashDone = false;
  bool? _onboardingSeen;
  late final AuthService _auth = widget.authService ?? AuthService();
  late final Stream<bool> _signedIn = _auth.signedIn;

  @override
  void initState() {
    super.initState();
    _splashDone = !widget.showSplash;
    if (widget.onboardingSeen != null) {
      _onboardingSeen = widget.onboardingSeen;
    } else {
      SharedPreferences.getInstance().then((SharedPreferences prefs) {
        if (!mounted) {
          return;
        }
        setState(() {
          _onboardingSeen =
              prefs.getBool(kOnboardingSeenKey) ?? false;
        });
      });
    }
  }

  Future<void> _finishOnboarding() async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();
    await prefs.setBool(kOnboardingSeenKey, true);
    if (!mounted) {
      return;
    }
    setState(() => _onboardingSeen = true);
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
      return _app(
        home: _FirebaseSetupNeededScreen(errorText: widget.firebaseError),
      );
    }
    if (!_splashDone) {
      return _app(
        home: SplashScreen(
          onDone: () => setState(() => _splashDone = true),
        ),
      );
    }
    if (_onboardingSeen == null) {
      return _app(
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    if (_onboardingSeen == false) {
      return _app(
        home: OnboardingScreen(onDone: _finishOnboarding),
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
        return _app(
          home: AppShell(
            firestoreService: widget.firestoreService,
            authService: _auth,
            askNotifications: widget.askNotifications,
          ),
        );
      },
    );
  }
}

class _FirebaseSetupNeededScreen extends StatelessWidget {
  const _FirebaseSetupNeededScreen({this.errorText});

  /// The caught init error, shown so the phone names the failing
  /// call. Null when the screen is shown without an error.
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dharm Guru Shrinkhala')),
      body: SingleChildScrollView(
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
            const SizedBox(height: AppSpacing.md),
            Text(
              kBuildStamp,
              style: AppTextStyles.themed(context, AppTextStyles.body.copyWith(
                color: AppColors.ink2,
              )),
            ),
            if (errorText != null) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              Text(
                'Start error:',
                style: AppTextStyles.themed(context, AppTextStyles.body),
              ),
              const SizedBox(height: AppSpacing.sm),
              SelectableText(
                errorText!,
                style: AppTextStyles.themed(context, AppTextStyles.body),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
