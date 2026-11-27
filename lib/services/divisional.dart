import '../models/kundli.dart';
import 'astro.dart';

/// Divisional charts (vargas), dignity, retrograde, combustion,
/// aspects and conjunctions. Every number comes from the shared
/// engine in astro.dart: the sidereal longitudes on
/// PlanetDetail.longitude. Nothing here takes a hand entered
/// planet position, and astro.dart is not rewritten to serve it.
///
/// Divisional rules follow Brihat Parashara Hora Shastra
/// chapter 6 as used by standard software: each rule below
/// names its start sign and its step, so any rule can be
/// checked by hand from one longitude.
///
/// North Indian chart: houses are fixed, signs move. House 1
/// is the top centre diamond, houses run anticlockwise, the
/// four diamonds are houses 1, 4, 7, 10. South Indian chart:
/// signs are fixed in a 4 by 4 grid, houses move, Lagna is
/// marked. Both draw the same chart.

/// One divisional chart: its number and its classical name.
class DivisionalChart {
  const DivisionalChart(this.divisor, this.name);

  /// D1, D2, D3 and so on.
  final int divisor;
  final String name;
}

/// The 16 divisional charts the app computes.
const List<DivisionalChart> kDivisionalCharts =
    <DivisionalChart>[
  DivisionalChart(1, 'Rasi'),
  DivisionalChart(2, 'Hora'),
  DivisionalChart(3, 'Drekkana'),
  DivisionalChart(4, 'Chaturthamsha'),
  DivisionalChart(7, 'Saptamsha'),
  DivisionalChart(9, 'Navamsha'),
  DivisionalChart(10, 'Dashamsha'),
  DivisionalChart(12, 'Dwadashamsha'),
  DivisionalChart(16, 'Shodashamsha'),
  DivisionalChart(20, 'Vimshamsha'),
  DivisionalChart(24, 'Chaturvimshamsha'),
  DivisionalChart(27, 'Saptavimshamsha'),
  DivisionalChart(30, 'Trimshamsha'),
  DivisionalChart(40, 'Khavedamsha'),
  DivisionalChart(45, 'Akshavedamsha'),
  DivisionalChart(60, 'Shashtiamsha'),
];

int _signIndex(double siderealLongitude) =>
    (siderealLongitude ~/ 30.0) % 12;

/// Degrees inside the sign, 0 to 30.
double _within(double siderealLongitude) =>
    siderealLongitude % 30.0;

bool _isOddSign(int sign) => sign % 2 == 0;

/// Movable signs: Mesha, Karka, Tula, Makara.
bool _isMovableSign(int sign) =>
    sign == 0 || sign == 3 || sign == 6 || sign == 9;

/// Fixed signs: Vrishabha, Simha, Vrishchika, Kumbha.
bool _isFixedSign(int sign) =>
    sign == 1 || sign == 4 || sign == 7 || sign == 10;

