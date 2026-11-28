import 'astro.dart';
import 'library_content.dart';
import '../models/festival_day.dart';
import 'panchang_extra.dart';

/// Phase 5 festival engine: named festivals computed from
/// the Panchang engine, never from a stored annual table.
/// A festival is a rule: a lunar month, a paksha, a tithi
/// number, and the moment of the day its tithi is read at.
/// The scan walks every day of the year, reads the tithi at
/// that festival own observance moment, and keeps the days
/// that match. Festival dates therefore move year to year
/// with the real Moon, and an Adhika Masa month shifts the
/// festivals after it on its own.
///
/// Rule sources: the tithi and month of each festival are
/// the standard panchang rules (Diwali is Ashwin Krishna
/// Amavasya in Amanta counting, Kartika Krishna Amavasya in
/// Purnimanta counting; Holi is Phalguna Shukla Purnima, and
/// so on). The month, the paksha and the tithi are all read
/// at the festival own observance moment, so a tithi that
/// starts just after sunrise belongs to the month it starts
/// in and is never counted twice.
/// The observance moment follows the usual practice: a
/// festival is kept on the day its tithi prevails at
/// sunrise, at noon, in the afternoon, at sunset, or at
/// midnight, as the rule names. Night festivals read at
/// sunset or midnight can land a day away from a sunrise
/// reading; the rule states which moment it uses, so the
/// difference is visible, not hidden.
///
/// shortcut: the tithi is read at one fixed moment per
/// festival, not at the exact start and end of the tithi.
/// A tithi that starts minutes after the reading moment can
/// move a festival by a day against a published panchang.
/// The test allows one day either side for that reason.

/// One named festival rule.
class FestivalRule {
  const FestivalRule({
    required this.name,
    required this.lunarMonth,
    required this.paksha,
    required this.tithiNumber,
    required this.moment,
    required this.rule,
    required this.source,
  });

  /// Festival name shown in the app.
  final String name;

  /// Lunar month, for example Kartika.
  final String lunarMonth;

  /// Shukla or Krishna.
  final String paksha;

  /// Tithi number 1 to 30: 15 is Purnima, 30 is Amavasya.
  final int tithiNumber;

  /// sunrise, noon, afternoon, sunset or midnight.
  final String moment;

  /// The rule in one line, shown with the festival.
  final String rule;

  /// Where the rule comes from.
  final String source;
}

