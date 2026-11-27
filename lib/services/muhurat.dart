import '../models/panchang.dart';
import 'astro.dart';
import 'panchang_extra.dart';

/// Phase 5 muhurat engine: good windows for a purpose over
/// a date range, with every rule that was applied and the
/// inputs it ran on, so the result explains itself.
///
/// The day rules are the common muhurat rules: Rikta
/// tithis (Chaturthi, Navami, Chaturdashi) and Amavasya are
/// avoided for beginnings, the yogas Vyatipata and
/// Vaidhriti are avoided, and Vishti karana is avoided.
/// Griha Pravesh additionally needs Shukla paksha. The
/// windows inside a good day are Abhijit and the good
/// Choghadiya segments (Shubh, Labh, Amrit), with any
/// window overlapping Rahu Kaal, Yamaganda or Gulika cut
/// out. Sources: the standard muhurat rules as used in
/// panchang muhurat tables; the per purpose lists below
/// name their own rule in each result.
///
/// shortcut: the engine reads the tithi, yoga, karana and
/// nakshatra at local noon. A tithi that changes near noon
/// can admit or reject a day a full tithi span check would
/// judge the other way. A span check is the upgrade when
/// sub day precision is ever needed.

/// What the muhurat is for.
enum MuhuratPurpose {
  marriage,
  grihaPravesh,
  vehicle,
  business,
  travel,
  naming,
}

/// Display name for a purpose.
String muhuratPurposeName(MuhuratPurpose purpose) => switch (purpose) {
      MuhuratPurpose.marriage => 'Marriage',
      MuhuratPurpose.grihaPravesh => 'Griha Pravesh',
      MuhuratPurpose.vehicle => 'Vehicle purchase',
      MuhuratPurpose.business => 'Business opening',
      MuhuratPurpose.travel => 'Travel',
      MuhuratPurpose.naming => 'Naming ceremony',
    };

/// Per purpose day rules.
class _PurposeRules {
  const _PurposeRules({
    required this.avoidTithis,
    required this.avoidYogas,
    required this.avoidNakshatras,
    this.requireShukla = false,
  });

  /// Tithi numbers to avoid, 1 to 30.
  final Set<int> avoidTithis;

  /// Yoga names to avoid.
  final Set<String> avoidYogas;

  /// Nakshatra names to avoid.
  final Set<String> avoidNakshatras;

  final bool requireShukla;
}

const Set<String> _badYogas = <String>{
  'Vyatipata',
  'Vaidhriti',
  'Atiganda',
  'Ganda',
  'Shula',
};

const Set<int> _riktaAndAmavasya = <int>{4, 9, 14, 30};

_PurposeRules _rulesFor(MuhuratPurpose purpose) => switch (purpose) {
      MuhuratPurpose.marriage => const _PurposeRules(
          avoidTithis: _riktaAndAmavasya,
          avoidYogas: _badYogas,
          avoidNakshatras: <String>{'Bharani', 'Krittika'},
        ),
      MuhuratPurpose.grihaPravesh => const _PurposeRules(
          avoidTithis: _riktaAndAmavasya,
          avoidYogas: <String>{'Vyatipata', 'Vaidhriti'},
          avoidNakshatras: <String>{},
          requireShukla: true,
        ),
      MuhuratPurpose.vehicle => const _PurposeRules(
          avoidTithis: _riktaAndAmavasya,
          avoidYogas: <String>{'Vyatipata', 'Vaidhriti'},
          avoidNakshatras: <String>{'Bharani'},
        ),
      MuhuratPurpose.business => const _PurposeRules(
          avoidTithis: _riktaAndAmavasya,
          avoidYogas: <String>{'Vyatipata', 'Vaidhriti', 'Atiganda'},
          avoidNakshatras: <String>{},
        ),
      MuhuratPurpose.travel => const _PurposeRules(
          avoidTithis: <int>{4, 9, 14},
          avoidYogas: <String>{'Vyatipata', 'Vaidhriti'},
          avoidNakshatras: <String>{},
        ),
      MuhuratPurpose.naming => const _PurposeRules(
          avoidTithis: _riktaAndAmavasya,
          avoidYogas: <String>{'Vyatipata', 'Vaidhriti'},
          avoidNakshatras: <String>{},
        ),
    };

/// One good window, with the rules that admitted it and the
/// inputs it was computed from.
class MuhuratWindow {
  const MuhuratWindow({
    required this.date,
    required this.startHours,
    required this.endHours,
    required this.purpose,
    required this.rulesApplied,
    required this.inputs,
  });

