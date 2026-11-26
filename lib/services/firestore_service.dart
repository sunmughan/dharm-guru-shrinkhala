import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore access. Collections used in Phase 1 planning only.
/// No real astrologer data is seeded in Phase 1.
class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get users =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get horoscopes =>
      _firestore.collection('horoscopes');

  CollectionReference<Map<String, dynamic>> get astrologers =>
      _firestore.collection('astrologers');

  CollectionReference<Map<String, dynamic>> get panchang =>
      _firestore.collection('panchang');

  Future<void> saveUserProfile({
    required String uid,
    required Map<String, Object?> data,
  }) async {
    await users.doc(uid).set(data, SetOptions(merge: true));
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchHoroscopes() {
    return horoscopes.orderBy('date', descending: true).snapshots();
  }
}
