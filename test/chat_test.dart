import 'package:dharm_guru_shrinkhala/services/chat_service.dart';
import 'package:dharm_guru_shrinkhala/services/firestore_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('chat send and read round trip on Firestore', () async {
    final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
    final FirestoreService service = FirestoreService(firestore: fake);
    final ChatService chat = ChatService(firestore: service);
    const String chatId = 'user_test_uid';
    await chat.sendMessage(
      chatId: chatId,
      senderId: 'test_uid',
      senderRole: 'user',
      text: 'Hello',
      participantIds: <String>['test_uid'],
    );
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await chat.sendMessage(
      chatId: chatId,
      senderId: 'admin_uid',
      senderRole: 'admin',
      text: 'Namaste',
      participantIds: <String>['test_uid'],
    );
    final List<ChatMessage> messages =
        await chat.watchMessages(chatId).first;
    expect(messages.length, 2);
    expect(messages[0].text, 'Hello');
    expect(messages[0].senderRole, 'user');
    expect(messages[1].text, 'Namaste');
    expect(messages[1].senderRole, 'admin');
    // An empty message is never stored.
    await chat.sendMessage(
      chatId: chatId,
      senderId: 'test_uid',
      senderRole: 'user',
      text: '   ',
      participantIds: <String>['test_uid'],
    );
    final List<ChatMessage> again =
        await chat.watchMessages(chatId).first;
    expect(again.length, 2);
    // The chat document carries the last message.
    final Map<String, dynamic>? doc =
        await service.getDoc('chats', chatId);
    expect(doc?['lastMessage'], 'Namaste');
  });

  test('chat ids are stable per user and per astrologer', () {
    expect(ChatService.userChatId('u1'), 'user_u1');
    expect(
      ChatService.astrologerChatId('a1', 'u1'),
      'chat_a1_u1',
    );
  });
}
