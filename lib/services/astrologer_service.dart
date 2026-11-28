import '../models/astrologer.dart';
import 'chat_service.dart';
import 'firestore_service.dart';

/// Astrologer workspace service, Phase 10.
///
/// Owns the Hans Ojha record in the `astrologers`
/// collection and the wiring from that record into consult
/// chat and consult call. Firebase only. The record is
/// created with his name plus the details he has provided,
/// phone, qualifications and specialities; every other field
/// stays absent until he provides it, and the service never
/// invents a value for one.
class AstrologerService {
  AstrologerService({
    FirestoreService? firestore,
    ChatService? chatService,
  })  : _firestore = firestore ?? FirestoreService(),
        _chat = chatService ?? ChatService(firestore: firestore);

  final FirestoreService _firestore;
  final ChatService _chat;

  /// Live list of all astrologer records.
  Stream<List<Astrologer>> watchAstrologers() {
    return _firestore.watchDocs('astrologers').map(
      (List<Map<String, dynamic>> docs) =>
          docs.map(Astrologer.fromMap).toList(),
    );
  }

  /// Live Hans Ojha record, or null when it does not exist
  /// yet. The workspace shows an honest empty state then.
  Stream<Astrologer?> watchHansOjha() {
    return watchAstrologers().map((List<Astrologer> list) {
      for (final Astrologer astrologer in list) {
        if (astrologer.id == kHansOjhaDocId) return astrologer;
      }
      return null;
    });
  }

  /// One astrologer record by document id, or null.
  Future<Astrologer?> getAstrologer(String id) async {
    final Map<String, dynamic>? doc =
        await _firestore.getDoc('astrologers', id);
    if (doc == null) return null;
    return Astrologer.fromMap(doc);
  }

  /// The Hans Ojha record, or null when it does not exist yet.
  Future<Astrologer?> getHansOjha() => getAstrologer(kHansOjhaDocId);

  /// Creates the Hans Ojha record when it does not exist yet:
  /// document id `hans-ojha`, his name plus the details he
  /// has provided, status 'waiting'.
  /// Returns the record. Never overwrites an existing
  /// record, so edits the owner made to it are kept.
  /// Call from the admin app only: the rules let only the
  /// owner write the astrologers collection.
  Future<Astrologer> ensureHansOjhaRecord() async {
    final Astrologer? existing = await getHansOjha();
    if (existing != null) return existing;
    await _firestore.saveDoc(
      'astrologers',
      kHansOjhaDocId,
      Astrologer.initialHansOjhaRecord(),
      isNew: true,
    );
    final Astrologer? created = await getHansOjha();
    return created ??
        const Astrologer(
          id: kHansOjhaDocId,
          name: kHansOjhaName,
        );
  }

  /// Merges [updates] into the record with [id]. Only the
  /// keys passed are written; a field left out is untouched.
  /// Pass a null value for a key to clear it. Used by Manage
  /// Astrologers to edit the Hans Ojha record.
  Future<void> updateAstrologer(
    String id,
    Map<String, Object?> updates,
  ) async {
    await _firestore.saveDoc('astrologers', id, updates);
  }

  /// Chat id for one user with Hans Ojha.
  static String chatIdForUser(String uid) =>
      ChatService.astrologerChatId(kHansOjhaDocId, uid);

  /// Records that the chat [chatId] belongs to Hans Ojha:
  /// stores his document id and name on the chat document
  /// and puts the user and his record id in participants.
  /// The admin chat view reads astrologerId off the chat to
  /// route the chat to him. Safe to call before the first
  /// message; sending the first message keeps the fields.
  Future<void> assignChatToHansOjha({
    required String chatId,
    required String uid,
  }) async {
    await _chat.assignAstrologer(
      chatId: chatId,
      astrologerId: kHansOjhaDocId,
      astrologerName: kHansOjhaName,
      participantIds: <String>[uid, kHansOjhaDocId],
    );
  }

  /// The dial URI for [astrologer], or null when he has not
  /// provided a phone number yet. Callers show an honest
  /// "no phone number yet" state when this is null, and
  /// never dial a made up number.
  static Uri? callUri(Astrologer astrologer) {
    final String? phone = astrologer.phone;
    if (phone == null || phone.trim().isEmpty) return null;
    return Uri(scheme: 'tel', path: phone.trim());
  }
}
