import 'dart:math' as math;

import 'astro.dart';

/// Phase 5 daily panchang extras: the parts the base
/// PanchangCalculator does not cover. Daily timings (Rahu
/// Kaal, Yamaganda, Gulika, Brahma Muhurat, Choghadiya),
/// moonrise and moonset, paksha, the lunar month under the
/// Amanta and Purnimanta conventions, and Adhika Masa.
///
/// Everything here is computed from the same engine in
/// astro.dart: Sun and Moon longitudes, sunrise, and the
/// Lahiri ayanamsa. No stored table, no hardcoded dates.
///
/// Sources for the rules: the Rahu Kaal, Yamaganda and
/// Gulika weekday tables and the Choghadiya lord cycle are
/// the standard Kala Velai tables used in Tamil and North
/// Indian panchangs. The lunar month is named by the
/// sankranti inside it: the Sun ingress that falls strictly
/// inside the lunar month names it, Mesha ingress meaning
/// Chaitra and so on round the year. A month with no
/// sankranti is Adhika and takes the following month name.
/// Naming from the Sun sign at the Purnima alone is wrong:
/// after an Adhik month it puts every later festival a
/// month early, and when two Purnimas share one Sun sign
/// it finds a festival twice.

/// Which lunar month convention a result uses.
enum LunarConvention { amanta, purnimanta }

/// Regional settings for the panchang. Amanta ends the month
/// on Amavasya, Purnimanta ends it on Purnima. The app shows
/// both month names, so the setting only picks which one a
/// festival rule reads.
class PanchangSettings {
  const PanchangSettings({
    this.convention = LunarConvention.amanta,
  });

  final LunarConvention convention;
}

/// Lunar months in order, Chaitra first.
const List<String> kLunarMonths = <String>[
  'Chaitra',
  'Vaishakha',
  'Jyeshtha',
  'Ashadha',
  'Shravana',
  'Bhadrapada',
  'Ashwin',
  'Kartika',
  'Margashirsha',
  'Pausha',
  'Magha',
  'Phalguna',
];

DateTime _utcFromIst(DateTime istWall) =>
    istWall.subtract(const Duration(hours: 5, minutes: 30));

DateTime _istDate(DateTime utc) {
  final DateTime ist = utc.add(const Duration(hours: 5, minutes: 30));
  return DateTime(ist.year, ist.month, ist.day);
}

double _norm360(double degrees) {
  double value = degrees % 360.0;
  if (value < 0) value += 360.0;
  return value;
}

/// Moon minus Sun elongation in degrees at a UTC moment.
double _elongation(DateTime utc) {
  final Map<String, double> longs = siderealLongitudes(utc);
  return _norm360(longs['Moon']! - longs['Sun']!);
}

/// Tithi number, 1 to 30, at a UTC moment. 1 to 15 are
/// Shukla, 16 to 30 are Krishna, 30 is Amavasya.
int tithiNumberAtUtc(DateTime utc) => (_elongation(utc) ~/ 12.0) + 1;

/// Tithi number at local noon IST on a date.
int tithiNumberAtNoon(DateTime day) {
  final DateTime noonIst =
      DateTime(day.year, day.month, day.day, 12);
  return tithiNumberAtUtc(_utcFromIst(noonIst));
}

/// The moment on a date a festival observance is read at:
/// sunrise, noon, afternoon (3 PM), sunset, or midnight
/// (the end of the day, 24:00 local). Different festivals
/// use different moments; the rule for each festival names
/// its own in festivals.dart.
DateTime observanceMoment(
  DateTime day,
  AstroPlace place,
  String moment, {
  SunTimes? times,
}) {
  final SunTimes sunTimes = times ?? sunTimesFor(day, place);
  final double hours = switch (moment) {
    'sunrise' => sunTimes.sunrise,
    'noon' => 12.0,
    'afternoon' => 15.0,
    'sunset' => sunTimes.sunset,
    'midnight' => 24.0,
    _ => sunTimes.sunrise,
  };
  final DateTime base = DateTime(day.year, day.month, day.day);
  return _utcFromIst(base.add(Duration(minutes: (hours * 60).round())));
}

