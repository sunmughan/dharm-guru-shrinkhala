import 'package:dharm_guru_shrinkhala/services/premium_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('premium stays off when the flag says so', () {
    expect(
      PremiumService(isEnabled: () => false).isPremiumEnabled,
      isFalse,
    );
  });

  test('premium turns on when the flag says so', () {
    expect(
      PremiumService(isEnabled: () => true).isPremiumEnabled,
      isTrue,
    );
  });
}