/// Divisional rashi for one sidereal longitude. [divisor] is
/// the D number: 1, 2, 3, 4, 7, 9, 10, 12, 16, 20, 24, 27,
/// 30, 40, 45 or 60. Anything else throws ArgumentError.
String divisionalSign({
  required double siderealLongitude,
  required int divisor,
}) {
  final int sign = _signIndex(siderealLongitude);
  final double within = _within(siderealLongitude);
  final bool odd = _isOddSign(sign);
  String from(int start, int part) =>
      kRashis[(start + part) % 12];
  switch (divisor) {
    case 1:
      return kRashis[sign];
    case 2:
      // Hora: odd signs, first half Sun hora Simha, second
      // half Moon hora Karka; even signs the other way round.
      if (odd) {
        return within < 15.0 ? 'Simha' : 'Karka';
      }
      return within < 15.0 ? 'Karka' : 'Simha';
    case 3:
      // Drekkana: thirds counted 1st, 5th, 9th from the sign.
      return from(sign, (within ~/ 10.0) * 4);
    case 4:
      // Chaturthamsha: quarters counted 1st, 4th, 7th, 10th.
      return from(sign, (within ~/ 7.5) * 3);
    case 7:
      // Saptamsha: odd signs from the sign, even signs from
      // the 7th from it.
      final int start = odd ? sign : sign + 6;
      return from(start, (within / (30.0 / 7.0)).floor());
    case 9:
      // Navamsha: movable signs from the sign, fixed signs
      // from the 9th from it, dual signs from the 5th.
      final int start = _isMovableSign(sign)
          ? sign
          : _isFixedSign(sign)
              ? sign + 8
              : sign + 4;
      return from(start, (within / (30.0 / 9.0)).floor());
    case 10:
      // Dashamsha: odd signs from the sign, even signs from
      // the 9th from it.
      final int start = odd ? sign : sign + 8;
      return from(start, (within / 3.0).floor());
    case 12:
      // Dwadashamsha: counted from the sign itself.
      return from(sign, (within / 2.5).floor());
    case 16:
      // Shodashamsha: odd signs from Mesha, even from Simha.
      final int start = odd ? 0 : 4;
      return from(start, (within / (30.0 / 16.0)).floor());
    case 20:
      // Vimshamsha: odd signs from Mesha, even from Dhanu.
      final int start = odd ? 0 : 8;
      return from(start, (within / 1.5).floor());
    case 24:
      // Chaturvimshamsha: odd signs from Simha, even from
      // Karka.
      final int start = odd ? 4 : 3;
      return from(start, (within / 1.25).floor());
    case 27:
      // Saptavimshamsha (Bhamsa): odd signs from Mesha, even
      // from Karka.
      final int start = odd ? 0 : 3;
      return from(start, (within / (30.0 / 27.0)).floor());
    case 30:
      // Trimshamsha: unequal parts from the BPHS table, by
      // odd and even sign.
      if (odd) {
        if (within < 5.0) return 'Mesha';
        if (within < 10.0) return 'Kumbha';
        if (within < 18.0) return 'Dhanu';
        if (within < 25.0) return 'Mithuna';
        return 'Tula';
      }
      if (within < 5.0) return 'Vrishabha';
      if (within < 12.0) return 'Kanya';
      if (within < 20.0) return 'Meena';
      if (within < 25.0) return 'Makara';
      return 'Vrishchika';
    case 40:
      // Khavedamsha: odd signs from Mesha, even from Tula.
      final int start = odd ? 0 : 6;
      return from(start, (within / 0.75).floor());
    case 45:
      // Akshavedamsha: odd signs from Mesha, even from Simha.
      final int start = odd ? 0 : 4;
      return from(start, (within / (30.0 / 45.0)).floor());
    case 60:
      // Shashtiamsha: odd signs from the sign, even signs
      // from the 9th from it, half a degree per part.
      final int start = odd ? sign : sign + 8;
      return from(start, (within / 0.5).floor());
    default:
      throw ArgumentError('No divisional rule for D$divisor');
  }
}

/// Whole divisional chart: planet name to divisional rashi.
Map<String, String> divisionalChart(
  KundliResult kundli,
  int divisor,
) {
  return <String, String>{
    for (final PlanetDetail p in kundli.planets)
      p.name: divisionalSign(
        siderealLongitude: p.longitude,
        divisor: divisor,
      ),
  };
}

/// Dignity of a planet in a sign. Exaltation and debilitation
/// use the whole sign, the classical software convention; the
/// exaltation degree is named in the table comment for the
/// reader. Moolatrikona needs the degree inside the sign.
enum Dignity { exalted, debilitated, moolatrikona, ownSign, neutral }

class _DignityRow {
  const _DignityRow({
    required this.exaltedSign,
    required this.debilitatedSign,
    required this.ownSigns,
    required this.moolatrikonaSign,
    required this.moolatrikonaFrom,
    required this.moolatrikonaTo,
  });

