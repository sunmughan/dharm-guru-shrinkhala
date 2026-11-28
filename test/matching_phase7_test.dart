import 'package:dharm_guru_shrinkhala/models/kundli.dart';
import 'package:dharm_guru_shrinkhala/services/astro.dart';
import 'package:dharm_guru_shrinkhala/services/matching.dart';
import 'package:flutter_test/flutter_test.dart';

KundliResult _handChart({
  required String moonRashi,
  required String moonNakshatra,
  required String marsRashi,
  required String marsBhava,
  String? jupiterRashi,
}) {
  final List<PlanetDetail> planets = <PlanetDetail>[
    PlanetDetail(
      name: 'Mars',
      rashi: marsRashi,
      bhava: marsBhava,
      degree: '10° 00′',
      swami: 'Mars',
      note: 'Mars in $marsRashi, $marsBhava.',
    ),
  ];
  if (jupiterRashi != null) {
    planets.add(
      PlanetDetail(
        name: 'Jupiter',
        rashi: jupiterRashi,
        bhava: 'Bhava 5',
        degree: '10° 00′',
        swami: 'Jupiter',
        note: 'Jupiter in $jupiterRashi.',
      ),
    );
  }
  return KundliResult(
    lagna: 'Dhanu',
    lagnaDegree: '10° 00′',
    moonRashi: moonRashi,
    moonNakshatra: moonNakshatra,
    tithiAtBirth: 'Shukla Pratipada',
    planets: planets,
    place: kDefaultPlace,
    placeApproximate: false,
    timeApproximate: false,
  );
}

GunaScore _row(MatchingResult result, String label) =>
    result.rows.firstWhere((GunaScore r) => r.label == label);

