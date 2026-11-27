import 'package:dharm_guru_shrinkhala/core/input_validation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Phase 18, test IDs VAL-01 to VAL-14. Every validator used
/// at a trust boundary gets a positive and a negative case.
void main() {
  group('InputValidation', () {
    test('VAL-01 accepts a normal email', () {
      expect(InputValidation.email('user@example.com'), isNull);
    });
    test('VAL-02 rejects a missing email and a bad email', () {
      expect(InputValidation.email(''), isNotNull);
      expect(InputValidation.email('not-an-email'), isNotNull);
      expect(InputValidation.email('a@b'), isNotNull);
    });
    test('VAL-03 rejects a short password, accepts 8 chars', () {
      expect(InputValidation.password('short'), isNotNull);
      expect(InputValidation.password('longenough'), isNull);
    });
    test('VAL-04 rejects an empty name and a very long name', () {
      expect(InputValidation.displayName(''), isNotNull);
      expect(InputValidation.displayName('  '), isNotNull);
      expect(InputValidation.displayName('A' * 81), isNotNull);
      expect(InputValidation.displayName('Sunmughan'), isNull);
    });
    test('VAL-05 accepts a valid birth date', () {
      expect(
        InputValidation.birthDate('2000-01-15', today: DateTime(2026, 11, 28)),
        isNull,
      );
    });
    test('VAL-06 rejects a future birth date', () {
      expect(
        InputValidation.birthDate('2030-01-15', today: DateTime(2026, 11, 28)),
        isNotNull,
      );
    });
    test('VAL-07 rejects a bad birth date format and year', () {
      expect(
        InputValidation.birthDate('15-01-2000', today: DateTime(2026, 11, 28)),
        isNotNull,
      );
      expect(
        InputValidation.birthDate('1899-01-15', today: DateTime(2026, 11, 28)),
        isNotNull,
      );
    });
    test('VAL-08 accepts a valid birth time, rejects bad ones', () {
      expect(InputValidation.birthTime('07:30'), isNull);
      expect(InputValidation.birthTime('23:59'), isNull);
      expect(InputValidation.birthTime('24:00'), isNotNull);
      expect(InputValidation.birthTime('7:30'), isNotNull);
      expect(InputValidation.birthTime(''), isNotNull);
    });
    test('VAL-09 rejects an empty birth place', () {
      expect(InputValidation.birthPlace(''), isNotNull);
      expect(InputValidation.birthPlace('Jaipur'), isNull);
    });
  });
}
