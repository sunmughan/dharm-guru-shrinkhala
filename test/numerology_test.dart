import 'package:dharm_guru_shrinkhala/services/numerology.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('P7N1 birth and life path for 14 March 1998', () {
    final NumerologyResult result = NumerologyCalculator.calculate(
      name: 'Ram',
      birthDate: DateTime(1998, 3, 14),
    );
    expect(result.birthNumber, 5);
    expect(result.birthSteps, '14 = 5');
    expect(result.lifePathNumber, 8);
    expect(result.bhagyank, 8);
    expect(result.lifePathSteps, contains('-> 8'));
    expect(result.planetFor(5), 'Mercury');
    expect(result.planetFor(8), 'Saturn');
  });

  test('P7N2 destiny number differs by system for Ram', () {
    final NumerologyResult chaldean = NumerologyCalculator.calculate(
      name: 'Ram',
      birthDate: DateTime(1998, 3, 14),
      options: const NumerologyOptions(
        system: NumerologySystem.chaldean,
      ),
    );
    // Chaldean R 2 + A 1 + M 4 = 7.
    expect(chaldean.destinyNumber, 7);
    expect(chaldean.system, NumerologySystem.chaldean);
    final NumerologyResult pythagorean = NumerologyCalculator.calculate(
      name: 'Ram',
      birthDate: DateTime(1998, 3, 14),
      options: const NumerologyOptions(
        system: NumerologySystem.pythagorean,
      ),
    );
    // Pythagorean R 9 + A 1 + M 4 = 14, then 1 + 4 = 5.
    expect(pythagorean.destinyNumber, 5);
    expect(pythagorean.destinySteps, '14 = 5');
  });

  test('P7N3 soul urge and personality split the name', () {
    final NumerologyResult result = NumerologyCalculator.calculate(
      name: 'Ram',
      birthDate: DateTime(1998, 3, 14),
    );
    // Chaldean vowels A 1, consonants R 2 + M 4 = 6.
    expect(result.soulUrgeNumber, 1);
    expect(result.personalityNumber, 6);
  });

  test('P7N4 Lo Shu for 14 March 1998 counts digits and missing numbers', () {
    final NumerologyResult result = NumerologyCalculator.calculate(
      name: 'Ram',
      birthDate: DateTime(1998, 3, 14),
    );
    // Digits 1, 4, 3, 1, 9, 9, 8: 1 twice, 9 twice, 3, 4, 8 once.
    expect(result.loShuCounts[1], 2);
    expect(result.loShuCounts[9], 2);
    expect(result.loShuCounts[3], 1);
    expect(result.loShuCounts[4], 1);
    expect(result.loShuCounts[8], 1);
    expect(result.loShuMissing, <int>[2, 5, 6, 7]);
    expect(result.loShuCompleteLines, isEmpty);
  });

  test('P7N5 Lo Shu complete line for a date with 4, 5 and 6 present', () {
    final NumerologyResult result = NumerologyCalculator.calculate(
      name: 'Ram',
      birthDate: DateTime(1996, 5, 4),
    );
    expect(result.loShuCompleteLines, contains(<int>[4, 5, 6]));
  });

  test('P7N6 number compatibility uses planet friendship', () {
    // 1 Sun with 3 Jupiter: friends, Compatible.
    expect(NumerologyCalculator.compatibility(1, 3), 'Compatible');
    // 1 Sun with 6 Venus: enemies, Challenging.
    expect(NumerologyCalculator.compatibility(1, 6), 'Challenging');
    // 2 Moon with 9 Mars: Moon neutral to Mars, Mars friend
    // to Moon, so Compatible.
    expect(NumerologyCalculator.compatibility(2, 9), 'Compatible');
    // 4 Rahu with 5 Mercury: no friend or enemy link, Neutral.
    expect(NumerologyCalculator.compatibility(4, 5), 'Neutral');
  });

  test('P7N7 same input gives the same result, no randomness', () {
    final NumerologyResult first = NumerologyCalculator.calculate(
      name: 'Sunmughan',
      birthDate: DateTime(1998, 3, 14),
    );
    final NumerologyResult second = NumerologyCalculator.calculate(
      name: 'Sunmughan',
      birthDate: DateTime(1998, 3, 14),
    );
    expect(second.birthNumber, first.birthNumber);
    expect(second.lifePathNumber, first.lifePathNumber);
    expect(second.destinyNumber, first.destinyNumber);
    expect(second.loShuMissing, first.loShuMissing);
  });

  test('P7N8 empty name gives destiny 0, not a crash', () {
    final NumerologyResult result = NumerologyCalculator.calculate(
      name: '',
      birthDate: DateTime(2000, 1, 15),
    );
    expect(result.destinyNumber, 0);
    expect(result.birthNumber, 6);
    expect(result.lifePathNumber, 9);
  });
}
