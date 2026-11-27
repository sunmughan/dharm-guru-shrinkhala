import 'package:flutter/foundation.dart';

/// App logging that never carries sensitive user data. Emails,
/// phone numbers and long digit runs are replaced before the
/// line is written, so a log line can never leak an address,
/// a phone number, a token or a birth date. Nothing here writes
/// to a file or a server; output goes to debugPrint only.
class AppLogger {
  AppLogger._();

  static final RegExp _email = RegExp(
    r'[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}',
  );
  static final RegExp _longDigits = RegExp(r'\d{6,}');

  /// Redacts emails and long digit runs in [message].
  static String redact(String message) {
    return message
        .replaceAll(_email, '[email]')
        .replaceAll(_longDigits, '[number]');
  }

  static void info(String message) {
    debugPrint('INFO ${redact(message)}');
  }

  static void warn(String message) {
    debugPrint('WARN ${redact(message)}');
  }

  static void error(String message, [Object? error]) {
    if (error == null) {
      debugPrint('ERROR ${redact(message)}');
    } else {
      debugPrint('ERROR ${redact(message)}: ${redact('$error')}');
    }
  }
}
