import 'package:dharm_guru_shrinkhala/models/kundli.dart';
import 'package:dharm_guru_shrinkhala/models/panchang.dart';
import 'package:dharm_guru_shrinkhala/services/astro.dart';
import 'package:flutter_test/flutter_test.dart';

/// The engine is checked against the real ephemeris for the
/// sample birth, 14 March 1998, 06:25 AM IST, Jaipur, taken
/// from JPL Horizons DE441 vectors for that minute. The old
/// hardcoded table in the app was fabricated: its Sun is 2
/// degrees off the real sky, its Moon 10.5 degrees off, its
/// Jupiter 7 degrees off, and its own panchang tithi
/// contradicts its own kundli, so the table is not used as a
/// reference anywhere. Tolerances are generous: the Sun
/// within 0.5 degrees, the Moon within 1 degree, the planets
/// within 2 degrees. A wrong sign or a wrong lagna fails
/// outright.
void main() {
  group('KundliCalculator', () {
    test('sample birth gives Kumbha lagna and the real planets', () {
      final KundliResult result = KundliCalculator.calculate(
        birthLocal: DateTime(1998, 3, 14, 6, 25),
        placeText: 'Jaipur, Rajasthan',
      );
      expect(result.lagna, 'Kumbha');
      expect(result.moonRashi, 'Kanya');
      expect(result.moonNakshatra, 'Uttara Phalguni');
      expect(result.tithiAtBirth, 'Krishna Pratipada');
      expect(result.placeApproximate, isFalse);
      expect(result.timeApproximate, isFalse);
      expect(result.planets.length, 9);
      final Map<String, PlanetDetail> byName = <String, PlanetDetail>{
        for (final PlanetDetail p in result.planets) p.name: p,
      };
      double degrees(String name) {
        final List<String> bits = byName[name]!.degree.split('°');
        final int deg = int.parse(bits[0]);
        final int min = int.parse(bits[1].replaceAll('′', '').trim());
        return deg + min / 60.0;
      }

      double longitude(String name) {
        final int sign = kRashis.indexOf(byName[name]!.rashi);
        return sign * 30.0 + degrees(name);
      }

      // Real sidereal longitudes for this birth, degrees:
      // JPL Horizons DE441 tropical longitudes minus the
      // Lahiri ayanamsa, 23.83 degrees.
      final Map<String, double> expected = <String, double>{
        'Sun': 329.44,
        'Moon': 158.63,
        'Mars': 343.44,
        'Mercury': 346.04,
        'Jupiter': 315.21,
        'Venus': 283.78,
        'Saturn': 355.78,
        'Rahu': 136.08,
        'Ketu': 316.08,
      };
      for (final MapEntry<String, double> entry in expected.entries) {
        final double got = longitude(entry.key);
        final double diff = (got - entry.value).abs();
        expect(
          diff,
          lessThan(2.0),
          reason: '${entry.key} expected about ${entry.value}, '
              'got $got',
        );
      }
      expect(longitude('Sun'), closeTo(329.44, 0.5));
      expect(longitude('Moon'), closeTo(158.63, 1.0));
      expect(byName['Sun']!.rashi, 'Kumbha');
      expect(byName['Sun']!.bhava, 'Bhava 1');
      expect(byName['Moon']!.rashi, 'Kanya');
      expect(byName['Moon']!.bhava, 'Bhava 8');
    });

    test('another birth gives a different chart', () {
      final KundliResult result = KundliCalculator.calculate(
        birthLocal: DateTime(2000, 6, 15, 14, 30),
        placeText: 'Delhi',
      );
      expect(result.planets.length, 9);
      expect(result.lagna, isNotEmpty);
      expect(result.moonRashi, isNotEmpty);
      // Mid June afternoon in Delhi: lagna is not Kumbha.
      expect(result.lagna, isNot('Kumbha'));
    });

    test('unknown place throws instead of falling back to Jaipur', () {
      expect(
        () => KundliCalculator.calculate(
          birthLocal: DateTime(1998, 3, 14, 6, 25),
          placeText: 'Somewhere Not In The List',
        ),
        throwsArgumentError,
      );
    });

    test('unknown birth time uses noon and says so', () {
      final KundliResult result = KundliCalculator.calculate(
        birthLocal: DateTime(1998, 3, 14, 6, 25),
        placeText: 'Jaipur',
        timeKnown: false,
      );
      expect(result.timeApproximate, isTrue);
      expect(result.planets.length, 9);
    });

    test('moon chart counts bhavas from the Moon sign', () {
      final KundliResult result = KundliCalculator.calculate(
        birthLocal: DateTime(1998, 3, 14, 6, 25),
        placeText: 'Jaipur',
      );
      final KundliResult moon = result.moonChart;
      expect(moon.lagna, 'Kanya');
      final PlanetDetail moonPlanet =
          moon.planets.firstWhere((PlanetDetail p) => p.name == 'Moon');
      expect(moonPlanet.bhava, 'Bhava 1');
      final PlanetDetail sun =
          moon.planets.firstWhere((PlanetDetail p) => p.name == 'Sun');
      expect(sun.bhava, 'Bhava 6');
    });
  });

  group('PanchangCalculator', () {
    test('14 March 1998 Jaipur matches the real panchang', () {
      final panchang = PanchangCalculator.forDate(
        DateTime(1998, 3, 14),
        kDefaultPlace,
      );
      expect(panchang.weekday, 'Saturday');
      expect(panchang.vaar, 'Shanivaar');
      expect(panchang.tithi, 'Krishna Pratipada');
      expect(panchang.nakshatra, contains('Hasta'));
      expect(panchang.city, 'Jaipur');
      expect(panchang.sunrise, contains('AM'));
      expect(panchang.sunset, contains('PM'));
      expect(panchang.shubhMuhurat, contains('Abhijit'));
      expect(panchang.rahuKaal, contains('Avoid starting new work'));
    });

    test('today has a valid tithi and a morning sunrise', () {
      final DateTime today = DateTime.now();
      final panchang = PanchangCalculator.forDate(today, kDefaultPlace);
      expect(panchang.tithi, isNotEmpty);
      expect(panchang.nakshatra, isNotEmpty);
      expect(panchang.yoga, isNotEmpty);
      expect(panchang.karana, isNotEmpty);
      expect(panchang.sunrise, contains('AM'));
      expect(panchang.sunset, contains('PM'));
    });

    test('new moon day is Amavasya and full moon day is Purnima', () {
      // Real moon phases, December 2026: new moon 8 December,
      // full moon 23 December. The old table labelled the 30th
      // tithi Krishna Purnima, so Amavasya never appeared.
      final Panchang newMoon = PanchangCalculator.forDate(
        DateTime(2026, 12, 8),
        kDefaultPlace,
      );
      expect(newMoon.tithi, 'Krishna Amavasya');
      final Panchang fullMoon = PanchangCalculator.forDate(
        DateTime(2026, 12, 23),
        kDefaultPlace,
      );
      expect(fullMoon.tithi, 'Shukla Purnima');
    });
  });

  group('placeFor', () {
    test('finds a city inside free text', () {
      expect(placeFor('Jaipur, Rajasthan')?.name, 'Jaipur');
      expect(placeFor('New Delhi')?.name, 'Delhi');
      expect(placeFor('Nowhere'), isNull);
    });
  });

  group('parseBirthDateTime', () {
    test('parses the form text', () {
      expect(
        parseBirthDateTime('14 March 1998', '06:25 AM'),
        DateTime(1998, 3, 14, 6, 25),
      );
      expect(
        parseBirthDateTime('1 January 2000', '12:00 PM'),
        DateTime(2000, 1, 1, 12, 0),
      );
      expect(parseBirthDateTime('not a date', '06:25 AM'), isNull);
      expect(parseBirthDateTime('14 March 1998', '25:99 AM'), isNull);
    });
    test('parses the picker output for 29 July 1995, 12:05 AM', () {
      // The date and time pickers write exactly this text, so
      // the values a user picks can never fail validation.
      expect(
        parseBirthDateTime('29 July 1995', '12:05 AM'),
        DateTime(1995, 7, 29, 0, 5),
      );
      // The typed text from the bug report never parsed.
      expect(parseBirthDateTime('29071995', '12:05 AM'), isNull);
    });
    test('parses legacy stored formats from older profiles', () {
      // The owners own profile carried a slash date, which the
      // old parser rejected and the form showed as a readOnly
      // prefill with the same "Enter a valid date and time."
      // error. Every stored shape must parse now.
      expect(
        parseBirthDateTime('29/07/1995', '12:00 AM'),
        DateTime(1995, 7, 29, 0, 0),
      );
      expect(
        parseBirthDateTime('1995-07-29', '00:05'),
        DateTime(1995, 7, 29, 0, 5),
      );
      expect(
        parseBirthDateTime('29 July 1995', '12:05 am'),
        DateTime(1995, 7, 29, 0, 5),
      );
      expect(
        parseBirthDateTime('29-07-1995', '12:05'),
        DateTime(1995, 7, 29, 12, 5),
      );
      expect(parseBirthDateTime('31 February 2000', '12:00 AM'), isNull);
    });
    test('Gautam Bhavsar saved profile parses and Jirapur resolves', () {
      // The saved profile that showed "These birth details
      // could not be read" on every open: its date and time
      // parsed fine, but Jirapur was missing from the city
      // list, so the engine threw and the screen blamed the
      // date and time.
      expect(
        parseBirthDateTime('29 January 2001', '09:45 PM'),
        DateTime(2001, 1, 29, 21, 45),
      );
      expect(placeFor('Jirapur, Madhya Pradesh'), isNotNull);
      final KundliResult result = KundliCalculator.calculate(
        birthLocal: DateTime(2001, 1, 29, 21, 45),
        placeText: 'Jirapur, Madhya Pradesh',
      );
      expect(result.lagna, isNotEmpty);
      expect(result.moonRashi, isNotEmpty);
    });
    test('calculator accepts exact coordinates from autocomplete', () {
      final KundliResult result = KundliCalculator.calculate(
        birthLocal: DateTime(2001, 1, 29, 21, 45),
        placeText: 'Somewhere, Madhya Pradesh',
        latitude: 24.0214,
        longitude: 76.3764,
      );
      expect(result.lagna, isNotEmpty);
    });
  });
}