/// The named festival rules. Tithi numbers use the lunar
/// count: 1 to 15 Shukla, 16 to 30 Krishna.
const List<FestivalRule> kFestivalRules = <FestivalRule>[
  FestivalRule(
    name: 'Diwali',
    lunarMonth: 'Ashwin',
    paksha: 'Krishna',
    tithiNumber: 30,
    moment: 'sunset',
    rule: 'Ashwin Krishna Amavasya prevailing at sunset, Lakshmi Puja after sunset. In Purnimanta counting this is Kartika Krishna Amavasya.',
    source: 'Panchang tithi rule: Ashwin Krishna Amavasya, Amanta month.',
  ),
  FestivalRule(
    name: 'Holi',
    lunarMonth: 'Phalguna',
    paksha: 'Shukla',
    tithiNumber: 15,
    moment: 'sunrise',
    rule: 'Phalguna Shukla Purnima prevailing at sunrise.',
    source: 'Panchang tithi rule: Phalguna Shukla Purnima.',
  ),
  FestivalRule(
    name: 'Raksha Bandhan',
    lunarMonth: 'Shravana',
    paksha: 'Shukla',
    tithiNumber: 15,
    moment: 'sunrise',
    rule: 'Shravana Shukla Purnima prevailing at sunrise.',
    source: 'Panchang tithi rule: Shravana Shukla Purnima.',
  ),
  FestivalRule(
    name: 'Janmashtami',
    lunarMonth: 'Shravana',
    paksha: 'Krishna',
    tithiNumber: 23,
    moment: 'midnight',
    rule: 'Shravana Krishna Ashtami prevailing at midnight, the birth hour.',
    source: 'Panchang tithi rule: Shravana Krishna Ashtami at midnight.',
  ),
  FestivalRule(
    name: 'Ram Navami',
    lunarMonth: 'Chaitra',
    paksha: 'Shukla',
    tithiNumber: 9,
    moment: 'noon',
    rule: 'Chaitra Shukla Navami prevailing at noon.',
    source: 'Panchang tithi rule: Chaitra Shukla Navami.',
  ),
  FestivalRule(
    name: 'Hanuman Jayanti',
    lunarMonth: 'Chaitra',
    paksha: 'Shukla',
    tithiNumber: 15,
    moment: 'sunrise',
    rule: 'Chaitra Shukla Purnima prevailing at sunrise.',
    source: 'Panchang tithi rule: Chaitra Shukla Purnima.',
  ),
  FestivalRule(
    name: 'Maha Shivratri',
    lunarMonth: 'Magha',
    paksha: 'Krishna',
    tithiNumber: 29,
    moment: 'sunset',
    rule: 'Magha Krishna Chaturdashi prevailing at sunset and through the night. In Purnimanta counting this is Phalguna Krishna Chaturdashi.',
    source: 'Panchang tithi rule: Magha Krishna Chaturdashi, Amanta month.',
  ),
  FestivalRule(
    name: 'Ganesh Chaturthi',
    lunarMonth: 'Bhadrapada',
    paksha: 'Shukla',
    tithiNumber: 4,
    moment: 'noon',
    rule: 'Bhadrapada Shukla Chaturthi prevailing at noon.',
    source: 'Panchang tithi rule: Bhadrapada Shukla Chaturthi.',
  ),
  FestivalRule(
    name: 'Dussehra',
    lunarMonth: 'Ashwin',
    paksha: 'Shukla',
    tithiNumber: 10,
    moment: 'afternoon',
    rule: 'Ashwin Shukla Dashami prevailing in the afternoon.',
    source: 'Panchang tithi rule: Ashwin Shukla Dashami.',
  ),
  FestivalRule(
    name: 'Chaitra Navratri begins',
    lunarMonth: 'Chaitra',
    paksha: 'Shukla',
    tithiNumber: 1,
    moment: 'sunset',
    rule: 'Chaitra Shukla Pratipada prevailing at sunset.',
    source: 'Panchang tithi rule: Chaitra Shukla Pratipada.',
  ),
  FestivalRule(
    name: 'Shardiya Navratri begins',
    lunarMonth: 'Ashwin',
    paksha: 'Shukla',
    tithiNumber: 1,
    moment: 'sunset',
    rule: 'Ashwin Shukla Pratipada prevailing at sunset.',
    source: 'Panchang tithi rule: Ashwin Shukla Pratipada.',
  ),
];

// Memoized named festivals: the scan is pure for one year
// and place, and the Panchang and Library screens ask for
// the same year on every build. Entries are shared and
// must not be mutated.
final Map<String, List<FestivalDay>> _namedFestivalsCache =
    <String, List<FestivalDay>>{};

/// Named festivals for a Gregorian year, computed day by
/// day from the engine. Makar Sankranti is solar: the day
/// the sidereal Sun enters Makara. The list is sorted by
/// date and holds one entry per festival. Memoized, see
/// _namedFestivalsCache above.
List<FestivalDay> namedFestivals({
  required int year,
  AstroPlace place = kDefaultPlace,
}) {
  final String key =
      '$year|${place.name}|${place.latitude}|${place.longitude}';
  final List<FestivalDay>? cached = _namedFestivalsCache[key];
  if (cached != null) {
    return cached;
  }
  final List<FestivalDay> found = _namedFestivals(year, place);
  _namedFestivalsCache[key] = found;
  return found;
}

