import '../models/kundli.dart';
import 'astro.dart';

/// Phase 6 gochar: transits of the planets over the natal
/// chart, Sade Sati and Dhaiya.
///
/// A transit is read from the real positions: the planet
/// sidereal longitude on the chosen date against the natal
/// longitude and the lagna from the birth chart. The date
/// can be past, current or future, so the same function
/// serves historical and future transits. No transit is
/// predicted from a table.
///
/// Sade Sati follows the standard rule: Saturn transiting
/// the Moon sign, the sign before it, or the sign after
/// it. Dhaiya is Saturn transiting the 4th or 8th sign from
/// the Moon. Source: the classical Saturn transit rules.

/// One planet in transit.
class TransitPosition {
  const TransitPosition({
    required this.planet,
    required this.transitSign,
    required this.transitDegree,
    required this.natalSign,
    required this.natalHouse,
    required this.houseFromLagna,
    required this.explanation,
  });

  final String planet;
  final String transitSign;
  final String transitDegree;
  final String natalSign;

  /// House the planet sits in natally, counted from lagna.
  final int natalHouse;

  /// House the transiting planet sits in, counted from lagna.
  final int houseFromLagna;

  final String explanation;
}

/// Sade Sati phase for a Moon sign and a Saturn sign.
class SadeSatiStatus {
  const SadeSatiStatus({
    required this.phase,
    required this.dhaiya,
    required this.explanation,
  });

  /// none, rising, peak or setting.
  final String phase;

  /// True when Saturn transits the 4th or 8th from the Moon.
  final bool dhaiya;

  final String explanation;
}

/// Sade Sati and Dhaiya from the Moon sign and the Saturn
/// transit sign, both as rashi names.
SadeSatiStatus sadeSatiFor({
  required String moonSign,
  required String saturnSign,
}) {
  final int moon = kRashis.indexOf(moonSign);
  final int saturn = kRashis.indexOf(saturnSign);
  final int diff = (saturn - moon + 12) % 12;
  final bool dhaiya = diff == 3 || diff == 7;
  final String phase = switch (diff) {
    11 => 'rising',
    0 => 'peak',
    1 => 'setting',
    _ => 'none',
  };
  final String explanation = switch (phase) {
    'rising' =>
      'Saturn transits the sign before the Moon sign, Sade Sati rising.',
    'peak' =>
      'Saturn transits the Moon sign itself, Sade Sati peak.',
    'setting' =>
      'Saturn transits the sign after the Moon sign, Sade Sati setting.',
    _ => dhaiya
        ? 'Saturn transits the ${diff + 1}th sign from the Moon, Dhaiya, no Sade Sati.'
        : 'Saturn is not in Sade Sati or Dhaiya from the Moon sign.',
  };
  return SadeSatiStatus(
    phase: phase,
    dhaiya: dhaiya,
    explanation: explanation,
  );
}

/// Transits for a birth chart on a date. [date] is the
/// transit date at local noon IST; it can be past, current
/// or future.
List<TransitPosition> gocharFor({
  required DateTime birthLocal,
  required String placeText,
  required DateTime date,
  bool timeKnown = true,
}) {
  final KundliResult natal = KundliCalculator.calculate(
    birthLocal: birthLocal,
    placeText: placeText,
    timeKnown: timeKnown,
  );
  final int lagnaIndex = kRashis.indexOf(natal.lagna);
  final DateTime noonUtc = DateTime(
    date.year, date.month, date.day, 12,
  ).subtract(const Duration(hours: 5, minutes: 30));
  final Map<String, double> transit = siderealLongitudes(noonUtc);
  final List<TransitPosition> out = <TransitPosition>[];
  for (final PlanetDetail planet in natal.planets) {
    final double lon = transit[planet.name]!;
    final int signIndex = (lon ~/ 30.0) % 12;
    final String transitSign = kRashis[signIndex];
    final int houseFromLagna =
        ((signIndex - lagnaIndex) % 12 + 12) % 12 + 1;
    final int natalHouse =
        int.parse(planet.bhava.replaceAll('Bhava ', ''));
    out.add(
      TransitPosition(
        planet: planet.name,
        transitSign: transitSign,
        transitDegree: formatDegree(lon),
        natalSign: planet.rashi,
        natalHouse: natalHouse,
        houseFromLagna: houseFromLagna,
        explanation:
            '${planet.name} transits $transitSign at ${formatDegree(lon)}, '
            'natal in ${planet.rashi} (Bhava $natalHouse), '
            'now in Bhava $houseFromLagna from lagna.',
      ),
    );
  }
  return out;
}

/// Sade Sati and Dhaiya for a birth chart on a date.
SadeSatiStatus sadeSatiOn({
  required DateTime birthLocal,
  required String placeText,
  required DateTime date,
  bool timeKnown = true,
}) {
  final KundliResult natal = KundliCalculator.calculate(
    birthLocal: birthLocal,
    placeText: placeText,
    timeKnown: timeKnown,
  );
  final DateTime noonUtc = DateTime(
    date.year, date.month, date.day, 12,
  ).subtract(const Duration(hours: 5, minutes: 30));
  final Map<String, double> transit = siderealLongitudes(noonUtc);
  final double saturnLon = transit['Saturn']!;
  final String saturnSign = kRashis[(saturnLon ~/ 30.0) % 12];
  return sadeSatiFor(moonSign: natal.moonRashi, saturnSign: saturnSign);
}