/// Tithi number at the observance moment on a date.
/// Pass the day's [times] when the caller already has
/// them, so a scan over many rules does not recompute
/// sunrise and sunset once per rule.
int tithiNumberAtMoment(
  DateTime day,
  AstroPlace place,
  String moment, {
  SunTimes? times,
}) =>
    tithiNumberAtUtc(observanceMoment(day, place, moment, times: times));

/// The most recent moment before [fromUtc] when the
/// elongation crossed [target]: 0 for a new moon, 180 for a
/// full moon. Found by scanning back in 6 hour steps, then
/// bisecting to the minute. A scan of 40 days always holds
/// one crossing, since the lunar month is about 29.5 days.
DateTime _phaseBefore(DateTime fromUtc, double target) {
  double gap(double e) {
    if (target == 0) {
      return e <= 180.0 ? e : e - 360.0;
    }
    return e - 180.0;
  }

  DateTime prevT = fromUtc;
  double prevGap = gap(_elongation(prevT));
  for (int i = 0; i < 160; i++) {
    final DateTime t =
        prevT.subtract(const Duration(hours: 6));
    final double g = gap(_elongation(t));
    if (prevGap > 0 && g <= 0) {
      DateTime lo = t;
      DateTime hi = prevT;
      for (int j = 0; j < 50; j++) {
        final DateTime mid =
            lo.add(Duration(microseconds: hi.difference(lo).inMicroseconds ~/ 2));
        if (gap(_elongation(mid)) > 0) {
          hi = mid;
        } else {
          lo = mid;
        }
      }
      return lo.add(
        Duration(microseconds: hi.difference(lo).inMicroseconds ~/ 2),
      );
    }
    prevT = t;
    prevGap = g;
  }
  throw StateError('No moon phase found in 40 days before $fromUtc');
}

/// The next moment after [fromUtc] when the elongation
/// crossed [target]: 0 for a new moon, 180 for a full moon.
DateTime _phaseAfter(DateTime fromUtc, double target) {
  double gap(double e) {
    if (target == 0) {
      return e <= 180.0 ? e : e - 360.0;
    }
    return e - 180.0;
  }

  DateTime prevT = fromUtc;
  double prevGap = gap(_elongation(prevT));
  for (int i = 0; i < 160; i++) {
    final DateTime t = prevT.add(const Duration(hours: 6));
    final double g = gap(_elongation(t));
    if (prevGap <= 0 && g > 0) {
      DateTime lo = prevT;
      DateTime hi = t;
      for (int j = 0; j < 50; j++) {
        final DateTime mid =
            lo.add(Duration(microseconds: hi.difference(lo).inMicroseconds ~/ 2));
        if (gap(_elongation(mid)) > 0) {
          hi = mid;
        } else {
          lo = mid;
        }
      }
      return lo.add(
        Duration(microseconds: hi.difference(lo).inMicroseconds ~/ 2),
      );
    }
    prevT = t;
    prevGap = g;
  }
  throw StateError('No moon phase found in 40 days after $fromUtc');
}

/// New moon moments from just before 1 January of [year]
/// to just after 31 December, as UTC datetimes.
List<DateTime> newMoonMoments(int year) {
  final DateTime start =
      DateTime.utc(year, 1, 1, 12);
  final List<DateTime> found = <DateTime>[_phaseBefore(start, 0)];
  while (found.last.isBefore(DateTime.utc(year + 1, 1, 2))) {
    found.add(
      _phaseAfter(
        found.last.add(const Duration(days: 1)),
        0,
      ),
    );
  }
  return found;
}

