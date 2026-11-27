import 'package:dharm_guru_shrinkhala/services/gochar.dart';
import 'package:flutter_test/flutter_test.dart';

/// Phase 6 gochar tests, on the sample birth used across
/// the suite: 14 March 1998, 06:25 AM IST, Jaipur. Lagna
/// Kumbha, Moon in Kanya.

void main() {
  final DateTime birth = DateTime(1998, 3, 14, 6, 25);

  group('sadeSatiFor', () {
    test('Saturn around the Moon sign gives rising, peak, setting', () {
      expect(
        sadeSatiFor(moonSign: 'Kanya', saturnSign: 'Simha').phase,
        'rising',
      );
      expect(
        sadeSatiFor(moonSign: 'Kanya', saturnSign: 'Kanya').phase,
        'peak',
      );
      expect(
        sadeSatiFor(moonSign: 'Kanya', saturnSign: 'Tula').phase,
        'setting',
      );
      expect(
        sadeSatiFor(moonSign: 'Kanya', saturnSign: 'Meena').phase,
        'none',
      );
    });

    test('Saturn 4th and 8th from the Moon is Dhaiya', () {
      final SadeSatiStatus fourth = sadeSatiFor(
        moonSign: 'Kanya',
        saturnSign: 'Dhanu',
      );
      expect(fourth.dhaiya, isTrue);
      expect(fourth.phase, 'none');
      final SadeSatiStatus eighth = sadeSatiFor(
        moonSign: 'Kanya',
        saturnSign: 'Mesha',
      );
      expect(eighth.dhaiya, isTrue);
      final SadeSatiStatus other = sadeSatiFor(
        moonSign: 'Kanya',
        saturnSign: 'Karka',
      );
      expect(other.dhaiya, isFalse);
      expect(other.phase, 'none');
    });
  });

  group('gocharFor', () {
    test('current transits sit in the right signs and houses', () {
      final List<TransitPosition> transits = gocharFor(
        birthLocal: birth,
        placeText: 'Jaipur',
        date: DateTime(2026, 11, 28),
      );
      expect(transits.length, 9);
      final TransitPosition saturn = transits.firstWhere(
        (TransitPosition t) => t.planet == 'Saturn',
      );
      expect(saturn.transitSign, 'Meena');
      expect(saturn.houseFromLagna, 2);
      expect(saturn.natalSign, 'Meena');
      final TransitPosition sun = transits.firstWhere(
        (TransitPosition t) => t.planet == 'Sun',
      );
      expect(sun.transitSign, 'Vrishchika');
      expect(sun.houseFromLagna, 10);
      for (final TransitPosition t in transits) {
        expect(t.explanation, isNotEmpty);
        expect(t.houseFromLagna, inInclusiveRange(1, 12));
        expect(t.natalHouse, inInclusiveRange(1, 12));
      }
    });

    test('a past date gives a past transit: Sade Sati rising in 2007', () {
      final SadeSatiStatus status = sadeSatiOn(
        birthLocal: birth,
        placeText: 'Jaipur',
        date: DateTime(2007, 8, 15),
      );
      expect(status.phase, 'rising');
      expect(status.explanation, contains('rising'));
    });

    test('no Sade Sati or Dhaiya on 28 November 2026', () {
      final SadeSatiStatus status = sadeSatiOn(
        birthLocal: birth,
        placeText: 'Jaipur',
        date: DateTime(2026, 11, 28),
      );
      expect(status.phase, 'none');
      expect(status.dhaiya, isFalse);
    });
  });
}