  final DateTime date;
  final double startHours;
  final double endHours;
  final MuhuratPurpose purpose;

  /// One line per rule, each naming the rule and the value
  /// it was checked against.
  final List<String> rulesApplied;

  /// Calculation inputs: place, coordinates, date range,
  /// tithi, nakshatra, yoga and karana of the day.
  final String inputs;

  String get windowText =>
      '${formatClockHours(startHours)} to ${formatClockHours(endHours)}';
}

/// Good windows for a purpose in the next [days] days from
/// [from], at most 10, earliest first. Empty when no day in
/// the range passes the rules.
List<MuhuratWindow> findMuhurat({
  required MuhuratPurpose purpose,
  required DateTime from,
  int days = 30,
  AstroPlace place = kDefaultPlace,
}) {
  final _PurposeRules rules = _rulesFor(purpose);
  final List<MuhuratWindow> found = <MuhuratWindow>[];
  final DateTime start = DateTime(from.year, from.month, from.day);
  for (int i = 0; i < days && found.length < 10; i++) {
    final DateTime day = start.add(Duration(days: i));
    final Panchang panchang = PanchangCalculator.forDate(day, place);
    final DayWindows windows = dayWindows(day, place);
    final String paksha = pakshaFor(day);
    final int tithi = tithiNumberAtNoon(day);
    final String nakshatra =
        panchang.nakshatra.split(' till ').first;
    final List<String> applied = <String>[
      'Tithi ${panchang.tithi} (number $tithi): '
          '${rules.avoidTithis.contains(tithi) ? 'avoided for ${muhuratPurposeName(purpose)}' : 'allowed'}.',
      'Yoga ${panchang.yoga}: '
          '${rules.avoidYogas.contains(panchang.yoga) ? 'avoided' : 'allowed'}.',
      'Karana ${panchang.karana}: '
          '${panchang.karana == 'Vishti' ? 'avoided' : 'allowed'}.',
      'Nakshatra $nakshatra: '
          '${rules.avoidNakshatras.contains(nakshatra) ? 'avoided' : 'allowed'}.',
      'Paksha $paksha: '
          '${rules.requireShukla && paksha != 'Shukla Paksha' ? 'needs Shukla, rejected' : 'allowed'}.',
    ];
    if (rules.avoidTithis.contains(tithi)) continue;
    if (rules.avoidYogas.contains(panchang.yoga)) continue;
    if (panchang.karana == 'Vishti') continue;
    if (rules.avoidNakshatras.contains(nakshatra)) continue;
    if (rules.requireShukla && paksha != 'Shukla Paksha') {
      continue;
    }
    final String inputs =
        'Place ${place.name} (${place.latitude}, ${place.longitude}), '
        'date ${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}, '
        'tithi ${panchang.tithi}, nakshatra $nakshatra, yoga ${panchang.yoga}, '
        'karana ${panchang.karana}, sunrise ${panchang.sunrise}, sunset ${panchang.sunset}, '
        'Lahiri ayanamsa.';
    final List<TimeWindow> candidates = <TimeWindow>[
      TimeWindow(
        label: 'Abhijit',
        startHours: sunTimesFor(day, place).noon - 24.0 / 60.0,
        endHours: sunTimesFor(day, place).noon + 24.0 / 60.0,
      ),
      ...timings.choghadiyaDay
          .where((ChoghadiyaSegment s) => s.isGood)
          .map(
            (ChoghadiyaSegment s) => TimeWindow(
              label: 'Choghadiya ${s.name}',
              startHours: s.startHours,
              endHours: s.endHours,
            ),
          ),
    ];
    for (final TimeWindow candidate in candidates) {
      if (found.length >= 10) break;
      if (candidate.overlaps(windows.rahuKaal)) continue;
      if (candidate.overlaps(windows.yamaganda)) continue;
      if (candidate.overlaps(windows.gulika)) continue;
      found.add(
        MuhuratWindow(
          date: day,
          startHours: candidate.startHours,
          endHours: candidate.endHours,
          purpose: purpose,
          rulesApplied: <String>[
            ...applied,
            'Window ${candidate.label} ${candidate.text}: '
                'outside Rahu Kaal ${windows.rahuKaal.text}, '
                'Yamaganda ${windows.yamaganda.text} and '
                'Gulika ${windows.gulika.text}.',
          ],
          inputs: inputs,
        ),
      );
    }
  }
  return found;
}