/// Full moon moments from just before 1 January of [year]
/// to just after 31 December, as UTC datetimes.
List<DateTime> fullMoonMoments(int year) {
  final DateTime start = DateTime.utc(year, 1, 1, 12);
  final List<DateTime> found = <DateTime>[_phaseBefore(start, 180)];
  while (found.last.isBefore(DateTime.utc(year + 1, 1, 2))) {
    found.add(
      _phaseAfter(
        found.last.add(const Duration(days: 1)),
        180,
      ),
    );
  }
  return found;
}

/// Sun sign index, 0 to 11, at a UTC moment.
int _sunSignAt(DateTime utc) {
  final double lon = siderealLongitudes(utc)['Sun']!;
  return (lon ~/ 30.0) % 12;
}

/// Lunar month name from the Sun sign at a Purnima. Used
/// only to name an Adhika month, where the month takes the
/// following month name: the Sun sign at the Purnima inside
/// an Adhika month is the sign before the following month
/// sankranti, so this gives the same name as the sankranti
/// rule. Everywhere else the month comes from
/// _amantaMonthAt below.
String _monthFromSunSign(int sunSign) =>
    kLunarMonths[(sunSign + 1) % 12];

/// Amanta month name for the lunar month holding a UTC
/// moment: the sankranti (Sun ingress) that falls strictly
/// inside the month names it, Mesha ingress meaning
/// Chaitra and so on round the year. A month with no
/// sankranti is Adhika and takes the following month name,
/// so the search moves to the next month. A month with two
/// sankrantis (Kshaya Masa) takes the first; Kshaya Masa is
/// not otherwise handled.
/// New moon instants for one year, memoized. One whole
/// year costs a single newMoonMoments scan, about 8ms,
/// instead of a phase scan per lunar month lookup. The
/// list runs from just before 1 January to just after
/// 31 December, so the windows at both ends of the year
/// are complete.
final Map<int, List<DateTime>> _newMoonsByYear =
    <int, List<DateTime>>{};

List<DateTime> _newMoonsForYear(int year) =>
    _newMoonsByYear.putIfAbsent(year, () => newMoonMoments(year));

/// Amanta month name for the lunar month holding [moment],
/// resolved from the month of the window it falls in.
/// The window edges come from the memoized new moons of
/// the years around the moment, never from a fresh phase
/// scan: the old code scanned back and forward for every
/// lookup, about 6ms a call, and the festival scan makes
/// thousands of lookups per year, which froze the UI for
/// seconds on every Panchang build. The month of a window
/// is cached under every window start the search visits,
/// so each window is resolved once per app run.
final Map<DateTime, String> _monthForWindowStart =
    <DateTime, String>{};

String _amantaMonthAt(DateTime moment) {
  final List<DateTime> moons = <DateTime>[
    ..._newMoonsForYear(moment.year - 1),
    ..._newMoonsForYear(moment.year),
    ..._newMoonsForYear(moment.year + 1),
  ]..sort();
  int index = moons.lastIndexWhere((DateTime m) => !m.isAfter(moment));
  if (index < 0) {
    index = 0;
  }
  final List<DateTime> visited = <DateTime>[];
  for (int i = 0; i < 3; i++) {
    final DateTime start = moons[index];
    final DateTime end = moons[index + 1];
    visited.add(start);
    final String? cached = _monthForWindowStart[start];
    if (cached != null) {
      for (final DateTime windowStart in visited) {
        _monthForWindowStart[windowStart] = cached;
      }
      return cached;
    }
    final List<DateTime> sankrantis =
        sankrantiMoments(start, end).where(
      (DateTime m) => m.isAfter(start) && m.isBefore(end),
    ).toList();
    if (sankrantis.isNotEmpty) {
      final int sign = _sunSignAt(
        sankrantis.first.add(const Duration(hours: 12)),
      );
      final String month = kLunarMonths[sign];
      for (final DateTime windowStart in visited) {
        _monthForWindowStart[windowStart] = month;
      }
      return month;
    }
    index++;
  }
  throw StateError(
    'No sankranti found in three lunar months from $moment',
  );
}

