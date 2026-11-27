import 'dart:math' as math;
import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/build_info.dart';
import '../core/theme/design_tokens.dart';
import '../models/kundli.dart';
import '../models/panchang.dart';
import '../models/remedies.dart';
import '../services/astro.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import '../services/firebase_service.dart';
import '../services/firestore_service.dart';
import '../services/kundli_pdf.dart';
import '../services/kundli_report.dart';
import '../services/library_content.dart';
import '../services/matching.dart';
import '../services/notification_schedule.dart';
import '../services/premium_service.dart';
import '../services/remedies_engine.dart';
import '../services/user_profile.dart';
import '../widgets/brand_mark.dart';
import '../widgets/kundli_chart.dart';
import '../widgets/planet_details.dart';
import 'profile_form_screen.dart';

/// Splash screen. Logo, wordmark and tagline, with a calm
/// entrance: the logo fades and settles in, a gold rays ring
/// turns a little behind it, the three dots pulse, then the
/// whole screen fades out. Auto advances after two seconds,
/// per design/screens/01-splash.md. The small build stamp at
/// the bottom tells the installed build apart on the phone,
/// and the developer credit sits just above it.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onDone, this.caption});

  final VoidCallback onDone;

  /// Short line under the tagline, used by the admin app to
  /// say Admin. Null on the user app.
  final String? caption;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _entrance;
  late final Animation<double> _turns;
  late final Animation<double> _exitFade;
  bool _advanced = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _entrance = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOutCubic),
    );
    // The rays ring turns a small part of a full circle while
    // the splash is up. It is driven by the same controller so
    // no animation runs forever and tests can settle.
    _turns = Tween<double>(begin: 0, end: 0.08).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );
    _exitFade = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.85, 1.0, curve: Curves.easeIn),
      ),
    );
    _controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed && !_advanced) {
        _advanced = true;
        widget.onDone();
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) {
            return Opacity(
              opacity: _exitFade.value,
              child: child,
            );
          },
          child: Column(
            children: <Widget>[
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      FadeTransition(
                        opacity: _entrance,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.9, end: 1.0)
                              .animate(_entrance),
                          child: Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              SplashRaysRing(turns: _turns, size: 168),
                              const BrandMark(size: 96),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      FadeTransition(
                        opacity: _entrance,
                        child: Text(
                          'Dharm Guru',
                          style: AppTextStyles.themed(
                              context, AppTextStyles.display),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      FadeTransition(
                        opacity: _entrance,
                        child: Text(
                          'Your kundli. Your guidance. Every single day.',
                          style: AppTextStyles.themed(
                              context,
                              AppTextStyles.body.copyWith(
                                color: AppColors.ink2,
                              )),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (widget.caption != null) ...<Widget>[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          widget.caption!,
                          style: AppTextStyles.themed(
                              context,
                              AppTextStyles.caption.copyWith(
                                color: AppColors.saffron2,
                              )),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.space3),
                      _SplashDots(progress: _controller),
                    ],
                  ),
                ),
              ),
              Text(
                'Developed by Codeair Software Solutions',
                style: AppTextStyles.themed(
                    context,
                    AppTextStyles.caption.copyWith(
                      color: AppColors.ink3,
                    )),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.space3),
              Text(
                kBuildStamp,
                style: AppTextStyles.themed(context, AppTextStyles.body.copyWith(
                  color: AppColors.ink2,
                )),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

/// Three calm dots, centre dot saffron, outer dots line2. The
/// dots pulse one after another while the splash timer runs.
class _SplashDots extends StatelessWidget {
  const _SplashDots({required this.progress});

  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (BuildContext context, Widget? child) {
        final double t = progress.value;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            for (int i = 0; i < 3; i++) ...<Widget>[
              if (i > 0) const SizedBox(width: AppSpacing.sm),
              _SplashDot(
                active: i == 1,
                opacity: 0.35 +
                    0.65 *
                        (0.5 +
                            0.5 *
                                math.sin(
                                    (t * 2 + i / 3) * 2 * math.pi)),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _SplashDot extends StatelessWidget {
  const _SplashDot({required this.active, this.opacity = 1});

  final bool active;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final bool dark =
        Theme.of(context).brightness == Brightness.dark;
    final Color dotColor = active
        ? (dark ? AppColorsDark.saffron : AppColors.saffron)
        : (dark ? AppColorsDark.line2 : AppColors.line2);
    return Opacity(
      opacity: opacity,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: dotColor,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// Onboarding screen, per design/screens/02-onboarding.md.
/// Three steps, one per swipe page, then the sign in screen.
/// Skip, Begin My Journey on the last page, and I Have an
/// Account all move to sign in, never to Home, because a
/// kundli needs an account to save. Shown only on the first
/// launch; the app shell remembers it in SharedPreferences.
class _OnboardingStepData {
  const _OnboardingStepData({
    required this.number,
    required this.label,
    required this.text,
  });

  final String number;
  final String label;
  final String text;
}

const List<_OnboardingStepData> _onboardingSteps =
    <_OnboardingStepData>[
  _OnboardingStepData(
    number: '1',
    label: 'Step one',
    text: 'Share your birth details once and your kundli stays saved forever.',
  ),
  _OnboardingStepData(
    number: '2',
    label: 'Step two',
    text: 'Read your horoscope and panchang every morning with one tap.',
  ),
  _OnboardingStepData(
    number: '3',
    label: 'Step three',
    text: 'Talk to an astrologer live when you want a human answer.',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextOrDone() {
    if (_page < _onboardingSteps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onDone();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool dark =
        Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Spacer(),
                  TextButton(
                    onPressed: widget.onDone,
                    style: TextButton.styleFrom(
                      minimumSize: const Size(44, 44),
                    ),
                    child: Text(
                      'Skip',
                      style: AppTextStyles.themed(
                          context,
                          AppTextStyles.button.copyWith(
                            color: dark
                                ? AppColorsDark.saffron2
                                : AppColors.saffron2,
                          )),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              const BrandMark(size: 48),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Know your stars in one minute',
                style: AppTextStyles.themed(context, AppTextStyles.title),
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _onboardingSteps.length,
                  onPageChanged: (int page) =>
                      setState(() => _page = page),
                  itemBuilder:
                      (BuildContext context, int index) {
                    final _OnboardingStepData step =
                        _onboardingSteps[index];
                    return _OnboardingStep(
                      number: step.number,
                      label: step.label,
                      body: step.text,
                    );
                  },
                ),
              ),
              Semantics(
                label: 'Page ${_page + 1} of ${_onboardingSteps.length}',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    for (int i = 0; i < _onboardingSteps.length; i++)
                      _OnboardingDot(active: i == _page),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextOrDone,
                  child: const Text('Begin My Journey'),
                ),
              ),
              const SizedBox(height: AppSpacing.space3),
              SizedBox(
                width: double.infinity,
                height: AppSpacing.buttonHeight,
                child: OutlinedButton(
                  onPressed: widget.onDone,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: dark
                        ? AppColorsDark.surface
                        : AppColors.surface,
                    foregroundColor:
                        dark ? AppColorsDark.ink : AppColors.ink,
                    side: BorderSide(
                      color: dark
                          ? AppColorsDark.line2
                          : AppColors.line2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          AppSpacing.buttonRadius),
                    ),
                    textStyle: AppTextStyles.button.copyWith(
                      color: dark ? AppColorsDark.ink : AppColors.ink,
                    ),
                  ),
                  child: const Text('I Have an Account'),
                ),
              ),
              const SizedBox(height: AppSpacing.space3),
              Center(
                child: Text(
                  'Sign in with phone OTP or Google.',
                  style: AppTextStyles.themed(
                      context,
                      AppTextStyles.caption.copyWith(
                        color: AppColors.ink3,
                      )),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One onboarding page: number pill, step label, step text.
/// Left aligned, per the spec.
class _OnboardingStep extends StatelessWidget {
  const _OnboardingStep({
    required this.number,
    required this.label,
    required this.body,
  });

  final String number;
  final String label;
  final String body;

  @override
  Widget build(BuildContext context) {
    final bool dark =
        Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: dark ? AppColorsDark.saffron : AppColors.saffron,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: AppTextStyles.themed(
                context,
                AppTextStyles.button.copyWith(
                  color: dark ? AppColorsDark.bg : AppColors.textOnSaffron,
                )),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          label,
          style: AppTextStyles.themed(
              context,
              AppTextStyles.caption.copyWith(
                color: dark ? AppColorsDark.saffron2 : AppColors.saffron2,
              )),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          body,
          style: AppTextStyles.themed(context, AppTextStyles.body),
        ),
      ],
    );
  }
}

/// Page dots. Active dot is a 24 wide saffron pill, inactive
/// dots are 8 round in line2.
class _OnboardingDot extends StatelessWidget {
  const _OnboardingDot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final bool dark =
        Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: active ? 24 : 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: active
            ? (dark ? AppColorsDark.saffron : AppColors.saffron)
            : (dark ? AppColorsDark.line2 : AppColors.line2),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// Home screen. Cards lead to kundli, horoscope, panchang,
/// matching, remedies and live consult. The greeting and birth
/// line come from the saved profile when one exists; with no
/// profile yet the screen asks the user to complete it instead
/// of showing a made up name.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onOpenTab, this.firestore, this.authService});

  final void Function(int tabIndex) onOpenTab;
  final FirestoreService? firestore;
  final AuthService? authService;

  @override
  Widget build(BuildContext context) {
    final String? uid = authService?.currentUserId;
    final Future<Map<String, dynamic>?>? profileFuture =
        firestore != null && uid != null
            ? firestore!.getUserProfile(uid)
            : null;
    return Scaffold(
      appBar: AppBar(title: const Text('Dharm Guru Shrinkhala')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: <Widget>[
          if (profileFuture == null)
            _HomeGreeting(profile: null, onOpenTab: onOpenTab)
          else
            FutureBuilder<Map<String, dynamic>?>(
              future: profileFuture,
              builder: (
                BuildContext context,
                AsyncSnapshot<Map<String, dynamic>?> snapshot,
              ) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 72,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final AppUserProfile? profile = snapshot.data == null
                    ? null
                    : AppUserProfile.fromMap(snapshot.data!);
                return _HomeGreeting(
                  profile: profile,
                  onOpenTab: onOpenTab,
                );
              },
            ),
          const SizedBox(height: AppSpacing.md),
          _HomeKundliCard(
            profileFuture: profileFuture,
            onTap: () => onOpenTab(1),
          ),
          _HomeHoroscopeCard(
            firestore: firestore,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => HoroscopeScreen(firestore: firestore),
                ),
              );
            },
          ),
          if (firestore != null)
            _HomeCard(
              title: 'Notifications',
              body: 'Horoscope alerts, festival wishes and offers.',
              icon: Icons.notifications,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => NotificationsScreen(
                      firestore: firestore!,
                      authService: authService,
                    ),
                  ),
                );
              },
            ),
          _HomeCard(
            title: 'Panchang',
            body: _todayPanchangLine(),
            icon: Icons.calendar_month,
            onTap: () => onOpenTab(2),
          ),
          _HomeCard(
            title: 'Kundli Matching',
            body: 'Guna milan score with dosha check.',
            icon: Icons.favorite,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => MatchingScreen(
                    firestore: firestore,
                    authService: authService,
                  ),
                ),
              );
            },
          ),
          _HomeCard(
            title: 'Remedies',
            body: 'Simple upay chosen from your kundli.',
            icon: Icons.spa,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => RemediesScreen(
                    firestore: firestore,
                    authService: authService,
                  ),
                ),
              );
            },
          ),
          _HomeCard(
            title: 'Library',
            body: 'Dasha timeline, festival days and planet reference.',
            icon: Icons.menu_book,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => LibraryScreen(
                    firestore: firestore,
                    authService: authService,
                  ),
                ),
              );
            },
          ),
          _HomeCard(
            title: 'Live Consult',
            body: 'Chat and call with an astrologer. Pricing to be decided.',
            icon: Icons.call,
            onTap: () => onOpenTab(3),
          ),
        ],
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  const _HomeCard({
    required this.title,
    required this.body,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String body;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.deepSaffron, size: 32),
        title: Text(title, style: AppTextStyles.themed(context, AppTextStyles.subtitle)),
        subtitle: Text(body, style: AppTextStyles.themed(context, AppTextStyles.bodySmall)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

/// Today's panchang line for the home card, computed from the
/// real date, not stored text.
String _todayPanchangLine() {
  final Panchang panchang =
      PanchangCalculator.forDate(DateTime.now(), kDefaultPlace);
  return '${panchang.tithi}, ${panchang.vaar}, ${panchang.nakshatra}.';
}

/// Home kundli card. With a complete profile it shows the
/// real lagna and rashi calculated from the birth details.
/// Without one it asks the user to complete the profile,
/// instead of showing a sample chart as if it were theirs.
class _HomeKundliCard extends StatelessWidget {
  const _HomeKundliCard({required this.profileFuture, required this.onTap});

  final Future<Map<String, dynamic>?>? profileFuture;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (profileFuture == null) {
      return _HomeCard(
        title: 'Your Kundli',
        body: 'Add your birth details to see your real kundli.',
        icon: Icons.grid_on,
        onTap: onTap,
      );
    }
    return FutureBuilder<Map<String, dynamic>?>(
      future: profileFuture,
      builder: (
        BuildContext context,
        AsyncSnapshot<Map<String, dynamic>?> snapshot,
      ) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _HomeCard(
            title: 'Your Kundli',
            body: 'Loading your kundli...',
            icon: Icons.grid_on,
            onTap: onTap,
          );
        }
        final AppUserProfile? profile = snapshot.data == null
            ? null
            : AppUserProfile.fromMap(snapshot.data!);
        if (profile == null || !profile.isComplete) {
          return _HomeCard(
            title: 'Your Kundli',
            body: 'Add your birth details to see your real kundli.',
            icon: Icons.grid_on,
            onTap: onTap,
          );
        }
        final DateTime? birth = parseBirthDateTime(
          AppUserProfile.displayDate(profile.dateOfBirth!),
          profile.birthTimeUnknown || profile.timeOfBirth == null
              ? '12:00 PM'
              : AppUserProfile.displayTime(profile.timeOfBirth!),
        );
        if (birth == null) {
          return _HomeCard(
            title: 'Your Kundli',
            body: 'Your birth details could not be read. '
                'Check them in your profile.',
            icon: Icons.grid_on,
            onTap: onTap,
          );
        }
        final KundliResult kundli = KundliCalculator.calculate(
          birthLocal: birth,
          placeText: profile.placeLine,
          timeKnown: !profile.birthTimeUnknown,
        );
        return _HomeCard(
          title: 'Your Kundli',
          body: 'Lagna ${kundli.lagna} · Rashi ${kundli.moonRashi} · '
              'Nakshatra ${kundli.moonNakshatra}.',
          icon: Icons.grid_on,
          onTap: onTap,
        );
      },
    );
  }
}

