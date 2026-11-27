import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dharm_guru_shrinkhala/services/firestore_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

/// Phase 18, test IDs PAGE-01 to PAGE-04. Paged reads against
/// an in memory Firestore, through the same FirestoreService
/// the screens use. Pages must not repeat or skip documents.
Future<void> _seed(
  FirestoreService service,
  String collection,
  int count,
) async {
  for (int i = 0; i < count; i++) {
    await service.addDoc(collection, <String, Object?>{
      'title': 'Doc $i',
      'createdAt': Timestamp.fromDate(DateTime(2026, 11, 1 + i)),
    });
  }
}

void main() {
  group('Firestore pagination', () {
    test(
      'PAGE-01 first page returns at most the limit, newest first',
      () async {
        final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
        final FirestoreService service = FirestoreService(firestore: fake);
        await _seed(service, 'horoscopes', 5);
        final ({List<Map<String, dynamic>> docs, String? lastId}) page =
            await service.getDocsPaged('horoscopes', limit: 2);
        expect(page.docs.length, 2);
        expect(page.docs.first['title'], 'Doc 4');
        expect(page.docs.last['title'], 'Doc 3');
        expect(page.lastId, isNotNull);
      },
    );

    test('PAGE-02 walking all pages returns every document once', () async {
      final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
      final FirestoreService service = FirestoreService(firestore: fake);
      await _seed(service, 'horoscopes', 5);
      final List<String> seen = <String>[];
      String? cursor;
      for (int step = 0; step < 10; step++) {
        final ({List<Map<String, dynamic>> docs, String? lastId}) page =
            await service.getDocsPaged(
              'horoscopes',
              limit: 2,
              startAfterId: cursor,
            );
        if (page.docs.isEmpty) break;
        seen.addAll(
          page.docs.map((Map<String, dynamic> d) => d['id'] as String),
        );
        cursor = page.lastId;
      }
      expect(seen.length, 5);
      expect(seen.toSet().length, 5);
    });

    test('PAGE-03 a limit larger than the collection returns all', () async {
      final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
      final FirestoreService service = FirestoreService(firestore: fake);
      await _seed(service, 'horoscopes', 3);
      final ({List<Map<String, dynamic>> docs, String? lastId}) page =
          await service.getDocsPaged('horoscopes', limit: 25);
      expect(page.docs.length, 3);
      expect(page.lastId, isNotNull);
    });

    test('PAGE-04 an empty collection returns an empty page', () async {
      final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
      final FirestoreService service = FirestoreService(firestore: fake);
      final ({List<Map<String, dynamic>> docs, String? lastId}) page =
          await service.getDocsPaged('horoscopes', limit: 25);
      expect(page.docs, isEmpty);
      expect(page.lastId, isNull);
    });
  });
}