/// Amanta month name for the lunar month holding a UTC
/// moment. The festival scan reads the month at the
/// festival own observance moment, so a tithi that starts
/// just after sunrise still belongs to the month it starts
/// in, and a Pratipada is never counted twice.
String lunarMonthAtUtc(DateTime utc) => _amantaMonthAt(utc);

/// Lunar month name for a date under a convention.
///
/// Amanta: the month holding local noon, named by the
/// sankranti inside it. Purnimanta: the month ends on its
/// Purnima, so the date reads the coming Purnima, and the
/// month takes the Amanta name of the month holding that
/// Purnima. The two agree in Shukla paksha and differ by
/// one month in Krishna paksha.
String lunarMonth(
  DateTime day,
  AstroPlace place, {
  LunarConvention convention = LunarConvention.amanta,
  List<DateTime>? fullMoons,
}) {
  final DateTime noonUtc = _utcFromIst(
    DateTime(day.year, day.month, day.day, 12),
  );
  if (convention == LunarConvention.purnimanta) {
    final DateTime purnima = fullMoons == null
        ? _phaseAfter(noonUtc, 180)
        : fullMoons.firstWhere((DateTime m) => m.isAfter(noonUtc));
    return _amantaMonthAt(purnima);
  }
  return _amantaMonthAt(noonUtc);
}

/// Paksha for a date, from the tithi at local noon.
String pakshaFor(DateTime day) =>
    tithiNumberAtNoon(day) <= 15 ? 'Shukla Paksha' : 'Krishna Paksha';

/// Moments the Sun changes sign between two UTC moments,
/// found by a daily scan and bisection. A sankranti is the
/// Sun entering a new sidereal sign.
List<DateTime> sankrantiMoments(DateTime startUtc, DateTime endUtc) {
  final List<DateTime> found = <DateTime>[];
  DateTime cursor =
      DateTime.utc(startUtc.year, startUtc.month, startUtc.day);
  int prevSign = _sunSignAt(cursor);
  while (cursor.isBefore(endUtc)) {
    final DateTime next = cursor.add(const Duration(days: 1));
    final int sign = _sunSignAt(next);
    if (sign != prevSign) {
      DateTime lo = cursor;
      DateTime hi = next;
      for (int i = 0; i < 40; i++) {
        final DateTime mid = lo.add(
          Duration(microseconds: hi.difference(lo).inMicroseconds ~/ 2),
        );
        if (_sunSignAt(mid) == prevSign) {
          lo = mid;
        } else {
          hi = mid;
        }
      }
      found.add(
        lo.add(Duration(microseconds: hi.difference(lo).inMicroseconds ~/ 2)),
      );
    }
    cursor = next;
    prevSign = sign;
  }
  return found;
}

/// One extra lunar month.
class AdhikaMonth {
  const AdhikaMonth({
    required this.name,
    required this.start,
    required this.end,
  });

  /// Month name, for example Jyeshtha.
  final String name;

  /// First IST date of the extra month.
  final DateTime start;

  /// Last IST date of the extra month.
  final DateTime end;
}