/// Home horoscope card. Shows whether a horoscope is
/// published for today, from the admin panel. Never a dead
/// placeholder line pretending the feature works.
class _HomeHoroscopeCard extends StatelessWidget {
  const _HomeHoroscopeCard({required this.firestore, required this.onTap});

  final FirestoreService? firestore;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (firestore == null) {
      return _HomeCard(
        title: 'Daily Horoscope',
        body: 'No horoscope published yet today.',
        icon: Icons.wb_sunny,
        onTap: onTap,
      );
    }
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: firestore!.watchDocs('horoscopes'),
      builder: (
        BuildContext context,
        AsyncSnapshot<List<Map<String, dynamic>>> snap,
      ) {
        String body = 'No horoscope published yet today.';
        if (snap.hasData) {
          final List<Map<String, dynamic>> published = snap.data!
              .where((Map<String, dynamic> d) => str(d, 'status') == 'published')
              .toList();
          if (published.isNotEmpty) {
            published.sort((Map<String, dynamic> a, Map<String, dynamic> b) =>
                str(b, 'date').compareTo(str(a, 'date')));
            final Map<String, dynamic> doc = published.first;
            body = "Today's horoscope for ${str(doc, 'rashi')} is ready.";
          }
        }
        return _HomeCard(
          title: 'Daily Horoscope',
          body: body,
          icon: Icons.wb_sunny,
          onTap: onTap,
        );
      },
    );
  }
}

/// Home greeting. With a complete profile it shows the real
/// name and birth line. With no profile it says Namaste and
/// offers the Profile tab, so the app never shows a made up
/// name as if it were the signed in user.
class _HomeGreeting extends StatelessWidget {
  const _HomeGreeting({required this.profile, required this.onOpenTab});

  final AppUserProfile? profile;
  final void Function(int tabIndex) onOpenTab;

  @override
  Widget build(BuildContext context) {
    final AppUserProfile? profile = this.profile;
    if (profile == null || !profile.isComplete) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Namaste',
            style: AppTextStyles.themed(context, AppTextStyles.display),
          ),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.person_add,
                color: AppColors.deepSaffron,
                size: 32,
              ),
              title: Text(
                'Complete your profile',
                style: AppTextStyles.themed(
                  context,
                  AppTextStyles.subtitle,
                ),
              ),
              subtitle: Text(
                'Add your birth details so your kundli and horoscope use your real details.',
                style: AppTextStyles.themed(
                  context,
                  AppTextStyles.bodySmall,
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => onOpenTab(4),
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Namaste, ${profile.name}',
          style: AppTextStyles.themed(context, AppTextStyles.display),
        ),
        Text(
          'Birth ${profile.birthLine}.',
          style: AppTextStyles.themed(context, AppTextStyles.bodySmall),
        ),
      ],
    );
  }
}

/// Kundli input form: name, date, time and place of birth.
/// When a saved profile exists, the form opens prefilled with
/// the profile birth details. Without one it opens empty: no
/// fixed details are ever shown as if they were the user.
class KundliInputScreen extends StatefulWidget {
  const KundliInputScreen({super.key, this.firestore, this.authService});

  final FirestoreService? firestore;
  final AuthService? authService;

  @override
  State<KundliInputScreen> createState() => _KundliInputScreenState();
}

