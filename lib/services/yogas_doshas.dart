import '../models/kundli.dart';
import 'astro.dart';

/// Phase 6 yogas and doshas, computed from the real chart.
///
/// Raj Yoga: a kendra lord (1st, 4th, 7th or 10th house)
/// and a trikona lord (1st, 5th or 9th house) in the same
/// sign, or in mutual exchange. Dhana Yoga: lords of the
/// 2nd, 5th, 9th and 11th houses in the same sign or in
/// mutual exchange. Source: the classical yoga rules in
/// Brihat Parashara Hora Shastra.
///
/// Mangal Dosha: Mars in the 1st, 2nd, 4th, 7th, 8th or
/// 12th house from lagna, from the Moon, or from Venus.
/// Mars in its own sign or exalted cancels the dosha, per
/// the classical exception.
///
/// Kaal Sarp Dosha: all seven visible planets on one side
/// of the Rahu Ketu axis, that is, all inside the same 180
/// degree arc from Rahu to Ketu.
///
/// Every result carries its explanation: which planets and
/// houses were checked and what was found. Nothing here
/// predicts an outcome; the result states the classical
/// combination and leaves the reading to the astrologer.

/// Longitude of a planet from its rashi and degree text.
double planetLongitude(PlanetDetail planet) {
  final int sign = kRashis.indexOf(planet.rashi);
  final List<String> bits = planet.degree.split('°');
  final int deg = int.parse(bits[0]);
  final int min =
      int.parse(bits[1].replaceAll('′', '').trim());
  return sign * 30.0 + deg + min / 60.0;
}

/// House number from a Bhava text like Bhava 7.
int houseNumber(PlanetDetail planet) =>
    int.parse(planet.bhava.replaceAll('Bhava ', ''));

/// Lord planet of a house counted from lagna.
String lordOfHouse(KundliResult kundli, int house) {
  final int lagnaIndex = kRashis.indexOf(kundli.lagna);
  final int signIndex = (lagnaIndex + house - 1) % 12;
  return kRashiLords[signIndex];
}

/// Sign a planet sits in, as a rashi name.
String signOf(KundliResult kundli, String planet) {
  final PlanetDetail detail = kundli.planets.firstWhere(
    (PlanetDetail p) => p.name == planet,
  );
  return detail.rashi;
}

/// One yoga found in the chart.
class YogaResult {
  const YogaResult({
    required this.name,
    required this.planets,
    required this.explanation,
  });

  /// Raj Yoga or Dhana Yoga.
  final String name;
  final List<String> planets;
  final String explanation;
}

List<YogaResult> _associationYogas(
  KundliResult kundli,
  String name,
  List<int> firstHouses,
  List<int> secondHouses,
) {
  final List<YogaResult> found = <YogaResult>[];
  final Set<String> seen = <String>{};
  final List<String> firstLords = firstHouses
      .map((int h) => lordOfHouse(kundli, h))
      .toSet()
      .toList();
  final List<String> secondLords = secondHouses
      .map((int h) => lordOfHouse(kundli, h))
      .toSet()
      .toList();
  for (final String first in firstLords) {
    for (final String second in secondLords) {
      if (first == second) continue;
      final String firstSign = signOf(kundli, first);
      final String secondSign = signOf(kundli, second);
      final List<String> key = <String>[first, second]..sort();
      final String pair = key.join('+');
      if (seen.contains(pair)) continue;
      if (firstSign == secondSign) {
        seen.add(pair);
        found.add(
          YogaResult(
            name: name,
            planets: <String>[first, second],
            explanation:
                '$name: $first and $second together in $firstSign.',
          ),
        );
      } else {
        // Mutual exchange: each lord sits in a sign the
        // other lord rules.
        final bool exchange =
            kRashiLords[kRashis.indexOf(firstSign)] == second &&
            kRashiLords[kRashis.indexOf(secondSign)] == first;
        if (exchange) {
          seen.add(pair);
          found.add(
            YogaResult(
              name: name,
              planets: <String>[first, second],
              explanation:
                  '$name: $first in $firstSign and $second in $secondSign, mutual exchange.',
            ),
          );
        }
      }
    }
  }
  return found;
}