  final int exaltedSign;
  final int debilitatedSign;
  final List<int> ownSigns;
  final int moolatrikonaSign;
  final double moolatrikonaFrom;
  final double moolatrikonaTo;
}

// Sign indexes: 0 Mesha, 1 Vrishabha, 2 Mithuna, 3 Karka,
// 4 Simha, 5 Kanya, 6 Tula, 7 Vrishchika, 8 Dhanu, 9 Makara,
// 10 Kumbha, 11 Meena. Exaltation degrees: Sun 10 Mesha,
// Moon 3 Vrishabha, Mars 28 Makara, Mercury 15 Kanya,
// Jupiter 5 Karka, Venus 27 Meena, Saturn 20 Tula.
const Map<String, _DignityRow> _dignityTable =
    <String, _DignityRow>{
  'Sun': _DignityRow(
    exaltedSign: 0,
    debilitatedSign: 6,
    ownSigns: <int>[4],
    moolatrikonaSign: 4,
    moolatrikonaFrom: 0,
    moolatrikonaTo: 20,
  ),
  'Moon': _DignityRow(
    exaltedSign: 1,
    debilitatedSign: 7,
    ownSigns: <int>[3],
    moolatrikonaSign: 1,
    moolatrikonaFrom: 3,
    moolatrikonaTo: 30,
  ),
  'Mars': _DignityRow(
    exaltedSign: 9,
    debilitatedSign: 3,
    ownSigns: <int>[0, 7],
    moolatrikonaSign: 0,
    moolatrikonaFrom: 0,
    moolatrikonaTo: 12,
  ),
  'Mercury': _DignityRow(
    exaltedSign: 5,
    debilitatedSign: 11,
    ownSigns: <int>[2, 5],
    moolatrikonaSign: 5,
    moolatrikonaFrom: 15,
    moolatrikonaTo: 20,
  ),
  'Jupiter': _DignityRow(
    exaltedSign: 3,
    debilitatedSign: 9,
    ownSigns: <int>[8, 11],
    moolatrikonaSign: 8,
    moolatrikonaFrom: 0,
    moolatrikonaTo: 10,
  ),
  'Venus': _DignityRow(
    exaltedSign: 11,
    debilitatedSign: 5,
    ownSigns: <int>[1, 6],
    moolatrikonaSign: 6,
    moolatrikonaFrom: 0,
    moolatrikonaTo: 15,
  ),
  'Saturn': _DignityRow(
    exaltedSign: 6,
    debilitatedSign: 0,
    ownSigns: <int>[9, 10],
    moolatrikonaSign: 10,
    moolatrikonaFrom: 0,
    moolatrikonaTo: 20,
  ),
};

/// Dignity of [planet] at [siderealLongitude]. Rahu and Ketu
/// have no agreed exaltation or own sign, so they are always
/// neutral. Precedence: exalted, debilitated, moolatrikona,
/// own sign, neutral.
Dignity dignityOf(String planet, double siderealLongitude) {
  final _DignityRow? row = _dignityTable[planet];
  if (row == null) return Dignity.neutral;
  final int sign = _signIndex(siderealLongitude);
  final double within = _within(siderealLongitude);
  if (sign == row.exaltedSign) return Dignity.exalted;
  if (sign == row.debilitatedSign) return Dignity.debilitated;
  if (sign == row.moolatrikonaSign &&
      within >= row.moolatrikonaFrom &&
      within < row.moolatrikonaTo) {
    return Dignity.moolatrikona;
  }
  if (row.ownSigns.contains(sign)) return Dignity.ownSign;
  return Dignity.neutral;
}