class _KundliInputScreenState extends State<KundliInputScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final FirestoreService? firestore = widget.firestore;
    final String? uid = widget.authService?.currentUserId;
    if (firestore != null && uid != null) {
      firestore.getUserProfile(uid).then((Map<String, dynamic>? map) {
        if (!mounted || map == null) {
          return;
        }
        final AppUserProfile profile = AppUserProfile.fromMap(map);
        if (!profile.isComplete) {
          return;
        }
        setState(() {
          _nameController.text = profile.name;
          _dateController.text =
              AppUserProfile.displayDate(profile.dateOfBirth!);
          _timeController.text =
              profile.birthTimeUnknown || profile.timeOfBirth == null
                  ? ''
                  : AppUserProfile.displayTime(profile.timeOfBirth!);
          _placeController.text = profile.placeLine;
        });
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _placeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Birth Details')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: <Widget>[
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _dateController,
            decoration: const InputDecoration(
              labelText: 'Date of birth',
              hintText: 'Day Month Year',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _timeController,
            decoration: const InputDecoration(
              labelText: 'Time of birth',
              hintText: 'HH:MM AM or PM',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _placeController,
            decoration: const InputDecoration(
              labelText: 'Place of birth',
              hintText: 'City, State',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: () {
              final String name = _nameController.text.trim();
              final String date = _dateController.text.trim();
              final String time = _timeController.text.trim();
              final String place = _placeController.text.trim();
              if (name.isEmpty ||
                  date.isEmpty ||
                  place.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Enter name, date and place of birth.',
                    ),
                  ),
                );
                return;
              }
              final BirthDetails entered = BirthDetails(
                name: name,
                dateOfBirth: date,
                timeOfBirth: time,
                placeOfBirth: place,
                rashi: '',
                nakshatra: '',
                tithiAtBirth: '',
              );
              final DateTime? birth = parseBirthDateTime(
                date,
                time.isEmpty ? '12:00 PM' : time,
              );
              if (birth == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Enter a valid date and time.',
                    ),
                  ),
                );
                return;
              }
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => KundliChartScreen(
                    birth: entered,
                  ),
                ),
              );
            },
            child: const Text('Show Kundli'),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Your kundli is calculated from your birth date, time and place.',
            style: AppTextStyles.themed(context, AppTextStyles.bodySmall),
          ),
        ],
      ),
    );
  }
}

/// Kundli chart screen with the North Indian chart, the
/// Lagna and Moon chart switcher, the summary chips and the
/// planet summary list, per design/screens/05-kundli-chart.md.
/// The chart is calculated from the entered birth details
/// with the real engine: lagna, planets, rashi and nakshatra
/// are all computed, for any birth date, time and place. The
/// Moon chart counts bhavas from the Moon sign.
class KundliChartScreen extends StatefulWidget {
  const KundliChartScreen({
    super.key,
    required this.birth,
  });

  final BirthDetails birth;

  @override
  State<KundliChartScreen> createState() => _KundliChartScreenState();
}

class _KundliChartScreenState extends State<KundliChartScreen> {
  bool _showMoonChart = false;

  /// The real kundli for the entered birth details. Null
  /// only when the date or time text does not parse, which
  /// the input screen already rejects.
  KundliResult? get _kundli {
    final DateTime? birth = parseBirthDateTime(
      widget.birth.dateOfBirth,
      widget.birth.timeOfBirth.isEmpty
          ? '12:00 PM'
          : widget.birth.timeOfBirth,
    );
    if (birth == null) return null;
    return KundliCalculator.calculate(
      birthLocal: birth,
      placeText: widget.birth.placeOfBirth,
      timeKnown: widget.birth.timeOfBirth.isNotEmpty,
    );
  }

  @override
  Widget build(BuildContext context) {
    final KundliResult? kundli = _kundli;
    return Scaffold(
      appBar: AppBar(title: const Text('Birth Kundli')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: <Widget>[
          if (kundli == null) ...<Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.birth.name,
                      style: AppTextStyles.themed(
                        context,
                        AppTextStyles.title,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '${widget.birth.dateOfBirth}, ${widget.birth.timeOfBirth}, ${widget.birth.placeOfBirth}',
                      style: AppTextStyles.themed(
                        context,
                        AppTextStyles.body,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'These birth details could not be read. '
                      'Enter a valid date and time.',
                      style: AppTextStyles.themed(
                        context,
                        AppTextStyles.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...<Widget>[
            _ChartSwitcher(
              showMoon: _showMoonChart,
              onChanged: (bool showMoon) {
                setState(() {
                  _showMoonChart = showMoon;
                });
              },
            ),
            if (widget.birth.timeOfBirth.isEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Birth time not known, so noon is used and the lagna is approximate.',
                style: AppTextStyles.themed(
                  context,
                  AppTextStyles.bodySmall,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            if (_showMoonChart) ...<Widget>[
              KundliChart(
                birth: widget.birth,
                planets: kundli.moonChart.planets,
                lagna: kundli.moonChart.lagna,
              ),
              const SizedBox(height: AppSpacing.space3),
              _ChartLegend(
                lagna: kundli.moonChart.lagna,
                rashi: kundli.moonRashi,
                nakshatra: kundli.moonNakshatra,
              ),
              const SizedBox(height: AppSpacing.md),
              _PlanetSummaryList(planets: kundli.moonChart.planets),
            ] else ...<Widget>[
              KundliChart(
                birth: widget.birth,
                planets: kundli.planets,
                lagna: kundli.lagna,
              ),
              const SizedBox(height: AppSpacing.space3),
              _ChartLegend(
                lagna: kundli.lagna,
                rashi: kundli.moonRashi,
                nakshatra: kundli.moonNakshatra,
              ),
              const SizedBox(height: AppSpacing.md),
              _PlanetSummaryList(planets: kundli.planets),
            ],
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => PlanetDetailsScreen(kundli: kundli),
                    ),
                  );
                },
                child: const Text('See Planet Details'),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _downloadPdfReport(kundli),
                child: const Text('Download PDF report'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Builds the PDF report from the chart on screen and shares
  /// it: download on web, share sheet on native. A failure
  /// shows a message, it never crashes the screen.
  Future<void> _downloadPdfReport(KundliResult kundli) async {
    try {
      final KundliPdfFonts fonts = await KundliPdfFonts.load();
      final KundliResult shown =
          _showMoonChart ? kundli.moonChart : kundli;
      final KundliReportData data = buildKundliReportData(
        birth: widget.birth,
        kundli: shown,
        chartKind: _showMoonChart ? 'Moon Chart' : 'Lagna Chart',
      );
      final Uint8List bytes = await KundliPdfBuilder.build(data, fonts);
      final String safeName = widget.birth.name.replaceAll(
        RegExp(r'[^A-Za-z0-9]+'),
        '_',
      );
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'kundli_report_$safeName.pdf',
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF report could not be made. Try again.'),
        ),
      );
    }
  }
}

/// Segmented control for Lagna Chart and Moon Chart, per the
/// design system section 10.3. Pill container in surface2,
/// selected segment in surface with a line2 border and saffron
/// text, unselected segment in ink2 text. Height 40.
class _ChartSwitcher extends StatelessWidget {
  const _ChartSwitcher({
    required this.showMoon,
    required this.onChanged,
  });

  final bool showMoon;
  final void Function(bool showMoon) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.resolve(
          context,
          AppColors.surface2,
          AppColorsDark.surface2,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _switcherSegment(
              context,
              label: 'Lagna Chart',
              selected: !showMoon,
              onTap: () => onChanged(false),
            ),
          ),
          Expanded(
            child: _switcherSegment(
              context,
              label: 'Moon Chart',
              selected: showMoon,
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _switcherSegment(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.resolve(
                  context,
                  AppColors.surface,
                  AppColorsDark.surface,
                )
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
          border: selected
              ? Border.all(
                  color: AppColors.resolve(
                    context,
                    AppColors.line2,
                    AppColorsDark.line2,
                  ),
                  width: 1,
                )
              : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.themed(context, AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.saffron : AppColors.ink2,
          )),
        ),
      ),
    );
  }
}

/// Three summary chips below the chart: Lagna, Rashi,
/// Nakshatra. Each is a small card with the label in Caption
/// 12 ink3 above the value in Title 17 ink. Tapping a chip
/// does nothing. They are a summary, not buttons.
class _ChartLegend extends StatelessWidget {
  const _ChartLegend({
    required this.lagna,
    required this.rashi,
    required this.nakshatra,
  });

  final String lagna;
  final String rashi;
  final String nakshatra;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(child: _LegendChip(label: 'Lagna', value: lagna)),
        const SizedBox(width: AppSpacing.space3),
        Expanded(child: _LegendChip(label: 'Rashi', value: rashi)),
        const SizedBox(width: AppSpacing.space3),
        Expanded(
          child: _LegendChip(label: 'Nakshatra', value: nakshatra),
        ),
      ],
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(label, style: AppTextStyles.themed(context, AppTextStyles.caption)),
            Text(value, style: AppTextStyles.themed(context, AppTextStyles.listTitle)),
          ],
        ),
      ),
    );
  }
}

/// Planet summary list below the chart. One row per planet in
/// the chart, in the same order as the planet details table.
/// This list is the text equivalent of the chart figure.
class _PlanetSummaryList extends StatelessWidget {
  const _PlanetSummaryList({required this.planets});

  final List<PlanetDetail> planets;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: planets.map((PlanetDetail planet) {
        final String abbr =
            kPlanetAbbreviations[planet.name] ?? '';
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Row(
            children: <Widget>[
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(
                    AppSpacing.pillRadius,
                  ),
                  border: Border.all(color: AppColors.line2, width: 1),
                ),
                child: Text(
                  abbr,
                  style: AppTextStyles.themed(context, AppTextStyles.chartPlanet),
                ),
              ),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: Text(
                  planet.name,
                  style: AppTextStyles.themed(context, AppTextStyles.listTitle),
                ),
              ),
              Text(
                '${planet.rashi}, ${planet.bhava}',
                style: AppTextStyles.themed(context, AppTextStyles.bodySmall),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Planet details screen: full table with exact degrees,
/// swami notes and the premium note, per
/// design/screens/06-planet-details.md. Shows the computed
/// kundli it is given.
class PlanetDetailsScreen extends StatelessWidget {
  const PlanetDetailsScreen({super.key, required this.kundli});

  final KundliResult kundli;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Planet Details')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: <Widget>[
          Text(
            'Position, rashi, bhava and exact degree of every graha.',
            style: AppTextStyles.themed(context, AppTextStyles.body),
          ),
          const SizedBox(height: AppSpacing.md),
          PlanetDetails(
            planets: kundli.planets,
            lagna: kundli.lagna,
            rashi: kundli.moonRashi,
            nakshatra: kundli.moonNakshatra,
          ),
        ],
      ),
    );
  }
}

