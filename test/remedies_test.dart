import 'package:dharm_guru_shrinkhala/models/kundli.dart';
import 'package:dharm_guru_shrinkhala/models/remedies.dart';
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
  test('weak planets are debilitated or in bhava 6, 8 or 12', () {
    final KundliResult kundli = _handChart(<PlanetDetail>[
      _planet('Sun', 'Tula', 'Bhava 1'),
      _planet('Saturn', 'Mesha', 'Bhava 8'),
      _planet('Venus', 'Simha', 'Bhava 5'),
    ]);
    final List<WeakPlanet> weak = RemedyEngine.weakPlanets(kundli);
    expect(
      weak.map((WeakPlanet w) => w.name).toList(),
      <String>['Sun', 'Saturn'],
    );
    expect(weak.first.reason, contains('debilitated in Tula'));
    expect(weak.last.reason, contains('in Bhava 8'));
  });

  test('derive lists weak planets and the current dasha lord', () {
    final KundliResult kundli = _handChart(<PlanetDetail>[
      _planet('Sun', 'Tula', 'Bhava 1'),
      _planet('Saturn', 'Mesha', 'Bhava 8'),
      _planet('Venus', 'Simha', 'Bhava 5'),
    ]);
    final DateTime birth = DateTime(2000, 1, 15, 7, 30);
    final DateTime asOf = DateTime(2026, 11, 27);
    final List<Remedy> remedies = RemedyEngine.derive(
      kundli: kundli,
      birthLocal: birth,
      asOf: asOf,
    );
    final List<String> titles =
        remedies.map((Remedy r) => r.title).toList();
    expect(titles, contains('For weak Sun'));
    expect(titles, contains('For weak Saturn'));
    final DashaInfo dasha = vimshottariDasha(
      birthLocal: birth,
      asOf: asOf,
    );
    if (dasha.lord == 'Sun' || dasha.lord == 'Saturn') {
      expect(
        titles.where((String t) => t.startsWith('Current Mahadasha')),
        isEmpty,
      );
    } else {
      expect(titles, contains('Current Mahadasha: ${dasha.lord}'));
    }
  });

  test('derive with no weak planet still returns the dasha card', () {
    final KundliResult kundli = _handChart(<PlanetDetail>[
      _planet('Sun', 'Mesha', 'Bhava 1'),
      _planet('Moon', 'Karka', 'Bhava 1'),
      _planet('Mars', 'Simha', 'Bhava 1'),
      _planet('Mercury', 'Kanya', 'Bhava 1'),
      _planet('Jupiter', 'Dhanu', 'Bhava 1'),
      _planet('Venus', 'Tula', 'Bhava 1'),
      _planet('Saturn', 'Makara', 'Bhava 1'),
      _planet('Rahu', 'Mithuna', 'Bhava 1'),
      _planet('Ketu', 'Dhanu', 'Bhava 1'),
    ]);
    final List<Remedy> remedies = RemedyEngine.derive(
      kundli: kundli,
      birthLocal: DateTime(2000, 1, 15, 7, 30),
      asOf: DateTime(2026, 11, 27),
    );
    expect(remedies.length, 1);
    expect(remedies.first.title, startsWith('Current Mahadasha: '));
    expect(remedies.first.action, 'ask');
  });

  test('Vimshottari opens with the Moon nakshatra lord', () {
    final DateTime birth = DateTime(1998, 3, 14, 6, 25);
    // Moon in Uttara Phalguni, whose lord is the Sun, 6 years.
    // The Moon is almost through the nakshatra at birth, so
    // the Sun balance is short, about 226 days.
    final DashaInfo first = vimshottariDasha(
      birthLocal: birth,
      asOf: DateTime(1998, 6, 1),
    );
    expect(first.lord, 'Sun');
    expect(first.start, birth);
    expect(first.end.isAfter(DateTime(1998, 6, 1)), isTrue);
    // Two years later the Sun balance is over and the Moon
    // dasha, 10 years, is running.
    final DashaInfo later = vimshottariDasha(
      birthLocal: birth,
      asOf: DateTime(2000, 3, 14),
    );
    expect(later.lord, 'Moon');
    expect(later.start, first.end);
  });
}