/// Raj Yoga and Dhana Yoga in the chart.
List<YogaResult> findYogas(KundliResult kundli) => <YogaResult>[
      ..._associationYogas(
        kundli,
        'Raj Yoga',
        <int>[1, 4, 7, 10],
        <int>[1, 5, 9],
      ),
      ..._associationYogas(
        kundli,
        'Dhana Yoga',
        <int>[2, 5, 9, 11],
        <int>[2, 5, 9, 11],
      ),
    ];

/// Mangal Dosha result.
class MangalDoshaResult {
  const MangalDoshaResult({
    required this.present,
    required this.references,
    required this.cancelled,
    required this.explanation,
  });

  final bool present;

  /// lagna, Moon or Venus, for each reference that shows it.
  final List<String> references;

  /// True when Mars in own or exalted sign cancels it.
  final bool cancelled;
  final String explanation;
}

/// Mangal Dosha from lagna, Moon and Venus.
MangalDoshaResult mangalDosha(KundliResult kundli) {
  final PlanetDetail mars = kundli.planets.firstWhere(
    (PlanetDetail p) => p.name == 'Mars',
  );
  final int marsHouse = houseNumber(mars);
  const Set<int> doshaHouses = <int>{1, 2, 4, 7, 8, 12};
  final List<String> references = <String>[];
  if (doshaHouses.contains(marsHouse)) references.add('lagna');
  final int moonIndex = kRashis.indexOf(kundli.moonRashi);
  final int marsIndex = kRashis.indexOf(mars.rashi);
  final int fromMoon = ((marsIndex - moonIndex) % 12 + 12) % 12 + 1;
  if (doshaHouses.contains(fromMoon)) references.add('Moon');
  final PlanetDetail venus = kundli.planets.firstWhere(
    (PlanetDetail p) => p.name == 'Venus',
  );
  final int venusIndex = kRashis.indexOf(venus.rashi);
  final int fromVenus =
      ((marsIndex - venusIndex) % 12 + 12) % 12 + 1;
  if (doshaHouses.contains(fromVenus)) references.add('Venus');
  final bool cancelled =
      mars.rashi == 'Mesha' ||
      mars.rashi == 'Vrishchika' ||
      mars.rashi == 'Makara';
  final bool present = references.isNotEmpty && !cancelled;
  return MangalDoshaResult(
    present: present,
    references: references,
    cancelled: cancelled,
    explanation: present
        ? 'Mangal Dosha: Mars in ${mars.rashi}, Bhava $marsHouse from lagna, '
            'Bhava $fromMoon from the Moon, Bhava $fromVenus from Venus. '
            'Found from ${references.join(', ')}.'
        : cancelled
            ? 'No Mangal Dosha: Mars in ${mars.rashi} is in own or exalted sign, so the dosha is cancelled.'
            : 'No Mangal Dosha: Mars in ${mars.rashi}, Bhava $marsHouse from lagna, '
                'Bhava $fromMoon from the Moon, Bhava $fromVenus from Venus.',
  );
}

/// Kaal Sarp Dosha result.
class KaalSarpResult {
  const KaalSarpResult({
    required this.present,
    required this.explanation,
  });

  final bool present;
  final String explanation;
}

/// Kaal Sarp Dosha: all seven visible planets on one side
/// of the Rahu Ketu axis.
KaalSarpResult kaalSarpDosha(KundliResult kundli) {
  final PlanetDetail rahu = kundli.planets.firstWhere(
    (PlanetDetail p) => p.name == 'Rahu',
  );
  final double rahuLon = planetLongitude(rahu);
  final List<double> diffs = <double>[];
  for (final PlanetDetail planet in kundli.planets) {
    if (planet.name == 'Rahu' || planet.name == 'Ketu') continue;
    final double diff =
        (planetLongitude(planet) - rahuLon + 360.0) % 360.0;
    diffs.add(diff);
  }
  final bool oneSide =
      diffs.every((double d) => d < 180.0) ||
      diffs.every((double d) => d > 180.0);
  return KaalSarpResult(
    present: oneSide,
    explanation: oneSide
        ? 'Kaal Sarp Dosha: all seven planets lie on one side of the Rahu Ketu axis.'
        : 'No Kaal Sarp Dosha: the planets sit on both sides of the Rahu Ketu axis.',
  );
}