/// Daily horoscope screen. Shows the latest published
/// horoscope from the admin panel. When nothing is published
/// yet, or the read fails, it says so honestly instead of
/// showing a sample prediction as if it were real.
class HoroscopeScreen extends StatelessWidget {
  const HoroscopeScreen({super.key, this.firestore});

  final FirestoreService? firestore;

  @override
  Widget build(BuildContext context) {
    if (firestore == null) {
      return const _HoroscopeNotReady();
    }
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: firestore!.watchDocs('horoscopes'),
      builder: (
        BuildContext context,
        AsyncSnapshot<List<Map<String, dynamic>>> snap,
      ) {
        if (snap.hasError) {
          return const _HoroscopeNotReady();
        }
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final List<Map<String, dynamic>> published = snap.data!
            .where((Map<String, dynamic> d) => str(d, 'status') == 'published')
            .toList();
        if (published.isEmpty) {
          return const _HoroscopeNotReady();
        }
        published.sort((Map<String, dynamic> a, Map<String, dynamic> b) =>
            str(b, 'date').compareTo(str(a, 'date')));
        final Map<String, dynamic> doc = published.first;
        return _HoroscopeView(
          entry: HoroscopeEntry(
            rashi: str(doc, 'rashi'),
            date: str(doc, 'date'),
            summary: str(doc, 'summary'),
          ),
          career: str(doc, 'career'),
          money: str(doc, 'money'),
          health: str(doc, 'health'),
          love: str(doc, 'love'),
          luckyNumber: str(doc, 'luckyNumber'),
          luckyColour: str(doc, 'luckyColour'),
          isLive: true,
        );
      },
    );
  }
}

String str(Map<String, dynamic> doc, String key) {
  final Object? value = doc[key];
  return value is String ? value : '';
}

double numVal(Map<String, dynamic> doc, String key) {
  final Object? value = doc[key];
  return value is num ? value.toDouble() : 0;
}

/// "today" or "tomorrow" for the next daily alert at [hhmm],
/// computed from the published schedule, not stored text.
String _nextAlertDay(String hhmm) {
  final DateTime now = DateTime.now();
  final DateTime next =
      NotificationSchedule.nextDailyAlertAfter(now, hhmm);
  return next.day == now.day ? 'today' : 'tomorrow';
}

class _HoroscopeView extends StatelessWidget {
  const _HoroscopeView({
    required this.entry,
    this.career = '',
    this.money = '',
    this.health = '',
    this.love = '',
    this.luckyNumber = '',
    this.luckyColour = '',
    this.isLive = false,
  });

  final HoroscopeEntry entry;
  final String career;
  final String money;
  final String health;
  final String love;
  final String luckyNumber;
  final String luckyColour;
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Horoscope')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: <Widget>[
          Text('Rashi: ${entry.rashi}', style: AppTextStyles.themed(context, AppTextStyles.title)),
          Text(entry.date, style: AppTextStyles.themed(context, AppTextStyles.bodySmall)),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(entry.summary, style: AppTextStyles.themed(context, AppTextStyles.body)),
            ),
          ),
          if (isLive) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            _HoroscopeArea(label: 'Career', value: career),
            _HoroscopeArea(label: 'Money', value: money),
            _HoroscopeArea(label: 'Health', value: health),
            _HoroscopeArea(label: 'Love', value: love),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Lucky Number $luckyNumber  •  Lucky Colour $luckyColour',
              style: AppTextStyles.themed(context, AppTextStyles.bodySmall),
            ),
          ],
        ],
      ),
    );
  }
}

/// Honest state when no horoscope has been published yet.
/// Never a sample prediction presented as real content.
class _HoroscopeNotReady extends StatelessWidget {
  const _HoroscopeNotReady();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Horoscope')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: <Widget>[
          Text(
            'No horoscope published yet.',
            style: AppTextStyles.themed(context, AppTextStyles.title),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'The daily horoscope appears here once it is published from the admin panel. Check back later today.',
            style: AppTextStyles.themed(context, AppTextStyles.body),
          ),
        ],
      ),
    );
  }
}

class _HoroscopeArea extends StatelessWidget {
  const _HoroscopeArea({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTextStyles.themed(
                context,
                AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.themed(context, AppTextStyles.body),
            ),
          ),
        ],
      ),
    );
  }
}

/// Panchang screen: tithi, vaar, nakshatra, yoga, karana,
/// sunrise, sunset, shubh muhurat and rahu kaal, per
/// design/screens/08-panchang.md. The date and the city are
/// real pickers: for the chosen date and city the screen shows
/// the panchang the admin published for that date when one
/// exists, else the values computed by the engine for that
/// date and city. No fixed values anywhere.
class PanchangScreen extends StatefulWidget {
  const PanchangScreen({super.key, this.firestore});

  final FirestoreService? firestore;

  @override
  State<PanchangScreen> createState() => _PanchangScreenState();
}

class _PanchangScreenState extends State<PanchangScreen> {
  DateTime _date = DateTime.now();
  AstroPlace _place = kDefaultPlace;

  String get _dateKey =>
      '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _pickCity() async {
    final AstroPlace? picked = await showDialog<AstroPlace>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('City'),
          children: kIndianCities
              .map(
                (AstroPlace place) => SimpleDialogOption(
                  onPressed: () => Navigator.of(context).pop(place),
                  child: Text(place.name),
                ),
              )
              .toList(),
        );
      },
    );
    if (picked != null) {
      setState(() => _place = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Panchang computed =
        PanchangCalculator.forDate(_date, _place);
    final FirestoreService? firestore = widget.firestore;
    if (firestore == null) {
      return _PanchangBody(
        panchang: computed,
        date: _date,
        onPickDate: _pickDate,
        onPickCity: _pickCity,
      );
    }
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: firestore.watchDocs('panchang'),
      builder: (
        BuildContext context,
        AsyncSnapshot<List<Map<String, dynamic>>> snap,
      ) {
        Panchang shown = computed;
        if (snap.hasData) {
          for (final Map<String, dynamic> doc in snap.data!) {
            if (str(doc, 'date') == _dateKey) {
              shown = _panchangFromDoc(doc);
            }
          }
        }
        return _PanchangBody(
          panchang: shown,
          date: _date,
          onPickDate: _pickDate,
          onPickCity: _pickCity,
        );
      },
    );
  }
}

Panchang _panchangFromDoc(Map<String, dynamic> doc) {
  const List<String> weekdays = <String>[
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];
  final DateTime? date = DateTime.tryParse(str(doc, 'date'));
  final String shubh =
      '${str(doc, 'shubhStart')} to ${str(doc, 'shubhEnd')} and ${str(doc, 'shubh2Start')} to ${str(doc, 'shubh2End')}';
  final String nakshatra = str(doc, 'nakshatraTill').isEmpty
      ? str(doc, 'nakshatra')
      : '${str(doc, 'nakshatra')} till ${str(doc, 'nakshatraTill')}';
  return Panchang(
    weekday: date == null ? '' : weekdays[date.weekday - 1],
    city: str(doc, 'city'),
    tithi: str(doc, 'tithi'),
    vaar: str(doc, 'vaar'),
    nakshatra: nakshatra,
    yoga: str(doc, 'yoga'),
    karana: str(doc, 'karana'),
    sunrise: str(doc, 'sunrise'),
    sunset: str(doc, 'sunset'),
    shubhMuhurat: shubh,
    rahuKaal:
        '${str(doc, 'rahuStart')} to ${str(doc, 'rahuEnd')}. Avoid starting new work in this window.',
  );
}

