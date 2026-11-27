import 'package:dharm_guru_shrinkhala/models/kundli.dart';
import 'package:dharm_guru_shrinkhala/services/astro.dart';
import 'package:dharm_guru_shrinkhala/services/remedies_engine.dart';
import 'package:flutter_test/flutter_test.dart';

PlanetDetail _planet(String name, String rashi, String bhava) {
  return PlanetDetail(
    name: name,
    rashi: rashi,
    bhava: bhava,
    degree: '10° 00′',
    swami: 'Jupiter',
    note: '$name in $rashi, $bhava.',
  );
}

KundliResult _handChart(List<PlanetDetail> planets) {
  return KundliResult(
    lagna: 'Dhanu',
    lagnaDegree: '10° 00′',
    moonRashi: 'Kanya',
    moonNakshatra: 'Hasta',
    tithiAtBirth: 'Shukla Pratipada',
    planets: planets,
    place: kDefaultPlace,
    placeApproximate: false,
    timeApproximate: false,
  );
}

void main() {
  test('P7R1 detailed remedy for weak Sun has mantra gemstone rudraksha', () {
    final PlanetRemedyDetail detail = RemedyEngine.detailedForPlanet(
      planet: 'Sun',
      reason: 'Sun is weak: debilitated in Tula.',
    );
    expect(detail.mantra, 'Om Suryaya Namah');
    expect(detail.mantraCount, 11);
    expect(detail.gemstone, 'Ruby');
    expect(detail.rudraksha, '1 Mukhi Rudraksha');
    expect(detail.donation, contains('Wheat'));
    expect(detail.donationDay, 'Sunday');
    expect(detail.fastingDay, 'Sunday');
    expect(detail.fastingRule, isNotEmpty);
    expect(detail.ritual, contains('rising Sun'));
    expect(detail.reason, contains('debilitated in Tula'));
    expect(PlanetRemedyDetail.gemstoneNote, contains('astrologer'));
  });

  test('P7R2 every planet in the dataset has all remedy fields', () {
    for (final String planet in <String>[
      'Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus',
      'Saturn', 'Rahu', 'Ketu',
    ]) {
      final PlanetRemedyDetail detail =
          RemedyEngine.detailedForPlanet(planet: planet, reason: 'test');
      expect(detail.mantra, isNotEmpty, reason: planet);
      expect(detail.mantraCount, 11, reason: planet);
      expect(detail.gemstone, isNotEmpty, reason: planet);
      expect(detail.rudraksha, isNotEmpty, reason: planet);
      expect(detail.donation, isNotEmpty, reason: planet);
      expect(detail.donationDay, isNotEmpty, reason: planet);
      expect(detail.fastingDay, isNotEmpty, reason: planet);
      expect(detail.fastingRule, isNotEmpty, reason: planet);
      expect(detail.ritual, isNotEmpty, reason: planet);
    }
  });

  test('P7R3 detailed remedies keep the Mahadasha link', () {
    final KundliResult kundli = _handChart(<PlanetDetail>[
      _planet('Sun', 'Tula', 'Bhava 1'),
      _planet('Saturn', 'Mesha', 'Bhava 8'),
      _planet('Venus', 'Simha', 'Bhava 5'),
    ]);
    final DateTime birth = DateTime(2000, 1, 15, 7, 30);
    final DateTime asOf = DateTime(2026, 11, 27);
    final List<PlanetRemedyDetail> details =
        RemedyEngine.detailedRemedies(
      kundli: kundli,
      birthLocal: birth,
      asOf: asOf,
    );
    expect(
      details.map((PlanetRemedyDetail d) => d.planet).toList(),
      containsAll(<String>['Sun', 'Saturn']),
    );
    final DashaInfo dasha = vimshottariDasha(
      birthLocal: birth,
      asOf: asOf,
    );
    expect(
      details.map((PlanetRemedyDetail d) => d.planet).toList(),
      contains(dasha.lord),
    );
    final PlanetRemedyDetail dashaDetail = details.firstWhere(
      (PlanetRemedyDetail d) => d.planet == dasha.lord,
    );
    expect(dashaDetail.reason, contains('Mahadasha'));
    // Same selection as derive: weak planets plus dasha lord.
    expect(details.length, greaterThanOrEqualTo(2));
  });

  test('P7R4 detailed remedies are deterministic', () {
    final KundliResult kundli = _handChart(<PlanetDetail>[
      _planet('Sun', 'Tula', 'Bhava 1'),
      _planet('Saturn', 'Mesha', 'Bhava 8'),
    ]);
    final List<PlanetRemedyDetail> first =
        RemedyEngine.detailedRemedies(
      kundli: kundli,
      birthLocal: DateTime(2000, 1, 15, 7, 30),
      asOf: DateTime(2026, 11, 27),
    );
    final List<PlanetRemedyDetail> second =
        RemedyEngine.detailedRemedies(
      kundli: kundli,
      birthLocal: DateTime(2000, 1, 15, 7, 30),
      asOf: DateTime(2026, 11, 27),
    );
    expect(
      second.map((PlanetRemedyDetail d) => d.planet).toList(),
      first.map((PlanetRemedyDetail d) => d.planet).toList(),
    );
    expect(
      second.map((PlanetRemedyDetail d) => d.mantra).toList(),
      first.map((PlanetRemedyDetail d) => d.mantra).toList(),
    );
  });

  test('P7R5 Saturn remedy is the Saturday set', () {
    final PlanetRemedyDetail detail = RemedyEngine.detailedForPlanet(
      planet: 'Saturn',
      reason: 'Saturn is weak: in Bhava 8.',
    );
    expect(detail.gemstone, 'Blue Sapphire');
    expect(detail.rudraksha, '7 Mukhi Rudraksha');
    expect(detail.donationDay, 'Saturday');
    expect(detail.fastingDay, 'Saturday');
    expect(detail.ritual, contains('peepal'));
  });
}