/// Adhika Masa in a Gregorian year: every Amavasya to
/// Amavasya lunar month with no sankranti inside it. A
/// lunar month is about 29.5 days and the Sun takes about
/// 30.4 days per sign, so about one month in 32 has no
/// sankranti and is counted twice. 2026 has one: Adhik
/// Jyeshtha, 17 May to 15 June.
List<AdhikaMonth> adhikaMonthsInYear(int year) {
  final List<DateTime> newMoons = newMoonMoments(year);
  final List<DateTime> fullMoons = fullMoonMoments(year);
  final List<AdhikaMonth> found = <AdhikaMonth>[];
  for (int i = 0; i + 1 < newMoons.length; i++) {
    final DateTime start = newMoons[i];
    final DateTime end = newMoons[i + 1];
    if (start.isBefore(DateTime.utc(year - 1, 12, 1))) continue;
    if (start.isAfter(DateTime.utc(year, 12, 31))) continue;
    final List<DateTime> sankrantis =
        sankrantiMoments(start, end).where(
      (DateTime m) => m.isAfter(start) && m.isBefore(end),
    ).toList();
    if (sankrantis.isNotEmpty) continue;
    final DateTime purnima = fullMoons.firstWhere(
      (DateTime m) => m.isAfter(start) && m.isBefore(end),
    );
    found.add(
      AdhikaMonth(
        name: _monthFromSunSign(_sunSignAt(purnima)),
        start: _istDate(start),
        end: _istDate(end),
      ),
    );
  }
  return found;
}

/// Whether the lunar month holding [day] is an Adhika month.
bool isAdhikaMonth(DateTime day) {
  final DateTime noonUtc = _utcFromIst(
    DateTime(day.year, day.month, day.day, 12),
  );
  final DateTime start = _phaseBefore(noonUtc, 0);
  final DateTime end = _phaseAfter(noonUtc, 0);
  final List<DateTime> sankrantis =
      sankrantiMoments(start, end).where(
    (DateTime m) => m.isAfter(start) && m.isBefore(end),
  ).toList();
  return sankrantis.isEmpty;
}

/// One inauspicious or auspicious window in the day.
class TimeWindow {
  const TimeWindow({
    required this.label,
    required this.startHours,
    required this.endHours,
  });

  final String label;
  final double startHours;
  final double endHours;

  String get text =>
      '${formatClockHours(startHours)} to ${formatClockHours(endHours)}';

  bool overlaps(TimeWindow other) =>
      startHours < other.endHours && other.startHours < endHours;
}

/// One Choghadiya segment: a lord ruling one eighth of the
/// day or the night.
class ChoghadiyaSegment {
  const ChoghadiyaSegment({
    required this.name,
    required this.startHours,
    required this.endHours,
    required this.isGood,
  });

  final String name;
  final double startHours;
  final double endHours;

  /// Shubh, Labh and Amrit are good; Char is neutral;
  /// Udveg, Kaal and Rog are avoided.
  final bool isGood;

  String get text =>
      '$name ${formatClockHours(startHours)} to ${formatClockHours(endHours)}';
}

/// Daily timings, moonrise and moonset, paksha and lunar
/// months for one date and place.
class DailyTimings {
  const DailyTimings({
    required this.rahuKaal,
    required this.yamaganda,
    required this.gulika,
    required this.brahmaMuhurat,
    required this.choghadiyaDay,
    required this.choghadiyaNight,
    required this.moonrise,
    required this.moonset,
    required this.paksha,
    required this.lunarMonthAmanta,
    required this.lunarMonthPurnimanta,
    required this.adhika,
  });

  final TimeWindow rahuKaal;
  final TimeWindow yamaganda;
  final TimeWindow gulika;
  final TimeWindow brahmaMuhurat;
  final List<ChoghadiyaSegment> choghadiyaDay;
  final List<ChoghadiyaSegment> choghadiyaNight;

  /// Clock text, or null when the Moon does not rise or set
  /// on this local date.
  final String? moonrise;
  final String? moonset;
  final String paksha;
  final String lunarMonthAmanta;
  final String lunarMonthPurnimanta;

  /// True when this date falls in an Adhika Masa month.
  final bool adhika;
}

/// The Kala Velai part tables, counted in 1.5 hour parts
/// from sunrise, Monday first. Rahu Kaal matches the table
/// the base engine already uses; Yamaganda and Gulika are
/// the same standard tables.
const List<int> kRahuKaalParts = <int>[1, 6, 4, 5, 3, 2, 7];
const List<int> kYamagandaParts = <int>[3, 2, 1, 0, 6, 5, 4];
const List<int> kGulikaParts = <int>[5, 4, 3, 2, 1, 0, 6];