String _formatLongDate(DateTime date) {
  const List<String> months = <String>[
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

class _PanchangBody extends StatelessWidget {
  const _PanchangBody({
    required this.panchang,
    required this.date,
    required this.onPickDate,
    required this.onPickCity,
  });

  final Panchang panchang;
  final DateTime date;
  final VoidCallback onPickDate;
  final VoidCallback onPickCity;

  @override
  Widget build(BuildContext context) {
    final List<String> muhuratWindows =
        panchang.shubhMuhurat.split(' and ');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panchang'),
        actions: <Widget>[
          TextButton.icon(
            onPressed: onPickDate,
            icon: const Icon(Icons.calendar_today, size: 20),
            label: Text(
              _formatLongDate(date),
              style: AppTextStyles.themed(context, AppTextStyles.body.copyWith(
                color: AppColors.saffron2,
                fontWeight: FontWeight.w600,
              )),
            ),
          ),
          TextButton.icon(
            onPressed: onPickCity,
            icon: const Icon(Icons.keyboard_arrow_down, size: 20),
            label: Text(
              panchang.city,
              style: AppTextStyles.themed(context, AppTextStyles.body.copyWith(
                color: AppColors.saffron2,
                fontWeight: FontWeight.w600,
              )),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: <Widget>[
          Text(
            panchang.dateLine,
            style: AppTextStyles.themed(context, AppTextStyles.body.copyWith(
              color: AppColors.ink2,
            )),
          ),
          const SizedBox(height: AppSpacing.md),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.7,
            children: <Widget>[
              _PanchangCard(label: 'Tithi', value: panchang.tithi),
              _PanchangCard(label: 'Vaar', value: panchang.vaar),
              _PanchangCard(
                label: 'Nakshatra',
                value: panchang.nakshatra,
              ),
              _PanchangCard(label: 'Yoga', value: panchang.yoga),
              _PanchangCard(label: 'Karana', value: panchang.karana),
              _PanchangCard(label: 'Sunrise', value: panchang.sunrise),
              _PanchangCard(label: 'Sunset', value: panchang.sunset),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            color: AppColors.resolve(
              context,
              AppColors.surface2,
              AppColorsDark.surface2,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.space5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Shubh Muhurat',
                    style: AppTextStyles.themed(context, AppTextStyles.caption.copyWith(
                      color: AppColors.saffron2,
                    )),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...muhuratWindows.map(
                    (String window) => Text(
                      window,
                      style: AppTextStyles.themed(context, AppTextStyles.subtitle),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Best for new beginnings.',
                    style: AppTextStyles.themed(context, AppTextStyles.bodySmall),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.space3),
            decoration: BoxDecoration(
              color: AppColors.resolve(
                context,
                AppColors.surface2,
                AppColorsDark.surface2,
              ),
              borderRadius: BorderRadius.circular(
                AppSpacing.smallRadius,
              ),
              border: Border(
                left: BorderSide(
                  color: AppColors.resolve(
                    context,
                    AppColors.maroon,
                    AppColorsDark.maroon,
                  ),
                  width: 3,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Rahu Kaal',
                  style: AppTextStyles.themed(context, AppTextStyles.caption.copyWith(
                    color: AppColors.maroon,
                  )),
                ),
                Text(
                  panchang.rahuKaal,
                  style: AppTextStyles.themed(context, AppTextStyles.bodySmall),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PanchangCard extends StatelessWidget {
  const _PanchangCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(label, style: AppTextStyles.themed(context, AppTextStyles.caption)),
            Text(value, style: AppTextStyles.themed(context, AppTextStyles.listTitle)),
          ],
        ),
      ),
    );
  }
}

/// Kundli matching screen. Both persons enter birth details
/// and the score is calculated from the two real charts by
/// MatchingCalculator: all eight gunas from the Moon rashi
/// and Moon nakshatra, plus Mangal Dosha from the Mars bhava.
/// The first person prefills from the saved profile when one
/// is complete. The full report is premium, gated by the
/// Remote Config flag, so its button says so honestly until
/// premium is on.
class MatchingScreen extends StatefulWidget {
  const MatchingScreen({
    super.key,
    this.firestore,
    this.authService,
    this.premiumService,
  });

  final FirestoreService? firestore;
  final AuthService? authService;

  /// Premium gate. Tests pass their own flag reader.
  final PremiumService? premiumService;

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> {
  final TextEditingController _name1 = TextEditingController();
  final TextEditingController _date1 = TextEditingController();
  final TextEditingController _time1 = TextEditingController();
  final TextEditingController _place1 = TextEditingController();
  final TextEditingController _name2 = TextEditingController();
  final TextEditingController _date2 = TextEditingController();
  final TextEditingController _time2 = TextEditingController();
  final TextEditingController _place2 = TextEditingController();

  MatchingResult? _result;
  String _name1Shown = 'First person';
  String _name2Shown = 'Second person';

  @override
  void initState() {
    super.initState();
    final FirestoreService? firestore = widget.firestore;
    final String? uid = widget.authService?.currentUserId;
    if (firestore != null && uid != null) {
      firestore.getUserProfile(uid).then((Map<String, dynamic>? map) {
        if (!mounted || map == null) {
          return;
        }
        final AppUserProfile profile = AppUserProfile.fromMap(map);
        if (!profile.isComplete) {
          return;
        }
        setState(() {
          _name1.text = profile.name;
          _date1.text =
              AppUserProfile.displayDate(profile.dateOfBirth!);
          _time1.text =
              profile.birthTimeUnknown || profile.timeOfBirth == null
                  ? ''
                  : AppUserProfile.displayTime(profile.timeOfBirth!);
          _place1.text = profile.placeLine;
        });
      });
    }
  }

  @override
  void dispose() {
    _name1.dispose();
    _date1.dispose();
    _time1.dispose();
    _place1.dispose();
    _name2.dispose();
    _date2.dispose();
    _time2.dispose();
    _place2.dispose();
    super.dispose();
  }

  KundliResult? _chartFor({
    required String date,
    required String time,
    required String place,
  }) {
    final DateTime? birth = parseBirthDateTime(
      date,
      time.isEmpty ? '12:00 PM' : time,
    );
    if (birth == null) return null;
    return KundliCalculator.calculate(
      birthLocal: birth,
      placeText: place,
      timeKnown: time.isNotEmpty,
    );
  }

  void _calculate() {
    final String date1 = _date1.text.trim();
    final String place1 = _place1.text.trim();
    final String date2 = _date2.text.trim();
    final String place2 = _place2.text.trim();
    if (date1.isEmpty || place1.isEmpty || date2.isEmpty || place2.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter date and place of birth for both persons.',
          ),
        ),
      );
      return;
    }
    final KundliResult? first = _chartFor(
      date: date1,
      time: _time1.text.trim(),
      place: place1,
    );
    final KundliResult? second = _chartFor(
      date: date2,
      time: _time2.text.trim(),
      place: place2,
    );
    if (first == null || second == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid date and time.'),
        ),
      );
      return;
    }
    setState(() {
      _result = MatchingCalculator.calculate(
        first: first,
        second: second,
      );
      _name1Shown =
          _name1.text.trim().isEmpty ? 'First person' : _name1.text.trim();
      _name2Shown =
          _name2.text.trim().isEmpty ? 'Second person' : _name2.text.trim();
    });
  }

  void _showFullReport() {
    final MatchingResult? result = _result;
    if (result == null) return;
    final bool enabled =
        (widget.premiumService ?? PremiumService()).isPremiumEnabled;
    if (!enabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Full milan report is premium. Premium is not available yet. Pricing to be decided.',
          ),
        ),
      );
      return;
    }
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Full Milan Report'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('$_name1Shown and $_name2Shown'),
                const SizedBox(height: AppSpacing.md),
                ...result.rows.map(
                  (GunaScore row) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Text(
                      '${row.label}: ${gunaScoreText(row)}. ${row.note}',
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Mangal Dosha: $_name1Shown '
                  '${result.mangalFirst ? 'present' : 'none'}, '
                  '$_name2Shown ${result.mangalSecond ? 'present' : 'none'}.',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final MatchingResult? result = _result;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kundli Matching'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              setState(() {
                _name2.clear();
                _date2.clear();
                _time2.clear();
                _place2.clear();
                _result = null;
              });
            },
            child: Text(
              'New match',
              style: AppTextStyles.themed(context, AppTextStyles.body),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: <Widget>[
          Text(
            'Milan for marriage and partnership.',
            style: AppTextStyles.themed(context, AppTextStyles.body),
          ),
          const SizedBox(height: AppSpacing.md),
          _PersonForm(
            label: 'First person',
            name: _name1,
            date: _date1,
            time: _time1,
            place: _place1,
          ),
          const SizedBox(height: AppSpacing.md),
          _PersonForm(
            label: 'Second person',
            name: _name2,
            date: _date2,
            time: _time2,
            place: _place2,
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _calculate,
              child: const Text('Calculate matching'),
            ),
          ),
          if (result != null) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            Card(
              color: AppColors.resolve(
                context,
                AppColors.surface2,
                AppColorsDark.surface2,
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.space5),
                child: Column(
                  children: <Widget>[
                    Text(
                      'Guna Milan Score',
                      style: AppTextStyles.themed(
                        context,
                        AppTextStyles.caption.copyWith(
                          color: AppColors.saffron2,
                        ),
                      ),
                    ),
                    Text(
                      result.totalText,
                      style: AppTextStyles.themed(
                        context,
                        AppTextStyles.title,
                      ),
                    ),
                    Text(
                      result.verdict,
                      style: AppTextStyles.themed(
                        context,
                        AppTextStyles.listTitle.copyWith(
                          color: AppColors.good,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Card(
              child: Column(
                children: result.rows
                    .map(
                      (GunaScore row) => _GunaRow(
                        label: row.label,
                        score: gunaScoreText(row),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Mangal Dosha',
                        style: AppTextStyles.themed(
                          context,
                          AppTextStyles.listTitle,
                        ),
                      ),
                    ),
                    Text(
                      '$_name1Shown: ${result.mangalFirst ? 'Present' : 'None'}',
                      style: AppTextStyles.themed(
                        context,
                        AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                          color: result.mangalFirst
                              ? AppColors.maroon
                              : AppColors.good,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Mangal Dosha',
                        style: AppTextStyles.themed(
                          context,
                          AppTextStyles.listTitle,
                        ),
                      ),
                    ),
                    Text(
                      '$_name2Shown: ${result.mangalSecond ? 'Present' : 'None'}',
                      style: AppTextStyles.themed(
                        context,
                        AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                          color: result.mangalSecond
                              ? AppColors.maroon
                              : AppColors.good,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _showFullReport,
                child: const Text('View Full Milan Report'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PersonForm extends StatelessWidget {
  const _PersonForm({
    required this.label,
    required this.name,
    required this.date,
    required this.time,
    required this.place,
  });

  final String label;
  final TextEditingController name;
  final TextEditingController date;
  final TextEditingController time;
  final TextEditingController place;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              style: AppTextStyles.themed(context, AppTextStyles.subtitle),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: date,
              decoration: const InputDecoration(
                labelText: 'Date of birth',
                hintText: 'Day Month Year',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: time,
              decoration: const InputDecoration(
                labelText: 'Time of birth',
                hintText: 'HH:MM AM or PM',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: place,
              decoration: const InputDecoration(
                labelText: 'Place of birth',
                hintText: 'City, State',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GunaRow extends StatelessWidget {
  const _GunaRow({required this.label, required this.score});

  final String label;
  final String score;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.themed(
                context,
                AppTextStyles.listTitle,
              ),
            ),
          ),
          Text(
            score,
            style: AppTextStyles.themed(
              context,
              AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// Remedies screen. Remedies come from the real kundli:
/// weak planets from computed positions, and the current
/// Mahadasha lord, through RemedyEngine. With no complete
/// profile the screen asks the user to complete it instead
/// of showing a fixed set. Mark as done is a real daily
/// habit check, saved in SharedPreferences for today. The
/// remedies the admin approved still list below.
class RemediesScreen extends StatefulWidget {
  const RemediesScreen({super.key, this.firestore, this.authService});

  final FirestoreService? firestore;
  final AuthService? authService;

  @override
  State<RemediesScreen> createState() => _RemediesScreenState();
}

class _RemediesScreenState extends State<RemediesScreen> {
  List<Remedy>? _remedies;
  bool _loading = true;
  Set<String> _doneToday = <String>{};
  String _doneKey = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _todayKey() {
    final DateTime now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  Future<void> _load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String key = _todayKey();
    final Set<String> done =
        prefs.getStringList('remedy_done_$key')?.toSet() ?? <String>{};
    final FirestoreService? firestore = widget.firestore;
    final String? uid = widget.authService?.currentUserId;
    List<Remedy>? remedies;
    if (firestore != null && uid != null) {
      final Map<String, dynamic>? map = await firestore.getUserProfile(uid);
      if (map != null) {
        final AppUserProfile profile = AppUserProfile.fromMap(map);
        if (profile.isComplete) {
          final DateTime? birth = parseBirthDateTime(
            AppUserProfile.displayDate(profile.dateOfBirth!),
            profile.birthTimeUnknown || profile.timeOfBirth == null
                ? '12:00 PM'
                : AppUserProfile.displayTime(profile.timeOfBirth!),
          );
          if (birth != null) {
            final KundliResult kundli = KundliCalculator.calculate(
              birthLocal: birth,
              placeText: profile.placeLine,
              timeKnown: !profile.birthTimeUnknown,
            );
            remedies = RemedyEngine.derive(
              kundli: kundli,
              birthLocal: birth,
              asOf: DateTime.now(),
            );
          }
        }
      }
    }
    if (!mounted) return;
    setState(() {
      _remedies = remedies;
      _loading = false;
      _doneToday = done;
      _doneKey = key;
    });
  }

  Future<void> _markDone(String title) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Set<String> done = <String>{..._doneToday, title};
    await prefs.setStringList(
      'remedy_done_$_doneKey',
      done.toList(),
    );
    if (!mounted) return;
    setState(() => _doneToday = done);
  }

  void _openConsult() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ConsultScreen(
          firestore: widget.firestore,
          authService: widget.authService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Remedies')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: <Widget>[
          Text(
            'Simple upay chosen from your own kundli.',
            style: AppTextStyles.themed(context, AppTextStyles.body),
          ),
          const SizedBox(height: AppSpacing.md),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_remedies == null)
            Card(
              child: ListTile(
                title: Text(
                  'Complete your profile first',
                  style: AppTextStyles.themed(
                    context,
                    AppTextStyles.subtitle,
                  ),
                ),
                subtitle: Text(
                  'Add your birth details in Profile so remedies can be chosen from your own kundli.',
                  style: AppTextStyles.themed(
                    context,
                    AppTextStyles.bodySmall,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ProfileScreen(
                        firestore: widget.firestore,
                        authService: widget.authService,
                      ),
                    ),
                  );
                },
              ),
            )
          else
            ..._remedies!.map(
              (Remedy remedy) {
                final bool done = _doneToday.contains(remedy.title);
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.space3),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            remedy.title,
                            style: AppTextStyles.themed(
                              context,
                              AppTextStyles.cardTitle,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            remedy.body,
                            style: AppTextStyles.themed(
                              context,
                              AppTextStyles.body,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.space3),
                          if (done)
                            Row(
                              children: <Widget>[
                                Icon(
                                  Icons.check_circle,
                                  color: AppColors.resolve(
                                    context,
                                    AppColors.good,
                                    AppColorsDark.good,
                                  ),
                                  size: 20,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  'Done today',
                                  style: AppTextStyles.themed(
                                    context,
                                    AppTextStyles.body.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.good,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else if (remedy.action == 'done')
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => _markDone(remedy.title),
                                child: const Text('Mark as done'),
                              ),
                            )
                          else
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _openConsult,
                                child: const Text('Ask about this remedy'),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: AppSpacing.lg),
          if (widget.firestore != null) ...<Widget>[
            Text(
              'Approved remedies',
              style: AppTextStyles.themed(context, AppTextStyles.title),
            ),
            const SizedBox(height: AppSpacing.md),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: widget.firestore!.watchDocs('moderation'),
              builder: (
                BuildContext context,
                AsyncSnapshot<List<Map<String, dynamic>>> snap,
              ) {
                if (snap.hasError) {
                  return const Text('Remedies could not be loaded.');
                }
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final List<Map<String, dynamic>> approved = snap.data!
                    .where((Map<String, dynamic> d) =>
                        str(d, 'type') == 'remedy' &&
                        str(d, 'status') == 'approved')
                    .toList();
                if (approved.isEmpty) {
                  return Text(
                    'No approved remedies yet.',
                    style: AppTextStyles.themed(context, AppTextStyles.bodySmall),
                  );
                }
                return Column(
                  children: approved
                      .map(
                        (Map<String, dynamic> doc) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSpacing.space3,
                          ),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    str(doc, 'title'),
                                    style: AppTextStyles.themed(
                                      context,
                                      AppTextStyles.cardTitle,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    str(doc, 'body'),
                                    style: AppTextStyles.themed(
                                      context,
                                      AppTextStyles.body,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _openConsult,
              child: const Text('Ask About a Remedy'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Library screen. Real computed content only, no stored
/// articles and no made up list. Three sections: the users
/// own Vimshottari dasha timeline from the real chart,
/// festival days in the next 30 days computed by the
/// Panchang engine, and a planet reference paired with the
/// users own computed positions when a profile exists.
/// Every row opens real content: a dasha span opens its
/// lords reference, a festival day opens that days full
/// panchang, a planet opens its reference and own position.
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key, this.firestore, this.authService});

  final FirestoreService? firestore;
  final AuthService? authService;

  @override
  Widget build(BuildContext context) {
    final String? uid = authService?.currentUserId;
    final Future<Map<String, dynamic>?>? profileFuture =
        firestore != null && uid != null
            ? firestore!.getUserProfile(uid)
            : null;
    return Scaffold(
      appBar: AppBar(title: const Text('Library')),
      body: profileFuture == null
          ? _LibraryBody(
              profile: null,
              firestore: firestore,
              authService: authService,
            )
          : FutureBuilder<Map<String, dynamic>?>(
              future: profileFuture,
              builder: (
                BuildContext context,
                AsyncSnapshot<Map<String, dynamic>?> snapshot,
              ) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final AppUserProfile? profile = snapshot.data == null
                    ? null
                    : AppUserProfile.fromMap(snapshot.data!);
                return _LibraryBody(
                  profile: profile,
                  firestore: firestore,
                  authService: authService,
                );
              },
            ),
    );
  }
}

class _LibraryBody extends StatelessWidget {
  const _LibraryBody({
    required this.profile,
    required this.firestore,
    required this.authService,
  });

  final AppUserProfile? profile;
  final FirestoreService? firestore;
  final AuthService? authService;

  KundliResult? _kundli() {
    final AppUserProfile? p = profile;
    if (p == null || !p.isComplete) return null;
    final DateTime? birth = parseBirthDateTime(
      AppUserProfile.displayDate(p.dateOfBirth!),
      p.birthTimeUnknown || p.timeOfBirth == null
          ? '12:00 PM'
          : AppUserProfile.displayTime(p.timeOfBirth!),
    );
    if (birth == null) return null;
    return KundliCalculator.calculate(
      birthLocal: birth,
      placeText: p.placeLine,
      timeKnown: !p.birthTimeUnknown,
    );
  }

  DateTime? _birth() {
    final AppUserProfile? p = profile;
    if (p == null || !p.isComplete) return null;
    return parseBirthDateTime(
      AppUserProfile.displayDate(p.dateOfBirth!),
      p.birthTimeUnknown || p.timeOfBirth == null
          ? '12:00 PM'
          : AppUserProfile.displayTime(p.timeOfBirth!),
    );
  }

  Future<void> _showPlanet(
    BuildContext context,
    PlanetReference ref,
    KundliResult? kundli,
  ) async {
    final PlanetDetail? own =
        kundli == null ? null : findPlanet(kundli, ref.name);
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(ref.name),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Signifies ${ref.signifies}.'),
                const SizedBox(height: AppSpacing.sm),
                Text('Rules ${ref.rules}.'),
                Text('Exalted in ${ref.exalted}.'),
                Text('Debilitated in ${ref.debilitated}.'),
                if (own != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'In your chart: ${own.note}',
                    style: AppTextStyles.themed(
                      context,
                      AppTextStyles.body,
                    ),
                  ),
                ] else ...<Widget>[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Add your birth details to see where this planet sits in your chart.',
                    style: AppTextStyles.themed(
                      context,
                      AppTextStyles.bodySmall,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showFestival(
    BuildContext context,
    FestivalDay day,
  ) async {
    final Panchang panchang =
        PanchangCalculator.forDate(day.date, kDefaultPlace);
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${day.observance} ${formatDay(day.date)}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Tithi ${panchang.tithi}.'),
                Text('Nakshatra ${panchang.nakshatra}.'),
                Text('Yoga ${panchang.yoga}.'),
                Text('Karana ${panchang.karana}.'),
                Text('Sunrise ${panchang.sunrise}.'),
                Text('Sunset ${panchang.sunset}.'),
                Text('Shubh muhurat ${panchang.shubhMuhurat}.'),
                Text('Rahu kaal ${panchang.rahuKaal}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final KundliResult? kundli = _kundli();
    final DateTime? birth = _birth();
    final List<DashaInfo> timeline =
        birth == null ? <DashaInfo>[] : vimshottariTimeline(birthLocal: birth);
    final DateTime today = DateTime.now();
    final DateTime todayDay = DateTime(today.year, today.month, today.day);
    final List<FestivalDay> festivals =
        festivalDays(from: todayDay);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: <Widget>[
        Text(
          'Your dasha timeline',
          style: AppTextStyles.themed(context, AppTextStyles.title),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (timeline.isEmpty)
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.person_add,
                color: AppColors.deepSaffron,
                size: 32,
              ),
              title: Text(
                'Complete your profile',
                style: AppTextStyles.themed(
                  context,
                  AppTextStyles.subtitle,
                ),
              ),
              subtitle: Text(
                'Add your birth details to see your dasha timeline.',
                style: AppTextStyles.themed(
                  context,
                  AppTextStyles.bodySmall,
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => KundliInputScreen(
                      firestore: firestore,
                      authService: authService,
                    ),
                  ),
                );
              },
            ),
          )
        else
          ...timeline.map((DashaInfo span) {
            final bool current = !todayDay.isBefore(span.start) &&
                !todayDay.isAfter(span.end);
            final PlanetReference ref = kPlanetReference.firstWhere(
              (PlanetReference r) => r.name == span.lord,
            );
            return Card(
              child: ListTile(
                leading: Icon(
                  Icons.circle,
                  color: current
                      ? AppColors.deepSaffron
                      : AppColors.ink2,
                  size: 16,
                ),
                title: Text(
                  '${span.lord} Mahadasha',
                  style: AppTextStyles.themed(
                    context,
                    AppTextStyles.subtitle,
                  ),
                ),
                subtitle: Text(
                  '${formatDay(span.start)} to ${formatDay(span.end)}',
                  style: AppTextStyles.themed(
                    context,
                    AppTextStyles.bodySmall,
                  ),
                ),
                trailing: current
                    ? const Text('Current')
                    : const Icon(Icons.chevron_right),
                onTap: () => _showPlanet(context, ref, kundli),
              ),
            );
          }),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Festivals in the next 30 days',
          style: AppTextStyles.themed(context, AppTextStyles.title),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (festivals.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Text('No festival day in the next 30 days.'),
            ),
          )
        else
          ...festivals.map(
            (FestivalDay day) => Card(
              child: ListTile(
                leading: const Icon(
                  Icons.celebration,
                  color: AppColors.deepSaffron,
                  size: 32,
                ),
                title: Text(
                  day.observance,
                  style: AppTextStyles.themed(
                    context,
                    AppTextStyles.subtitle,
                  ),
                ),
                subtitle: Text(
                  '${formatDay(day.date)} ${day.tithi}',
                  style: AppTextStyles.themed(
                    context,
                    AppTextStyles.bodySmall,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showFestival(context, day),
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Planets',
          style: AppTextStyles.themed(context, AppTextStyles.title),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...kPlanetReference.map(
          (PlanetReference ref) => Card(
            child: ListTile(
              leading: const Icon(
                Icons.public,
                color: AppColors.deepSaffron,
                size: 32,
              ),
              title: Text(
                ref.name,
                style: AppTextStyles.themed(
                  context,
                  AppTextStyles.subtitle,
                ),
              ),
              subtitle: Text(
                'Rules ${ref.rules}. Exalted in ${ref.exalted}.',
                style: AppTextStyles.themed(
                  context,
                  AppTextStyles.bodySmall,
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showPlanet(context, ref, kundli),
            ),
          ),
        ),
      ],
    );
  }
}

/// Consult screen. Lists the astrologers the admin
/// approved, in real time, with a real chat and a real call
/// path for each one. Chat opens a Firestore backed room
/// that stores and reads messages. Call dials the phone
/// number the admin saved for that astrologer, and says so
/// plainly when none is saved. No astrologer is on the other
/// side yet: the general chat room stores the user messages
/// and the admin app reads and replies there, but no
/// astrologer name, photo or reply is invented.
class ConsultScreen extends StatelessWidget {
  const ConsultScreen({
    super.key,
    this.firestore,
    this.authService,
    this.chatService,
  });

  final FirestoreService? firestore;
  final AuthService? authService;
  final ChatService? chatService;

  ChatService get _chat =>
      chatService ?? ChatService(firestore: firestore);

  void _openGeneralChat(BuildContext context) {
    final String? uid = authService?.currentUserId;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in to chat.')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatScreen(
          chatId: ChatService.userChatId(uid),
          title: 'Chat with the astrologer',
          currentUserId: uid,
          senderRole: 'user',
          firestore: firestore,
          chatService: _chat,
        ),
      ),
    );
  }

  void _openAstrologerChat(
    BuildContext context,
    Map<String, dynamic> doc,
  ) {
    final String? uid = authService?.currentUserId;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in to chat.')),
      );
      return;
    }
    final String astrologerId = str(doc, 'id');
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatScreen(
          chatId: ChatService.astrologerChatId(astrologerId, uid),
          title: str(doc, 'name'),
          currentUserId: uid,
          senderRole: 'user',
          participantIds: <String>[uid, astrologerId],
          firestore: firestore,
          chatService: _chat,
        ),
      ),
    );
  }

  Future<void> _callAstrologer(
    BuildContext context,
    Map<String, dynamic> doc,
  ) async {
    final String phone = str(doc, 'phone').trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No phone number yet for this astrologer.',
          ),
        ),
      );
      return;
    }
    final bool opened = await launchUrl(
      Uri(scheme: 'tel', path: phone),
    );
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open the dialer.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Consult')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: <Widget>[
          Text(
            'Chat and call with an astrologer.',
            style: AppTextStyles.themed(context, AppTextStyles.body),
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: ListTile(
              leading: const Icon(Icons.chat, color: AppColors.deepSaffron),
              title: Text(
                'Chat with the astrologer',
                style: AppTextStyles.themed(context, AppTextStyles.subtitle),
              ),
              subtitle: Text(
                'Messages are saved. No astrologer has joined yet.',
                style: AppTextStyles.themed(
                  context,
                  AppTextStyles.bodySmall,
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openGeneralChat(context),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (firestore == null)
            Text(
              'No astrologers yet. Astrologers appear here once the admin adds and approves them.',
              style: AppTextStyles.themed(context, AppTextStyles.bodySmall),
            )
          else
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: firestore!.watchDocs('astrologers'),
              builder: (
                BuildContext context,
                AsyncSnapshot<List<Map<String, dynamic>>> snap,
              ) {
                if (snap.hasError) {
                  return Text(
                    'Astrologers could not be loaded.',
                    style: AppTextStyles.themed(context, AppTextStyles.body),
                  );
                }
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final List<Map<String, dynamic>> approved = snap.data!
                    .where((Map<String, dynamic> d) =>
                        str(d, 'status') == 'approved')
                    .toList();
                if (approved.isEmpty) {
                  return Text(
                    'No astrologers yet. Astrologers appear here once the admin adds and approves them.',
                    style:
                        AppTextStyles.themed(context, AppTextStyles.bodySmall),
                  );
                }
                return Column(
                  children: approved
                      .map(
                        (Map<String, dynamic> doc) => Card(
                          child: ListTile(
                            leading: const Icon(
                              Icons.person,
                              color: AppColors.deepSaffron,
                            ),
                            title: Text(
                              str(doc, 'name'),
                              style: AppTextStyles.themed(
                                context,
                                AppTextStyles.subtitle,
                              ),
                            ),
                            subtitle: Text(
                              str(doc, 'languages'),
                              style: AppTextStyles.themed(
                                context,
                                AppTextStyles.bodySmall,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                if (doc['chatAvailable'] == true)
                                  IconButton(
                                    icon: const Icon(Icons.chat),
                                    onPressed: () =>
                                        _openAstrologerChat(context, doc),
                                  ),
                                if (doc['callAvailable'] == true)
                                  IconButton(
                                    icon: const Icon(Icons.call),
                                    onPressed: () =>
                                        _callAstrologer(context, doc),
                                  ),
                              ],
                            ),
                            onTap: () => _openAstrologerChat(context, doc),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
        ],
      ),
    );
  }
}

/// Real chat room over Firestore. Messages stream live,
/// oldest first. Sending stores the message with the sender
/// id, the sender role and a server timestamp, and keeps the
/// chat document current. The empty state names the honest
/// boundary: no astrologer has joined yet.
class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.chatId,
    required this.title,
    required this.currentUserId,
    required this.senderRole,
    this.participantIds,
    this.firestore,
    this.chatService,
  });

  final String chatId;
  final String title;
  final String currentUserId;
  final String senderRole;
  final List<String>? participantIds;
  final FirestoreService? firestore;
  final ChatService? chatService;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  ChatService get _chat =>
      widget.chatService ?? ChatService(firestore: widget.firestore);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final String text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    await _chat.sendMessage(
      chatId: widget.chatId,
      senderId: widget.currentUserId,
      senderRole: widget.senderRole,
      text: text,
      participantIds:
          widget.participantIds ?? <String>[widget.currentUserId],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = widget.senderRole == 'admin';
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _chat.watchMessages(widget.chatId),
              builder: (
                BuildContext context,
                AsyncSnapshot<List<ChatMessage>> snap,
              ) {
                if (snap.hasError) {
                  return const Center(
                    child: Text('Messages could not be loaded.'),
                  );
                }
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final List<ChatMessage> messages = snap.data!;
                if (messages.isEmpty) {
                  return Center(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(AppSpacing.screenPadding),
                      child: Text(
                        isAdmin
                            ? 'No messages yet.'
                            : 'No astrologer has joined yet. Your messages are saved here and the astrologer will reply once added.',
                        style: AppTextStyles.themed(
                          context,
                          AppTextStyles.body,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding:
                      const EdgeInsets.all(AppSpacing.screenPadding),
                  itemCount: messages.length,
                  itemBuilder: (BuildContext context, int index) {
                    final ChatMessage message = messages[index];
                    final bool mine =
                        message.senderId == widget.currentUserId;
                    return Align(
                      alignment: mine
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(
                          bottom: AppSpacing.sm,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: mine
                              ? AppColors.saffron
                              : AppColors.resolve(
                                  context,
                                  AppColors.surface2,
                                  AppColorsDark.surface2,
                                ),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.smallRadius,
                          ),
                        ),
                        child: Text(
                          message.text,
                          style: AppTextStyles.themed(
                            context,
                            AppTextStyles.body,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _send,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Profile screen. Loads the saved profile from the user
/// document and shows every field it holds: name, gender,
/// birth details, place of birth, marital status, occupation,
/// phone, language and the daily horoscope alert time. With no
/// profile yet it asks the user to complete one instead of
/// showing a made up name. Free and premium plan. Pricing to
/// be decided. With a Firestore service, it shows the active
/// plan the admin set, instead of assuming the free plan.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.firestore, this.authService});

  final FirestoreService? firestore;
  final AuthService? authService;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<Map<String, dynamic>?>? _profileFuture;

  AuthService get _auth => widget.authService ?? AuthService();
  FirestoreService? get _firestore => widget.firestore;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final String? uid = _auth.currentUserId;
    final FirestoreService? firestore = _firestore;
    setState(() {
      _profileFuture = firestore != null && uid != null
          ? firestore.getUserProfile(uid)
          : Future<Map<String, dynamic>?>.value(null);
    });
  }

  Future<void> _openForm(AppUserProfile? existing) async {
    final bool? saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => ProfileFormScreen(
          authService: _auth,
          firestoreService: _firestore,
          existing: existing,
        ),
      ),
    );
    if (saved == true && mounted) {
      _loadProfile();
    }
  }

  String _initials(String name) {
    final List<String> parts =
        name.trim().split(RegExp(r'\s+')).where((String p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: AppTextStyles.themed(context, AppTextStyles.bodySmall),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.themed(context, AppTextStyles.body),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? email = _auth.currentUserEmail;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: <Widget>[
          FutureBuilder<Map<String, dynamic>?>(
            future: _profileFuture,
            builder: (
              BuildContext context,
              AsyncSnapshot<Map<String, dynamic>?> snapshot,
            ) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 120,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final AppUserProfile? profile = snapshot.data == null
                  ? null
                  : AppUserProfile.fromMap(snapshot.data!);
              final String name =
                  profile != null && profile.name.isNotEmpty
                      ? profile.name
                      : 'Your profile';
              final String alertTime =
                  profile?.horoscopeAlertTime != null
                      ? AppUserProfile.displayTime(profile!.horoscopeAlertTime!)
                      : '06:00 AM';
              return Column(
                children: <Widget>[
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.saffron,
                    child: Text(
                      _initials(name),
                      style: AppTextStyles.themed(
                        context,
                        AppTextStyles.title,
                      ).copyWith(color: Colors.white, fontSize: 28),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    name,
                    style: AppTextStyles.themed(
                      context,
                      AppTextStyles.title,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (email != null)
                    Text(
                      email,
                      style: AppTextStyles.themed(
                        context,
                        AppTextStyles.bodySmall,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  if (profile != null && profile.birthLine.isNotEmpty)
                    Text(
                      'Birth ${profile.birthLine}',
                      style: AppTextStyles.themed(
                        context,
                        AppTextStyles.bodySmall,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: AppSpacing.md),
                  if (profile == null || !profile.isComplete)
                    Card(
                      child: ListTile(
                        title: Text(
                          'Complete your profile',
                          style: AppTextStyles.themed(
                            context,
                            AppTextStyles.subtitle,
                          ),
                        ),
                        subtitle: Text(
                          'Add your birth details so your kundli and horoscope use your real details.',
                          style: AppTextStyles.themed(
                            context,
                            AppTextStyles.bodySmall,
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _openForm(profile),
                      ),
                    )
                  else
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            if (profile.gender != null)
                              _detailRow('Gender', profile.gender!),
                            if (profile.dateOfBirth != null)
                              _detailRow(
                                'Date of birth',
                                AppUserProfile.displayDate(profile.dateOfBirth!),
                              ),
                            _detailRow(
                              'Time of birth',
                              profile.birthTimeUnknown
                                  ? 'Not known'
                                  : profile.timeOfBirth == null
                                      ? 'Not set'
                                      : AppUserProfile.displayTime(
                                          profile.timeOfBirth!,
                                        ),
                            ),
                            if (profile.placeLine.isNotEmpty)
                              _detailRow('Place of birth', profile.placeLine),
                            if (profile.maritalStatus != null)
                              _detailRow(
                                'Marital status',
                                profile.maritalStatus!,
                              ),
                            if (profile.occupation != null)
                              _detailRow('Occupation', profile.occupation!),
                            if (profile.phoneNumber != null)
                              _detailRow('Phone', profile.phoneNumber!),
                            if (profile.language != null)
                              _detailRow('Language', profile.language!),
                            _detailRow(
                              'Horoscope alert',
                              'Daily at $alertTime',
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () => _openForm(profile),
                                child: const Text('Edit profile'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.md),
                  Card(
                    child: ListTile(
                      title: Text(
                        'Notifications',
                        style: AppTextStyles.themed(
                          context,
                          AppTextStyles.subtitle,
                        ),
                      ),
                      subtitle: Text(
                        'Daily horoscope alert at $alertTime. '
                        'Next alert ${_nextAlertDay(profile?.horoscopeAlertTime ?? '06:00')}.',
                        style: AppTextStyles.themed(
                          context,
                          AppTextStyles.bodySmall,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      // Asks for permission again from here when the
                      // user wants alerts, with the reason on this
                      // screen, not at app open.
                      onTap: () async {
                        await FirebaseService
                            .requestNotificationPermission();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'If you allow, daily horoscope alerts will arrive at $alertTime.',
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              );
            },
          ),
          Card(
            child: ListTile(
              title: Text('Plan', style: AppTextStyles.themed(context, AppTextStyles.subtitle)),
              subtitle: _firestore == null
                  ? Text(
                      'Free plan. Premium pricing to be decided.',
                      style: AppTextStyles.themed(
                          context, AppTextStyles.bodySmall),
                    )
                  : StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _firestore!.watchDocs('plans'),
                      builder: (
                        BuildContext context,
                        AsyncSnapshot<List<Map<String, dynamic>>> snap,
                      ) {
                        if (snap.hasError || !snap.hasData) {
                          return Text(
                            'Plan could not be loaded.',
                            style: AppTextStyles.themed(
                                context, AppTextStyles.bodySmall),
                          );
                        }
                        final List<Map<String, dynamic>> active = snap.data!
                            .where((Map<String, dynamic> d) =>
                                str(d, 'status') == 'active')
                            .toList();
                        if (active.isEmpty) {
                          return Text(
                            'Free plan. Premium pricing to be decided.',
                            style: AppTextStyles.themed(
                                context, AppTextStyles.bodySmall),
                          );
                        }
                        final Map<String, dynamic> plan = active.first;
                        return Text(
                          '${str(plan, 'name')} plan',
                          style: AppTextStyles.themed(
                              context, AppTextStyles.bodySmall),
                        );
                      },
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton(
            // Profile only opens signed in, so this is sign out.
            // The auth gate takes the app back to sign in.
            onPressed: () async {
              await _auth.signOut();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

/// Notifications inbox. Shows the notifications the admin sent
/// or scheduled, in real time. Tapping one opens the screen the
/// admin chose for it.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({
    super.key,
    required this.firestore,
    this.authService,
  });

  final FirestoreService firestore;
  final AuthService? authService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: firestore.watchDocs('notifications'),
        builder: (
          BuildContext context,
          AsyncSnapshot<List<Map<String, dynamic>>> snap,
        ) {
          if (snap.hasError) {
            return const Center(
              child: Text('Notifications could not be loaded.'),
            );
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final List<Map<String, dynamic>> visible = snap.data!
              .where((Map<String, dynamic> d) =>
                  str(d, 'status') == 'sent' ||
                  str(d, 'status') == 'scheduled')
              .toList();
          if (visible.isEmpty) {
            return const Center(
              child: Text('No notifications yet.'),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: visible
                .map(
                  (Map<String, dynamic> doc) => Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.notifications,
                        color: AppColors.deepSaffron,
                      ),
                      title: Text(
                        str(doc, 'title'),
                        style: AppTextStyles.themed(
                          context,
                          AppTextStyles.subtitle,
                        ),
                      ),
                      subtitle: Text(
                        '${str(doc, 'message')}\n${str(doc, 'audience')}  •  ${str(doc, 'type')}',
                        style: AppTextStyles.themed(
                          context,
                          AppTextStyles.bodySmall,
                        ),
                      ),
                      isThreeLine: true,
                      onTap: () {
                        final String open = str(doc, 'openScreen');
                        final Widget? target = open == 'Daily Horoscope'
                            ? HoroscopeScreen(firestore: firestore)
                            : open == 'Panchang'
                                ? PanchangScreen(firestore: firestore)
                                : open == 'Consult'
                                    ? ConsultScreen(
                                        firestore: firestore,
                                        authService: authService,
                                      )
                                    : null;
                        if (target != null) {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => target,
                            ),
                          );
                        } else if (open == 'Home') {
                          Navigator.of(context).popUntil(
                            (Route<dynamic> route) => route.isFirst,
                          );
                        }
                      },
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}
