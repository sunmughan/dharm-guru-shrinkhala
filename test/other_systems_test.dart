import 'package:dharm_guru_shrinkhala/services/astro.dart';
import 'package:dharm_guru_shrinkhala/services/other_systems.dart';
import 'package:flutter_test/flutter_test.dart';

/// Phase 6 other systems evaluation tests. The sample birth
/// is 14 March 1998, 06:25 AM IST, Jaipur: sidereal Sun
/// 329.44 degrees, so the Western tropical Sun is Pisces.

void main() {
  group('evaluateOtherSystems', () {
    test('four systems, each with needs, gaps and a verdict', () {
      final List<SystemEvaluation> systems = evaluateOtherSystems();
      expect(
        systems.map((SystemEvaluation s) => s.name).toList(),
        <String>['Jaimini', 'KP', 'Lal Kitab', 'Western'],
      );
      for (final SystemEvaluation system in systems) {
        expect(system.needs, isNotEmpty);
        expect(system.available, isNotEmpty);
        expect(system.gaps, isNotEmpty);
        expect(system.verdict, isNotEmpty);
      }
      expect(
        systems
            .firstWhere((SystemEvaluation s) => s.name == 'Western')
            .status,
        'Partially available',
      );
      for (final SystemEvaluation system in systems) {
        if (system.name == 'Western') continue;
        expect(system.status, 'Evaluated only');
      }
    });
  });

  group('westernSigns', () {
    test('the sample birth has a tropical Pisces Sun and Libra Moon', () {
      final DateTime utc =
          DateTime(1998, 3, 14, 6, 25).subtract(
        const Duration(hours: 5, minutes: 30),
      );
      final Map<String, String> signs =
          westernSigns(utc, kDefaultPlace);
      expect(signs['Sun'], 'Pisces');
      expect(signs['Moon'], 'Libra');
      expect(signs['Ascendant'], isNotEmpty);
      for (final String sign in signs.values) {
        expect(kWesternSigns.contains(sign), isTrue);
      }
    });
  });
}
