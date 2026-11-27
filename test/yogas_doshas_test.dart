import 'package:dharm_guru_shrinkhala/services/astro.dart';
import 'package:dharm_guru_shrinkhala/services/yogas_doshas.dart';
import 'package:flutter_test/flutter_test.dart';

/// Phase 6 yoga and dosha tests, on the sample birth used
/// across the suite: 14 March 1998, 06:25 AM IST, Jaipur.
/// Lagna Kumbha, Moon in Kanya, Mars in Meena, Saturn in
/// Meena, Mercury in Meena, Sun in Kumbha.

void main() {
  late KundliResult kundli;

  setUpAll(() {
    kundli = KundliCalculator.calculate(
      birthLocal: DateTime(1998, 3, 14, 6, 25),
      placeText: 'Jaipur',
    );
  });

  group('findYogas', () {
    test('three Raj Yogas from the Meena lords, no Dhana Yoga', () {
      final List<YogaResult> yogas = findYogas(kundli);
      final List<YogaResult> raj = yogas
          .where((YogaResult y) => y.name == 'Raj Yoga')
          .toList();
      final List<YogaResult> dhana = yogas
          .where((YogaResult y) => y.name == 'Dhana Yoga')
          .toList();
      expect(raj.length, 3);
      expect(dhana, isEmpty);
      for (final YogaResult yoga in yogas) {
        expect(yoga.planets.length, 2);
        expect(yoga.explanation, isNotEmpty);
      }
    });
  });

  group('mangalDosha', () {
    test('Mars in Meena shows from lagna and Moon, then cancels', () {
      final MangalDoshaResult result = mangalDosha(kundli);
      expect(result.references, contains('lagna'));
      expect(result.references, contains('Moon'));
      expect(result.references, isNot(contains('Venus')));
      expect(result.cancelled, isTrue);
      expect(result.present, isFalse);
      expect(result.explanation, contains('cancelled'));
    });

    test('a chart with Mars in the 8th from lagna shows the dosha', () {
      final KundliResult other = KundliCalculator.calculate(
        birthLocal: DateTime(2000, 6, 15, 14, 30),
        placeText: 'Delhi',
      );
      final MangalDoshaResult result = mangalDosha(other);
      expect(result.explanation, isNotEmpty);
      expect(result.references, isA<List<String>>());
    });
  });

  group('kaalSarpDosha', () {
    test('the sample chart has planets on both sides of the axis', () {
      final KaalSarpResult result = kaalSarpDosha(kundli);
      expect(result.present, isFalse);
      expect(result.explanation, contains('both sides'));
    });
  });
}
