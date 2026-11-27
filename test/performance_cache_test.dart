import 'package:dharm_guru_shrinkhala/core/performance.dart';
import 'package:dharm_guru_shrinkhala/models/panchang.dart';
import 'package:dharm_guru_shrinkhala/services/astro.dart';
import 'package:flutter_test/flutter_test.dart';

/// Phase 18, test IDs PERF-01 to PERF-05. Calculation timings
/// measured on the CI runner with a stopwatch, and the cache
/// behaviour behind them. These are runner numbers, not phone
/// numbers: device timings stay NOT_TESTED until a phone run
/// records them. Thresholds are generous on purpose: the test
/// fails only on a real regression, not on a slow runner.
void main() {
  group('Calculation performance and caching', () {
    test('PERF-01 kundli calculation finishes in under 5 seconds', () {
      KundliCalculator.clearCache();
      final Timed<KundliResult> timed = measureSync(
        () => KundliCalculator.calculate(
          birthLocal: DateTime(2000, 1, 15, 7, 30),
          placeText: 'Jaipur',
        ),
      );
      expect(timed.value.lagna, isNotEmpty);
      expect(timed.value.planets.length, 9);
      expect(timed.elapsedMs, lessThan(5000));
    });

    test('PERF-02 panchang calculation finishes in under 5 seconds', () {
      PanchangCalculator.clearCache();
      final Timed<Panchang> timed = measureSync(
        () => PanchangCalculator.forDate(
          DateTime(2026, 11, 28),
          kDefaultPlace,
        ),
      );
      expect(timed.value.tithi, isNotEmpty);
      expect(timed.elapsedMs, lessThan(5000));
    });

    test('PERF-03 repeated kundli calculation returns the cached chart',
        () {
      KundliCalculator.clearCache();
      final KundliResult first = KundliCalculator.calculate(
        birthLocal: DateTime(2000, 1, 15, 7, 30),
        placeText: 'Jaipur',
      );
      final KundliResult second = KundliCalculator.calculate(
        birthLocal: DateTime(2000, 1, 15, 7, 30),
        placeText: 'Jaipur',
      );
      expect(identical(first, second), isTrue);
    });

    test('PERF-04 different birth inputs do not share a cached chart', () {
      KundliCalculator.clearCache();
      final KundliResult jaipur = KundliCalculator.calculate(
        birthLocal: DateTime(2000, 1, 15, 7, 30),
        placeText: 'Jaipur',
      );
      final KundliResult delhi = KundliCalculator.calculate(
        birthLocal: DateTime(2000, 1, 15, 7, 30),
        placeText: 'Delhi',
      );
      expect(identical(jaipur, delhi), isFalse);
      expect(delhi.place.name, 'Delhi');
    });

    test('PERF-05 clearing the cache forces a fresh calculation', () {
      PanchangCalculator.clearCache();
      final Panchang first = PanchangCalculator.forDate(
        DateTime(2026, 11, 28),
        kDefaultPlace,
      );
      final Panchang cached = PanchangCalculator.forDate(
        DateTime(2026, 11, 28),
        kDefaultPlace,
      );
      expect(identical(first, cached), isTrue);
      PanchangCalculator.clearCache();
      final Panchang fresh = PanchangCalculator.forDate(
        DateTime(2026, 11, 28),
        kDefaultPlace,
      );
      expect(identical(first, fresh), isFalse);
      expect(fresh.tithi, first.tithi);
    });
  });
}
