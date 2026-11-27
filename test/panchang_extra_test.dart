import 'package:dharm_guru_shrinkhala/services/astro.dart';
import 'package:dharm_guru_shrinkhala/services/panchang_extra.dart';
import 'package:flutter_test/flutter_test.dart';

/// Phase 5 daily timings tests. Weekday tables are checked
/// as offsets from sunrise, so the test does not depend on
/// the clock reading of one day. Moonrise is checked
/// against sunset on a full moon day and against sunrise on
/// a new moon day, where the geometry fixes it.

int _minutes(String clock) {
  final List<String> bits = clock.split(' ');
  final List<String> hm = bits[0].split(':');
  int minutes = int.parse(hm[0]) % 12 * 60 + int.parse(hm[1]);
  if (bits[1] == 'PM') minutes += 12 * 60;
  return minutes;
}

void main() {
  group('dailyTimings weekday tables', () {
    test('Monday 30 November 2026 Jaipur parts sit at the table offsets', () {
      final DateTime day = DateTime(2026, 11, 30);
      final DailyTimings timings = dailyTimings(day, kDefaultPlace);
      final double sunrise = sunTimesFor(day, kDefaultPlace).sunrise;
      expect(timings.rahuKaal.startHours, closeTo(sunrise + 1.5, 0.001));
      expect(timings.rahuKaal.endHours, closeTo(sunrise + 3.0, 0.001));
      expect(timings.yamaganda.startHours, closeTo(sunrise + 4.5, 0.001));
      expect(timings.yamaganda.endHours, closeTo(sunrise + 6.0, 0.001));
      expect(timings.gulika.startHours, closeTo(sunrise + 7.5, 0.001));
      expect(timings.gulika.endHours, closeTo(sunrise + 9.0, 0.001));
      expect(timings.brahmaMuhurat.startHours, closeTo(sunrise - 1.6, 0.001));
      expect(timings.brahmaMuhurat.endHours, closeTo(sunrise - 0.8, 0.001));
    });

    test('Sunday 29 November 2026 parts use the Sunday row', () {
      final DateTime day = DateTime(2026, 11, 29);
      final DailyTimings timings = dailyTimings(day, kDefaultPlace);
      final double sunrise = sunTimesFor(day, kDefaultPlace).sunrise;
      expect(timings.rahuKaal.startHours, closeTo(sunrise + 10.5, 0.001));
      expect(timings.yamaganda.startHours, closeTo(sunrise + 6.0, 0.001));
      expect(timings.gulika.startHours, closeTo(sunrise + 9.0, 0.001));
    });

    test('Choghadiya day covers sunrise to sunset, Monday starts Amrit', () {
      final DateTime day = DateTime(2026, 11, 30);
      final DailyTimings timings = dailyTimings(day, kDefaultPlace);
      final SunTimes times = sunTimesFor(day, kDefaultPlace);
      expect(timings.choghadiyaDay.length, 8);
      expect(timings.choghadiyaDay.first.name, 'Amrit');
      expect(
        timings.choghadiyaDay.first.startHours,
        closeTo(times.sunrise, 0.001),
      );
      expect(
        timings.choghadiyaDay.last.endHours,
        closeTo(times.sunset, 0.001),
      );
      for (int i = 1; i < 8; i++) {
        expect(
          timings.choghadiyaDay[i].startHours,
          closeTo(timings.choghadiyaDay[i - 1].endHours, 0.001),
        );
      }
      expect(
        timings.choghadiyaDay.where((ChoghadiyaSegment s) => s.isGood).length,
        greaterThan(0),
      );
      expect(timings.choghadiyaNight.length, 8);
      expect(timings.choghadiyaNight.first.name, 'Kaal');
    });
  });

  group('moonrise and moonset', () {
    test('full moon day moonrise sits near sunset', () {
      final DateTime day = DateTime(2026, 11, 24);
      final DailyTimings timings = dailyTimings(day, kDefaultPlace);
      expect(timings.moonrise, isNotNull);
      expect(timings.moonset, isNotNull);
      final int sunset =
          _minutes(PanchangCalculator.forDate(day, kDefaultPlace).sunset);
      final int rise = _minutes(timings.moonrise!);
      expect((rise - sunset).abs(), lessThan(90));
    });

    test('new moon day moonrise sits near sunrise', () {
      final DateTime day = DateTime(2026, 12, 8);
      final DailyTimings timings = dailyTimings(day, kDefaultPlace);
      expect(timings.moonrise, isNotNull);
      final int sunrise =
          _minutes(PanchangCalculator.forDate(day, kDefaultPlace).sunrise);
      final int rise = _minutes(timings.moonrise!);
      expect((rise - sunrise).abs(), lessThan(120));
    });
  });

  group('paksha and lunar month', () {
    test('8 December 2026 is Krishna, 23 December is Shukla', () {
      expect(pakshaFor(DateTime(2026, 12, 8)), 'Krishna Paksha');
      expect(pakshaFor(DateTime(2026, 12, 23)), 'Shukla Paksha');
    });

    test('Amanta and Purnimanta agree in Shukla, differ in Krishna', () {
      expect(
        lunarMonth(DateTime(2026, 12, 10), kDefaultPlace),
        'Pausha',
      );
      expect(
        lunarMonth(
          DateTime(2026, 12, 10),
          kDefaultPlace,
          convention: LunarConvention.purnimanta,
        ),
        'Pausha',
      );
      expect(
        lunarMonth(DateTime(2026, 12, 5), kDefaultPlace),
        'Margashirsha',
      );
      expect(
        lunarMonth(
          DateTime(2026, 12, 5),
          kDefaultPlace,
          convention: LunarConvention.purnimanta,
        ),
        'Pausha',
      );
    });
  });

  group('Adhika Masa', () {
    test('2026 has one Adhik Jyeshtha, May to June', () {
      final List<AdhikaMonth> months = adhikaMonthsInYear(2026);
      expect(months.length, 1);
      expect(months.first.name, 'Jyeshtha');
      expect(months.first.start.month, 5);
      expect(months.first.end.month, 6);
      expect(months.first.start.day, 17);
    });

    test('2025 has no Adhika Masa', () {
      expect(adhikaMonthsInYear(2025), isEmpty);
    });

    test('a date inside Adhik Jyeshtha reports adhika', () {
      expect(isAdhikaMonth(DateTime(2026, 5, 20)), isTrue);
      expect(isAdhikaMonth(DateTime(2026, 11, 28)), isFalse);
      final DailyTimings timings =
          dailyTimings(DateTime(2026, 5, 20), kDefaultPlace);
      expect(timings.adhika, isTrue);
      expect(timings.lunarMonthAmanta, 'Jyeshtha');
    });
  });

  group('Amavasya regression', () {
    test('the 30th tithi is Amavasya on every December 2026 day', () {
      for (int day = 1; day <= 31; day++) {
        final String tithi =
            PanchangCalculator.forDate(DateTime(2026, 12, day), kDefaultPlace)
                .tithi;
        expect(
          tithi.contains('Krishna Purnima'),
          isFalse,
          reason: '2026-12-$day gave $tithi',
        );
      }
      expect(
        PanchangCalculator.forDate(DateTime(2026, 12, 8), kDefaultPlace)
            .tithi,
        'Krishna Amavasya',
      );
    });
  });
}
