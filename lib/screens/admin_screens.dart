import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:material_ui/material_ui.dart';

import '../core/build_info.dart';
import '../core/theme/design_tokens.dart';
import 'auth_screen.dart';
import 'screens.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/user_profile.dart';

/// Admin app for Dharm Guru Shrinkhala. Same Firebase project as
/// the user app, same auth system, owner only. Admin screens are
/// per design/screens/16 to 22. Every value comes from Firestore;
/// nothing is invented, and empty collections show honest empty
/// states instead of sample numbers.
const List<String> kRashis = <String>[
  'Mesha',
  'Vrishabha',
  'Mithuna',
  'Karka',
  'Simha',
  'Kanya',
  'Tula',
  'Vrishchika',
  'Dhanu',
  'Makara',
  'Kumbha',
  'Meena',
];

const List<String> _months = <String>[
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String dateKey(DateTime day) {
  final String m = day.month.toString().padLeft(2, '0');
  final String d = day.day.toString().padLeft(2, '0');
  return '${day.year}-$m-$d';
}

String formatDay(DateTime day) =>
    '${day.day} ${_months[day.month - 1]} ${day.year}';

String formatStamp(Object? value) {
  if (value is Timestamp) {
    final DateTime at = value.toDate();
    final String hh = at.hour.toString().padLeft(2, '0');
    final String mm = at.minute.toString().padLeft(2, '0');
    return '${formatDay(at)}, $hh:$mm';
  }
  if (value is String && value.isNotEmpty) return value;
  return '';
}

String str(Map<String, dynamic> doc, String key) {
  final Object? value = doc[key];
  return value is String ? value : '';
}

double numVal(Map<String, dynamic> doc, String key) {
  final Object? value = doc[key];
  return value is num ? value.toDouble() : 0;
}

DateTime? docDay(Map<String, dynamic> doc) {
  final Object? created = doc['createdAt'];
  if (created is Timestamp) return created.toDate();
  final String date = str(doc, 'date');
  if (date.length == 10) return DateTime.tryParse(date);
  return null;
}

bool inRange(DateTime? day, String range) {
  if (day == null) return false;
  final DateTime now = DateTime.now();
  final DateTime start = DateTime(now.year, now.month, now.day);
  if (range == 'Today') {
    return day.year == start.year &&
        day.month == start.month &&
        day.day == start.day;
  }
  final int days = range == '7 days' ? 7 : 30;
  return day.isAfter(start.subtract(Duration(days: days - 1)));
}

/// Root widget for the admin entrypoint. Firebase is initialised
/// by main_admin before this runs. Shows the same animated
/// splash as the user app, then the auth gate. Signed out users
/// see only the sign in screen. Signed in users who are not the
/// owner see the denied screen, never the admin screens. Set
/// showSplash false in tests to skip the splash screen.
class DharmGuruAdminApp extends StatefulWidget {
  const DharmGuruAdminApp({
    super.key,
    this.firebaseReady = true,
    this.firebaseError,
    this.showSplash = true,
    this.authService,
    this.firestoreService,
    this.featureFlags,
  });

  final bool firebaseReady;

  /// The init error text, shown on the setup screen when Firebase
  /// failed to initialise, so the phone names the failing call.
  final String? firebaseError;
  final bool showSplash;
  final AuthService? authService;
  final FirestoreService? firestoreService;

  /// Remote Config flags. Production reads them live; tests pass
  /// them in so the widget never touches Firebase.
  final Map<String, bool>? featureFlags;

  @override
  State<DharmGuruAdminApp> createState() => _DharmGuruAdminAppState();
}

class _DharmGuruAdminAppState extends State<DharmGuruAdminApp> {
  bool _splashDone = false;
  late final AuthService _auth = widget.authService ?? AuthService();
  late final FirestoreService _firestore =
      widget.firestoreService ?? FirestoreService();

  @override
  void initState() {
    super.initState();
    _splashDone = !widget.showSplash;
  }

  /// Admin gate. A Google account that signs in to the admin app
  /// gets its owner record created first, so whoever creates an
  /// account once through Google in the admin app can use admin
  /// access. The default admin account passes through the
  /// seeded email check in isAdminUser. Everyone else needs an
  /// admins document with role owner.
  Future<bool> _checkAdminAccess(String uid) async {
    final String? email = _auth.currentUserEmail;
    if (_auth.currentUserHasGoogleProvider) {
      try {
        await _firestore.ensureAdminDoc(uid, email ?? '');
      } catch (_) {
        // A failed write must not lock the owner out: the gate
        // below still checks the document and the seeded email.
      }
    }
    return _firestore.isAdminUser(uid: uid, email: email);
  }

  MaterialApp _app({required Widget home}) {
    return MaterialApp(
      title: 'Dharm Guru Admin',
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
          caption: 'Admin',
          onDone: () => setState(() => _splashDone = true),
        ),
      );
    }
    return StreamBuilder<bool>(
      stream: _auth.signedIn,
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
        final String? uid = _auth.currentUserId;
        if (uid == null) {
          return _app(home: AuthScreen(authService: _auth));
        }
        return FutureBuilder<bool>(
          future: _checkAdminAccess(uid),
          builder: (BuildContext context, AsyncSnapshot<bool> adminSnap) {
            if (!adminSnap.hasData) {
              return _app(
                home: const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                ),
              );
            }
            if (adminSnap.data != true) {
              return _app(
                home: _AdminDeniedScreen(
                  email: _auth.currentUserEmail ?? '',
                  onSignOut: () => _auth.signOut(),
                ),
              );
            }
            return _app(
              home: AdminShell(
                firestore: _firestore,
                auth: _auth,
                featureFlags: widget.featureFlags,
              ),
            );
          },
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
      appBar: AppBar(title: const Text('Dharm Guru Admin')),
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

class _AdminDeniedScreen extends StatelessWidget {
  const _AdminDeniedScreen({required this.email, required this.onSignOut});

  final String email;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dharm Guru Admin')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'You do not have admin access.',
              style: AppTextStyles.themed(context, AppTextStyles.title),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Signed in as $email. Only the owner can open the admin panel. '
              'The owner enables admin access by creating an admins record '
              'for this account in the Firebase console. See FIREBASE-SETUP.md.',
              style: AppTextStyles.themed(context, AppTextStyles.body),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: onSignOut,
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shared admin bits: status pill, stat card, empty and error states.
class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.themed(
          context,
          AppTextStyles.caption.copyWith(color: color),
        ),
      ),
    );
  }
}

Color _statusColor(String status) {
  return switch (status) {
    'Online' || 'Published' || 'Active' || 'Paid' || 'Sent' || 'Approved' =>
      AppColors.good,
    'Waiting approval' || 'Draft' || 'Pending' || 'Scheduled' ||
    'Escalated' =>
      AppColors.saffron2,
    'Failed' || 'Removed' => AppColors.maroon,
    _ => AppColors.ink3,
  };
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

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
              style: AppTextStyles.themed(context, AppTextStyles.caption),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: AppTextStyles.themed(context, AppTextStyles.title),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: <Widget>[
          const Icon(Icons.wb_sunny, size: 48, color: AppColors.saffron),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: AppTextStyles.themed(context, AppTextStyles.title)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            body,
            style: AppTextStyles.themed(context, AppTextStyles.body),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: <Widget>[
          Text(message, style: AppTextStyles.themed(context, AppTextStyles.body)),
          TextButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}

Widget _adminField({
  required String label,
  required TextEditingController controller,
  int maxLines = 1,
  String? hint,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.md),
    child: TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
    ),
  );
}