/// Signed daily motion of a planet in degrees per day,
/// from its tropical longitude a day either side of [utc].
/// Negative means retrograde. Sun and Moon are always direct.
double planetMotion({required String planet, required DateTime utc}) {
  final double before = tropicalLongitudeAt(
    planet: planet,
    utc: utc.subtract(const Duration(days: 1)),
  );
  final double after = tropicalLongitudeAt(
    planet: planet,
    utc: utc.add(const Duration(days: 1)),
  );
  double motion = (after - before) % 360.0;
  if (motion > 180.0) motion -= 360.0;
  return motion / 2.0;
}

/// True when [planet] moves backwards at [utc]. Rahu and
/// Ketu are always retrograde by definition; Sun and Moon
/// never are.
bool isRetrograde({required String planet, required DateTime utc}) {
  if (planet == 'Rahu' || planet == 'Ketu') return true;
  if (planet == 'Sun' || planet == 'Moon') return false;
  return planetMotion(planet: planet, utc: utc) < 0;
}

/// Combustion orbs in degrees from the Sun: Moon 12, Mars 17,
/// Mercury 14 (12 when retrograde), Jupiter 11, Venus 10
/// (8 when retrograde), Saturn 15. Rahu, Ketu and the Sun
/// itself are never combust.
const Map<String, double> kCombustionOrbs = <String, double>{
  'Moon': 12,
  'Mars': 17,
  'Mercury': 14,
  'Jupiter': 11,
  'Venus': 10,
  'Saturn': 15,
};

/// True when [planet] at [planetSidereal] sits within its
/// combustion orb of the Sun at [sunSidereal]. Pass
/// [retrograde] for Mercury and Venus, whose orbs shrink
/// when they move backwards.
bool isCombust({
  required String planet,
  required double sunSidereal,
  required double planetSidereal,
  bool retrograde = false,
}) {
  final double? orb = kCombustionOrbs[planet];
  if (orb == null) return false;
  double limit = orb;
  if (retrograde && planet == 'Mercury') limit = 12;
  if (retrograde && planet == 'Venus') limit = 8;
  double separation = (planetSidereal - sunSidereal).abs() % 360.0;
  if (separation > 180.0) separation = 360.0 - separation;
  return separation <= limit;
}

/// One Vedic aspect: [planet] looks at [targetBhava] counted
/// from the Lagna, which falls in [targetRashi]. [special]
/// is true for the extra Mars, Jupiter and Saturn aspects;
/// every planet aspects the 7th from itself.
class PlanetAspect {
  const PlanetAspect({
    required this.planet,
    required this.targetBhava,
    required this.targetRashi,
    required this.special,
  });

  final String planet;
  final int targetBhava;
  final String targetRashi;
  final bool special;
}

/// All Vedic aspects in a chart. Mars aspects the 4th, 7th
/// and 8th from itself; Jupiter the 5th, 7th and 9th; Saturn
/// the 3rd, 7th and 10th; every other planet the 7th only.
List<PlanetAspect> aspectsOf(KundliResult kundli) {
  final int lagnaIndex = kRashis.indexOf(kundli.lagna);
  final List<PlanetAspect> aspects = <PlanetAspect>[];
  for (final PlanetDetail p in kundli.planets) {
    if (p.name == 'Rahu' || p.name == 'Ketu') continue;
    final int sign = kRashis.indexOf(p.rashi);
    final List<int> offsets = <int>[7];
    if (p.name == 'Mars') offsets.addAll(<int>[4, 8]);
    if (p.name == 'Jupiter') offsets.addAll(<int>[5, 9]);
    if (p.name == 'Saturn') offsets.addAll(<int>[3, 10]);
    for (final int offset in offsets) {
      final int targetSign = (sign + offset - 1) % 12;
      final int bhava =
          ((targetSign - lagnaIndex) % 12 + 12) % 12 + 1;
      aspects.add(
        PlanetAspect(
          planet: p.name,
          targetBhava: bhava,
          targetRashi: kRashis[targetSign],
          special: offset != 7,
        ),
      );
    }
  }
  return aspects;
}

