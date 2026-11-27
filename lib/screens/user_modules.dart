import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme/design_tokens.dart';
import '../models/kundli.dart';
import '../models/panchang.dart';
import '../services/astro.dart';
import '../services/auth_service.dart';
import '../services/birth_profile.dart';
import '../services/consult_booking.dart';
import '../services/firestore_service.dart';
import '../services/gochar.dart';
import '../services/horoscope_periods.dart';
import '../services/library_content.dart';
import '../services/notification_prefs.dart';
import '../services/numerology.dart';
import '../services/premium_service.dart';
import '../services/report_builder.dart';
import '../services/user_profile.dart';

/// Phase 8 user modules. Every screen here reads and writes
/// real user data only. No screen shows a price, no screen
/// invents an astrologer, and no screen shows sample content
/// as if it were real. Hindi copy is not available yet, so
/// all copy here is English.

String _docStr(Map<String, dynamic> doc, String key) {
  final Object? value = doc[key];
  return value is String ? value : '';
}

void _showMsg(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}

Widget _sectionTitle(BuildContext context, String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: Text(text, style: AppTextStyles.themed(context, AppTextStyles.title)),
  );
}

/// Numerology screen: name and date of birth in, digit sums
/// out. Results can be saved to the users saved results.
class NumerologyScreen extends StatefulWidget {
  const NumerologyScreen({super.key, this.firestore, this.authService});

  final FirestoreService? firestore;
  final AuthService? authService;

  @override
  State<NumerologyScreen> createState() => _NumerologyScreenState();
}

