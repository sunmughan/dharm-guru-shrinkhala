import 'package:dharm_guru_shrinkhala/core/app_logger.dart';
import 'package:flutter_test/flutter_test.dart';

/// Phase 18, test IDs LOG-01 to LOG-04. Logs must never carry
/// an email address, a phone number or a long digit run.
void main() {
  group('AppLogger.redact', () {
    test('LOG-01 redacts an email address', () {
      expect(
        AppLogger.redact('sign in failed for user@example.com'),
        'sign in failed for [email]',
      );
    });

    test('LOG-02 redacts a long digit run such as a phone number', () {
      expect(AppLogger.redact('call 9876543210 now'), 'call [number] now');
    });

    test('LOG-03 leaves short numbers and plain text alone', () {
      expect(AppLogger.redact('retry 3 of 5'), 'retry 3 of 5');
      expect(AppLogger.redact('kundli ready'), 'kundli ready');
    });

    test('LOG-04 redacts an email inside an error object string', () {
      expect(
        AppLogger.redact('AuthException for admin@gmail.com code 123456'),
        'AuthException for [email] code [number]',
      );
    });
  });
}
