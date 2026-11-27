import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore access. All data is plain maps, so admin and user
/// screens share the same shapes. No real data is seeded here.
/// The owner writes content from the admin app; the user app
/// only reads published content.
class FirestoreService {
  // Private initializing formal, same as AuthService: no caller
  // ever passes a firestore object in.
  FirestoreService({this._firestore});

  // Nullable on purpose: tests subclass this service and override
  // the methods below, so FirebaseFirestore.instance is never
  // touched when no real firestore object is passed in.
  final FirebaseFirestore? _firestore;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get users =>
      _db.collection('users');

  CollectionReference<Map<String, dynamic>> get horoscopes =>
      _db.collection('horoscopes');

  CollectionReference<Map<String, dynamic>> get astrologers =>
      _db.collection('astrologers');

  CollectionReference<Map<String, dynamic>> get panchang =>
      _db.collection('panchang');

  CollectionReference<Map<String, dynamic>> get admins =>
      _db.collection('admins');

  CollectionReference<Map<String, dynamic>> get plans =>
      _db.collection('plans');

  CollectionReference<Map<String, dynamic>> get payments =>
      _db.collection('payments');

  CollectionReference<Map<String, dynamic>> get notifications =>
      _db.collection('notifications');

  CollectionReference<Map<String, dynamic>> get moderation =>
      _db.collection('moderation');

  /// True only when the admins collection holds a document for
  /// this uid with role owner. The owner creates that document
  /// in the Firebase console; the app never grants admin access.
  Future<bool> isAdmin(String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> doc =
        await admins.doc(uid).get();
    return doc.exists && doc.data()?['role'] == 'owner';
  }

  /// Live list of documents in a collection, each map carrying
  /// its document id under 'id'. Sorted client side by createdAt
  /// descending, documents without one last, so old documents
  /// are never hidden by a server side orderBy.
  Stream<List<Map<String, dynamic>>> watchDocs(String collection) {
    return _db.collection(collection).snapshots().map(
      (QuerySnapshot<Map<String, dynamic>> snap) {
        final List<Map<String, dynamic>> docs =
            snap.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> d) {
          return <String, dynamic>{'id': d.id, ...d.data()};
        }).toList();
        docs.sort((Map<String, dynamic> a, Map<String, dynamic> b) {
          final Timestamp? at = a['createdAt'] as Timestamp?;
          final Timestamp? bt = b['createdAt'] as Timestamp?;
          if (at == null && bt == null) return 0;
          if (at == null) return 1;
          if (bt == null) return -1;
          return bt.compareTo(at);
        });
        return docs;
      },
    );
  }

  /// Creates or merges a document. New documents get a server
  /// createdAt timestamp; updates get updatedAt instead.
  Future<void> saveDoc(
    String collection,
    String id,
    Map<String, Object?> data, {
    bool isNew = false,
  }) async {
    final Map<String, Object?> body = <String, Object?>{...data};
    if (isNew) {
      body['createdAt'] = FieldValue.serverTimestamp();
    } else {
      body['updatedAt'] = FieldValue.serverTimestamp();
    }
    await _db.collection(collection).doc(id).set(body, SetOptions(merge: true));
  }

  Future<void> deleteDoc(String collection, String id) async {
    await _db.collection(collection).doc(id).delete();
  }

  Future<void> saveUserProfile({
    required String uid,
    required Map<String, Object?> data,
  }) async {
    final DocumentSnapshot<Map<String, dynamic>> existing =
        await users.doc(uid).get();
    final Map<String, Object?> body = <String, Object?>{...data};
    if (!existing.exists) {
      body['createdAt'] = FieldValue.serverTimestamp();
    } else {
      body['updatedAt'] = FieldValue.serverTimestamp();
    }
    await users.doc(uid).set(body, SetOptions(merge: true));
  }
}