/// Choghadiya lords in cycle order.
const List<String> kChoghadiyaLords = <String>[
  'Udveg',
  'Char',
  'Labh',
  'Amrit',
  'Kaal',
  'Shubh',
  'Rog',
];

/// First day lord per weekday, Monday first: Monday Amrit,
/// Tuesday Kaal, Wednesday Labh, Thursday Shubh, Friday
/// Char, Saturday Rog, Sunday Udveg.
const List<int> kChoghadiyaFirstLord = <int>[3, 4, 2, 5, 1, 6, 0];

TimeWindow _partWindow(
  String label,
  double sunrise,
  int part,
) =>
    TimeWindow(
      label: label,
      startHours: sunrise + part * 1.5,
      endHours: sunrise + (part + 1) * 1.5,
    );

List<ChoghadiyaSegment> _choghadiya(
  double start,
  double end,
  int firstLord,
) {
  final double length = (end - start) / 8.0;
  final List<ChoghadiyaSegment> out = <ChoghadiyaSegment>[];
  for (int i = 0; i < 8; i++) {
    final String name =
        kChoghadiyaLords[(firstLord + i) % kChoghadiyaLords.length];
    out.add(
      ChoghadiyaSegment(
        name: name,
        startHours: start + i * length,
        endHours: start + (i + 1) * length,
        isGood: name == 'Shubh' || name == 'Labh' || name == 'Amrit',
      ),
    );
  }
  return out;
}

/// Moonrise and moonset clock texts for a local date, or
/// null for an event that does not fall on that date. The
/// Moon altitude is scanned every 10 minutes from the
/// ecliptic longitude, with the lunar latitude left out:
/// that keeps the result within about 20 minutes of a full
/// ephemeris, and the value is labelled approximate in the
/// UI. The longitude is tropical: the right ascension and
/// declination here are tropical, and they are compared
/// with tropical local sidereal time, so a sidereal
/// longitude would shift every rise and set by the
/// ayanamsa, about an hour and a half. shortcut: add the
/// lunar latitude term when sub 10 minute moonrise
/// precision is ever needed.
({String? rise, String? set}) _moonRiseSet(
  DateTime day,
  AstroPlace place,
) {
  const double eps = 23.44;
  const double threshold = -0.583;
  final double latR = place.latitude * math.pi / 180.0;
  final DateTime midnightIst = DateTime(day.year, day.month, day.day);
  String? rise;
  String? set;
  double? prevAlt;
  for (int i = 0; i <= 144; i++) {
    final DateTime utc = _utcFromIst(
      midnightIst.add(Duration(minutes: i * 10)),
    );
    final double moonLon = tropicalLongitudes(utc)['Moon']!;
    final double lonR = moonLon * math.pi / 180.0;
    const double epsR = eps * math.pi / 180.0;
    final double dec = math.asin(math.sin(epsR) * math.sin(lonR));
    double ra = math.atan2(
      math.sin(lonR) * math.cos(epsR),
      math.cos(lonR),
    );
    if (ra < 0) ra += 2 * math.pi;
    final double raHours = ra * 180.0 / math.pi / 15.0;
    final double lst =
        localSiderealTimeHours(utc, place.longitude);
    double hourAngle = (lst - raHours) * 15.0;
    if (hourAngle > 180.0) hourAngle -= 360.0;
    if (hourAngle < -180.0) hourAngle += 360.0;
    final double hourR = hourAngle * math.pi / 180.0;
    final double alt = math.asin(
      math.sin(latR) * math.sin(dec) +
          math.cos(latR) * math.cos(dec) * math.cos(hourR),
    ) * 180.0 / math.pi;
    if (prevAlt != null) {
      final bool wasBelow = prevAlt < threshold;
      final bool isBelow = alt < threshold;
      if (wasBelow != isBelow) {
        final double frac =
            (threshold - prevAlt) / (alt - prevAlt);
        final double minutes = (i - 1) * 10.0 + frac * 10.0;
        final String text = formatClockHours(minutes / 60.0);
        if (isBelow && set == null) {
          set = text;
        } else if (!isBelow && rise == null) {
          rise = text;
        }
      }
    }
    prevAlt = alt;
  }
  return (rise: rise, set: set);
}

