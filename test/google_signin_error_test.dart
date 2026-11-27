import 'package:dharm_guru_shrinkhala/services/auth_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Google sign in failure names the incomplete setup', () {
    expect(
      AuthService.plainError(
        PlatformException(code: 'sign_in_failed'),
      ),
      'Google sign in could not finish. The app setup for Google '
      'sign in is incomplete. Sign in with email and password for '
      'now and tell the app team.',
    );
  });

  test('Other platform errors stay generic', () {
    expect(
      AuthService.plainError(
        PlatformException(code: 'unknown_error'),
      ),
      'Something went wrong. Try again.',
    );
  });
}
