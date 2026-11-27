import 'package:dharm_guru_shrinkhala/models/kundli.dart';
import 'package:dharm_guru_shrinkhala/services/astro.dart';
import 'package:dharm_guru_shrinkhala/services/matching.dart';
import 'package:flutter_test/flutter_test.dart';

KundliResult _chart({
  required DateTime birth,
  required String place,
}) =>
    KundliCalculator.calculate(birthLocal: birth, placeText: place);

KundliResult _handChart({
  required String moonRashi,
  required String moonNakshatra,
  required String marsRashi,
  required String marsBhava,
}) {
  return KundliResult(
    lagna: 'Dhanu',
    lagnaDegree: '10° 00′',
    moonRashi: moonRashi,
    moonNakshatra: moonNakshatra,
    tithiAtBirth: 'Shukla Pratipada',
    planets: <PlanetDetail>[
      PlanetDetail(
        name: 'Mars',
        rashi: marsRashi,
        bhava: marsBhava,
        degree: '10° 00′',
        swami: 'Mars',
        note: 'Mars in $marsRashi, $marsBhava.',
      ),
    ],
    place: kDefaultPlace,
    placeApproximate: false,
    timeApproximate: false,
  );
}

void main() {
  test('identical charts score 17.5 out of 36', () {
    final KundliResult chart = _chart(
      birth: DateTime(2000, 1, 1, 6, 25),
      place: 'Jaipur',
    );
    final MatchingResult result = MatchingCalculator.calculate(
      first: chart,
      second: chart,
    );
    expect(result.rows.length, 8);
    expect(result.total, 17.5);
    expect(result.totalText, '17.5 / 36');
    expect(result.verdict, 'Low Match');
    expect(result.mangalFirst, result.mangalSecond);
  });

  test('two real charts give a score inside 0 to 36 that sums its rows', () {
    final MatchingResult result = MatchingCalculator.calculate(
      first: _chart(
        birth: DateTime(2000, 1, 1, 6, 25),
        place: 'Jaipur',
      ),
      second: _chart(
        birth: DateTime(1998, 3, 14, 6, 25),
        place: 'Jaipur, Rajasthan',
      ),
    );
    expect(result.total, greaterThanOrEqualTo(0));
    expect(result.total, lessThanOrEqualTo(36));
    final double sum = result.rows.fold<double>(
      0,
      (double total, GunaScore row) => total + row.score,
    );
    expect(result.total, sum);
    for (final GunaScore row in result.rows) {
      expect(row.score, greaterThanOrEqualTo(0));
      expect(row.score, lessThanOrEqualTo(row.max));
    }
    expect(
      result.verdict,
      result.total >= 28
          ? 'Very Good Match'
          : result.total >= 18
              ? 'Average Match'
              : 'Low Match',
    );
  });

  test('Mangal Dosha reads Mars bhava from the real chart', () {
    final MatchingResult result = MatchingCalculator.calculate(
      first: _handChart(
        moonRashi: 'Kanya',
        moonNakshatra: 'Hasta',
        marsRashi: 'Mesha',
        marsBhava: 'Bhava 1',
      ),
      second: _handChart(
        moonRashi: 'Mithuna',
        moonNakshatra: 'Ardra',
        marsRashi: 'Mesha',
        marsBhava: 'Bhava 5',
      ),
    );
    expect(result.mangalFirst, isTrue);
    expect(result.mangalSecond, isFalse);
  });

  test('guna score text drops the .0 on whole numbers', () {
    expect(
      gunaScoreText(
        const GunaScore(label: 'Varna', score: 1, max: 1, note: ''),
      ),
      '1 / 1',
    );
    expect(
      gunaScoreText(
        const GunaScore(label: 'Tara', score: 1.5, max: 3, note: ''),
      ),
      '1.5 / 3',
    );
  });
}