/// The inauspicious windows and Choghadiya of one day,
/// without the moonrise scan or the lunar month work, so
/// the muhurat engine can scan a whole date range cheaply.
class DayWindows {
  const DayWindows({
    required this.rahuKaal,
    required this.yamaganda,
    required this.gulika,
    required this.brahmaMuhurat,
    required this.choghadiyaDay,
    required this.choghadiyaNight,
  });

  final TimeWindow rahuKaal;
  final TimeWindow yamaganda;
  final TimeWindow gulika;
  final TimeWindow brahmaMuhurat;
  final List<ChoghadiyaSegment> choghadiyaDay;
  final List<ChoghadiyaSegment> choghadiyaNight;
}

/// Rahu Kaal, Yamaganda, Gulika, Brahma Muhurat and
/// Choghadiya for a date and a place.
DayWindows dayWindows(DateTime day, AstroPlace place) {
  final SunTimes times = sunTimesFor(day, place);
  final int weekdayIndex = day.weekday - 1;
  final TimeWindow rahu = _partWindow(
    'Rahu Kaal',
    times.sunrise,
    kRahuKaalParts[weekdayIndex],
  );
  final TimeWindow yamaganda = _partWindow(
    'Yamaganda',
    times.sunrise,
    kYamagandaParts[weekdayIndex],
  );
  final TimeWindow gulika = _partWindow(
    'Gulika',
    times.sunrise,
    kGulikaParts[weekdayIndex],
  );
  final TimeWindow brahma = TimeWindow(
    label: 'Brahma Muhurat',
    startHours: times.sunrise - 96.0 / 60.0,
    endHours: times.sunrise - 48.0 / 60.0,
  );
  final int firstLord = kChoghadiyaFirstLord[weekdayIndex];
  final List<ChoghadiyaSegment> daySegments = _choghadiya(
    times.sunrise,
    times.sunset,
    firstLord,
  );
  final SunTimes nextTimes = sunTimesFor(
    day.add(const Duration(days: 1)),
    place,
  );
  final List<ChoghadiyaSegment> nightSegments = _choghadiya(
    times.sunset,
    nextTimes.sunrise + 24.0,
    (firstLord + 8) % kChoghadiyaLords.length,
  );
  return DayWindows(
    rahuKaal: rahu,
    yamaganda: yamaganda,
    gulika: gulika,
    brahmaMuhurat: brahma,
    choghadiyaDay: daySegments,
    choghadiyaNight: nightSegments,
  );
}

/// Daily timings for a date and a place.
DailyTimings dailyTimings(DateTime day, AstroPlace place) {
  final DayWindows windows = dayWindows(day, place);
  final ({String? rise, String? set}) moon = _moonRiseSet(day, place);
  return DailyTimings(
    rahuKaal: windows.rahuKaal,
    yamaganda: windows.yamaganda,
    gulika: windows.gulika,
    brahmaMuhurat: windows.brahmaMuhurat,
    choghadiyaDay: windows.choghadiyaDay,
    choghadiyaNight: windows.choghadiyaNight,
    moonrise: moon.rise,
    moonset: moon.set,
    paksha: pakshaFor(day),
    lunarMonthAmanta: lunarMonth(day, place),
    lunarMonthPurnimanta: lunarMonth(
      day,
      place,
      convention: LunarConvention.purnimanta,
    ),
    adhika: isAdhikaMonth(day),
  );
}