List<FestivalDay> _namedFestivals(int year, AstroPlace place) {
  final List<FestivalDay> found = <FestivalDay>[];
  DateTime day = DateTime(year, 1, 1);
  final DateTime last = DateTime(year, 12, 31);
  DateTime? prevNoonUtc;
  int prevSunSign = -1;
  while (!day.isAfter(last)) {
    // The month, the paksha and the tithi are all read at
    // the rule own observance moment. Reading the paksha at
    // noon while the tithi is read at sunrise loses a
    // Purnima that falls between sunrise and noon, and
    // reading the month at noon while the tithi is read at
    // sunset counts a Pratipada twice: once on the first
    // day of its month and once on the last day of the
    // month before it. The month is computed once per
    // distinct moment, not once per rule.
    //
    // Sunrise and sunset are computed once per day and the
    // tithi once per distinct moment, for the same reason:
    // the twelve rules share five moments, and recomputing
    // them per rule made the year scan seconds slow.
    final SunTimes times = sunTimesFor(day, place);
    final Map<String, String> monthAtMoment = <String, String>{};
    final Map<String, int> tithiAtMoment = <String, int>{};
    for (final FestivalRule rule in kFestivalRules) {
      final String month = monthAtMoment.putIfAbsent(
        rule.moment,
        () => lunarMonthAtUtc(
          observanceMoment(day, place, rule.moment, times: times),
        ),
      );
      if (rule.lunarMonth != month) continue;
      final int tithi = tithiAtMoment.putIfAbsent(
        rule.moment,
        () => tithiNumberAtMoment(
          day,
          place,
          rule.moment,
          times: times,
        ),
      );
      final String pakshaName = tithi <= 15 ? 'Shukla' : 'Krishna';
      if (rule.paksha != pakshaName) continue;
      if (tithi != rule.tithiNumber) continue;
      found.add(
        FestivalDay(
          date: day,
          tithi: PanchangCalculator.forDate(day, place).tithi,
          observance: rule.name,
          rule: '${rule.rule} Source: ${rule.source}',
        ),
      );
    }
    // Makar Sankranti is solar: the day the sidereal Sun
    // enters Makara. The ingress moment is bisected between
    // two noon readings, and the festival takes the IST date
    // of that moment, not the day after it.
    final DateTime noonUtc =
        DateTime.utc(day.year, day.month, day.day, 6, 30);
    final double sunLon = siderealLongitudes(noonUtc)['Sun']!;
    final int sunSign = (sunLon ~/ 30.0) % 12;
    if (prevSunSign == 8 && sunSign == 9 && prevNoonUtc != null) {
      DateTime lo = prevNoonUtc;
      DateTime hi = noonUtc;
      for (int i = 0; i < 40; i++) {
        final DateTime mid = lo.add(
          Duration(microseconds: hi.difference(lo).inMicroseconds ~/ 2),
        );
        final double midLon = siderealLongitudes(mid)['Sun']!;
        if (((midLon ~/ 30.0) % 12) == 8) {
          lo = mid;
        } else {
          hi = mid;
        }
      }
      final DateTime ingress = lo.add(
        Duration(microseconds: hi.difference(lo).inMicroseconds ~/ 2),
      );
      final DateTime ist =
          ingress.add(const Duration(hours: 5, minutes: 30));
      final DateTime sankrantiDay =
          DateTime(ist.year, ist.month, ist.day);
      found.add(
        FestivalDay(
          date: sankrantiDay,
          tithi:
              PanchangCalculator.forDate(sankrantiDay, place).tithi,
          observance: 'Makar Sankranti',
          rule: 'Sidereal Sun enters Makara. Source: solar ingress, computed from the engine Sun longitude.',
        ),
      );
    }
    prevNoonUtc = noonUtc;
    prevSunSign = sunSign;
    day = day.add(const Duration(days: 1));
  }
  found.sort((FestivalDay a, FestivalDay b) => a.date.compareTo(b.date));
  return found;
}
