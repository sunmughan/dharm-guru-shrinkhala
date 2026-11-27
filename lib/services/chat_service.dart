import 'package:cloud_firestore/cloud_firestore.dart';

import 'firestore_service.dart';

/// One chat message. senderRole is 'user' or 'admin'.
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderRole,
    required this.text,
    this.createdAt,
    this.sentAt,
  });

  final String id;
  final String senderId;
  final String senderRole;
  final String text;
  final DateTime? createdAt;

  /// Client side milliseconds since epoch, kept so messages
  /// sort in send order even when two server timestamps land
  /// in the same millisecond.
  final int? sentAt;

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    final Object? created = map['createdAt'];
    DateTime? at;
    if (created is Timestamp) {
      at = created.toDate();
    } else if (created is String) {
      at = DateTime.tryParse(created);
    }
    return ChatMessage(
      id: map['id'] is String ? map['id'] as String : '',
      senderId: map['senderId'] is String ? map['senderId'] as String : '',
      senderRole:
          map['senderRole'] is String ? map['senderRole'] as String : '',
      text: map['text'] is String ? map['text'] as String : '',
      createdAt: at,
      sentAt: map['sentAt'] is int ? map['sentAt'] as int : null,
    );
  }
}

/// Real consult chat over Firestore. Chats live in
/// chats/{chatId}/messages, one chat per user. The user side
/// uses chat id "user_<uid>"; a chat with one astrologer uses
/// "chat_<astrologerId>_<uid>". There is no astrologer on the
/// other side yet: messages are stored and the admin app reads
/// and replies in the same chat, but no astrologer identity is
/// invented anywhere.
class ChatService {
  ChatService({FirestoreService? firestore})
      : _firestore = firestore ?? FirestoreService();

  final FirestoreService _firestore;

  /// Chat id for the general room of one user.
  static String userChatId(String uid) => 'user_$uid';

  /// Chat id for one user with one astrologer document.
  static String astrologerChatId(String astrologerId, String uid) =>
      'chat_${astrologerId}_$uid';

  /// Messages oldest first, live.
  Stream<List<ChatMessage>> watchMessages(String chatId) {
    return _firestore.watchDocs('chats/$chatId/messages').map(
      (List<Map<String, dynamic>> docs) {
        final List<ChatMessage> messages =
            docs.map(ChatMessage.fromMap).toList();
        messages.sort((ChatMessage a, ChatMessage b) {
          final int at = a.sentAt ??
              (a.createdAt?.millisecondsSinceEpoch ?? 0);
          final int bt = b.sentAt ??
              (b.createdAt?.millisecondsSinceEpoch ?? 0);
          return at.compareTo(bt);
        });
        return messages;
      },
    );
  }

  /// Stores one message and keeps the chat document current:
  /// participants, last message and last message time. Creates
  /// the chat document on the first message.
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderRole,
    required String text,
    required List<String> participantIds,
  }) async {
    final String trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final Map<String, dynamic>? existing =
        await _firestore.getDoc('chats', chatId);
    await _firestore.saveDoc(
      'chats',
      chatId,
      <String, Object?>{
        'participantIds': participantIds,
        'lastMessage': trimmed,
        'lastMessageAt': FieldValue.serverTimestamp(),
      },
      isNew: existing == null,
    );
    await _firestore.addDoc(
      'chats/$chatId/messages',
      <String, Object?>{
        'senderId': senderId,
        'senderRole': senderRole,
        'text': trimmed,
        'createdAt': FieldValue.serverTimestamp(),
        'sentAt': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }
}