void main() {
  test('P7M1 hand pair Mesha Ashwini with Vrishabha Bharani totals 25', () {
    final MatchingResult result = MatchingCalculator.calculate(
      first: _handChart(
        moonRashi: 'Mesha',
        moonNakshatra: 'Ashwini',
        marsRashi: 'Mesha',
        marsBhava: 'Bhava 5',
      ),
      second: _handChart(
        moonRashi: 'Vrishabha',
        moonNakshatra: 'Bharani',
        marsRashi: 'Mesha',
        marsBhava: 'Bhava 5',
      ),
    );
    expect(_row(result, 'Varna').score, 1);
    expect(_row(result, 'Vashya').score, 2);
    expect(_row(result, 'Tara').score, 3);
    expect(_row(result, 'Yoni').score, 3);
    expect(_row(result, 'Graha Maitri').score, 3);
    expect(_row(result, 'Gana').score, 5);
    expect(_row(result, 'Bhakoot').score, 0);
    expect(_row(result, 'Bhakoot').isDosha, isTrue);
    expect(_row(result, 'Nadi').score, 8);
    expect(result.total, 25);
    expect(result.verdict, 'Average Match');
    expect(result.totalText, '25 / 36');
    for (final GunaScore row in result.rows) {
      expect(row.rule, isNotEmpty);
    }
  });

  test('P7M2 Tara counts both ways, one bad direction gives 1.5', () {
    // Ashwini to Magha counts 10 one way, Tara 1, and 19 the
    // other way, Tara 1, both good, so 3. Ashwini to Rohini
    // counts 4 one way, Tara 4 good, and 25 the other way,
    // Tara 7 bad, so 1.5. With inclusive counts the two
    // directions always sum to 29, so both directions bad
    // never occurs and Tara is 3 or 1.5.
    final MatchingResult good = MatchingCalculator.calculate(
      first: _handChart(
        moonRashi: 'Mesha',
        moonNakshatra: 'Ashwini',
        marsRashi: 'Mesha',
        marsBhava: 'Bhava 5',
      ),
      second: _handChart(
        moonRashi: 'Simha',
        moonNakshatra: 'Magha',
        marsRashi: 'Mesha',
        marsBhava: 'Bhava 5',
      ),
    );
    expect(_row(good, 'Tara').score, 3);
    final MatchingResult mixed = MatchingCalculator.calculate(
      first: _handChart(
        moonRashi: 'Mesha',
        moonNakshatra: 'Ashwini',
        marsRashi: 'Mesha',
        marsBhava: 'Bhava 5',
      ),
      second: _handChart(
        moonRashi: 'Vrishabha',
        moonNakshatra: 'Rohini',
        marsRashi: 'Mesha',
        marsBhava: 'Bhava 5',
      ),
    );
    expect(_row(mixed, 'Tara').score, 1.5);
  });

  test('P7M3 Yoni bitter enemy Horse with Buffalo scores 0', () {
    final MatchingResult result = MatchingCalculator.calculate(
      first: _handChart(
        moonRashi: 'Mesha',
        moonNakshatra: 'Ashwini',
        marsRashi: 'Mesha',
        marsBhava: 'Bhava 5',
      ),
      second: _handChart(
        moonRashi: 'Kanya',
        moonNakshatra: 'Hasta',
        marsRashi: 'Mesha',
        marsBhava: 'Bhava 5',
      ),
    );
    expect(_row(result, 'Yoni').score, 0);
    expect(_row(result, 'Yoni').note, contains('bitter enemy'));
  });

  test('P7M4 Yoni mild enemy Serpent with Rat scores 1', () {
    final MatchingResult result = MatchingCalculator.calculate(
      first: _handChart(
        moonRashi: 'Vrishabha',
        moonNakshatra: 'Rohini',
        marsRashi: 'Mesha',
        marsBhava: 'Bhava 5',
      ),
      second: _handChart(
        moonRashi: 'Simha',
        moonNakshatra: 'Magha',
        marsRashi: 'Mesha',
        marsBhava: 'Bhava 5',
      ),
    );
    expect(_row(result, 'Yoni').score, 1);
  });

  test('P7M5 Bhakoot 6-8 with same lord is 0 points but dosha cleared', () {
    final MatchingResult result = MatchingCalculator.calculate(
      first: _handChart(
        moonRashi: 'Mesha',
        moonNakshatra: 'Ashwini',
        marsRashi: 'Mesha',
        marsBhava: 'Bhava 5',
      ),
      second: _handChart(
        moonRashi: 'Vrishchika',
        moonNakshatra: 'Anuradha',
        marsRashi: 'Mesha',
        marsBhava: 'Bhava 5',
      ),
    );
    expect(_row(result, 'Bhakoot').score, 0);
    expect(_row(result, 'Bhakoot').isDosha, isFalse);
    expect(_row(result, 'Bhakoot').exception, contains('same Moon lord'));
    expect(_row(result, 'Graha Maitri').score, 5);
  });

  test('P7M6 Bhakoot 6-8 with unfriendly lords stays a dosha', () {
    final MatchingResult result = MatchingCalculator.calculate(
      first: _handChart(
        moonRashi: 'Mesha',
        moonNakshatra: 'Ashwini',
        marsRashi: 'Mesha',
        marsBhava: 'Bhava 5',
      ),
      second: _handChart(
        moonRashi: 'Kanya',
        moonNakshatra: 'Chitra',
        marsRashi: 'Mesha',
        marsBhava: 'Bhava 5',
      ),
    );
    expect(_row(result, 'Bhakoot').score, 0);
    expect(_row(result, 'Bhakoot').isDosha, isTrue);
    expect(_row(result, 'Bhakoot').exception, isEmpty);
  });

  test('P7M7 Nadi same rashi different nakshatra clears the dosha flag', () {
    final MatchingResult result = MatchingCalculator.calculate(
      first: _handChart(
        moonRashi: 'Kanya',
        moonNakshatra: 'Hasta',
        marsRashi: 'Mesha',
        marsBhava: 'Bhava 5',
      ),
      second: _handChart(
        moonRashi: 'Kanya',
        moonNakshatra: 'Uttara Phalguni',
        marsRashi: 'Mesha',
        marsBhava: 'Bhava 5',
      ),
    );
    expect(_row(result, 'Nadi').score, 0);
    expect(_row(result, 'Nadi').isDosha, isFalse);
    expect(_row(result, 'Nadi').exception, contains('same Moon rashi'));
    final MatchingResult strict = MatchingCalculator.calculate(
      first: _handChart(
        moonRashi: 'Kanya',
        moonNakshatra: 'Hasta',
        marsRashi: 'Mesha',
        marsBhava: 'Bhava 5',
      ),
      second: _handChart(
        moonRashi: 'Kanya',
        moonNakshatra: 'Uttara Phalguni',
        marsRashi: 'Mesha',
        marsBhava: 'Bhava 5',
      ),
      tradition: const MatchingTradition.strict(),
    );
    expect(_row(strict, 'Nadi').isDosha, isTrue);
  });

  test('P7M8 Graha Maitri Mars with Saturn is neutral with enemy 0.5', () {
    final MatchingResult result = MatchingCalculator.calculate(
      first: _handChart(
        moonRashi: 'Mesha',
        moonNakshatra: 'Ashwini',
        marsRashi: 'Mesha',
        marsBhava: 'Bhava 5',
      ),
      second: _handChart(
        moonRashi: 'Makara',
        moonNakshatra: 'Shravana',
        marsRashi: 'Mesha',
        marsBhava: 'Bhava 5',
      ),
    );
    expect(_row(result, 'Graha Maitri').score, 0.5);
  });

  test('P7M9 Gana Deva with Rakshasa scores 1 and is a dosha', () {
    final MatchingResult result = MatchingCalculator.calculate(
      first: _handChart(
        moonRashi: 'Mesha',
        moonNakshatra: 'Ashwini',
        marsRashi: 'Mesha',
        marsBhava: 'Bhava 5',
      ),
      second: _handChart(
        moonRashi: 'Vrishabha',
        moonNakshatra: 'Krittika',
        marsRashi: 'Mesha',
        marsBhava: 'Bhava 5',
      ),
    );
    expect(_row(result, 'Gana').score, 1);
    expect(_row(result, 'Gana').isDosha, isTrue);
  });

  test('P7M10 Vashya Simha with Mesha scores 0, Vanachara with Chatushpada', () {
    final MatchingResult result = MatchingCalculator.calculate(
      first: _handChart(
        moonRashi: 'Mesha',
        moonNakshatra: 'Ashwini',
        marsRashi: 'Mesha',
        marsBhava: 'Bhava 5',
      ),
      second: _handChart(
        moonRashi: 'Simha',
        moonNakshatra: 'Magha',
        marsRashi: 'Mesha',
        marsBhava: 'Bhava 5',
      ),
    );
    expect(_row(result, 'Vashya').score, 0);
  });

  test('P7M11 Manglik both present is compatible, one alone is not', () {
    final MatchingResult both = MatchingCalculator.calculate(
      first: _handChart(
        moonRashi: 'Mesha',
        moonNakshatra: 'Ashwini',
        marsRashi: 'Simha',
        marsBhava: 'Bhava 1',
      ),
      second: _handChart(
        moonRashi: 'Vrishabha',
        moonNakshatra: 'Bharani',
        marsRashi: 'Simha',
        marsBhava: 'Bhava 1',
      ),
    );
    expect(both.mangalFirst, isTrue);
    expect(both.mangalSecond, isTrue);
    expect(both.manglik.compatible, isTrue);
    expect(both.manglik.firstEffective, isTrue);
    final MatchingResult one = MatchingCalculator.calculate(
      first: _handChart(
        moonRashi: 'Mesha',
        moonNakshatra: 'Ashwini',
        marsRashi: 'Simha',
        marsBhava: 'Bhava 1',
      ),
      second: _handChart(
        moonRashi: 'Vrishabha',
        moonNakshatra: 'Bharani',
        marsRashi: 'Mesha',
        marsBhava: 'Bhava 5',
      ),
    );
    expect(one.manglik.compatible, isFalse);
    expect(one.manglik.firstEffective, isTrue);
    expect(one.manglik.secondEffective, isFalse);
  });

  test('P7M12 Manglik in own rashi Mesha is cancelled, not effective', () {
    final MatchingResult result = MatchingCalculator.calculate(
      first: _handChart(
        moonRashi: 'Mesha',
        moonNakshatra: 'Ashwini',
        marsRashi: 'Mesha',
        marsBhava: 'Bhava 1',
      ),
      second: _handChart(
        moonRashi: 'Vrishabha',
        moonNakshatra: 'Bharani',
        marsRashi: 'Mesha',
        marsBhava: 'Bhava 5',
      ),
    );
    expect(result.mangalFirst, isTrue);
    expect(result.manglik.firstEffective, isFalse);
    expect(result.manglik.compatible, isTrue);
    expect(result.manglik.cancellations.first, contains('own rashi'));
  });

  test('P7M13 Manglik cancelled by Jupiter conjunct Mars', () {
    final MatchingResult result = MatchingCalculator.calculate(
      first: _handChart(
        moonRashi: 'Mesha',
        moonNakshatra: 'Ashwini',
        marsRashi: 'Simha',
        marsBhava: 'Bhava 1',
        jupiterRashi: 'Simha',
      ),
      second: _handChart(
        moonRashi: 'Vrishabha',
        moonNakshatra: 'Bharani',
        marsRashi: 'Mesha',
        marsBhava: 'Bhava 5',
      ),
    );
    expect(result.manglik.firstEffective, isFalse);
    expect(result.manglik.compatible, isTrue);
  });

  test('P7M14 real proof pair total is the row sum and every row has a rule', () {
    final KundliResult first = KundliCalculator.calculate(
      birthLocal: DateTime(1998, 3, 14, 6, 25),
      placeText: 'Jaipur, Rajasthan',
    );
    final KundliResult second = KundliCalculator.calculate(
      birthLocal: DateTime(2000, 1, 15, 7, 30),
      placeText: 'Delhi, Delhi',
    );
    final MatchingResult result = MatchingCalculator.calculate(
      first: first,
      second: second,
    );
    expect(result.rows.length, 8);
    expect(
      result.total,
      result.rows.fold<double>(
        0,
        (double total, GunaScore row) => total + row.score,
      ),
    );
    expect(result.total, greaterThanOrEqualTo(0));
    expect(result.total, lessThanOrEqualTo(36));
    for (final GunaScore row in result.rows) {
      expect(row.rule, isNotEmpty);
      expect(row.score, lessThanOrEqualTo(row.max));
    }
    // ignore: avoid_print
    print(
      'INPUT boy 14 March 1998 Jaipur girl 15 January 2000 Delhi '
      'OUTPUT score ${result.totalText} verdict ${result.verdict} '
      'rows ${result.rows.map((GunaScore r) => '${r.label} ${r.score}/${r.max}').join(', ')} '
      'doshas ${result.doshas.map((GunaScore r) => r.label).join(', ')} '
      'manglik compatible ${result.manglik.compatible}',
    );
  });
}
