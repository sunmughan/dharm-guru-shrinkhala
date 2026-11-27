import 'package:dharm_guru_shrinkhala/models/kundli.dart';
import 'package:dharm_guru_shrinkhala/services/astro.dart';
import 'package:dharm_guru_shrinkhala/services/divisional.dart';
import 'package:flutter_test/flutter_test.dart';

/// Phase 4 divisional chart tests. Every expectation below is
/// hand computed from the rule in lib/services/divisional.dart
/// and written in the comment next to it, so a wrong rule
/// fails here instead of hiding in a chart.
///
/// Canonical sidereal longitudes from test/astro_test.dart:
/// Sun 329.44 Kumbha 29.44, Moon 158.63 Kanya 8.63, Mars
/// 343.44 Meena 13.44, Mercury 346.04 Meena 16.04, Jupiter
/// 315.21 Kumbha 15.21, Venus 283.78 Makara 13.78, Saturn
/// 355.78 Meena 25.78, Rahu 136.08 Simha 16.08.
void main() {
  KundliResult canonical() {
    return KundliCalculator.calculate(
      birthLocal: DateTime(1998, 3, 14, 6, 25),
      placeText: 'Jaipur, Rajasthan',
    );
  }

  group('divisionalSign', () {
    test('Sun 329.44 across the equal divisions', () {
      // Kumbha, odd sign, 29.44 inside.
      // D2 Hora: second half, Moon hora Karka.
      expect(divisionalSign(siderealLongitude: 329.44, divisor: 2), 'Karka');
      // D3: part 2, 9th from Kumbha is Tula.
      expect(divisionalSign(siderealLongitude: 329.44, divisor: 3), 'Tula');
      // D4: part 3, 10th from Kumbha is Vrishchika.
      expect(divisionalSign(siderealLongitude: 329.44, divisor: 4), 'Vrishchika');
      // D7: odd from Kumbha, part 6, Kumbha plus 6 is Simha.
      expect(divisionalSign(siderealLongitude: 329.44, divisor: 7), 'Simha');
      // D9: Kumbha fixed, start 9th from it Tula, part 8,
      // Tula plus 8 is Mithuna.
      expect(divisionalSign(siderealLongitude: 329.44, divisor: 9), 'Mithuna');
      // D10: odd from Kumbha, part 9, Kumbha plus 9 is
      // Vrishchika.
      expect(divisionalSign(siderealLongitude: 329.44, divisor: 10), 'Vrishchika');
      // D12: part 11, Kumbha plus 11 is Makara.
      expect(divisionalSign(siderealLongitude: 329.44, divisor: 12), 'Makara');
      // D16: odd from Mesha, part 15, Mesha plus 15 is Karka.
      expect(divisionalSign(siderealLongitude: 329.44, divisor: 16), 'Karka');
      // D20: odd from Mesha, part 19, Mesha plus 19 is
      // Vrishchika.
      expect(divisionalSign(siderealLongitude: 329.44, divisor: 20), 'Vrishchika');
      // D24: odd from Simha, part 23, Simha plus 23 is Karka.
      expect(divisionalSign(siderealLongitude: 329.44, divisor: 24), 'Karka');
      // D27: odd from Mesha, part 26, Mesha plus 26 is
      // Mithuna.
      expect(divisionalSign(siderealLongitude: 329.44, divisor: 27), 'Mithuna');
      // D30: odd sign, 29.44 in the 25 to 30 band, Tula.
      expect(divisionalSign(siderealLongitude: 329.44, divisor: 30), 'Tula');
      // D40: odd from Mesha, part 39, Mesha plus 39 is Karka.
      expect(divisionalSign(siderealLongitude: 329.44, divisor: 40), 'Karka');
      // D45: odd from Mesha, part 44, Mesha plus 44 is Dhanu.
      expect(divisionalSign(siderealLongitude: 329.44, divisor: 45), 'Dhanu');
      // D60: odd from Kumbha, part 58, Kumbha plus 58 is
      // Dhanu.
      expect(divisionalSign(siderealLongitude: 329.44, divisor: 60), 'Dhanu');
    });

    test('Moon 158.63 across the divisions', () {
      // Kanya, even sign, 8.63 inside.
      // D2 Hora: even sign first half, Moon hora Karka.
      expect(divisionalSign(siderealLongitude: 158.63, divisor: 2), 'Karka');
      // D3: part 0, Kanya itself.
      expect(divisionalSign(siderealLongitude: 158.63, divisor: 3), 'Kanya');
      // D7: even from 7th, Meena, part 2, Meena plus 2 is
      // Vrishabha.
      expect(divisionalSign(siderealLongitude: 158.63, divisor: 7), 'Vrishabha');
      // D9: Kanya dual, start 5th from it Makara, part 2,
      // Makara plus 2 is Meena.
      expect(divisionalSign(siderealLongitude: 158.63, divisor: 9), 'Meena');
      // D12: part 3, Kanya plus 3 is Dhanu.
      expect(divisionalSign(siderealLongitude: 158.63, divisor: 12), 'Dhanu');
      // D16: even from Simha, part 4, Simha plus 4 is Dhanu.
      expect(divisionalSign(siderealLongitude: 158.63, divisor: 16), 'Dhanu');
      // D30: even sign, 8.63 in the 5 to 12 band, Kanya.
      expect(divisionalSign(siderealLongitude: 158.63, divisor: 30), 'Kanya');
    });

    test('D9 movable fixed dual starts differ', () {
      // Mesha 10 degrees, movable, from Mesha, part 3.
      expect(divisionalSign(siderealLongitude: 10.0, divisor: 9), 'Karka');
      // Vrishabha 10 degrees, fixed, from 9th Makara, part 3.
      expect(divisionalSign(siderealLongitude: 40.0, divisor: 9), 'Mesha');
      // Mithuna 10 degrees, dual, from 5th Tula, part 3.
      expect(divisionalSign(siderealLongitude: 70.0, divisor: 9), 'Makara');
    });

    test('divisional boundary takes the later part', () {
      // Exactly on a Navamsha boundary: 10 degrees in Mesha
      // is the start of part 3, not the end of part 2.
      expect(divisionalSign(siderealLongitude: 10.0, divisor: 9), 'Karka');
      expect(
        divisionalSign(siderealLongitude: 9.99, divisor: 9),
        'Mithuna',
      );
      // 29.99 in a sign and 0.01 in the next sign land in
      // adjacent Navamsha parts of adjacent signs: Mesha part
      // 8 is Dhanu, Vrishabha part 0 is Makara.
      final String before =
          divisionalSign(siderealLongitude: 29.99, divisor: 9);
      final String after =
          divisionalSign(siderealLongitude: 30.01, divisor: 9);
      expect(before, 'Dhanu');
      expect(after, 'Makara');
    });

    test('unknown divisor throws', () {
      expect(
        () => divisionalSign(siderealLongitude: 100.0, divisor: 5),
        throwsArgumentError,
      );
    });

    test('all 16 charts exist', () {
      expect(kDivisionalCharts.length, 16);
      expect(
        kDivisionalCharts.map((DivisionalChart c) => c.divisor).toList(),
        <int>[1, 2, 3, 4, 7, 9, 10, 12, 16, 20, 24, 27, 30, 40, 45, 60],
      );
    });
  });

  group('divisionalChart', () {
    test('canonical chart Navamsha comes from the engine', () {
      final KundliResult kundli = canonical();
      final Map<String, String> navamsha = divisionalChart(kundli, 9);
      expect(navamsha.length, 9);
      expect(navamsha['Sun'], 'Mithuna');
      expect(navamsha['Moon'], 'Meena');
    });

    test('D1 is the rasi chart itself', () {
      final KundliResult kundli = canonical();
      final Map<String, String> d1 = divisionalChart(kundli, 1);
      final Map<String, PlanetDetail> byName = <String, PlanetDetail>{
        for (final PlanetDetail p in kundli.planets) p.name: p,
      };
      for (final MapEntry<String, String> entry in d1.entries) {
        expect(entry.value, byName[entry.key]!.rashi);
      }
    });
  });

  group('dignityOf', () {
    test('canonical planets', () {
      expect(dignityOf('Mercury', 346.04), Dignity.debilitated);
      expect(dignityOf('Jupiter', 315.21), Dignity.neutral);
      expect(dignityOf('Sun', 329.44), Dignity.neutral);
      expect(dignityOf('Moon', 158.63), Dignity.neutral);
      expect(dignityOf('Rahu', 136.08), Dignity.neutral);
    });

    test('exaltation, debilitation, moolatrikona, own sign', () {
      expect(dignityOf('Sun', 10.0), Dignity.exalted);
      expect(dignityOf('Sun', 190.0), Dignity.debilitated);
      expect(dignityOf('Sun', 130.0), Dignity.moolatrikona);
      expect(dignityOf('Sun', 145.0), Dignity.ownSign);
      expect(dignityOf('Moon', 33.0), Dignity.exalted);
      expect(dignityOf('Moon', 35.0), Dignity.moolatrikona);
      expect(dignityOf('Mars', 298.0), Dignity.exalted);
      expect(dignityOf('Mercury', 165.0), Dignity.exalted);
      expect(dignityOf('Jupiter', 95.0), Dignity.exalted);
      expect(dignityOf('Venus', 357.0), Dignity.exalted);
      expect(dignityOf('Saturn', 200.0), Dignity.exalted);
      expect(dignityOf('Jupiter', 285.0), Dignity.debilitated);
    });
  });

  group('retrograde', () {
    test('canonical birth is all direct', () {
      final DateTime utc = DateTime.utc(1998, 3, 14, 0, 55);
      for (final String planet in <String>[
        'Mars',
        'Mercury',
        'Jupiter',
        'Venus',
        'Saturn',
      ]) {
        expect(
          isRetrograde(planet: planet, utc: utc),
          isFalse,
          reason: '$planet should be direct on the canonical date',
        );
      }
      expect(isRetrograde(planet: 'Sun', utc: utc), isFalse);
      expect(isRetrograde(planet: 'Moon', utc: utc), isFalse);
      expect(isRetrograde(planet: 'Rahu', utc: utc), isTrue);
      expect(isRetrograde(planet: 'Ketu', utc: utc), isTrue);
    });

    test('Jupiter retrograde on 1 December 2025', () {
      // Skyfield: Jupiter minus 0.0649 degrees a day.
      expect(
        isRetrograde(
          planet: 'Jupiter',
          utc: DateTime.utc(2025, 12, 1, 12),
        ),
        isTrue,
      );
      expect(
        planetMotion(
          planet: 'Jupiter',
          utc: DateTime.utc(2025, 12, 1, 12),
        ),
        lessThan(0),
      );
    });

    test('Saturn retrograde on 1 August 2025', () {
      // Skyfield: Saturn minus 0.0311 degrees a day.
      expect(
        isRetrograde(
          planet: 'Saturn',
          utc: DateTime.utc(2025, 8, 1, 12),
        ),
        isTrue,
      );
    });

    test('motion changes sign across each station', () {
      // Jupiter direct on 1 November 2025, retrograde on 1
      // December 2025. Saturn direct on 1 July 2025,
      // retrograde on 1 August 2025.
      expect(
        planetMotion(
          planet: 'Jupiter',
          utc: DateTime.utc(2025, 11, 1, 12),
        ),
        greaterThan(0),
      );
      expect(
        planetMotion(
          planet: 'Saturn',
          utc: DateTime.utc(2025, 7, 1, 12),
        ),
        greaterThan(0),
      );
    });
  });

  group('combustion', () {
    test('orbs and retrograde shrinkage', () {
      expect(
        isCombust(
          planet: 'Moon',
          sunSidereal: 100.0,
          planetSidereal: 105.0,
        ),
        isTrue,
      );
      expect(
        isCombust(
          planet: 'Moon',
          sunSidereal: 100.0,
          planetSidereal: 115.0,
        ),
        isFalse,
      );
      // Mercury 13 degrees out: combust direct, free retrograde.
      expect(
        isCombust(
          planet: 'Mercury',
          sunSidereal: 100.0,
          planetSidereal: 113.0,
        ),
        isTrue,
      );
      expect(
        isCombust(
          planet: 'Mercury',
          sunSidereal: 100.0,
          planetSidereal: 113.0,
          retrograde: true,
        ),
        isFalse,
      );
      expect(
        isCombust(
          planet: 'Rahu',
          sunSidereal: 100.0,
          planetSidereal: 101.0,
        ),
        isFalse,
      );
      expect(
        isCombust(
          planet: 'Sun',
          sunSidereal: 100.0,
          planetSidereal: 100.0,
        ),
        isFalse,
      );
    });
  });

  group('aspects and conjunctions', () {
    test('canonical aspects follow the Vedic rules', () {
      final KundliResult kundli = canonical();
      final List<PlanetAspect> aspects = aspectsOf(kundli);
      // Lagna Kumbha. Sun in Kumbha aspects Simha, Bhava 7.
      final PlanetAspect sunSeventh = aspects.firstWhere(
        (PlanetAspect a) => a.planet == 'Sun' && !a.special,
      );
      expect(sunSeventh.targetRashi, 'Simha');
      expect(sunSeventh.targetBhava, 7);
      // Mars in Meena aspects Mithuna Bhava 5, Kanya Bhava 8,
      // Tula Bhava 9. The 4th and 8th are special.
      final List<PlanetAspect> mars =
          aspects.where((PlanetAspect a) => a.planet == 'Mars').toList();
      expect(mars.length, 3);
      expect(mars.map((PlanetAspect a) => a.targetBhava).toSet(), <int>{5, 8, 9});
      expect(mars.where((PlanetAspect a) => a.special).length, 2);
      // Jupiter in Kumbha aspects Mithuna Bhava 5, Simha
      // Bhava 7, Tula Bhava 9.
      final List<PlanetAspect> jupiter = aspects
          .where((PlanetAspect a) => a.planet == 'Jupiter')
          .toList();
      expect(jupiter.length, 3);
      expect(
        jupiter.map((PlanetAspect a) => a.targetBhava).toSet(),
        <int>{5, 7, 9},
      );
      // Saturn in Meena aspects Vrishabha Bhava 4, Kanya
      // Bhava 8, Dhanu Bhava 11.
      final List<PlanetAspect> saturn = aspects
          .where((PlanetAspect a) => a.planet == 'Saturn')
          .toList();
      expect(saturn.length, 3);
      expect(
        saturn.map((PlanetAspect a) => a.targetBhava).toSet(),
        <int>{4, 8, 11},
      );
      // Rahu and Ketu cast no Vedic aspect.
      expect(
        aspects.any(
          (PlanetAspect a) => a.planet == 'Rahu' || a.planet == 'Ketu',
        ),
        isFalse,
      );
    });

    test('canonical conjunctions share a rashi', () {
      final KundliResult kundli = canonical();
      final List<Conjunction> found = conjunctionsOf(kundli);
      final Set<String> pairs = <String>{
        for (final Conjunction c in found) '${c.first}-${c.second}',
      };
      expect(pairs.contains('Sun-Jupiter'), isTrue);
      expect(pairs.contains('Sun-Ketu'), isTrue);
      expect(pairs.contains('Jupiter-Ketu'), isTrue);
      expect(pairs.contains('Mars-Mercury'), isTrue);
      expect(pairs.contains('Mars-Saturn'), isTrue);
      expect(pairs.contains('Mercury-Saturn'), isTrue);
      expect(pairs.length, 6);
    });
  });

  group('chart layouts', () {
    test('South Indian grid holds every sign exactly once', () {
      final Set<String> cells = <String>{};
      for (int sign = 0; sign < 12; sign++) {
        final ({int row, int col}) cell = southIndianCell(sign);
        cells.add('${cell.row},${cell.col}');
      }
      expect(cells.length, 12);
      expect(southIndianCell(0), (row: 0, col: 1));
      expect(southIndianCell(11), (row: 0, col: 0));
      expect(southIndianCell(10), (row: 1, col: 0));
      expect(southIndianCell(5), (row: 3, col: 3));
    });

    test('North Indian houses are fixed and distinct', () {
      final Set<String> positions = <String>{
        for (int house = 1; house <= 12; house++)
          northIndianHousePosition(house),
      };
      expect(positions.length, 12);
      expect(northIndianHousePosition(1), 'top diamond');
      expect(northIndianHousePosition(7), 'bottom diamond');
      expect(northIndianHousePosition(4), 'left diamond');
      expect(northIndianHousePosition(10), 'right diamond');
      // Lagna Kumbha: house 1 holds Kumbha, house 7 Simha.
      expect(northIndianSignForHouse(10, 1), 10);
      expect(northIndianSignForHouse(10, 7), 4);
      expect(
        () => northIndianSignForHouse(10, 13),
        throwsArgumentError,
      );
    });

    test('house lords follow the Lagna', () {
      final KundliResult kundli = canonical();
      expect(houseLord(kundli, 1), 'Saturn');
      expect(houseLord(kundli, 2), 'Jupiter');
      expect(houseLord(kundli, 7), 'Sun');
      expect(houseLord(kundli, 10), 'Mars');
      expect(() => houseLord(kundli, 13), throwsArgumentError);
    });
  });

  group('nakshatraPada', () {
    test('canonical Moon is Uttara Phalguni pada 4', () {
      // Moon 158.63: nakshatra 11, within 11.97 degrees, pada 4.
      expect(nakshatraPada(158.63), 4);
      expect(nakshatraPada(329.44), 3);
      expect(nakshatraPada(0.0), 1);
      expect(nakshatraPada(3.33), 1);
      expect(nakshatraPada(3.34), 2);
    });
  });
}