class _NumerologyScreenState extends State<NumerologyScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _dob = TextEditingController();
  NumerologyResult? _result;
  String? _error;
  bool _saved = false;

  @override
  void dispose() {
    _name.dispose();
    _dob.dispose();
    super.dispose();
  }

  void _calculate() {
    final String name = _name.text.trim();
    final String? stored = AppUserProfile.storeDate(_dob.text.trim());
    if (name.isEmpty || stored == null) {
      setState(() {
        _error = 'Enter your full name and date of birth, for example 15 January 2000.';
        _result = null;
      });
      return;
    }
    setState(() {
      _result = Numerology.calculate(
        fullName: name,
        dateOfBirth: stored,
        asOf: DateTime.now(),
      );
      _error = null;
      _saved = false;
    });
  }

  Future<void> _save() async {
    final NumerologyResult? result = _result;
    final FirestoreService? firestore = widget.firestore;
    final String? uid = widget.authService?.currentUserId;
    final String? stored = AppUserProfile.storeDate(_dob.text.trim());
    if (result == null || firestore == null || uid == null || stored == null) {
      _showMsg(context, 'Sign in to save this result.');
      return;
    }
    await firestore.addDoc(savedResultsPath(uid), <String, Object?>{
      'kind': 'numerology',
      'name': _name.text.trim(),
      'dateOfBirth': stored,
      'createdAt': DateTime.now().toIso8601String(),
      ...result.toMap(),
    });
    if (!mounted) return;
    setState(() => _saved = true);
    _showMsg(context, 'Numerology result saved.');
  }

  Widget _numberRow(String label, int value) {
    return Card(
      child: ListTile(
        title: Text(label, style: AppTextStyles.themed(context, AppTextStyles.listTitle)),
        subtitle: Text(
          kNumerologyMeanings[value] ?? '',
          style: AppTextStyles.themed(context, AppTextStyles.bodySmall),
        ),
        trailing: Text(
          '$value',
          style: AppTextStyles.themed(context, AppTextStyles.title),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final NumerologyResult? result = _result;
    return Scaffold(
      appBar: AppBar(title: const Text('Numerology')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: <Widget>[
          Text(
            'Numbers are digit sums from your name and date of birth. They are reference guidance only.',
            style: AppTextStyles.themed(context, AppTextStyles.body),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Full name'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _dob,
            decoration: const InputDecoration(
              labelText: 'Date of birth',
              hintText: '15 January 2000',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (_error != null)
            Text(_error!, style: AppTextStyles.themed(context, AppTextStyles.body)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _calculate,
              child: const Text('Calculate numbers'),
            ),
          ),
          if (result != null) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            _numberRow('Life Path', result.lifePath),
            _numberRow('Destiny', result.destiny),
            _numberRow('Soul Urge', result.soulUrge),
            _numberRow('Personality', result.personality),
            _numberRow('Birth Day', result.birthDay),
            _numberRow('Personal Year', result.personalYear),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _saved ? null : _save,
                child: Text(_saved ? 'Saved' : 'Save this result'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Dasha and Gochar screen: Vimshottari timeline, current
/// transits from the real engine, and Sade Sati phase.
class GocharScreen extends StatefulWidget {
  const GocharScreen({super.key, this.firestore, this.authService});

  final FirestoreService? firestore;
  final AuthService? authService;

  @override
  State<GocharScreen> createState() => _GocharScreenState();
}

class _GocharScreenState extends State<GocharScreen> {
  Future<Map<String, dynamic>?>? _profileFuture;

  @override
  void initState() {
    super.initState();
    final String? uid = widget.authService?.currentUserId;
    _profileFuture = widget.firestore != null && uid != null
        ? widget.firestore!.getUserProfile(uid)
        : Future<Map<String, dynamic>?>.value(null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dasha and Gochar')),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _profileFuture,
        builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>?> snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final AppUserProfile? profile =
              snap.data == null ? null : AppUserProfile.fromMap(snap.data!);
          if (profile == null || !profile.isComplete) {
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              children: <Widget>[
                Text(
                  'Complete your profile first, so dasha and transits can be calculated from your real birth details.',
                  style: AppTextStyles.themed(context, AppTextStyles.body),
                ),
              ],
            );
          }
          final DateTime? birth = parseBirthDateTime(
            AppUserProfile.displayDate(profile.dateOfBirth!),
            profile.birthTimeUnknown || profile.timeOfBirth == null
                ? '12:00 PM'
                : AppUserProfile.displayTime(profile.timeOfBirth!),
          );
          if (birth == null) {
            return const Center(child: Text('Your birth details could not be read.'));
          }
          final KundliResult natal = KundliCalculator.calculate(
            birthLocal: birth,
            placeText: profile.placeLine,
            timeKnown: !profile.birthTimeUnknown,
          );
          final DateTime now = DateTime.now();
          final GocharReading gochar = Gochar.forDate(natal: natal, asOf: now);
          final DashaInfo dasha = vimshottariDasha(birthLocal: birth, asOf: now);
          final List<DashaInfo> timeline = vimshottariTimeline(birthLocal: birth);
          final String period = HoroscopePeriods.forBirth(
            period: 'monthly',
            birthLocal: birth,
            placeText: profile.placeLine,
            asOf: now,
          );
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: <Widget>[
              _sectionTitle(context, 'Current Dasha'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    '${dasha.lord} Mahadasha, ${formatDay(dasha.start)} to ${formatDay(dasha.end)}.',
                    style: AppTextStyles.themed(context, AppTextStyles.body),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _sectionTitle(context, 'Sade Sati'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    gochar.sadeSatiActive
                        ? 'Sade Sati is active now, phase ${gochar.sadeSatiPhase}. Saturn is transiting ${gochar.saturnRashi} and your Moon rashi is ${natal.moonRashi}.'
                        : 'Sade Sati is not active now. Saturn is transiting ${gochar.saturnRashi} and your Moon rashi is ${natal.moonRashi}.',
                    style: AppTextStyles.themed(context, AppTextStyles.body),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _sectionTitle(context, 'Transits today'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Jupiter is in ${gochar.jupiterRashi}. Saturn is in ${gochar.saturnRashi}.',
                        style: AppTextStyles.themed(context, AppTextStyles.body),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ...gochar.transit.planets.map(
                        (PlanetDetail p) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Text(
                            '${p.name} in ${p.rashi}, Bhava ${Gochar.transitBhava(transitRashi: p.rashi, natalLagna: natal.lagna)} from your lagna.',
                            style: AppTextStyles.themed(context, AppTextStyles.bodySmall),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _sectionTitle(context, 'Rule based guidance'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(period, style: AppTextStyles.themed(context, AppTextStyles.body)),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _sectionTitle(context, 'Dasha timeline'),
              ...timeline.map(
                (DashaInfo span) => Card(
                  child: ListTile(
                    title: Text(
                      '${span.lord} Mahadasha',
                      style: AppTextStyles.themed(context, AppTextStyles.listTitle),
                    ),
                    subtitle: Text(
                      '${formatDay(span.start)} to ${formatDay(span.end)}',
                      style: AppTextStyles.themed(context, AppTextStyles.bodySmall),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Reports screen: build a text report from real data, save
/// it, list saved reports, view one, delete one. There is no
/// PDF export yet, so the screen says so and never claims a
/// PDF was made.
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key, this.firestore, this.authService});

  final FirestoreService? firestore;
  final AuthService? authService;

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _busy = false;

  Future<void> _generateKundliReport() async {
    final FirestoreService? firestore = widget.firestore;
    final String? uid = widget.authService?.currentUserId;
    if (firestore == null || uid == null) {
      _showMsg(context, 'Sign in to save a report.');
      return;
    }
    setState(() => _busy = true);
    try {
      final Map<String, dynamic>? map = await firestore.getUserProfile(uid);
      if (map == null) {
        _showMsg(context, 'Complete your profile first.');
        return;
      }
      final AppUserProfile profile = AppUserProfile.fromMap(map);
      if (!profile.isComplete) {
        _showMsg(context, 'Complete your profile first.');
        return;
      }
      final DateTime? birth = parseBirthDateTime(
        AppUserProfile.displayDate(profile.dateOfBirth!),
        profile.birthTimeUnknown || profile.timeOfBirth == null
            ? '12:00 PM'
            : AppUserProfile.displayTime(profile.timeOfBirth!),
      );
      if (birth == null) {
        _showMsg(context, 'Your birth details could not be read.');
        return;
      }
      final KundliResult kundli = KundliCalculator.calculate(
        birthLocal: birth,
        placeText: profile.placeLine,
        timeKnown: !profile.birthTimeUnknown,
      );
      final String body = ReportBuilder.kundli(
        name: profile.name,
        birthLine: profile.birthLine,
        kundli: kundli,
        birthLocal: birth,
        asOf: DateTime.now(),
      );
      await firestore.addDoc(savedReportsPath(uid), <String, Object?>{
        'kind': 'kundli',
        'title': 'Kundli report for ${profile.name}',
        'body': body,
        'createdAt': DateTime.now().toIso8601String(),
      });
      if (!mounted) return;
      _showMsg(context, 'Kundli report saved.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _generatePanchangReport() async {
    final FirestoreService? firestore = widget.firestore;
    final String? uid = widget.authService?.currentUserId;
    if (firestore == null || uid == null) {
      _showMsg(context, 'Sign in to save a report.');
      return;
    }
    setState(() => _busy = true);
    try {
      final DateTime now = DateTime.now();
      final Panchang panchang = PanchangCalculator.forDate(now, kDefaultPlace);
      final String body = ReportBuilder.panchang(
        date: now,
        panchang: panchang,
        festivals: festivalDays(from: now, days: 30),
      );
      await firestore.addDoc(savedReportsPath(uid), <String, Object?>{
        'kind': 'panchang',
        'title': 'Panchang report for ${formatDay(now)}',
        'body': body,
        'createdAt': DateTime.now().toIso8601String(),
      });
      if (!mounted) return;
      _showMsg(context, 'Panchang report saved.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _viewReport(BuildContext context, Map<String, dynamic> doc) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_docStr(doc, 'title')),
          content: SingleChildScrollView(
            child: Text(_docStr(doc, 'body')),
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
    final FirestoreService? firestore = widget.firestore;
    final String? uid = widget.authService?.currentUserId;
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: <Widget>[
          Text(
            'Reports are text built from your real kundli and panchang. PDF download is not available yet.',
            style: AppTextStyles.themed(context, AppTextStyles.body),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _busy ? null : _generateKundliReport,
              child: const Text('Generate Kundli report'),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _busy ? null : _generatePanchangReport,
              child: const Text('Generate Panchang report'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _sectionTitle(context, 'Saved reports'),
          if (firestore == null || uid == null)
            Text(
              'Sign in to see saved reports.',
              style: AppTextStyles.themed(context, AppTextStyles.bodySmall),
            )
          else
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: firestore.watchDocs(savedReportsPath(uid)),
              builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snap) {
                if (snap.hasError) {
                  return Text(
                    'Reports could not be loaded.',
                    style: AppTextStyles.themed(context, AppTextStyles.body),
                  );
                }
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.data!.isEmpty) {
                  return Text(
                    'No reports saved yet.',
                    style: AppTextStyles.themed(context, AppTextStyles.bodySmall),
                  );
                }
                return Column(
                  children: snap.data!.map((Map<String, dynamic> doc) {
                    return Card(
                      child: ListTile(
                        title: Text(
                          _docStr(doc, 'title'),
                          style: AppTextStyles.themed(context, AppTextStyles.listTitle),
                        ),
                        subtitle: Text(
                          '${_docStr(doc, 'kind')}  •  ${_docStr(doc, 'createdAt')}',
                          style: AppTextStyles.themed(context, AppTextStyles.bodySmall),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await firestore.deleteDoc(
                              savedReportsPath(uid),
                              _docStr(doc, 'id'),
                            );
                            if (context.mounted) {
                              _showMsg(context, 'Report deleted.');
                            }
                          },
                        ),
                        onTap: () => _viewReport(context, doc),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
        ],
      ),
    );
  }
}

/// Birth profiles screen: list, add, edit, delete and set
/// the active profile for the family.
class BirthProfilesScreen extends StatelessWidget {
  const BirthProfilesScreen({super.key, this.firestore, this.authService});

  final FirestoreService? firestore;
  final AuthService? authService;

  Future<void> _setActive(
    BuildContext context,
    List<Map<String, dynamic>> docs,
    Map<String, dynamic> chosen,
  ) async {
    final FirestoreService? firestore = this.firestore;
    final String? uid = authService?.currentUserId;
    if (firestore == null || uid == null) return;
    for (final Map<String, dynamic> doc in docs) {
      await firestore.saveDoc(
        birthProfilesPath(uid),
        _docStr(doc, 'id'),
        <String, Object?>{'isActive': _docStr(doc, 'id') == _docStr(chosen, 'id')},
      );
    }
    await firestore.saveUserProfile(
      uid: uid,
      data: <String, Object?>{'activeBirthProfileId': _docStr(chosen, 'id')},
    );
    if (context.mounted) _showMsg(context, 'Active birth profile changed.');
  }

  Future<void> _openForm(BuildContext context, [BirthProfile? existing]) async {
    await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => _BirthProfileForm(
        existing: existing,
        firestore: firestore,
        authService: authService,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final FirestoreService? firestore = this.firestore;
    final String? uid = authService?.currentUserId;
    return Scaffold(
      appBar: AppBar(title: const Text('Birth Profiles')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context),
        child: const Icon(Icons.add),
      ),
      body: firestore == null || uid == null
          ? const Center(child: Text('Sign in to manage birth profiles.'))
          : StreamBuilder<List<Map<String, dynamic>>>(
              stream: firestore.watchDocs(birthProfilesPath(uid)),
              builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snap) {
                if (snap.hasError) {
                  return const Center(child: Text('Birth profiles could not be loaded.'));
                }
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.data!.isEmpty) {
                  return ListView(
                    padding: const EdgeInsets.all(AppSpacing.screenPadding),
                    children: <Widget>[
                      Text(
                        'No birth profiles yet. Add one for a family member, with name, date, time, place, latitude, longitude and timezone.',
                        style: AppTextStyles.themed(context, AppTextStyles.body),
                      ),
                    ],
                  );
                }
                return ListView(
                  padding: const EdgeInsets.all(AppSpacing.screenPadding),
                  children: snap.data!.map((Map<String, dynamic> doc) {
                    final BirthProfile profile = BirthProfile.fromMap(doc);
                    return Card(
                      child: ListTile(
                        title: Text(
                          profile.name,
                          style: AppTextStyles.themed(context, AppTextStyles.listTitle),
                        ),
                        subtitle: Text(
                          '${profile.relation ?? ''}  •  ${profile.dateOfBirth ?? ''}  •  ${BirthProfile.accuracyLabel(profile.timeAccuracy)}${profile.isActive ? '  •  Active' : ''}',
                          style: AppTextStyles.themed(context, AppTextStyles.bodySmall),
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (String choice) async {
                            if (choice == 'active') {
                              await _setActive(context, snap.data!, doc);
                            } else if (choice == 'edit') {
                              await _openForm(context, profile);
                            } else if (choice == 'delete') {
                              await firestore.deleteDoc(
                                birthProfilesPath(uid),
                                _docStr(doc, 'id'),
                              );
                              if (context.mounted) {
                                _showMsg(context, 'Birth profile deleted.');
                              }
                            }
                          },
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'active',
                              child: Text('Set active'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
    );
  }
}

/// Add and edit form for one birth profile. Saves straight
/// to Firestore; the dialog returns true only after a save.
class _BirthProfileForm extends StatefulWidget {
  const _BirthProfileForm({this.existing, this.firestore, this.authService});

  final BirthProfile? existing;
  final FirestoreService? firestore;
  final AuthService? authService;

  @override
  State<_BirthProfileForm> createState() => _BirthProfileFormState();
}

class _BirthProfileFormState extends State<_BirthProfileForm> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _relation = TextEditingController();
  final TextEditingController _dob = TextEditingController();
  final TextEditingController _time = TextEditingController();
  final TextEditingController _city = TextEditingController();
  final TextEditingController _state = TextEditingController();
  final TextEditingController _country = TextEditingController();
  final TextEditingController _lat = TextEditingController();
  final TextEditingController _lng = TextEditingController();
  final TextEditingController _tz = TextEditingController();
  String _accuracy = 'exact';
  String? _error;
  bool _busy = false;

  /// Stored yyyy-MM-dd, from a display date like 15 January
  /// 2000 or from yyyy-MM-dd typed directly.
  String _storedDob(String text) {
    final String trimmed = text.trim();
    if (trimmed.contains('-')) return trimmed;
    return AppUserProfile.storeDate(trimmed) ?? trimmed;
  }

  @override
  void initState() {
    super.initState();
    final BirthProfile? e = widget.existing;
    if (e != null) {
      _name.text = e.name;
      _relation.text = e.relation ?? '';
      _dob.text = e.dateOfBirth ?? '';
      _time.text = e.timeOfBirth ?? '';
      _city.text = e.birthCity ?? '';
      _state.text = e.birthState ?? '';
      _country.text = e.birthCountry ?? '';
      _lat.text = e.latitude?.toString() ?? '';
      _lng.text = e.longitude?.toString() ?? '';
      _tz.text = e.timezone ?? 'Asia/Kolkata';
      _accuracy = e.timeAccuracy;
    } else {
      _tz.text = 'Asia/Kolkata';
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _relation.dispose();
    _dob.dispose();
    _time.dispose();
    _city.dispose();
    _state.dispose();
    _country.dispose();
    _lat.dispose();
    _lng.dispose();
    _tz.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'Add birth profile' : 'Edit birth profile'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: _relation, decoration: const InputDecoration(labelText: 'Relation, for example Son')),
            TextField(controller: _dob, decoration: const InputDecoration(labelText: 'Date of birth', hintText: '15 January 2000')),
            TextField(controller: _time, decoration: const InputDecoration(labelText: 'Time of birth', hintText: '07:30')),
            DropdownButton<String>(
              value: _accuracy,
              isExpanded: true,
              items: BirthProfile.timeAccuracies
                  .map((String v) => DropdownMenuItem<String>(
                        value: v,
                        child: Text(BirthProfile.accuracyLabel(v)),
                      ))
                  .toList(),
              onChanged: (String? v) {
                if (v != null) setState(() => _accuracy = v);
              },
            ),
            TextField(controller: _city, decoration: const InputDecoration(labelText: 'Birth city')),
            TextField(controller: _state, decoration: const InputDecoration(labelText: 'Birth state')),
            TextField(controller: _country, decoration: const InputDecoration(labelText: 'Birth country')),
            TextField(controller: _lat, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Latitude, optional')),
            TextField(controller: _lng, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Longitude, optional')),
            TextField(controller: _tz, decoration: const InputDecoration(labelText: 'Timezone')),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(_error!),
              ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _busy
              ? null
              : () async {
                  final String? error = BirthProfile.validate(
                    name: _name.text,
                    dateOfBirth: _dob.text.trim().isEmpty ? null : _storedDob(_dob.text),
                    timeOfBirth: _time.text.trim().isEmpty ? null : _time.text.trim(),
                    timeAccuracy: _accuracy,
                    latitude: double.tryParse(_lat.text.trim()),
                    longitude: double.tryParse(_lng.text.trim()),
                  );
                  if (error != null) {
                    setState(() => _error = error);
                    return;
                  }
                  setState(() => _busy = true);
                  final FirestoreService? firestore = widget.firestore;
                  final String? uid = widget.authService?.currentUserId;
                  if (firestore == null || uid == null) {
                    if (mounted) {
                      setState(() {
                        _busy = false;
                        _error = 'Sign in to save a birth profile.';
                      });
                    }
                    return;
                  }
                  final BirthProfile profile = BirthProfile(
                    id: widget.existing?.id,
                    name: _name.text.trim(),
                    relation: _relation.text.trim().isEmpty ? null : _relation.text.trim(),
                    dateOfBirth: _dob.text.trim().isEmpty ? null : _storedDob(_dob.text),
                    timeOfBirth: _time.text.trim().isEmpty ? null : _time.text.trim(),
                    timeAccuracy: _accuracy,
                    birthCity: _city.text.trim().isEmpty ? null : _city.text.trim(),
                    birthState: _state.text.trim().isEmpty ? null : _state.text.trim(),
                    birthCountry: _country.text.trim().isEmpty ? null : _country.text.trim(),
                    latitude: double.tryParse(_lat.text.trim()),
                    longitude: double.tryParse(_lng.text.trim()),
                    timezone: _tz.text.trim().isEmpty ? 'Asia/Kolkata' : _tz.text.trim(),
                    isActive: widget.existing?.isActive ?? false,
                  );
                  try {
                    if (profile.id == null || profile.id!.isEmpty) {
                      await firestore.addDoc(
                        birthProfilesPath(uid),
                        profile.toMap(),
                      );
                    } else {
                      await firestore.saveDoc(
                        birthProfilesPath(uid),
                        profile.id!,
                        profile.toMap(),
                      );
                    }
                  } catch (error) {
                    if (mounted) {
                      setState(() {
                        _busy = false;
                        _error = 'Could not save. Check your connection and try again.';
                      });
                    }
                    return;
                  }
                  if (!mounted) return;
                  Navigator.of(context).pop(true);
                },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

/// Settings screen: language, notification preferences,
/// email verification, change email and password, data
/// export, account deletion, and the session record.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, this.firestore, this.authService});

  final FirestoreService? firestore;
  final AuthService? authService;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _language = 'English';
  bool _daily = true;
  bool _festival = true;
  bool _consult = true;
  bool _loaded = false;
  String? _notice;

  AuthService get _auth => widget.authService ?? AuthService();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? uid = _auth.currentUserId;
    String language = 'English';
    if (widget.firestore != null && uid != null) {
      final Map<String, dynamic>? map =
          await widget.firestore!.getUserProfile(uid);
      if (map != null) {
        language = AppUserProfile.fromMap(map).language ?? 'English';
      }
    }
    if (!mounted) return;
    setState(() {
      _language = language;
      _daily = prefs.getBool(NotificationPrefs.dailyKey) ?? true;
      _festival = prefs.getBool(NotificationPrefs.festivalKey) ?? true;
      _consult = prefs.getBool(NotificationPrefs.consultKey) ?? true;
      _loaded = true;
    });
  }

  bool get _emailVerified {
    try {
      return _auth.isEmailVerified;
    } catch (_) {
      return false;
    }
  }

  Future<void> _toggle(String key, bool value) async {
    await NotificationPrefs.setEnabled(key, value);
    setState(() {
      if (key == NotificationPrefs.dailyKey) _daily = value;
      if (key == NotificationPrefs.festivalKey) _festival = value;
      if (key == NotificationPrefs.consultKey) _consult = value;
    });
  }

  Future<void> _changeLanguage(String? value) async {
    if (value == null) return;
    final String? uid = _auth.currentUserId;
    if (widget.firestore != null && uid != null) {
      await widget.firestore!.saveUserProfile(
        uid: uid,
        data: <String, Object?>{'language': value},
      );
    }
    setState(() => _language = value);
    _showMsg(context, 'Language saved. Hindi copy is not ready yet, so the app stays in English.');
  }

  Future<void> _exportData() async {
    final String? uid = _auth.currentUserId;
    if (widget.firestore == null || uid == null) {
      _showMsg(context, 'Sign in to export your data.');
      return;
    }
    final Map<String, dynamic>? profile =
        await widget.firestore!.getUserProfile(uid);
    final Map<String, Object?> export = <String, Object?>{
      'uid': uid,
      'email': _auth.currentUserEmail,
      'profile': profile,
      'exportedAt': DateTime.now().toIso8601String(),
    };
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Your data'),
          content: SingleChildScrollView(
            child: Text(const JsonEncoder.withIndent('  ').convert(export)),
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

  Future<void> _deleteAccount() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete account?'),
          content: const Text(
            'This deletes your profile and your account. This cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Keep account'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete account'),
            ),
          ],
        );
      },
    );
    if (confirm != true) return;
    final String? uid = _auth.currentUserId;
    try {
      if (widget.firestore != null && uid != null) {
        await widget.firestore!.deleteDoc('users', uid);
      }
      await _auth.deleteAccount();
    } catch (error) {
      if (mounted) {
        _showMsg(context, AuthService.plainError(error));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? email = _auth.currentUserEmail;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              children: <Widget>[
                _sectionTitle(context, 'Language'),
                Card(
                  child: ListTile(
                    title: Text(
                      'App language',
                      style: AppTextStyles.themed(context, AppTextStyles.listTitle),
                    ),
                    subtitle: Text(
                      'Hindi copy is not ready yet, so the app stays in English.',
                      style: AppTextStyles.themed(context, AppTextStyles.bodySmall),
                    ),
                    trailing: DropdownButton<String>(
                      value: _language,
                      items: const <DropdownMenuItem<String>>[
                        DropdownMenuItem<String>(value: 'English', child: Text('English')),
                        DropdownMenuItem<String>(value: 'Hindi', child: Text('Hindi')),
                      ],
                      onChanged: _changeLanguage,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _sectionTitle(context, 'Notifications'),
                SwitchListTile(
                  title: const Text('Daily horoscope alerts'),
                  value: _daily,
                  onChanged: (bool v) => _toggle(NotificationPrefs.dailyKey, v),
                ),
                SwitchListTile(
                  title: const Text('Festival alerts'),
                  value: _festival,
                  onChanged: (bool v) => _toggle(NotificationPrefs.festivalKey, v),
                ),
                SwitchListTile(
                  title: const Text('Consult replies'),
                  value: _consult,
                  onChanged: (bool v) => _toggle(NotificationPrefs.consultKey, v),
                ),
                const SizedBox(height: AppSpacing.md),
                _sectionTitle(context, 'Account'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (email != null)
                          Text(email, style: AppTextStyles.themed(context, AppTextStyles.body)),
                        Text(
                          _emailVerified
                              ? 'Email is verified.'
                              : 'Email is not verified yet.',
                          style: AppTextStyles.themed(context, AppTextStyles.bodySmall),
                        ),
                        if (_auth.accountCreatedAt != null)
                          Text(
                            'Account created: ${_auth.accountCreatedAt}',
                            style: AppTextStyles.themed(context, AppTextStyles.bodySmall),
                          ),
                        if (_auth.lastSignInAt != null)
                          Text(
                            'Last sign in: ${_auth.lastSignInAt}',
                            style: AppTextStyles.themed(context, AppTextStyles.bodySmall),
                          ),
                        Text(
                          'Firebase Auth has no list of other sessions, so only this session is shown.',
                          style: AppTextStyles.themed(context, AppTextStyles.bodySmall),
                        ),
                        if (_notice != null)
                          Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.sm),
                            child: Text(_notice!),
                          ),
                        const SizedBox(height: AppSpacing.sm),
                        if (!_emailVerified)
                          OutlinedButton(
                            onPressed: () async {
                              try {
                                await _auth.sendEmailVerification();
                                if (mounted) {
                                  setState(() => _notice = 'Verification link sent. Open your email and tap the link.');
                                }
                              } catch (error) {
                                if (mounted) {
                                  setState(() => _notice = AuthService.plainError(error));
                                }
                              }
                            },
                            child: const Text('Send verification link'),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                OutlinedButton(
                  onPressed: _exportData,
                  child: const Text('Export my data'),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: () => _showMsg(
                    context,
                    'Terms and Privacy live in the app documents. No third party terms are shown here.',
                  ),
                  child: const Text('Terms and Privacy'),
                ),
                const SizedBox(height: AppSpacing.md),
                ElevatedButton(
                  onPressed: _deleteAccount,
                  child: const Text('Delete account'),
                ),
              ],
            ),
    );
  }
}

/// Subscription screen: plans from Firestore, entitlement
/// from Remote Config, payment history read. No price is
/// shown anywhere, because pricing is not decided yet.
class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key, this.firestore, this.premiumService});

  final FirestoreService? firestore;
  final PremiumService? premiumService;

  @override
  Widget build(BuildContext context) {
    final bool enabled =
        (premiumService ?? PremiumService()).isPremiumEnabled;
    return Scaffold(
      appBar: AppBar(title: const Text('Subscription')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                enabled
                    ? 'Premium is on for this account.'
                    : 'Free plan. Premium is not available yet. Pricing to be decided, so no plan can be bought here.',
                style: AppTextStyles.themed(context, AppTextStyles.body),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _sectionTitle(context, 'Plans'),
          if (firestore == null)
            Text(
              'Plans could not be loaded.',
              style: AppTextStyles.themed(context, AppTextStyles.body),
            )
          else
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: firestore!.watchDocs('plans'),
              builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snap) {
                if (snap.hasError) {
                  return Text(
                    'Plans could not be loaded.',
                    style: AppTextStyles.themed(context, AppTextStyles.body),
                  );
                }
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final List<Map<String, dynamic>> active = snap.data!
                    .where((Map<String, dynamic> d) => _docStr(d, 'status') == 'active')
                    .toList();
                if (active.isEmpty) {
                  return Text(
                    'No plans published yet.',
                    style: AppTextStyles.themed(context, AppTextStyles.bodySmall),
                  );
                }
                return Column(
                  children: active.map((Map<String, dynamic> doc) {
                    return Card(
                      child: ListTile(
                        title: Text(
                          _docStr(doc, 'name'),
                          style: AppTextStyles.themed(context, AppTextStyles.listTitle),
                        ),
                        subtitle: Text(
                          _docStr(doc, 'description'),
                          style: AppTextStyles.themed(context, AppTextStyles.bodySmall),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          const SizedBox(height: AppSpacing.md),
          _sectionTitle(context, 'Payment history'),
          if (firestore == null)
            Text(
              'Payment history is not available yet.',
              style: AppTextStyles.themed(context, AppTextStyles.bodySmall),
            )
          else
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: firestore!.watchDocs('payments'),
              builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snap) {
                if (snap.hasError || !snap.hasData || snap.data!.isEmpty) {
                  return Text(
                    'No payments recorded for this account.',
                    style: AppTextStyles.themed(context, AppTextStyles.bodySmall),
                  );
                }
                return Column(
                  children: snap.data!.map((Map<String, dynamic> doc) {
                    return Card(
                      child: ListTile(
                        title: Text(
                          _docStr(doc, 'status'),
                          style: AppTextStyles.themed(context, AppTextStyles.listTitle),
                        ),
                        subtitle: Text(
                          _docStr(doc, 'createdAt'),
                          style: AppTextStyles.themed(context, AppTextStyles.bodySmall),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton(
            onPressed: () {
              _showMsg(
                context,
                enabled
                    ? 'Entitlement checked. Premium is on.'
                    : 'Entitlement checked. Premium is off. Pricing to be decided.',
              );
            },
            child: const Text('Restore entitlement'),
          ),
        ],
      ),
    );
  }
}

/// My bookings screen: bookings the user requested, cancel
/// a requested booking, and leave a review for an astrologer.
class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key, this.firestore, this.authService});

  final FirestoreService? firestore;
  final AuthService? authService;

  Future<void> _review(
    BuildContext context,
    Map<String, dynamic> booking,
  ) async {
    final String? uid = authService?.currentUserId;
    final FirestoreService? firestore = this.firestore;
    if (uid == null || firestore == null) return;
    int rating = 5;
    final TextEditingController text = TextEditingController();
    final bool? saved = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Review ${_docStr(booking, 'astrologerName')}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              DropdownButton<int>(
                value: rating,
                isExpanded: true,
                items: <int>[1, 2, 3, 4, 5]
                    .map((int v) => DropdownMenuItem<int>(
                          value: v,
                          child: Text('$v out of 5'),
                        ))
                    .toList(),
                onChanged: (int? v) {
                  if (v != null) rating = v;
                },
              ),
              TextField(
                controller: text,
                decoration: const InputDecoration(labelText: 'Your review'),
                maxLines: 3,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final String? error = ConsultBooking.validateReview(
                  rating: rating,
                  text: text.text,
                );
                if (error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error)),
                  );
                  return;
                }
                Navigator.of(context).pop(true);
              },
              child: const Text('Save review'),
            ),
          ],
        );
      },
    );
    if (saved != true || !context.mounted) return;
    await firestore.addDoc(
      'reviews',
      ConsultBooking.reviewPayload(
        userId: uid,
        astrologerId: _docStr(booking, 'astrologerId'),
        rating: rating,
        text: text.text,
      ),
    );
    if (context.mounted) _showMsg(context, 'Review saved.');
  }

  @override
  Widget build(BuildContext context) {
    final FirestoreService? firestore = this.firestore;
    final String? uid = authService?.currentUserId;
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: firestore == null || uid == null
          ? const Center(child: Text('Sign in to see your bookings.'))
          : StreamBuilder<List<Map<String, dynamic>>>(
              stream: firestore.watchDocs('bookings'),
              builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snap) {
                if (snap.hasError) {
                  return const Center(child: Text('Bookings could not be loaded.'));
                }
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final List<Map<String, dynamic>> mine = snap.data!
                    .where((Map<String, dynamic> d) => _docStr(d, 'userId') == uid)
                    .toList();
                if (mine.isEmpty) {
                  return ListView(
                    padding: const EdgeInsets.all(AppSpacing.screenPadding),
                    children: <Widget>[
                      Text(
                        'No bookings yet. Book a chat or call from an astrologer in Live Consult. A booking is a request until the admin confirms it.',
                        style: AppTextStyles.themed(context, AppTextStyles.body),
                      ),
                    ],
                  );
                }
                return ListView(
                  padding: const EdgeInsets.all(AppSpacing.screenPadding),
                  children: mine.map((Map<String, dynamic> doc) {
                    final String status = _docStr(doc, 'status');
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              _docStr(doc, 'astrologerName'),
                              style: AppTextStyles.themed(context, AppTextStyles.listTitle),
                            ),
                            Text(
                              '${_docStr(doc, 'mode')}  •  ${_docStr(doc, 'date')} at ${_docStr(doc, 'time')}  •  $status',
                              style: AppTextStyles.themed(context, AppTextStyles.bodySmall),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              children: <Widget>[
                                if (ConsultBooking.canCancel(status))
                                  TextButton(
                                    onPressed: () async {
                                      await firestore.saveDoc(
                                        'bookings',
                                        _docStr(doc, 'id'),
                                        <String, Object?>{'status': 'cancelled'},
                                      );
                                      if (context.mounted) {
                                        _showMsg(context, 'Booking cancelled.');
                                      }
                                    },
                                    child: const Text('Cancel booking'),
                                  ),
                                TextButton(
                                  onPressed: () => _review(context, doc),
                                  child: const Text('Write a review'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
    );
  }
}

/// Book a chat or call with one astrologer. Saves a booking
/// request; the admin confirms it. No price is shown, because
/// pricing is not decided yet.
class BookConsultDialog extends StatefulWidget {
  const BookConsultDialog({
    super.key,
    required this.astrologerId,
    required this.astrologerName,
  });

  final String astrologerId;
  final String astrologerName;

  @override
  State<BookConsultDialog> createState() => _BookConsultDialogState();
}

class _BookConsultDialogState extends State<BookConsultDialog> {
  final TextEditingController _date = TextEditingController();
  final TextEditingController _time = TextEditingController();
  final TextEditingController _note = TextEditingController();
  String _mode = 'chat';
  String? _error;

  @override
  void dispose() {
    _date.dispose();
    _time.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Book ${_mode} with ${widget.astrologerName}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          DropdownButton<String>(
            value: _mode,
            isExpanded: true,
            items: const <DropdownMenuItem<String>>[
              DropdownMenuItem<String>(value: 'chat', child: Text('Chat')),
              DropdownMenuItem<String>(value: 'call', child: Text('Call')),
            ],
            onChanged: (String? v) {
              if (v != null) setState(() => _mode = v);
            },
          ),
          TextField(
            controller: _date,
            decoration: const InputDecoration(labelText: 'Date', hintText: '29 November 2026'),
          ),
          TextField(
            controller: _time,
            decoration: const InputDecoration(labelText: 'Time', hintText: '10:00'),
          ),
          TextField(
            controller: _note,
            decoration: const InputDecoration(labelText: 'Note, optional'),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(_error!),
            ),
          const SizedBox(height: AppSpacing.sm),
          const Text('A booking is a request until the admin confirms it. No payment is taken here.'),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final String storedDate = _date.text.trim().contains('-')
                ? _date.text.trim()
                : AppUserProfile.storeDate(_date.text.trim()) ?? _date.text.trim();
            final String? error = ConsultBooking.validate(
              date: storedDate,
              time: _time.text.trim(),
              mode: _mode,
            );
            if (error != null) {
              setState(() => _error = error);
              return;
            }
            Navigator.of(context).pop(<String, String>{
              'mode': _mode,
              'date': storedDate,
              'time': _time.text.trim(),
              'note': _note.text.trim(),
            });
          },
          child: const Text('Request booking'),
        ),
      ],
    );
  }
}