/// Two planets in one rashi, with their separation in
/// degrees. Conjunctions are read off the shared longitudes,
/// never off the degree strings.
class Conjunction {
  const Conjunction({
    required this.first,
    required this.second,
    required this.rashi,
    required this.separation,
  });

  final String first;
  final String second;
  final String rashi;
  final double separation;
}

List<Conjunction> conjunctionsOf(KundliResult kundli) {
  final List<Conjunction> found = <Conjunction>[];
  final List<PlanetDetail> planets = kundli.planets;
  for (int i = 0; i < planets.length; i++) {
    for (int j = i + 1; j < planets.length; j++) {
      if (planets[i].rashi != planets[j].rashi) continue;
      double separation =
          (planets[i].longitude - planets[j].longitude).abs();
      if (separation > 180.0) separation = 360.0 - separation;
      found.add(
        Conjunction(
          first: planets[i].name,
          second: planets[j].name,
          rashi: planets[i].rashi,
          separation: separation,
        ),
      );
    }
  }
  return found;
}

/// North Indian chart: the position of a house. Houses are
/// fixed, signs move: house 1 is the top centre diamond and
/// houses run anticlockwise. The four diamonds are houses 1,
/// 4, 7 and 10.
String northIndianHousePosition(int house) {
  return switch (house) {
    1 => 'top diamond',
    2 => 'top left upper triangle',
    3 => 'top left lower triangle',
    4 => 'left diamond',
    5 => 'bottom left upper triangle',
    6 => 'bottom left lower triangle',
    7 => 'bottom diamond',
    8 => 'bottom right lower triangle',
    9 => 'bottom right upper triangle',
    10 => 'right diamond',
    11 => 'top right lower triangle',
    12 => 'top right upper triangle',
    _ => throw ArgumentError('No house $house'),
  };
}

/// Sign in a North Indian house for a Lagna sign index:
/// house 1 holds the Lagna sign, the rest follow in order.
int northIndianSignForHouse(int lagnaSignIndex, int house) {
  if (house < 1 || house > 12) {
    throw ArgumentError('No house $house');
  }
  return (lagnaSignIndex + house - 1) % 12;
}

/// South Indian chart: grid cell (row, column) of a sign
/// index in the fixed 4 by 4 grid. Signs run clockwise from
/// Meena at the top left; the centre four cells are empty.
({int row, int col}) southIndianCell(int signIndex) {
  return switch (signIndex) {
    11 => (row: 0, col: 0),
    0 => (row: 0, col: 1),
    1 => (row: 0, col: 2),
    2 => (row: 0, col: 3),
    3 => (row: 1, col: 3),
    4 => (row: 2, col: 3),
    5 => (row: 3, col: 3),
    6 => (row: 3, col: 2),
    7 => (row: 3, col: 1),
    8 => (row: 3, col: 0),
    9 => (row: 2, col: 0),
    10 => (row: 1, col: 0),
    _ => throw ArgumentError('No sign $signIndex'),
  };
}

/// Nakshatra pada (quarter) of a sidereal longitude, 1 to 4.
/// Each nakshatra spans 13 degrees 20 minutes; each pada is
/// 3 degrees 20 minutes.
int nakshatraPada(double siderealLongitude) {
  final double withinNakshatra =
      siderealLongitude % (40.0 / 3.0);
  return (withinNakshatra / (10.0 / 3.0)).floor() + 1;
}

/// House lordship: lord of a bhava counted from the Lagna.
/// Bhava 1 is the Lagna sign itself.
String houseLord(KundliResult kundli, int bhava) {
  if (bhava < 1 || bhava > 12) {
    throw ArgumentError('No bhava $bhava');
  }
  final int lagnaIndex = kRashis.indexOf(kundli.lagna);
  final int sign = (lagnaIndex + bhava - 1) % 12;
  return kRashiLords[sign];
}