Future<bool> _confirm(
  BuildContext context,
  String title,
  String body,
  String action,
) async {
  final bool? result = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(action),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

void _toast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

/// Admin shell: left rail on wide screens, drawer on narrow ones.
/// Destinations in the fixed spec order.
class AdminShell extends StatefulWidget {
  const AdminShell({
    super.key,
    required this.firestore,
    required this.auth,
    this.featureFlags,
  });

  final FirestoreService firestore;
  final AuthService auth;
  final Map<String, bool>? featureFlags;

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  static const List<String> _labels = <String>[
    'Dashboard',
    'Astrologers',
    'Daily Content',
    'Subscriptions',
    'Analytics',
    'Notifications',
    'Moderation',
    'Account',
  ];

  static const List<IconData> _icons = <IconData>[
    Icons.dashboard,
    Icons.person,
    Icons.wb_sunny,
    Icons.card_membership,
    Icons.bar_chart,
    Icons.notifications,
    Icons.shield,
    Icons.manage_accounts,
  ];

  void _go(int index) {
    setState(() => _index = index);
  }

  Widget _screen(int index) {
    return switch (index) {
      0 => AdminDashboardScreen(
          firestore: widget.firestore,
          featureFlags: widget.featureFlags,
          onNavigate: _go,
        ),
      1 => AstrologersScreen(firestore: widget.firestore),
      2 => DailyContentScreen(firestore: widget.firestore),
      3 => SubscriptionsScreen(firestore: widget.firestore),
      4 => AnalyticsScreen(firestore: widget.firestore),
      5 => NotificationsScreenAdmin(firestore: widget.firestore),
      6 => ModerationScreen(firestore: widget.firestore),
      _ => AdminAccountScreen(
          firestore: widget.firestore,
          auth: widget.auth,
        ),
    };
  }

  Widget _rail() {
    return Container(
      width: 240,
      color: AppColors.resolve(
        context,
        AppColors.surface2,
        AppColorsDark.surface2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              'Dharm Guru',
              style: AppTextStyles.themed(
                context,
                AppTextStyles.title.copyWith(fontFamily: 'Georgia'),
              ),
            ),
          ),
          ...List<Widget>.generate(_labels.length, (int i) {
            final bool active = i == _index;
            return ListTile(
              leading: Icon(
                _icons[i],
                color: active ? AppColors.saffron2 : AppColors.ink2,
              ),
              title: Text(
                _labels[i],
                style: AppTextStyles.themed(
                  context,
                  AppTextStyles.body.copyWith(
                    color: active ? AppColors.saffron2 : AppColors.ink2,
                    fontWeight:
                        active ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
              selected: active,
              onTap: () => _go(i),
            );
          }),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Admin',
                  style: AppTextStyles.themed(
                    context,
                    AppTextStyles.caption,
                  ),
                ),
                TextButton(
                  onPressed: () => widget.auth.signOut(),
                  child: const Text('Sign out'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth >= 900) {
          return Scaffold(
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _rail(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: _screen(_index),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(title: Text(_labels[_index])),
          drawer: Drawer(
            child: ListView(
              children: <Widget>[
                DrawerHeader(
                  child: Text(
                    'Dharm Guru',
                    style: AppTextStyles.themed(
                      context,
                      AppTextStyles.title,
                    ),
                  ),
                ),
                ...List<Widget>.generate(_labels.length, (int i) {
                  return ListTile(
                    leading: Icon(_icons[i]),
                    title: Text(_labels[i]),
                    selected: i == _index,
                    onTap: () {
                      Navigator.of(context).pop();
                      _go(i);
                    },
                  );
                }),
                ListTile(
                  title: const Text('Sign out'),
                  onTap: () => widget.auth.signOut(),
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: _screen(_index),
          ),
        );
      },
    );
  }
}

/// Dashboard, design 16. Live counts only, no sample numbers.
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({
    super.key,
    required this.firestore,
    required this.featureFlags,
    required this.onNavigate,
  });

  final FirestoreService firestore;
  final Map<String, bool>? featureFlags;
  final void Function(int index) onNavigate;

  Map<String, bool> _flags() {
    if (featureFlags != null) return featureFlags!;
    try {
      final FirebaseRemoteConfig config = FirebaseRemoteConfig.instance;
      return <String, bool>{
        'premium_enabled': config.getBool('premium_enabled'),
        'live_consult_enabled': config.getBool('live_consult_enabled'),
      };
    } catch (_) {
      return <String, bool>{
        'premium_enabled': false,
        'live_consult_enabled': false,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, bool> flags = _flags();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Dashboard', style: AppTextStyles.themed(context, AppTextStyles.display)),
        Text(
          'Today',
          style: AppTextStyles.themed(context, AppTextStyles.bodySmall),
        ),
        const SizedBox(height: AppSpacing.md),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final int cols = constraints.maxWidth > 700 ? 4 : 2;
            final List<Widget> cards = <Widget>[
              _CountStat(
                label: 'Users',
                stream: firestore.watchDocs('users'),
              ),
              _CountStat(
                label: 'Astrologers',
                stream: firestore.watchDocs('astrologers'),
              ),
              _CountStat(
                label: 'Published horoscopes',
                stream: firestore.watchDocs('horoscopes'),
                count: (List<Map<String, dynamic>> docs) => docs
                    .where((Map<String, dynamic> d) =>
                        str(d, 'status') == 'published')
                    .length,
              ),
              _EarningsStat(firestore: firestore),
            ];
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                mainAxisExtent: 150,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cards.length,
              itemBuilder: (BuildContext context, int index) =>
                  cards[index],
            );
          },
        ),
        const SizedBox(height: AppSpacing.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Needs attention',
                  style: AppTextStyles.themed(context, AppTextStyles.subtitle),
                ),
                const SizedBox(height: AppSpacing.sm),
                _AttentionRow(
                  label: 'Astrologers waiting for approval',
                  stream: firestore.watchDocs('astrologers'),
                  count: (List<Map<String, dynamic>> docs) => docs
                      .where((Map<String, dynamic> d) =>
                          str(d, 'status') == 'waiting')
                      .length,
                  onTap: () => onNavigate(1),
                ),
                _AttentionRow(
                  label: 'Horoscopes still drafts today',
                  stream: firestore.watchDocs('horoscopes'),
                  count: (List<Map<String, dynamic>> docs) => docs
                      .where((Map<String, dynamic> d) =>
                          str(d, 'date') == dateKey(DateTime.now()) &&
                          str(d, 'status') == 'draft')
                      .length,
                  onTap: () => onNavigate(2),
                ),
                _AttentionRow(
                  label: 'Moderation items waiting',
                  stream: firestore.watchDocs('moderation'),
                  count: (List<Map<String, dynamic>> docs) => docs
                      .where((Map<String, dynamic> d) =>
                          str(d, 'status') == 'pending')
                      .length,
                  onTap: () => onNavigate(6),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: <Widget>[
            OutlinedButton(
              onPressed: () => onNavigate(2),
              child: const Text('Publish todays horoscope'),
            ),
            OutlinedButton(
              onPressed: () => onNavigate(1),
              child: const Text('Add astrologer'),
            ),
            OutlinedButton(
              onPressed: () => onNavigate(5),
              child: const Text('Send notification'),
            ),
            OutlinedButton(
              onPressed: () => onNavigate(6),
              child: const Text('Review reports'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Feature control',
                  style: AppTextStyles.themed(context, AppTextStyles.subtitle),
                ),
                Text(
                  'Turn features on or off with Remote Config without shipping an app update. Change the values in the Firebase console.',
                  style: AppTextStyles.themed(context, AppTextStyles.bodySmall),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...flags.entries.map(
                  (MapEntry<String, bool> flag) => Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          flag.key,
                          style: AppTextStyles.themed(
                            context,
                            AppTextStyles.body,
                          ),
                        ),
                      ),
                      Text(
                        flag.value ? 'On' : 'Off',
                        style: AppTextStyles.themed(
                          context,
                          AppTextStyles.body,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CountStat extends StatelessWidget {
  const _CountStat({
    required this.label,
    required this.stream,
    this.count,
  });

  final String label;
  final Stream<List<Map<String, dynamic>>> stream;
  final int Function(List<Map<String, dynamic>> docs)? count;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: stream,
      builder: (
        BuildContext context,
        AsyncSnapshot<List<Map<String, dynamic>>> snap,
      ) {
        if (snap.hasError) {
          return const _StatCard(label: '', value: 'Could not load.');
        }
        if (!snap.hasData) {
          return _StatCard(label: label, value: 'Loading');
        }
        final List<Map<String, dynamic>> docs = snap.data!;
        if (docs.isEmpty) {
          return _StatCard(label: label, value: 'No data yet');
        }
        final int value = count == null ? docs.length : count!(docs);
        return _StatCard(label: label, value: '$value');
      },
    );
  }
}

class _EarningsStat extends StatelessWidget {
  const _EarningsStat({required this.firestore});

  final FirestoreService firestore;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: firestore.watchDocs('payments'),
      builder: (
        BuildContext context,
        AsyncSnapshot<List<Map<String, dynamic>>> snap,
      ) {
        if (snap.hasError) {
          return const _StatCard(label: 'Earnings', value: 'Could not load.');
        }
        if (!snap.hasData) {
          return const _StatCard(label: 'Earnings', value: 'Loading');
        }
        final List<Map<String, dynamic>> paid = snap.data!
            .where((Map<String, dynamic> d) => str(d, 'status') == 'paid')
            .toList();
        if (paid.isEmpty) {
          return const _StatCard(label: 'Earnings', value: 'No payments yet');
        }
        double total = 0;
        for (final Map<String, dynamic> d in paid) {
          total += numVal(d, 'amount');
        }
        final String currency = str(paid.first, 'currency');
        final String shown = total == total.truncateToDouble()
            ? total.toInt().toString()
            : total.toStringAsFixed(2);
        return _StatCard(label: 'Earnings', value: '$shown $currency'.trim());
      },
    );
  }
}

class _AttentionRow extends StatelessWidget {
  const _AttentionRow({
    required this.label,
    required this.stream,
    required this.count,
    required this.onTap,
  });

  final String label;
  final Stream<List<Map<String, dynamic>>> stream;
  final int Function(List<Map<String, dynamic>> docs) count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: stream,
      builder: (
        BuildContext context,
        AsyncSnapshot<List<Map<String, dynamic>>> snap,
      ) {
        if (!snap.hasData) {
          return const ListTile(title: Text('Loading'));
        }
        final int value = count(snap.data!);
        return ListTile(
          title: Text(
            '$label: $value',
            style: AppTextStyles.themed(context, AppTextStyles.body),
          ),
          trailing:
              value == 0 ? null : const Icon(Icons.chevron_right),
          onTap: value == 0 ? null : onTap,
        );
      },
    );
  }
}

/// Astrologers, design 17. List, approve, reject, slots, add form.
/// No name, language or rate is invented; every value comes from
/// the astrologers collection.
class AstrologersScreen extends StatefulWidget {
  const AstrologersScreen({super.key, required this.firestore});

  final FirestoreService firestore;

  @override
  State<AstrologersScreen> createState() => _AstrologersScreenState();
}

class _AstrologersScreenState extends State<AstrologersScreen> {
  String _query = '';
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Astrologers',
                style: AppTextStyles.themed(context, AppTextStyles.display),
              ),
            ),
            ElevatedButton(
              onPressed: () => _showAddForm(context),
              child: const Text('Add astrologer'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              onChanged: (String value) =>
                  setState(() => _query = value.toLowerCase()),
              decoration: const InputDecoration(
                hintText: 'Search by name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<String>(
                segments: const <ButtonSegment<String>>[
                  ButtonSegment<String>(value: 'All', label: Text('All')),
                  ButtonSegment<String>(
                      value: 'Online', label: Text('Online')),
                  ButtonSegment<String>(
                      value: 'Offline', label: Text('Offline')),
                  ButtonSegment<String>(
                      value: 'waiting', label: Text('Waiting approval')),
                ],
                selected: <String>{_filter},
                onSelectionChanged: (Set<String> value) =>
                    setState(() => _filter = value.first),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: widget.firestore.watchDocs('astrologers'),
          builder: (
            BuildContext context,
            AsyncSnapshot<List<Map<String, dynamic>>> snap,
          ) {
            if (snap.hasError) {
              return _LoadError(
                message: 'Astrologers could not be loaded.',
                onRetry: () => setState(() {}),
              );
            }
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            List<Map<String, dynamic>> docs = snap.data!;
            if (_filter != 'All') {
              docs = docs
                  .where((Map<String, dynamic> d) =>
                      str(d, 'status') == _filter)
                  .toList();
            }
            if (_query.isNotEmpty) {
              docs = docs
                  .where((Map<String, dynamic> d) =>
                      str(d, 'name').toLowerCase().contains(_query))
                  .toList();
            }
            if (docs.isEmpty) {
              if (snap.data!.isEmpty) {
                return const _Empty(
                  title: 'No astrologers yet',
                  body: 'Add your first astrologer to open live consult.',
                );
              }
              return const _Empty(
                title: 'No astrologer matches this search.',
                body: 'Try a different name or filter.',
              );
            }
            return Card(
              child: Column(
                children: docs
                    .map(
                      (Map<String, dynamic> doc) => ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            str(doc, 'name').isEmpty
                                ? '?'
                                : str(doc, 'name')[0].toUpperCase(),
                          ),
                        ),
                        title: Text(str(doc, 'name')),
                        subtitle: Text(
                          str(doc, 'languages').isEmpty
                              ? 'Languages not set'
                              : str(doc, 'languages'),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            _Pill(
                              label: str(doc, 'status').isEmpty
                                  ? 'Offline'
                                  : str(doc, 'status'),
                              color: _statusColor(str(doc, 'status')),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              str(doc, 'rate').isEmpty
                                  ? 'Rate to be decided'
                                  : str(doc, 'rate'),
                            ),
                            TextButton(
                              onPressed: () => _showDetail(context, doc),
                              child: const Text('View'),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _showAddForm(BuildContext context) async {
    final TextEditingController name = TextEditingController();
    final TextEditingController languages = TextEditingController();
    final TextEditingController bio = TextEditingController();
    final TextEditingController rate = TextEditingController();
    bool chat = true;
    bool call = true;
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialog) {
            return AlertDialog(
              title: const Text('Add astrologer'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _adminField(label: 'Full name', controller: name),
                    _adminField(
                      label: 'Languages',
                      controller: languages,
                      hint: 'Hindi, English',
                    ),
                    _adminField(
                      label: 'Short bio',
                      controller: bio,
                      maxLines: 3,
                    ),
                    _adminField(
                      label: 'Rate',
                      controller: rate,
                      hint: 'Pricing is to be decided. Leave blank until rates are set.',
                    ),
                    SwitchListTile(
                      title: const Text('Chat available'),
                      value: chat,
                      onChanged: (bool value) =>
                          setDialog(() => chat = value),
                    ),
                    SwitchListTile(
                      title: const Text('Call available'),
                      value: call,
                      onChanged: (bool value) =>
                          setDialog(() => call = value),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: name,
                  builder: (
                    BuildContext context,
                    TextEditingValue value,
                    Widget? child,
                  ) {
                    return ElevatedButton(
                      onPressed: value.text.trim().isEmpty
                          ? null
                          : () async {
                              await widget.firestore.saveDoc(
                                'astrologers',
                                DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString(),
                                <String, Object?>{
                                  'name': name.text.trim(),
                                  'languages': languages.text.trim(),
                                  'bio': bio.text.trim(),
                                  'rate': rate.text.trim(),
                                  'chatAvailable': chat,
                                  'callAvailable': call,
                                  'status': 'waiting',
                                  'slots': <String>[],
                                },
                                isNew: true,
                              );
                              if (context.mounted) {
                                Navigator.of(context).pop();
                                _toast(
                                  context,
                                  'Astrologer saved as waiting approval.',
                                );
                              }
                            },
                      child: const Text('Save astrologer'),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showDetail(
    BuildContext context,
    Map<String, dynamic> doc,
  ) async {
    final String id = str(doc, 'id');
    final List<String> slots =
        (doc['slots'] as List<dynamic>? ?? <dynamic>[])
            .map((dynamic s) => s.toString())
            .toList();
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(str(doc, 'name')),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(str(doc, 'bio')),
                const SizedBox(height: AppSpacing.md),
                Text('Languages: ${str(doc, 'languages')}'),
                Text('Status: ${str(doc, 'status')}'),
                Text(
                  'Rate: ${str(doc, 'rate').isEmpty ? 'Rate to be decided' : str(doc, 'rate')}',
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Slots',
                  style: AppTextStyles.themed(context, AppTextStyles.subtitle),
                ),
                if (slots.isEmpty)
                  const Text('No slots set yet.')
                else
                  ...slots.map((String s) => Text(s)),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Session history',
                  style: AppTextStyles.themed(context, AppTextStyles.subtitle),
                ),
                const Text('No sessions yet.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                await widget.firestore.saveDoc('astrologers', id,
                    <String, Object?>{'status': 'rejected'});
                if (context.mounted) {
                  Navigator.of(context).pop();
                  _toast(context, 'Astrologer rejected.');
                }
              },
              child: const Text('Reject'),
            ),
            ElevatedButton(
              onPressed: () async {
                await widget.firestore.saveDoc('astrologers', id,
                    <String, Object?>{'status': 'offline'});
                if (context.mounted) {
                  Navigator.of(context).pop();
                  _toast(
                    context,
                    'Astrologer approved. Set slots to bring them online.',
                  );
                }
              },
              child: const Text('Approve'),
            ),
          ],
        );
      },
    );
  }
}

/// Daily content, design 18. Horoscope grid for twelve rashis and
/// the panchang form. Publishing writes to Firestore, and the user
/// app reads the same documents, so published content reaches
/// users the moment it is published.
class DailyContentScreen extends StatefulWidget {
  const DailyContentScreen({super.key, required this.firestore});

  final FirestoreService firestore;

  @override
  State<DailyContentScreen> createState() => _DailyContentScreenState();
}

class _DailyContentScreenState extends State<DailyContentScreen> {
  DateTime _date = DateTime.now();
  String _type = 'Horoscope';

  String get _key => dateKey(_date);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Daily Content',
                style: AppTextStyles.themed(context, AppTextStyles.display),
              ),
            ),
            if (_type == 'Horoscope')
              OutlinedButton(
                onPressed: () => _publishAll(context),
                child: const Text('Publish all'),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: <Widget>[
            OutlinedButton(
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2035),
                );
                if (picked != null) setState(() => _date = picked);
              },
              child: Text(formatDay(_date)),
            ),
            const SizedBox(width: AppSpacing.md),
            SegmentedButton<String>(
              segments: const <ButtonSegment<String>>[
                ButtonSegment<String>(
                    value: 'Horoscope', label: Text('Horoscope')),
                ButtonSegment<String>(
                    value: 'Panchang', label: Text('Panchang')),
              ],
              selected: <String>{_type},
              onSelectionChanged: (Set<String> value) =>
                  setState(() => _type = value.first),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (_type == 'Horoscope')
          _HoroscopeGrid(firestore: widget.firestore, dateKey: _key)
        else
          _PanchangForm(firestore: widget.firestore, dateKey: _key),
      ],
    );
  }

  Future<void> _publishAll(BuildContext context) async {
    final bool ok = await _confirm(
      context,
      'Publish all drafts?',
      'Every rashi with a saved draft for ${formatDay(_date)} will be published.',
      'Publish all',
    );
    if (!ok) return;
    // Drafts are read from the same stream the grid uses, so this
    // publishes exactly what the owner sees as drafts.
    final List<Map<String, dynamic>> docs = await widget.firestore
        .watchDocs('horoscopes')
        .first;
    int done = 0;
    for (final Map<String, dynamic> doc in docs) {
      if (str(doc, 'date') == _key && str(doc, 'status') == 'draft') {
        await widget.firestore.saveDoc(
          'horoscopes',
          str(doc, 'id'),
          <String, Object?>{'status': 'published'},
        );
        done++;
      }
    }
    if (context.mounted) {
      _toast(context, 'Published $done ${done == 1 ? 'rashi' : 'rashis'}. Users see it now.');
    }
  }
}

class _HoroscopeGrid extends StatelessWidget {
  const _HoroscopeGrid({required this.firestore, required this.dateKey});

  final FirestoreService firestore;
  final String dateKey;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: firestore.watchDocs('horoscopes'),
      builder: (
        BuildContext context,
        AsyncSnapshot<List<Map<String, dynamic>>> snap,
      ) {
        if (snap.hasError) {
          return const Text('Horoscopes could not be loaded.');
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final Map<String, Map<String, dynamic>> byRashi =
            <String, Map<String, dynamic>>{};
        for (final Map<String, dynamic> doc in snap.data!) {
          if (str(doc, 'date') == dateKey) {
            byRashi[str(doc, 'rashi')] = doc;
          }
        }
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final int cols = constraints.maxWidth > 700 ? 3 : 1;
            return GridView.count(
              crossAxisCount: cols,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 1.0,
              children: kRashis.map((String rashi) {
                final Map<String, dynamic>? doc = byRashi[rashi];
                final String status = doc == null
                    ? 'Not started'
                    : str(doc, 'status').isEmpty
                        ? 'Draft'
                        : str(doc, 'status');
                final String body = doc == null ||
                        str(doc, 'summary').isEmpty
                    ? 'No content yet.'
                    : str(doc, 'summary');
                return Card(
                  child: InkWell(
                    onTap: () => _showEditor(context, rashi, doc),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  rashi,
                                  style: AppTextStyles.themed(
                                    context,
                                    AppTextStyles.subtitle,
                                  ),
                                ),
                              ),
                              _Pill(
                                label: status,
                                color: _statusColor(status),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              body,
                              style: AppTextStyles.themed(
                                context,
                                AppTextStyles.bodySmall,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Lucky Number ${str(doc ?? <String, dynamic>{}, 'luckyNumber')}  •  Lucky Colour ${str(doc ?? <String, dynamic>{}, 'luckyColour')}',
                            style: AppTextStyles.themed(
                              context,
                              AppTextStyles.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  Future<void> _showEditor(
    BuildContext context,
    String rashi,
    Map<String, dynamic>? doc,
  ) async {
    final TextEditingController summary =
        TextEditingController(text: str(doc ?? <String, dynamic>{}, 'summary'));
    final TextEditingController career =
        TextEditingController(text: str(doc ?? <String, dynamic>{}, 'career'));
    final TextEditingController money =
        TextEditingController(text: str(doc ?? <String, dynamic>{}, 'money'));
    final TextEditingController health =
        TextEditingController(text: str(doc ?? <String, dynamic>{}, 'health'));
    final TextEditingController love =
        TextEditingController(text: str(doc ?? <String, dynamic>{}, 'love'));
    final TextEditingController luckyNumber = TextEditingController(
        text: str(doc ?? <String, dynamic>{}, 'luckyNumber'));
    final TextEditingController luckyColour = TextEditingController(
        text: str(doc ?? <String, dynamic>{}, 'luckyColour'));
    final String id = doc == null
        ? '${dateKey}_$rashi'
        : str(doc, 'id');
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(rashi),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _adminField(
                  label: 'Horoscope text',
                  controller: summary,
                  maxLines: 6,
                ),
                _adminField(label: 'Career', controller: career),
                _adminField(label: 'Money', controller: money),
                _adminField(label: 'Health', controller: health),
                _adminField(label: 'Love', controller: love),
                _adminField(label: 'Lucky Number', controller: luckyNumber),
                _adminField(label: 'Lucky Colour', controller: luckyColour),
                if (doc != null)
                  Text(
                    'Last saved ${formatStamp(doc['updatedAt'] ?? doc['createdAt'])}',
                    style: AppTextStyles.themed(
                      context,
                      AppTextStyles.bodySmall,
                    ),
                  ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                await firestore.saveDoc(
                  'horoscopes',
                  id,
                  <String, Object?>{
                    'date': dateKey,
                    'rashi': rashi,
                    'summary': summary.text.trim(),
                    'career': career.text.trim(),
                    'money': money.text.trim(),
                    'health': health.text.trim(),
                    'love': love.text.trim(),
                    'luckyNumber': luckyNumber.text.trim(),
                    'luckyColour': luckyColour.text.trim(),
                    'status': 'draft',
                  },
                  isNew: doc == null,
                );
                if (context.mounted) {
                  Navigator.of(context).pop();
                  _toast(context, 'Draft saved.');
                }
              },
              child: const Text('Save draft'),
            ),
            ElevatedButton(
              onPressed: () async {
                await firestore.saveDoc(
                  'horoscopes',
                  id,
                  <String, Object?>{
                    'date': dateKey,
                    'rashi': rashi,
                    'summary': summary.text.trim(),
                    'career': career.text.trim(),
                    'money': money.text.trim(),
                    'health': health.text.trim(),
                    'love': love.text.trim(),
                    'luckyNumber': luckyNumber.text.trim(),
                    'luckyColour': luckyColour.text.trim(),
                    'status': 'published',
                  },
                  isNew: doc == null,
                );
                if (context.mounted) {
                  Navigator.of(context).pop();
                  _toast(context, 'Published. Users see it now.');
                }
              },
              child: const Text('Publish'),
            ),
          ],
        );
      },
    );
  }
}

class _PanchangForm extends StatefulWidget {
  const _PanchangForm({required this.firestore, required this.dateKey});

  final FirestoreService firestore;
  final String dateKey;

  @override
  State<_PanchangForm> createState() => _PanchangFormState();
}

class _PanchangFormState extends State<_PanchangForm> {
  static const List<String> _labels = <String>[
    'City',
    'Tithi',
    'Vaar',
    'Nakshatra',
    'Nakshatra till',
    'Yoga',
    'Karana',
    'Sunrise',
    'Sunset',
    'Shubh Muhurat start',
    'Shubh Muhurat end',
    'Second Shubh Muhurat start',
    'Second Shubh Muhurat end',
    'Rahu Kaal start',
    'Rahu Kaal end',
    'Festival notes',
  ];

  static const List<String> _keys = <String>[
    'city',
    'tithi',
    'vaar',
    'nakshatra',
    'nakshatraTill',
    'yoga',
    'karana',
    'sunrise',
    'sunset',
    'shubhStart',
    'shubhEnd',
    'shubh2Start',
    'shubh2End',
    'rahuStart',
    'rahuEnd',
    'festivalNotes',
  ];

  final Map<String, TextEditingController> _controllers =
      <String, TextEditingController>{};
  bool _loaded = false;
  String? _docId;

  @override
  void dispose() {
    for (final TextEditingController c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: widget.firestore.watchDocs('panchang'),
      builder: (
        BuildContext context,
        AsyncSnapshot<List<Map<String, dynamic>>> snap,
      ) {
        if (snap.hasError) {
          return const Text('Panchang could not be loaded.');
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        Map<String, dynamic>? doc;
        for (final Map<String, dynamic> d in snap.data!) {
          if (str(d, 'date') == widget.dateKey) doc = d;
        }
        if (!_loaded) {
          for (int i = 0; i < _keys.length; i++) {
            _controllers[_keys[i]] = TextEditingController(
              text: doc == null ? '' : str(doc, _keys[i]),
            );
          }
          _docId = doc == null ? null : str(doc, 'id');
          _loaded = true;
        }
        final bool past = DateTime.tryParse(widget.dateKey)
                ?.isBefore(DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                )) ??
            false;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Panchang for ${formatDay(DateTime.parse(widget.dateKey))}',
                  style: AppTextStyles.themed(context, AppTextStyles.subtitle),
                ),
                if (past)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Text(
                      'This date is in the past. Content is read only.',
                      style: AppTextStyles.themed(
                        context,
                        AppTextStyles.bodySmall,
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.md),
                ...List<Widget>.generate(_labels.length, (int i) {
                  return _adminField(
                    label: _labels[i],
                    controller: _controllers[_keys[i]]!,
                  );
                }),
                const SizedBox(height: AppSpacing.sm),
                ElevatedButton(
                  onPressed: past
                      ? null
                      : () async {
                          final Map<String, Object?> data =
                              <String, Object?>{
                            'date': widget.dateKey,
                          };
                          for (final String key in _keys) {
                            data[key] = _controllers[key]!.text.trim();
                          }
                          await widget.firestore.saveDoc(
                            'panchang',
                            _docId ?? widget.dateKey,
                            data,
                            isNew: _docId == null,
                          );
                          if (context.mounted) {
                            _toast(context, 'Panchang saved.');
                          }
                        },
                  child: const Text('Save panchang'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Subscriptions and payments, design 19. Plans are real documents.
/// Pricing is to be decided, so no price is invented anywhere: a
/// plan without a price shows "To be decided".
class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key, required this.firestore});

  final FirestoreService firestore;

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  String _query = '';
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Subscriptions and Payments',
                style: AppTextStyles.themed(context, AppTextStyles.display),
              ),
            ),
            ElevatedButton(
              onPressed: () => _showPlanForm(context, null),
              child: const Text('New plan'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: widget.firestore.watchDocs('plans'),
          builder: (
            BuildContext context,
            AsyncSnapshot<List<Map<String, dynamic>>> snap,
          ) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final List<Map<String, dynamic>> plans = snap.data!;
            if (plans.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Text('No plans yet. Create the first plan.'),
                ),
              );
            }
            return LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: plans.map((Map<String, dynamic> plan) {
                    final List<String> benefits =
                        (plan['benefits'] as List<dynamic>? ?? <dynamic>[])
                            .map((dynamic b) => b.toString())
                            .toList();
                    final String status = str(plan, 'status').isEmpty
                        ? 'Draft'
                        : str(plan, 'status');
                    return SizedBox(
                      width: 320,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      str(plan, 'name'),
                                      style: AppTextStyles.themed(
                                        context,
                                        AppTextStyles.subtitle,
                                      ),
                                    ),
                                  ),
                                  _Pill(
                                    label: status,
                                    color: _statusColor(status),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                str(plan, 'price').isEmpty
                                    ? 'To be decided'
                                    : str(plan, 'price'),
                                style: AppTextStyles.themed(
                                  context,
                                  AppTextStyles.title,
                                ),
                              ),
                              if (str(plan, 'length').isNotEmpty)
                                Text(str(plan, 'length')),
                              ...benefits.map((String b) => Text('• $b')),
                              const SizedBox(height: AppSpacing.sm),
                              Row(
                                children: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        _showPlanForm(context, plan),
                                    child: const Text('Edit plan'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      await widget.firestore.saveDoc(
                                        'plans',
                                        str(plan, 'id'),
                                        <String, Object?>{
                                          'status': status == 'Paused'
                                              ? 'Active'
                                              : 'Paused',
                                        },
                                      );
                                    },
                                    child: Text(
                                      status == 'Paused'
                                          ? 'Resume'
                                          : 'Pause',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            );
          },
        ),
        const SizedBox(height: AppSpacing.md),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Trials'),
                Text('Trial length is to be decided.'),
                Text('Turn on trials when trial length is decided.'),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                onChanged: (String value) =>
                    setState(() => _query = value.toLowerCase()),
                decoration: const InputDecoration(
                  hintText: 'Search by user',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            SegmentedButton<String>(
              segments: const <ButtonSegment<String>>[
                ButtonSegment<String>(value: 'All', label: Text('All')),
                ButtonSegment<String>(value: 'paid', label: Text('Paid')),
                ButtonSegment<String>(value: 'failed', label: Text('Failed')),
                ButtonSegment<String>(
                    value: 'refunded', label: Text('Refunded')),
                ButtonSegment<String>(
                    value: 'pending', label: Text('Pending')),
              ],
              selected: <String>{_filter},
              onSelectionChanged: (Set<String> value) =>
                  setState(() => _filter = value.first),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: widget.firestore.watchDocs('payments'),
          builder: (
            BuildContext context,
            AsyncSnapshot<List<Map<String, dynamic>>> snap,
          ) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            List<Map<String, dynamic>> docs = snap.data!;
            if (_filter != 'All') {
              docs = docs
                  .where((Map<String, dynamic> d) =>
                      str(d, 'status') == _filter)
                  .toList();
            }
            if (_query.isNotEmpty) {
              docs = docs
                  .where((Map<String, dynamic> d) =>
                      str(d, 'user').toLowerCase().contains(_query))
                  .toList();
            }
            if (docs.isEmpty) {
              return const _Empty(
                title: 'No payments yet.',
                body: 'Payments appear here once users pay.',
              );
            }
            return Card(
              child: Column(
                children: docs
                    .map(
                      (Map<String, dynamic> doc) => ListTile(
                        title: Text(
                          '${formatStamp(doc['createdAt'])}  •  ${str(doc, 'user')}',
                        ),
                        subtitle: Text(
                          '${str(doc, 'plan')}  •  ${numVal(doc, 'amount')} ${str(doc, 'currency')}',
                        ),
                        trailing: _Pill(
                          label: str(doc, 'status'),
                          color: _statusColor(str(doc, 'status')),
                        ),
                        onTap: () => _showPayment(context, doc),
                      ),
                    )
                    .toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _showPlanForm(
    BuildContext context,
    Map<String, dynamic>? plan,
  ) async {
    final TextEditingController name =
        TextEditingController(text: plan == null ? '' : str(plan, 'name'));
    final TextEditingController length = TextEditingController(
        text: plan == null ? '' : str(plan, 'length'));
    final TextEditingController benefits = TextEditingController(
      text: plan == null
          ? ''
          : ((plan['benefits'] as List<dynamic>? ?? <dynamic>[])
                  .map((dynamic b) => b.toString())
                  .join('\n')),
    );
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(plan == null ? 'New plan' : 'Edit plan'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _adminField(label: 'Plan name', controller: name),
                _adminField(
                  label: 'Length',
                  controller: length,
                  hint: 'Monthly',
                ),
                _adminField(
                  label: 'Benefits, one per line',
                  controller: benefits,
                  maxLines: 5,
                ),
                const Text(
                  'Price is to be decided. Plans stay in Draft until a price is set.',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await widget.firestore.saveDoc(
                  'plans',
                  plan == null
                      ? DateTime.now().millisecondsSinceEpoch.toString()
                      : str(plan, 'id'),
                  <String, Object?>{
                    'name': name.text.trim(),
                    'length': length.text.trim(),
                    'benefits': benefits.text
                        .split('\n')
                        .map((String b) => b.trim())
                        .where((String b) => b.isNotEmpty)
                        .toList(),
                    'status': plan == null ? 'Draft' : str(plan, 'status'),
                  },
                  isNew: plan == null,
                );
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Save plan'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPayment(
    BuildContext context,
    Map<String, dynamic> doc,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${str(doc, 'user')}  •  ${str(doc, 'plan')}'),
          content: Text(
            'Amount ${numVal(doc, 'amount')} ${str(doc, 'currency')}. '
            'Status ${str(doc, 'status')}. '
            '${str(doc, 'note')}',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            if (str(doc, 'status') == 'paid')
              TextButton(
                onPressed: () async {
                  final bool ok = await _confirm(
                    context,
                    'Refund this payment?',
                    'The amount returns to the user. This cannot be undone. '
                    'Record the refund here, and return the money in the payment provider.',
                    'Refund',
                  );
                  if (!ok) return;
                  await widget.firestore.saveDoc(
                    'payments',
                    str(doc, 'id'),
                    <String, Object?>{'status': 'refunded'},
                  );
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: const Text('Refund'),
              ),
          ],
        );
      },
    );
  }
}

/// Analytics and revenue, design 20. Every number comes from
/// Firestore. Charts with no source data say so plainly.
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key, required this.firestore});

  final FirestoreService firestore;

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _range = '7 days';

  @override
  Widget build(BuildContext context) {
    final int days = _range == 'Today' ? 1 : _range == '7 days' ? 7 : 30;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Analytics and Revenue',
                style: AppTextStyles.themed(context, AppTextStyles.display),
              ),
            ),
            SegmentedButton<String>(
              segments: const <ButtonSegment<String>>[
                ButtonSegment<String>(value: 'Today', label: Text('Today')),
                ButtonSegment<String>(value: '7 days', label: Text('7 days')),
                ButtonSegment<String>(
                    value: '30 days', label: Text('30 days')),
              ],
              selected: <String>{_range},
              onSelectionChanged: (Set<String> value) =>
                  setState(() => _range = value.first),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: widget.firestore.watchDocs('users'),
          builder: (
            BuildContext context,
            AsyncSnapshot<List<Map<String, dynamic>>> snap,
          ) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final List<Map<String, dynamic>> inRangeDocs = snap.data!
                .where((Map<String, dynamic> d) => inRange(docDay(d), _range))
                .toList();
            return LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final int cols = constraints.maxWidth > 700 ? 4 : 2;
                final List<Widget> cards = <Widget>[
                  _StatCard(
                    label: 'Daily users',
                    value: inRangeDocs.isEmpty
                        ? 'No data yet'
                        : '${inRangeDocs.length}',
                  ),
                  _RangeStat(
                    label: 'Kundlis created',
                    stream: widget.firestore.watchDocs('users'),
                    range: _range,
                  ),
                  const _StatCard(
                    label: 'Consult minutes',
                    value: 'No data yet',
                  ),
                  _EarningsStat(firestore: widget.firestore),
                ];
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    mainAxisSpacing: AppSpacing.md,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisExtent: 150,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cards.length,
                  itemBuilder: (BuildContext context, int index) =>
                      cards[index],
                );
              },
            );
          },
        ),
        const SizedBox(height: AppSpacing.md),
        _ChartCard(
          title: 'Kundlis created',
          stream: widget.firestore.watchDocs('users'),
          days: days,
          line: true,
        ),
        const SizedBox(height: AppSpacing.md),
        _ChartCard(
          title: 'Daily users',
          stream: widget.firestore.watchDocs('users'),
          days: days,
          line: false,
        ),
        const SizedBox(height: AppSpacing.md),
        _ChartCard(
          title: 'Earnings',
          stream: widget.firestore.watchDocs('payments'),
          days: days,
          line: false,
          values: (List<Map<String, dynamic>> docs) {
            final DateTime now = DateTime.now();
            final DateTime start = DateTime(now.year, now.month, now.day)
                .subtract(Duration(days: days - 1));
            final List<double> sums = List<double>.filled(days, 0);
            for (final Map<String, dynamic> doc in docs) {
              if (str(doc, 'status') != 'paid') continue;
              final DateTime? day = docDay(doc);
              if (day == null) continue;
              final DateTime d = DateTime(day.year, day.month, day.day);
              final int index = d.difference(start).inDays;
              if (index >= 0 && index < days) {
                sums[index] += numVal(doc, 'amount');
              }
            }
            return sums;
          },
        ),
        const SizedBox(height: AppSpacing.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Key events',
                  style: AppTextStyles.themed(context, AppTextStyles.subtitle),
                ),
                const SizedBox(height: AppSpacing.sm),
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: widget.firestore.watchDocs('users'),
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<List<Map<String, dynamic>>> snap,
                  ) {
                    final int created = snap.hasData
                        ? snap.data!
                            .where((Map<String, dynamic> d) =>
                                inRange(docDay(d), _range))
                            .length
                        : 0;
                    return Column(
                      children: <Widget>[
                        const _EventRow(
                          name: 'Screen views',
                          value: 'No data yet',
                        ),
                        _EventRow(
                          name: 'Kundli creation',
                          value: snap.hasData ? '$created' : 'Loading',
                        ),
                        const _EventRow(
                          name: 'Consult bookings',
                          value: 'No data yet',
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RangeStat extends StatelessWidget {
  const _RangeStat({
    required this.label,
    required this.stream,
    required this.range,
  });

  final String label;
  final Stream<List<Map<String, dynamic>>> stream;
  final String range;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: stream,
      builder: (
        BuildContext context,
        AsyncSnapshot<List<Map<String, dynamic>>> snap,
      ) {
        if (!snap.hasData) {
          return _StatCard(label: label, value: 'Loading');
        }
        final int count = snap.data!
            .where((Map<String, dynamic> d) => inRange(docDay(d), range))
            .length;
        return _StatCard(
          label: label,
          value: count == 0 ? 'No data yet' : '$count',
        );
      },
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.name, required this.value});

  final String name;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              name,
              style: AppTextStyles.themed(context, AppTextStyles.body),
            ),
          ),
          Text(
            value,
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

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.stream,
    required this.days,
    required this.line,
    this.values,
  });

  final String title;
  final Stream<List<Map<String, dynamic>>> stream;
  final int days;
  final bool line;
  final List<double> Function(List<Map<String, dynamic>> docs)? values;

  List<double> _series(List<Map<String, dynamic>> docs) {
    if (values != null) return values!(docs);
    final DateTime now = DateTime.now();
    final DateTime start =
        DateTime(now.year, now.month, now.day).subtract(Duration(days: days - 1));
    final List<double> counts = List<double>.filled(days, 0);
    for (final Map<String, dynamic> doc in docs) {
      final DateTime? day = docDay(doc);
      if (day == null) continue;
      final DateTime d = DateTime(day.year, day.month, day.day);
      final int index = d.difference(start).inDays;
      if (index >= 0 && index < days) counts[index] += 1;
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: AppTextStyles.themed(context, AppTextStyles.subtitle),
            ),
            const SizedBox(height: AppSpacing.sm),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: stream,
              builder: (
                BuildContext context,
                AsyncSnapshot<List<Map<String, dynamic>>> snap,
              ) {
                if (!snap.hasData) {
                  return const Text('Loading');
                }
                final List<double> series = _series(snap.data!);
                final double total =
                    series.fold(0, (double a, double b) => a + b);
                if (total == 0) {
                  return const Text('No data in this range.');
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 120,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: line
                            ? _LinePainter(series)
                            : _BarPainter(series),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '$title in this range: ${total.toInt()}',
                      style: AppTextStyles.themed(
                        context,
                        AppTextStyles.bodySmall,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter(this.values);

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    final double max =
        values.fold(0.0, (double a, double b) => b > a ? b : a);
    if (max == 0) return;
    final Paint paint = Paint()
      ..color = const Color(0xFFD96C00)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final Path path = Path();
    for (int i = 0; i < values.length; i++) {
      final double x = values.length == 1
          ? size.width / 2
          : i * size.width / (values.length - 1);
      final double y = size.height - (values[i] / max) * (size.height - 8) - 4;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LinePainter old) => old.values != values;
}

class _BarPainter extends CustomPainter {
  _BarPainter(this.values);

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    final double max =
        values.fold(0.0, (double a, double b) => b > a ? b : a);
    if (max == 0) return;
    final Paint paint = Paint()
      ..color = const Color(0xFFD96C00).withValues(alpha: 0.7);
    final double slot = size.width / values.length;
    for (int i = 0; i < values.length; i++) {
      final double height = (values[i] / max) * (size.height - 8);
      canvas.drawRect(
        Rect.fromLTWH(
          i * slot + slot * 0.2,
          size.height - height,
          slot * 0.6,
          height,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarPainter old) => old.values != values;
}

/// Push notifications, design 21. Compose, save draft, send or
/// schedule. Sending writes the notification to Firestore, and the
/// user app shows it in its notifications list right away.
/// Device push delivery itself needs the Firebase console composer
/// or a Cloud Function; the admin app does not pretend to send FCM
/// directly from the device.
class NotificationsScreenAdmin extends StatefulWidget {
  const NotificationsScreenAdmin({super.key, required this.firestore});

  final FirestoreService firestore;

  @override
  State<NotificationsScreenAdmin> createState() =>
      _NotificationsScreenAdminState();
}

class _NotificationsScreenAdminState
    extends State<NotificationsScreenAdmin> {
  bool _composing = false;
  String? _editingId;
  final TextEditingController _title = TextEditingController();
  final TextEditingController _message = TextEditingController();
  String _audience = 'All users';
  String _type = 'Horoscope alert';
  String _sendTime = 'Send now';
  String _openScreen = 'Home';

  @override
  void dispose() {
    _title.dispose();
    _message.dispose();
    super.dispose();
  }

  void _openCompose([Map<String, dynamic>? doc]) {
    setState(() {
      _composing = true;
      _editingId = doc == null ? null : str(doc, 'id');
      _title.text = doc == null ? '' : str(doc, 'title');
      _message.text = doc == null ? '' : str(doc, 'message');
      _audience = doc == null ? 'All users' : str(doc, 'audience');
      _type = doc == null ? 'Horoscope alert' : str(doc, 'type');
      _sendTime = doc == null ? 'Send now' : str(doc, 'sendTime');
      _openScreen = doc == null ? 'Home' : str(doc, 'openScreen');
    });
  }

  Future<void> _save(String status) async {
    final String id = _editingId ??
        DateTime.now().millisecondsSinceEpoch.toString();
    await widget.firestore.saveDoc(
      'notifications',
      id,
      <String, Object?>{
        'title': _title.text.trim(),
        'message': _message.text.trim(),
        'audience': _audience,
        'type': _type,
        'sendTime': _sendTime,
        'openScreen': _openScreen,
        'status': status,
      },
      isNew: _editingId == null,
    );
    if (!mounted) return;
    setState(() {
      _composing = false;
      _editingId = null;
    });
    _toast(
      context,
      status == 'draft'
          ? 'Draft saved.'
          : 'Notification sent. Users see it in the app now.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Push Notifications',
                style: AppTextStyles.themed(context, AppTextStyles.display),
              ),
            ),
            ElevatedButton(
              onPressed: () => _openCompose(),
              child: const Text('New notification'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (_composing)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _adminField(
                    label: 'Title',
                    controller: _title,
                    hint: 'Todays horoscope is ready',
                  ),
                  _adminField(
                    label: 'Message',
                    controller: _message,
                    maxLines: 4,
                    hint: 'Kanya: a strong day for money talks.',
                  ),
                  _SegmentRow(
                    label: 'Audience',
                    value: _audience,
                    options: const <String>[
                      'All users',
                      'Free users',
                      'Premium users',
                    ],
                    onChanged: (String v) =>
                        setState(() => _audience = v),
                  ),
                  _SegmentRow(
                    label: 'Type',
                    value: _type,
                    options: const <String>[
                      'Horoscope alert',
                      'Festival wish',
                      'Offer message',
                    ],
                    onChanged: (String v) => setState(() => _type = v),
                  ),
                  _SegmentRow(
                    label: 'Send time',
                    value: _sendTime,
                    options: const <String>['Send now', 'Send at 06:00 AM'],
                    onChanged: (String v) =>
                        setState(() => _sendTime = v),
                  ),
                  _SegmentRow(
                    label: 'Open screen',
                    value: _openScreen,
                    options: const <String>[
                      'Home',
                      'Daily Horoscope',
                      'Panchang',
                      'Consult',
                    ],
                    onChanged: (String v) =>
                        setState(() => _openScreen = v),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: <Widget>[
                      OutlinedButton(
                        onPressed: () => _save('draft'),
                        child: const Text('Save draft'),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _title,
                        builder: (
                          BuildContext context,
                          TextEditingValue value,
                          Widget? child,
                        ) {
                          return ElevatedButton(
                            onPressed: value.text.trim().isEmpty
                                ? null
                                : () async {
                                    final String when =
                                        _sendTime == 'Send now'
                                            ? 'Send this notification?'
                                            : 'Schedule this notification for 06:00 AM?';
                                    final bool ok = await _confirm(
                                      context,
                                      when,
                                      'This goes to $_audience.',
                                      _sendTime == 'Send now'
                                          ? 'Send'
                                          : 'Schedule',
                                    );
                                    if (!ok) return;
                                    await _save(
                                      _sendTime == 'Send now'
                                          ? 'sent'
                                          : 'scheduled',
                                    );
                                  },
                            child: Text(
                              _sendTime == 'Send now'
                                  ? 'Send now'
                                  : 'Schedule for 06:00 AM',
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: widget.firestore.watchDocs('notifications'),
          builder: (
            BuildContext context,
            AsyncSnapshot<List<Map<String, dynamic>>> snap,
          ) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final List<Map<String, dynamic>> docs = snap.data!;
            if (docs.isEmpty) {
              return const _Empty(
                title: 'No notifications sent yet',
                body: 'Send your first horoscope alert or festival wish.',
              );
            }
            return Card(
              child: Column(
                children: docs.map((Map<String, dynamic> doc) {
                  final String status = str(doc, 'status');
                  return ListTile(
                    title: Text(str(doc, 'title')),
                    subtitle: Text(
                      '${str(doc, 'message')}\n${str(doc, 'audience')}  •  ${str(doc, 'type')}  •  ${formatStamp(doc['createdAt'])}',
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _Pill(
                          label: status.isEmpty ? 'Draft' : status,
                          color: _statusColor(status),
                        ),
                        if (status == 'draft')
                          TextButton(
                            onPressed: () => _openCompose(doc),
                            child: const Text('Edit'),
                          ),
                        if (status == 'scheduled')
                          TextButton(
                            onPressed: () async {
                              final bool ok = await _confirm(
                                context,
                                'Cancel this schedule?',
                                'The notification will not be sent.',
                                'Cancel schedule',
                              );
                              if (!ok) return;
                              await widget.firestore.deleteDoc(
                                'notifications',
                                str(doc, 'id'),
                              );
                            },
                            child: const Text('Cancel'),
                          ),
                        if (status == 'failed')
                          TextButton(
                            onPressed: () => _openCompose(doc),
                            child: const Text('Retry'),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _SegmentRow extends StatelessWidget {
  const _SegmentRow({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> options;
  final void Function(String value) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: AppTextStyles.themed(context, AppTextStyles.body)),
          const SizedBox(height: AppSpacing.sm),
          SegmentedButton<String>(
            segments: options
                .map(
                  (String o) => ButtonSegment<String>(
                    value: o,
                    label: Text(o),
                  ),
                )
                .toList(),
            selected: <String>{value},
            onSelectionChanged: (Set<String> v) => onChanged(v.first),
          ),
        ],
      ),
    );
  }
}

/// Content moderation, design 22. Queue of chats, reports and
/// remedies. Each decision is recorded with who decided and when.
/// Escalation records the decision; no escalation target is
/// invented, the open question in the spec is still open.
class ModerationScreen extends StatefulWidget {
  const ModerationScreen({super.key, required this.firestore});

  final FirestoreService firestore;

  @override
  State<ModerationScreen> createState() => _ModerationScreenState();
}

class _ModerationScreenState extends State<ModerationScreen> {
  String _filter = 'All';
  String _query = '';
  int _decidedLimit = 30;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Content Moderation',
                style: AppTextStyles.themed(context, AppTextStyles.display),
              ),
            ),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: widget.firestore.watchDocs('moderation'),
              builder: (
                BuildContext context,
                AsyncSnapshot<List<Map<String, dynamic>>> snap,
              ) {
                final int waiting = snap.hasData
                    ? snap.data!
                        .where((Map<String, dynamic> d) =>
                            str(d, 'status') == 'pending')
                        .length
                    : 0;
                return Text(
                  waiting == 0 ? 'All clear' : '$waiting items waiting',
                  style: AppTextStyles.themed(context, AppTextStyles.body),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: <Widget>[
            SegmentedButton<String>(
              segments: const <ButtonSegment<String>>[
                ButtonSegment<String>(value: 'All', label: Text('All')),
                ButtonSegment<String>(value: 'chat', label: Text('Chats')),
                ButtonSegment<String>(
                    value: 'report', label: Text('Reports')),
                ButtonSegment<String>(
                    value: 'remedy', label: Text('Remedies')),
              ],
              selected: <String>{_filter},
              onSelectionChanged: (Set<String> value) =>
                  setState(() => _filter = value.first),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: TextField(
                onChanged: (String value) =>
                    setState(() => _query = value.toLowerCase()),
                decoration: const InputDecoration(
                  hintText: 'Search by user or astrologer',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: widget.firestore.watchDocs('moderation'),
          builder: (
            BuildContext context,
            AsyncSnapshot<List<Map<String, dynamic>>> snap,
          ) {
            if (snap.hasError) {
              return _LoadError(
                message: 'Moderation queue could not be loaded.',
                onRetry: () => setState(() {}),
              );
            }
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            List<Map<String, dynamic>> pending = snap.data!
                .where((Map<String, dynamic> d) =>
                    str(d, 'status') == 'pending')
                .toList();
            final List<Map<String, dynamic>> decided = snap.data!
                .where((Map<String, dynamic> d) =>
                    str(d, 'status') != 'pending')
                .toList();
            if (_filter != 'All') {
              pending = pending
                  .where((Map<String, dynamic> d) =>
                      str(d, 'type') == _filter)
                  .toList();
            }
            if (_query.isNotEmpty) {
              pending = pending
                  .where((Map<String, dynamic> d) =>
                      (str(d, 'title') + str(d, 'body'))
                          .toLowerCase()
                          .contains(_query))
                  .toList();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (pending.isEmpty)
                  const _Empty(
                    title: 'Nothing waiting',
                    body:
                        'New chats, reports, and remedies will appear here for review.',
                  )
                else
                  ...pending.map(
                    (Map<String, dynamic> doc) => Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppSpacing.space3),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  _Pill(
                                    label: str(doc, 'type'),
                                    color: AppColors.saffron2,
                                  ),
                                  const Spacer(),
                                  Text(
                                    formatStamp(doc['createdAt']),
                                    style: AppTextStyles.themed(
                                      context,
                                      AppTextStyles.caption,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                str(doc, 'title'),
                                style: AppTextStyles.themed(
                                  context,
                                  AppTextStyles.subtitle,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                str(doc, 'body'),
                                style: AppTextStyles.themed(
                                  context,
                                  AppTextStyles.body,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Row(
                                children: <Widget>[
                                  OutlinedButton(
                                    onPressed: () =>
                                        _decide(context, doc, 'approved'),
                                    child: const Text('Approve'),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  TextButton(
                                    onPressed: () =>
                                        _decide(context, doc, 'removed'),
                                    child: const Text('Remove'),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  OutlinedButton(
                                    onPressed: () =>
                                        _decide(context, doc, 'escalated'),
                                    child: const Text('Escalate'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Decided',
                  style: AppTextStyles.themed(context, AppTextStyles.title),
                ),
                const SizedBox(height: AppSpacing.sm),
                if (decided.isEmpty)
                  const Text('No decisions yet.')
                else
                  Card(
                    child: Column(
                      children: decided
                          .take(_decidedLimit)
                          .map(
                            (Map<String, dynamic> doc) => ListTile(
                              title: Text(str(doc, 'title')),
                              subtitle: Text(
                                '${str(doc, 'decidedBy')}  •  ${formatStamp(doc['decidedAt'])}',
                              ),
                              trailing: _Pill(
                                label: str(doc, 'status'),
                                color: _statusColor(str(doc, 'status')),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                if (decided.length > _decidedLimit)
                  TextButton(
                    onPressed: () =>
                        setState(() => _decidedLimit += 30),
                    child: const Text('Load more'),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<void> _decide(
    BuildContext context,
    Map<String, dynamic> doc,
    String decision,
  ) async {
    final String verb = decision == 'approved'
        ? 'Approve'
        : decision == 'removed'
            ? 'Remove'
            : 'Escalate';
    final bool ok = await _confirm(
      context,
      '$verb this item?',
      str(doc, 'title'),
      verb,
    );
    if (!ok) return;
    await widget.firestore.saveDoc(
      'moderation',
      str(doc, 'id'),
      <String, Object?>{
        'status': decision,
        'decidedBy': 'owner',
        'decidedAt': FieldValue.serverTimestamp(),
      },
    );
    if (context.mounted) {
      _toast(context, 'Item $decision.');
    }
  }
}

/// Admin account screen. Shows the signed in admin account and
/// role, the admin profile (name, phone, language, kept in the
/// user document), change email and change password through
/// Firebase Auth, and Google linking. Change email sends a
/// verification link to the new email: the email only changes
/// after that link is tapped. Change password needs the current
/// password first, as Firebase requires reauthentication.
/// Google only accounts have no password to change: they use
/// Forgot password on the sign in screen instead.
class AdminAccountScreen extends StatefulWidget {
  const AdminAccountScreen({
    super.key,
    required this.firestore,
    required this.auth,
  });

  final FirestoreService firestore;
  final AuthService auth;

  @override
  State<AdminAccountScreen> createState() => _AdminAccountScreenState();
}

class _AdminAccountScreenState extends State<AdminAccountScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _newEmailController = TextEditingController();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _currentPasswordForEmailController =
      TextEditingController();
  final TextEditingController _newPasswordController =
      TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _language;
  UserProfile? _profile;
  bool _profileLoaded = false;
  String? _profileNote;
  String? _emailNote;
  String? _emailError;
  String? _passwordNote;
  String? _passwordError;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _newEmailController.dispose();
    _currentPasswordController.dispose();
    _currentPasswordForEmailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final String? uid = widget.auth.currentUserId;
    if (uid == null) {
      setState(() => _profileLoaded = true);
      return;
    }
    final Map<String, dynamic>? map =
        await widget.firestore.getUserProfile(uid);
    if (!mounted) return;
    setState(() {
      _profile = map == null ? null : UserProfile.fromMap(map);
      _profileLoaded = true;
      _nameController.text = _profile?.name ?? '';
      _phoneController.text = _profile?.phoneNumber ?? '';
      _language = _profile?.language;
    });
  }

  Future<void> _saveProfile() async {
    final String? uid = widget.auth.currentUserId;
    if (uid == null) return;
    final String name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _profileNote = 'Enter your full name.');
      return;
    }
    setState(() {
      _busy = true;
      _profileNote = null;
    });
    final UserProfile profile = UserProfile(
      name: name,
      gender: _profile?.gender,
      dateOfBirth: _profile?.dateOfBirth,
      timeOfBirth: _profile?.timeOfBirth,
      birthTimeUnknown: _profile?.birthTimeUnknown ?? false,
      birthCity: _profile?.birthCity,
      birthState: _profile?.birthState,
      birthCountry: _profile?.birthCountry,
      maritalStatus: _profile?.maritalStatus,
      occupation: _profile?.occupation,
      phoneNumber: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      language: _language,
      horoscopeAlertTime: _profile?.horoscopeAlertTime,
    );
    try {
      await widget.firestore.saveUserProfile(uid: uid, data: profile.toMap());
      if (mounted) {
        setState(() {
          _profile = profile;
          _profileNote = 'Profile saved.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _profileNote = 'Could not save the profile.');
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _changeEmail() async {
    final String newEmail = _newEmailController.text.trim();
    final String? problem = validateEmail(newEmail);
    if (problem != null) {
      setState(() => _emailError = problem);
      return;
    }
    setState(() {
      _busy = true;
      _emailError = null;
      _emailNote = null;
    });
    try {
      await widget.auth.updateEmailAddress(
        newEmail: newEmail,
        currentPassword:
            widget.auth.currentUserHasPasswordProvider
                ? _currentPasswordForEmailController.text
                : null,
      );
      if (mounted) {
        setState(() {
          _emailNote =
              'Verification link sent to $newEmail. Tap the link in that email to complete the change.';
          _newEmailController.clear();
          _currentPasswordForEmailController.clear();
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() => _emailError = AuthService.plainError(error));
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _changePassword() async {
    final String current = _currentPasswordController.text;
    final String next = _newPasswordController.text;
    final String confirm = _confirmPasswordController.text;
    final String? passwordError = validatePassword(next);
    if (passwordError != null) {
      setState(() => _passwordError = passwordError);
      return;
    }
    final String? matchError = validatePasswordMatch(next, confirm);
    if (matchError != null) {
      setState(() => _passwordError = matchError);
      return;
    }
    setState(() {
      _busy = true;
      _passwordError = null;
      _passwordNote = null;
    });
    try {
      await widget.auth.updateAccountPassword(
        currentPassword: current,
        newPassword: next,
      );
      if (mounted) {
        setState(() {
          _passwordNote = 'Password changed.';
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() => _passwordError = AuthService.plainError(error));
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _linkGoogle() async {
    setState(() {
      _busy = true;
      _emailError = null;
      _emailNote = null;
    });
    try {
      await widget.auth.signInWithGoogle();
      if (mounted) {
        setState(() => _emailNote = 'Google account linked.');
      }
    } catch (error) {
      if (mounted) {
        setState(() => _emailError = AuthService.plainError(error));
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: AppTextStyles.themed(context, AppTextStyles.title),
    );
  }

  Widget _note(String? text) {
    if (text == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Text(
        text,
        style: AppTextStyles.themed(context, AppTextStyles.body),
      ),
    );
  }

  Widget _error(String? text) {
    if (text == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Text(
        text,
        style: AppTextStyles.themed(context, AppTextStyles.body).copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String email = widget.auth.currentUserEmail ?? '';
    final bool hasGoogle = widget.auth.currentUserHasGoogleProvider;
    final bool hasPassword = widget.auth.currentUserHasPasswordProvider;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _sectionTitle('Account'),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Signed in as $email. Role: owner.',
          style: AppTextStyles.themed(context, AppTextStyles.body),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          hasGoogle
              ? 'Google sign in is linked to this account.'
              : 'Google sign in is not linked to this account.',
          style: AppTextStyles.themed(context, AppTextStyles.body),
        ),
        if (!hasGoogle) ...<Widget>[
          const SizedBox(height: AppSpacing.md),
          OutlinedButton(
            onPressed: _busy ? null : _linkGoogle,
            child: const Text('Link Google account'),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        _sectionTitle('Admin profile'),
        const SizedBox(height: AppSpacing.md),
        if (!_profileLoaded)
          const Center(child: CircularProgressIndicator())
        else ...<Widget>[
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Full name'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Phone number'),
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            value: _language,
            decoration:
                const InputDecoration(labelText: 'Horoscope language'),
            items: UserProfile.languages
                .map(
                  (String value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  ),
                )
                .toList(),
            onChanged: (String? value) =>
                setState(() => _language = value),
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton(
            onPressed: _busy ? null : _saveProfile,
            child: const Text('Save profile'),
          ),
          _note(_profileNote),
        ],
        const SizedBox(height: AppSpacing.lg),
        _sectionTitle('Change email'),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _newEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'New email'),
        ),
        if (hasPassword) ...<Widget>[
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _currentPasswordForEmailController,
            obscureText: true,
            decoration:
                const InputDecoration(labelText: 'Current password'),
          ),
        ],
        if (!hasPassword) ...<Widget>[
          const SizedBox(height: AppSpacing.sm),
          Text(
            'You sign in with Google, so changing the email asks you to sign in with Google again first.',
            style: AppTextStyles.themed(context, AppTextStyles.bodySmall),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        ElevatedButton(
          onPressed: _busy ? null : _changeEmail,
          child: const Text('Send verification link'),
        ),
        _error(_emailError),
        _note(_emailNote),
        const SizedBox(height: AppSpacing.lg),
        _sectionTitle('Change password'),
        const SizedBox(height: AppSpacing.md),
        if (!hasPassword)
          Text(
            'This account signs in with Google and has no password yet. Use Forgot password on the sign in screen to set one.',
            style: AppTextStyles.themed(context, AppTextStyles.body),
          )
        else ...<Widget>[
          TextField(
            controller: _currentPasswordController,
            obscureText: true,
            decoration:
                const InputDecoration(labelText: 'Current password'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _newPasswordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'New password'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _confirmPasswordController,
            obscureText: true,
            decoration:
                const InputDecoration(labelText: 'Confirm new password'),
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton(
            onPressed: _busy ? null : _changePassword,
            child: const Text('Change password'),
          ),
          _error(_passwordError),
          _note(_passwordNote),
        ],
        const SizedBox(height: AppSpacing.lg),
        OutlinedButton(
          onPressed: () => widget.auth.signOut(),
          child: const Text('Sign Out'),
        ),
      ],
    );
  }
}
