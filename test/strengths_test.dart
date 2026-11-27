import 'package:dharm_guru_shrinkhala/services/astro.dart';
import 'package:dharm_guru_shrinkhala/services/strengths.dart';
import 'package:flutter_test/flutter_test.dart';

/// Phase 6 strength tests, on the sample birth used across
/// the suite: 14 March 1998, 06:25 AM IST, Jaipur. Lagna
/// Kumbha, Sun in Kumbha, Moon in Kanya, Saturn in Meena.

void main() {
  late KundliResult kundli;

  setUpAll(() {
    kundli = KundliCalculator.calculate(
      birthLocal: DateTime(1998, 3, 14, 6, 25),
      placeText: 'Jaipur',
    );
  });

  group('ashtakavarga', () {
    test('per planet totals are the fixed classical totals', () {
      final AshtakavargaResult result = ashtakavarga(kundli);
      expect(result.totals, kAshtakavargaTotals);
      for (final MapEntry<String, List<int>> entry
          in result.bindus.entries) {
        expect(entry.value.length, 12);
        for (final int count in entry.value) {
          expect(count, inInclusiveRange(0, 8));
        }
      }
    });

    test('sarvashtakavarga always totals 337', () {
      final AshtakavargaResult result = ashtakavarga(kundli);
      expect(result.sarva.length, 12);
      expect(
        result.sarva.fold(0, (int a, int b) => a + b),
        337,
      );
    });

    test('the same totals hold for another chart', () {
      final KundliResult other = KundliCalculator.calculate(
        birthLocal: DateTime(2000, 6, 15, 14, 30),
        placeText: 'Delhi',
      );
      final AshtakavargaResult result = ashtakavarga(other);
      expect(result.totals, kAshtakavargaTotals);
      expect(
        result.sarva.fold(0, (int a, int b) => a + b),
        337,
      );
    });
  });

  group('shadbala simplified', () {
    test('Sun and Moon totals follow the three part rule', () {
      final List<ShadbalaResult> results = shadbala(
        kundli,
        isDayBirth: true,
      );
      expect(results.length, 7);
      final ShadbalaResult sun = results.firstWhere(
        (ShadbalaResult r) => r.planet == 'Sun',
      );
      expect(sun.sthana, 30);
      expect(sun.dig, 50);
      expect(sun.kaala, 100);
      expect(sun.total, 180);
      expect(sun.band, 'Moderate');
      final ShadbalaResult moon = results.firstWhere(
        (ShadbalaResult r) => r.planet == 'Moon',
      );
      expect(moon.sthana, 60);
      expect(moon.dig, 50);
      expect(moon.kaala, 60);
      expect(moon.total, 170);
      expect(moon.band, 'Moderate');
      for (final ShadbalaResult r in results) {
        expect(r.total, inInclusiveRange(0, 300));
        expect(r.explanation, contains('Simplified Shadbala'));
      }
    });
  });

  group('bhavaBala', () {
    test('first and second houses score from lord and occupants', () {
      final List<BhavaBalaResult> results = bhavaBala(kundli);
      expect(results.length, 12);
      final BhavaBalaResult first = results.firstWhere(
        (BhavaBalaResult r) => r.house == 1,
      );
      expect(first.sign, 'Kumbha');
      expect(first.lord, 'Saturn');
      expect(first.score, 100);
      expect(first.band, 'Strong');
      final BhavaBalaResult second = results.firstWhere(
        (BhavaBalaResult r) => r.house == 2,
      );
      expect(second.sign, 'Meena');
      expect(second.lord, 'Jupiter');
      expect(second.score, 110);
      for (final BhavaBalaResult r in results) {
        expect(r.explanation, contains('Simplified Bhava Bala'));
      }
    });
  });
}
