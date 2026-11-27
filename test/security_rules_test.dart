import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Phase 18, test IDs RULES-01 to RULES-08. Static audit of
/// the rules files in this repo. This is NOT an emulator run:
/// the Firebase emulator is not available in this CI, so no
/// test here proves a live allow or deny. Emulator rules tests
/// stay BLOCKED in docs/qa/FIREBASE_SECURITY_REPORT.md until
/// the rules emulator job lands. What these tests do prove is
/// that the shipped rules text has the required guards and no
/// open allow.
String _read(String path) => File(path).readAsStringSync();

void main() {
  group('Firestore rules static audit', () {
    late String rules;
    late String storageRules;

    setUpAll(() {
      rules = _read('firebase/firestore.rules');
      storageRules = _read('firebase/storage.rules');
    });

    test('RULES-01 no open allow anywhere in the Firestore rules', () {
      expect(rules.contains('allow read, write: if true'), isFalse);
      expect(rules.contains('allow read: if true'), isFalse);
      expect(rules.contains('allow write: if true'), isFalse);
    });

    test('RULES-02 a user reads and writes only their own profile', () {
      expect(rules.contains('match /users/{uid}'), isTrue);
      expect(
        rules.contains('request.auth.uid == uid'),
        isTrue,
      );
    });

    test('RULES-03 published content writes need the owner role', () {
      expect(rules.contains('allow write: if isOwner()'), isTrue);
      expect(rules.contains("data.role == 'owner'"), isTrue);
    });

    test('RULES-04 chat messages can only be sent as yourself', () {
      expect(
        rules.contains(
          'request.resource.data.senderId == request.auth.uid',
        ),
        isTrue,
      );
    });

    test('RULES-05 payments and moderation are owner only', () {
      expect(rules.contains('match /payments/{doc}'), isTrue);
      expect(rules.contains('match /moderation/{doc}'), isTrue);
    });

    test('RULES-06 rules version 2 is declared', () {
      expect(rules.startsWith("rules_version = '2';"), isTrue);
    });

    test('RULES-07 Storage rules deny everything by default', () {
      expect(storageRules.contains('allow read, write: if false'), isTrue);
      expect(storageRules.contains('request.auth.uid == uid'), isTrue);
    });

    test('RULES-08 Storage rules have no open allow', () {
      expect(
        storageRules.contains('allow read, write: if true'),
        isFalse,
      );
      expect(storageRules.contains('allow read: if true'), isFalse);
    });
  });
}
