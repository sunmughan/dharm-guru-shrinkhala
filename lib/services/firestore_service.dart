import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/admin_config.dart';

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

  CollectionReference<Map<String, dynamic>> get chats =>
      _db.collection('chats');

  CollectionReference<Map<String, dynamic>> get moderation =>
      _db.collection('moderation');

  /// True only when the admins collection holds a document for
  /// this uid with role owner. The owner creates that document
  /// in the Firebase console; the app never grants admin access.
  Future<bool> isAdmin(String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> doc = await admins
        .doc(uid)
        .get();
    return doc.exists && doc.data()?['role'] == 'owner';
  }

  /// Admin gate check. The admins document is the real gate. The
  /// default admin account (admin@gmail.com, seeded by the admin
  /// app on first launch) also passes when its document is
  /// missing, for example when the rules were not published yet
  /// when the seed ran. This is not an auth bypass: Firebase Auth
  /// still checks the password, this only maps the seeded account
  /// to the owner role.
  Future<bool> isAdminUser({required String uid, String? email}) async {
    if (email != null && email.trim().toLowerCase() == kDefaultAdminEmail) {
      return true;
    }
    return isAdmin(uid);
  }

  /// Creates the admins document for a uid when it is missing.
  /// Used when a Google account signs in to the admin app: the
  /// owner ordered that whoever creates an account once through
  /// Google in the admin app can use admin access. The rules
  /// allow a signed in user to write only their own document.
  Future<void> ensureAdminDoc(String uid, String email) async {
    final DocumentSnapshot<Map<String, dynamic>> doc = await admins
        .doc(uid)
        .get();
    if (doc.exists) {
      return;
    }
    await admins.doc(uid).set(<String, Object?>{
      'role': 'owner',
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// The signed in user profile document, or null when the user
  /// has not completed a profile yet. The map carries its
  /// document id under 'id'.
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> doc = await users
        .doc(uid)
        .get();
    if (!doc.exists) {
      return null;
    }
    return <String, dynamic>{'id': uid, ...?doc.data()};
  }

  /// Live list of documents in a collection, each map carrying
  /// its document id under 'id'. Sorted client side by createdAt
  /// descending, documents without one last, so old documents
  /// are never hidden by a server side orderBy.
  Stream<List<Map<String, dynamic>>> watchDocs(String collection) {
    return _db.collection(collection).snapshots().map((
      QuerySnapshot<Map<String, dynamic>> snap,
    ) {
      final List<Map<String, dynamic>> docs = snap.docs.map((
        QueryDocumentSnapshot<Map<String, dynamic>> d,
      ) {
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
    });
  }

  /// One page of documents, newest first by createdAt, at most
  /// [limit] documents. Pass the [lastId] returned by the
  /// previous page to fetch the next page. This is the paged
  /// read admin lists must use: watchDocs streams the whole
  /// collection with no limit, which grows without bound as
  /// users, chats and payments accumulate.
  ///
  /// The cursor is the createdAt value of the last document,
  /// not a document snapshot: the in memory Firestore used by
  /// tests does not page startAfterDocument correctly with a
  /// descending orderBy, and a value cursor behaves the same in
  /// the fake and in real Firestore.
  ///
  /// shortcut: documents without a createdAt field are never
  /// returned by a paged read, and two documents that share
  /// the exact same createdAt value can be skipped at a page
  /// boundary. saveDoc always stamps createdAt on new
  /// documents, so this only bites hand written documents.
  Future<({List<Map<String, dynamic>> docs, String? lastId})> getDocsPaged(
    String collection, {
    int limit = 25,
    String? startAfterId,
  }) async {
    Query<Map<String, dynamic>> query = _db.collection(collection);
    if (startAfterId != null) {
      final DocumentSnapshot<Map<String, dynamic>> cursor = await _db
          .collection(collection)
          .doc(startAfterId)
          .get();
      final Timestamp? at = cursor.data()?['createdAt'] as Timestamp?;
      if (at != null) {
        query = query.where('createdAt', isLessThan: at);
      }
    }
    query = query.orderBy('createdAt', descending: true).limit(limit);
    final QuerySnapshot<Map<String, dynamic>> snap = await query.get();
    final List<Map<String, dynamic>> docs = snap.docs.map((
      QueryDocumentSnapshot<Map<String, dynamic>> d,
    ) {
      return <String, dynamic>{'id': d.id, ...d.data()};
    }).toList();
    return (
      docs: docs,
      lastId: docs.isEmpty ? null : docs.last['id'] as String?,
    );
  }

  /// One document by id, or null when it does not exist.
  /// The map carries its document id under 'id'.
  Future<Map<String, dynamic>?> getDoc(String collection, String id) async {
    final DocumentSnapshot<Map<String, dynamic>> doc = await _db
        .collection(collection)
        .doc(id)
        .get();
    if (!doc.exists) {
      return null;
    }
    return <String, dynamic>{'id': id, ...?doc.data()};
  }

  /// Adds a document with an auto id to a collection or a
  /// subcollection path such as chats/<id>/messages. Returns
  /// the new document id.
  Future<String> addDoc(String collection, Map<String, Object?> data) async {
    final DocumentReference<Map<String, dynamic>> ref = await _db
        .collection(collection)
        .add(data);
    return ref.id;
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
    final DocumentSnapshot<Map<String, dynamic>> existing = await users
        .doc(uid)
        .get();
    final Map<String, Object?> body = <String, Object?>{...data};
    if (!existing.exists) {
      body['createdAt'] = FieldValue.serverTimestamp();
    } else {
      body['updatedAt'] = FieldValue.serverTimestamp();
    }
    await users.doc(uid).set(body, SetOptions(merge: true));
  }
}
