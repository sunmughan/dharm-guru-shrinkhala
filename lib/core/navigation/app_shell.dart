import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';
import '../../screens/screens.dart';

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

/// Root widget. Shows splash, then onboarding, then the tab shell.
/// Set showSplash false in tests to skip the splash screen.
class DharmGuruApp extends StatefulWidget {
  const DharmGuruApp({
    super.key,
    this.firebaseReady = true,
    this.showSplash = true,
  });

  final bool firebaseReady;
  final bool showSplash;

  @override
  State<DharmGuruApp> createState() => _DharmGuruAppState();
}

class _DharmGuruAppState extends State<DharmGuruApp> {
  bool _splashDone = false;
  bool _onboardingDone = false;

  @override
  void initState() {
    super.initState();
    _splashDone = !widget.showSplash;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.firebaseReady) {
      return MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.light,
        home: const _FirebaseSetupNeededScreen(),
      );
    }
    if (!_splashDone) {
      return MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.light,
        home: SplashScreen(
          onDone: () => setState(() => _splashDone = true),
        ),
      );
    }
    if (!_onboardingDone) {
      return MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.light,
        home: OnboardingScreen(
          onDone: () => setState(() => _onboardingDone = true),
        ),
      );
    }
    return MaterialApp(
      title: 'Dharm Guru Shrinkhala',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.light,
      home: const AppShell(),
    );
  }
}

class _FirebaseSetupNeededScreen extends StatelessWidget {
  const _FirebaseSetupNeededScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dharm Guru Shrinkhala')),
      body: const Padding(
        padding: EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Firebase is not configured yet.',
              style: AppTextStyles.title,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'See FIREBASE-SETUP.md for the console steps, then run flutterfire configure.',
              style: AppTextStyles.body,
            ),
          ],
        ),
      ),
    );
  }
}
