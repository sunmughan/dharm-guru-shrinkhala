import 'package:dharm_guru_shrinkhala/services/firestore_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

/// The admin publish flow against an in memory Firestore,
/// through the same FirestoreService the screens use: save a
/// draft, publish it, then read it back the way the user app
/// reads it. The live step that remains is the console step
/// in the report: the repo rules must be published and the
/// owner record created before a live write is allowed.
void main() {
  test('profile save and read back', () async {
    final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
    final FirestoreService service = FirestoreService(firestore: fake);
    await service.saveUserProfile(
      uid: 'u1',
      data: <String, Object?>{
        'name': 'Test User',
        'dateOfBirth': '2000-01-15',
        'timeOfBirth': '07:30',
        'birthCity': 'Delhi',
        'birthState': 'Delhi',
        'birthCountry': 'India',
        'horoscopeAlertTime': '06:00',
      },
    );
    final Map<String, dynamic>? read =
        await service.getUserProfile('u1');
    expect(read?['name'], 'Test User');
    expect(read?['dateOfBirth'], '2000-01-15');
    expect(read?['birthCity'], 'Delhi');
    expect(read?['horoscopeAlertTime'], '06:00');
    // A second save merges: the city survives a name change.
    await service.saveUserProfile(
      uid: 'u1',
      data: <String, Object?>{'name': 'Test User Two'},
    );
    final Map<String, dynamic>? reread =
        await service.getUserProfile('u1');
    expect(reread?['name'], 'Test User Two');
    expect(reread?['birthCity'], 'Delhi');
  });

  test('horoscope publish flow: draft hidden, published read', () async {
    final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
    final FirestoreService service = FirestoreService(firestore: fake);
    const String id = '2026-11-27_Kanya';
    await service.saveDoc(
      'horoscopes',
      id,
      <String, Object?>{
        'date': '2026-11-27',
        'rashi': 'Kanya',
        'summary': 'A strong day for money talks.',
        'career': 'Good progress.',
        'money': 'Steady.',
        'health': 'Take rest.',
        'love': 'Warm.',
        'luckyNumber': '5',
        'luckyColour': 'Green',
        'status': 'draft',
      },
      isNew: true,
    );
    Future<List<Map<String, dynamic>>> published() async {
      final List<Map<String, dynamic>> docs =
          await service.watchDocs('horoscopes').first;
      return docs
          .where((Map<String, dynamic> d) => d['status'] == 'published')
          .toList();
    }

    expect(await published(), isEmpty);
    await service.saveDoc(
      'horoscopes',
      id,
      <String, Object?>{'status': 'published'},
    );
    final List<Map<String, dynamic>> live = await published();
    expect(live.length, 1);
    expect(live.first['rashi'], 'Kanya');
    expect(live.first['date'], '2026-11-27');
    expect(live.first['summary'], 'A strong day for money talks.');
  });

  test('panchang save and read back by date', () async {
    final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
    final FirestoreService service = FirestoreService(firestore: fake);
    await service.saveDoc(
      'panchang',
      '2026-11-27',
      <String, Object?>{
        'date': '2026-11-27',
        'city': 'Jaipur',
        'tithi': 'Shukla Panchami',
        'sunrise': '06:48 AM',
      },
      isNew: true,
    );
    final List<Map<String, dynamic>> docs =
        await service.watchDocs('panchang').first;
    final Map<String, dynamic> found = docs.firstWhere(
      (Map<String, dynamic> d) => d['date'] == '2026-11-27',
    );
    expect(found['city'], 'Jaipur');
    expect(found['tithi'], 'Shukla Panchami');
  });
}
