import 'package:dharm_guru_shrinkhala/services/firestore_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

/// Phase 18, test IDs NEG-01 to NEG-04. Negative tests for
/// the admin gate and ownership. NEG-03 documents a real
/// defect instead of passing it: the seeded admin email still
/// passes isAdminUser with no admins document at all. That
/// behaviour is P1 in docs/qa/FIREBASE_SECURITY_REPORT.md and
/// must be removed once secure owner provisioning is proven,
/// per the master order. The test pins the behaviour so the
/// removal is a visible, deliberate change, not a silent one.
void main() {
  group('Admin gate negative tests', () {
    test('NEG-01 a uid with no admins document is not an admin', () async {
      final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
      final FirestoreService service = FirestoreService(firestore: fake);
      expect(await service.isAdmin('nobody'), isFalse);
    });

    test('NEG-02 a uid with role member is not an admin', () async {
      final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
      final FirestoreService service = FirestoreService(firestore: fake);
      await fake.collection('admins').doc('u1').set(
        <String, Object?>{'role': 'member', 'email': 'u1@example.com'},
      );
      expect(await service.isAdmin('u1'), isFalse);
      expect(
        await service.isAdminUser(uid: 'u1', email: 'u1@example.com'),
        isFalse,
      );
    });

    test('NEG-03 KNOWN DEFECT P1: seeded admin email passes with no '
        'admins document', () async {
      final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
      final FirestoreService service = FirestoreService(firestore: fake);
      expect(
        await service.isAdminUser(
          uid: 'seed-uid',
          email: 'admin@gmail.com',
        ),
        isTrue,
      );
    });

    test('NEG-04 a uid with role owner passes the doc based check',
        () async {
      final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
      final FirestoreService service = FirestoreService(firestore: fake);
      await fake.collection('admins').doc('owner1').set(
        <String, Object?>{'role': 'owner', 'email': 'owner@example.com'},
      );
      expect(await service.isAdmin('owner1'), isTrue);
      expect(
        await service.isAdminUser(
          uid: 'owner1',
          email: 'owner@example.com',
        ),
        isTrue,
      );
    });

    test('NEG-05 ensureAdminDoc does not overwrite an existing role',
        () async {
      final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
      final FirestoreService service = FirestoreService(firestore: fake);
      await fake.collection('admins').doc('u2').set(
        <String, Object?>{'role': 'member', 'email': 'u2@example.com'},
      );
      await service.ensureAdminDoc('u2', 'u2@example.com');
      final Map<String, dynamic>? doc =
          (await fake.collection('admins').doc('u2').get()).data();
      expect(doc?['role'], 'member');
    });
  });
}
