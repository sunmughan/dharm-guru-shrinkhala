import 'package:dharm_guru_shrinkhala/models/astrologer.dart';
import 'package:dharm_guru_shrinkhala/screens/admin_screens.dart';
import 'package:dharm_guru_shrinkhala/screens/astrologer_workspace_screen.dart';
import 'package:dharm_guru_shrinkhala/screens/screens.dart';
import 'package:dharm_guru_shrinkhala/services/astrologer_service.dart';
import 'package:dharm_guru_shrinkhala/services/auth_service.dart';
import 'package:dharm_guru_shrinkhala/services/chat_service.dart';
import 'package:dharm_guru_shrinkhala/services/firestore_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Phase 10 proof: the Hans Ojha astrologer workspace.
///
/// Every test runs against the real AstrologerService,
/// ChatService and FirestoreService on an in memory
/// Firestore. Nothing about Hans Ojha is invented here:
/// the record is created with his name plus the details he
/// has provided, phone, qualifications and specialities,
/// and the tests assert the fields he has not provided stay
/// absent and the UI says so plainly.
void main() {
  group('Astrologer model', () {
    test('name only record has no phone, photo, bio, qualifications or specialities', () {
      const Astrologer astrologer = Astrologer(
        id: kHansOjhaDocId,
        name: kHansOjhaName,
      );
      expect(astrologer.name, 'Hans Ojha');
      expect(astrologer.hasPhone, isFalse);
      expect(astrologer.hasPhoto, isFalse);
      expect(astrologer.hasBio, isFalse);
      expect(astrologer.hasQualifications, isFalse);
      expect(astrologer.hasSpecialities, isFalse);
      expect(astrologer.hasLanguages, isFalse);
      expect(astrologer.hasExperience, isFalse);
      expect(astrologer.hasRate, isFalse);
      expect(
        astrologer.missingDetails,
        <String>[
          'Phone number',
          'Photo',
          'Bio',
          'Qualifications',
          'Specialities',
          'Languages',
          'Experience',
          'Rate',
        ],
      );
    });

    test('empty strings from Firestore read as not provided', () {
      final Astrologer astrologer = Astrologer.fromMap(
        <String, dynamic>{
          'id': kHansOjhaDocId,
          'name': kHansOjhaName,
          'phone': '',
          'bio': '   ',
          'status': 'waiting',
        },
      );
      expect(astrologer.hasPhone, isFalse);
      expect(astrologer.hasBio, isFalse);
      expect(astrologer.missingDetails, contains('Phone number'));
      expect(astrologer.missingDetails, contains('Bio'));
    });

    test('toMap leaves unprovided fields out entirely', () {
      const Astrologer astrologer = Astrologer(
        id: kHansOjhaDocId,
        name: kHansOjhaName,
      );
      final Map<String, Object?> map = astrologer.toMap();
      expect(map['name'], 'Hans Ojha');
      expect(map.containsKey('phone'), isFalse);
      expect(map.containsKey('photoUrl'), isFalse);
      expect(map.containsKey('bio'), isFalse);
      expect(map.containsKey('qualifications'), isFalse);
      expect(map.containsKey('specialities'), isFalse);
      // The seed carries the details he has provided.
      final Map<String, Object?> initial =
          Astrologer.initialHansOjhaRecord();
      expect(initial['name'], 'Hans Ojha');
      expect(initial['phone'], '9303849941');
      expect(initial['qualifications'], 'Astrology');
      expect(
        initial['specialities'],
        <String>[
          'Kundli vishleshan',
          'Mahadosh nivaran',
          'Vivah evam rishta margdarshan',
          'Career evam vyavasay margdarshan',
          'Grah shanti evam vastu margdarshan',
          'Swasthya margdarshan',
          'Santan prapti evam parivar sukh',
          'Adhyatmik sadhna evam jeevan margdarshan',
        ],
      );
      expect(initial.containsKey('photoUrl'), isFalse);
      expect(initial.containsKey('bio'), isFalse);
      expect(initial.containsKey('languages'), isFalse);
      expect(initial.containsKey('experience'), isFalse);
      expect(initial.containsKey('rate'), isFalse);
    });

    test('listed for consult once approved, online or offline', () {
      expect(Astrologer.isListedForConsultStatus('approved'), isTrue);
      expect(Astrologer.isListedForConsultStatus('Online'), isTrue);
      expect(Astrologer.isListedForConsultStatus('offline'), isTrue);
      expect(Astrologer.isListedForConsultStatus('Offline'), isTrue);
      expect(Astrologer.isListedForConsultStatus('waiting'), isFalse);
      expect(Astrologer.isListedForConsultStatus('rejected'), isFalse);
    });
  });

  group('AstrologerService record', () {
    test('ensure creates the Hans Ojha record with his provided details', () async {
      final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
      final FirestoreService firestore = FirestoreService(firestore: fake);
      final AstrologerService service = AstrologerService(
        firestore: firestore,
      );
      expect(await service.getHansOjha(), isNull);
      final Astrologer created = await service.ensureHansOjhaRecord();
      expect(created.id, 'hans-ojha');
      expect(created.name, 'Hans Ojha');
      expect(created.phone, '9303849941');
      expect(created.qualifications, 'Astrology');
      expect(created.specialities, <String>[
        'Kundli vishleshan',
        'Mahadosh nivaran',
        'Vivah evam rishta margdarshan',
        'Career evam vyavasay margdarshan',
        'Grah shanti evam vastu margdarshan',
        'Swasthya margdarshan',
        'Santan prapti evam parivar sukh',
        'Adhyatmik sadhna evam jeevan margdarshan',
      ]);
      expect(created.status, 'waiting');
      final Map<String, dynamic>? doc =
          await firestore.getDoc('astrologers', 'hans-ojha');
      expect(doc?['name'], 'Hans Ojha');
      expect(doc?['phone'], '9303849941');
      expect(doc?['qualifications'], 'Astrology');
      expect(doc?.containsKey('photoUrl'), isFalse);
      expect(doc?.containsKey('bio'), isFalse);
      expect(doc?.containsKey('languages'), isFalse);
      expect(doc?.containsKey('experience'), isFalse);
      expect(doc?.containsKey('rate'), isFalse);
      // The admin list reads him back from the collection.
      final List<Astrologer> listed =
          await service.watchAstrologers().first;
      expect(
        listed.map((Astrologer a) => a.name),
        contains('Hans Ojha'),
      );
    });

    test('ensure never overwrites an edited record', () async {
      final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
      final AstrologerService service = AstrologerService(
        firestore: FirestoreService(firestore: fake),
      );
      await service.ensureHansOjhaRecord();
      await service.updateAstrologer(
        kHansOjhaDocId,
        <String, Object?>{'phone': '9876543210', 'bio': 'Vedic astrologer'},
      );
      final Astrologer again = await service.ensureHansOjhaRecord();
      expect(again.phone, '9876543210');
      expect(again.bio, 'Vedic astrologer');
      expect(again.missingDetails, isNot(contains('Phone number')));
      expect(again.missingDetails, isNot(contains('Bio')));
    });

    test('watchHansOjha emits the record once it exists', () async {
      final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
      final AstrologerService service = AstrologerService(
        firestore: FirestoreService(firestore: fake),
      );
      await service.ensureHansOjhaRecord();
      final Astrologer? hans = await service.watchHansOjha().first;
      expect(hans?.name, 'Hans Ojha');
      expect(hans?.id, 'hans-ojha');
    });
  });

  group('Consult chat assignment', () {
    test('chat is assigned to Hans Ojha and keeps his name', () async {
      final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
      final FirestoreService firestore = FirestoreService(firestore: fake);
      final ChatService chat = ChatService(firestore: firestore);
      final AstrologerService service = AstrologerService(
        firestore: firestore,
        chatService: chat,
      );
      await service.ensureHansOjhaRecord();
      const String uid = 'user_1';
      final String chatId = AstrologerService.chatIdForUser(uid);
      expect(chatId, 'chat_hans-ojha_user_1');
      await service.assignChatToHansOjha(chatId: chatId, uid: uid);
      final Map<String, dynamic>? doc =
          await firestore.getDoc('chats', chatId);
      expect(doc?['astrologerId'], 'hans-ojha');
      expect(doc?['astrologerName'], 'Hans Ojha');
      expect(doc?['participantIds'], <String>['user_1', 'hans-ojha']);
    });

    test('user and astrologer messages share the assigned chat', () async {
      final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
      final FirestoreService firestore = FirestoreService(firestore: fake);
      final ChatService chat = ChatService(firestore: firestore);
      final AstrologerService service = AstrologerService(
        firestore: firestore,
        chatService: chat,
      );
      const String uid = 'user_1';
      final String chatId = AstrologerService.chatIdForUser(uid);
      await service.assignChatToHansOjha(chatId: chatId, uid: uid);
      await chat.sendMessage(
        chatId: chatId,
        senderId: uid,
        senderRole: 'user',
        text: 'Please read my chart',
        participantIds: <String>[uid, kHansOjhaDocId],
      );
      await chat.sendMessage(
        chatId: chatId,
        senderId: kHansOjhaDocId,
        senderRole: 'astrologer',
        text: 'Namaste, I will look at it',
        participantIds: <String>[uid, kHansOjhaDocId],
      );
      final List<ChatMessage> messages =
          await chat.watchMessages(chatId).first;
      expect(messages.length, 2);
      expect(messages[0].senderRole, 'user');
      expect(messages[1].senderRole, 'astrologer');
      expect(messages[1].senderId, 'hans-ojha');
      // Assignment survives the first message.
      final Map<String, dynamic>? doc =
          await firestore.getDoc('chats', chatId);
      expect(doc?['astrologerName'], 'Hans Ojha');
      expect(doc?['lastMessage'], 'Namaste, I will look at it');
    });
  });

  group('Consult call behaviour', () {
    test('no phone saved means no dial URI', () async {
      final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
      final FirestoreService firestore = FirestoreService(firestore: fake);
      final AstrologerService service = AstrologerService(
        firestore: firestore,
      );
      // A record without a phone, as the seed was before he
      // provided his number.
      await fake.collection('astrologers').doc('hans-ojha').set(
        <String, Object?>{
          'name': 'Hans Ojha',
          'status': 'waiting',
          'chatAvailable': true,
          'callAvailable': true,
        },
      );
      final Astrologer? hans = await service.getHansOjha();
      expect(AstrologerService.callUri(hans!), isNull);
    });

    test('saved phone dials that number and only that number', () async {
      final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
      final AstrologerService service = AstrologerService(
        firestore: FirestoreService(firestore: fake),
      );
      await service.ensureHansOjhaRecord();
      await service.updateAstrologer(
        kHansOjhaDocId,
        <String, Object?>{'phone': '9876543210'},
      );
      final Astrologer? hans = await service.getHansOjha();
      expect(
        AstrologerService.callUri(hans!),
        Uri(scheme: 'tel', path: '9876543210'),
      );
    });
  });

  group('Workspace screen', () {
    testWidgets('shows Hans Ojha with honest not provided states',
        (WidgetTester tester) async {
      final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
      final FirestoreService firestore = FirestoreService(firestore: fake);
      await AstrologerService(firestore: firestore).ensureHansOjhaRecord();
      // The profile is longer than the default 600px test
      // surface once specialities are listed, so give the
      // viewport room to build the whole list.
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await _pumpApp(
        tester,
        AstrologerWorkspaceScreen(
          firestore: firestore,
          currentUserId: 'user_1',
        ),
      );
      expect(find.text('Hans Ojha'), findsOneWidget);
      expect(find.text('Astrologer'), findsNWidgets(2));
      expect(find.text('Phone: 9303849941'), findsOneWidget);
      expect(find.text('Photo not provided yet'), findsOneWidget);
      expect(find.text('Bio: Bio not provided yet'), findsOneWidget);
      expect(find.text('Qualifications: Astrology'), findsOneWidget);
      expect(find.text('Specialities'), findsOneWidget);
      expect(find.text('Kundli vishleshan'), findsOneWidget);
      expect(find.text('Mahadosh nivaran'), findsOneWidget);
      expect(find.text('Vivah evam rishta margdarshan'), findsOneWidget);
      expect(find.text('Career evam vyavasay margdarshan'), findsOneWidget);
      expect(find.text('Grah shanti evam vastu margdarshan'), findsOneWidget);
      expect(find.text('Swasthya margdarshan'), findsOneWidget);
      expect(find.text('Santan prapti evam parivar sukh'), findsOneWidget);
      expect(
        find.text('Adhyatmik sadhna evam jeevan margdarshan'),
        findsOneWidget,
      );
      expect(find.text('Rate: Rate to be decided'), findsOneWidget);
      expect(find.text('Phone number: not provided yet'), findsNothing);
      expect(find.text('Photo: not provided yet'), findsOneWidget);
    });

    testWidgets('says the record is missing when it does not exist',
        (WidgetTester tester) async {
      final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
      await _pumpApp(
        tester,
        AstrologerWorkspaceScreen(
          firestore: FirestoreService(firestore: fake),
          currentUserId: 'user_1',
        ),
      );
      expect(find.textContaining('has not been added yet'), findsOneWidget);
    });

    testWidgets('call with no phone saved says so plainly',
        (WidgetTester tester) async {
      final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
      final FirestoreService firestore = FirestoreService(firestore: fake);
      // A record without a phone, as the seed was before he
      // provided his number.
      await fake.collection('astrologers').doc('hans-ojha').set(
        <String, Object?>{
          'name': 'Hans Ojha',
          'status': 'waiting',
          'chatAvailable': true,
          'callAvailable': true,
        },
      );
      await _pumpApp(
        tester,
        AstrologerWorkspaceScreen(
          firestore: firestore,
          currentUserId: 'user_1',
        ),
      );
      await tester.tap(find.text('Call Hans Ojha'));
      await tester.pumpAndSettle();
      expect(
        find.text('No phone number yet for Hans Ojha.'),
        findsOneWidget,
      );
    });

    testWidgets('chat opens his assigned room and names him',
        (WidgetTester tester) async {
      final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
      final FirestoreService firestore = FirestoreService(firestore: fake);
      final ChatService chat = ChatService(firestore: firestore);
      await AstrologerService(
        firestore: firestore,
        chatService: chat,
      ).ensureHansOjhaRecord();
      // Tall surface, as in the profile states test above:
      // the chat button sits below the specialities list.
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await _pumpApp(
        tester,
        AstrologerWorkspaceScreen(
          firestore: firestore,
          currentUserId: 'user_1',
          chatService: chat,
        ),
      );
      await tester.tap(find.text('Chat with Hans Ojha'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Hans Ojha has not joined the chat yet. Your messages are saved here.',
        ),
        findsOneWidget,
      );
      final Map<String, dynamic>? doc = await firestore.getDoc(
        'chats',
        'chat_hans-ojha_user_1',
      );
      expect(doc?['astrologerId'], 'hans-ojha');
      expect(doc?['astrologerName'], 'Hans Ojha');
    });
  });

  group('Consult screen workspace card', () {
    testWidgets('listed Hans Ojha opens the workspace from Consult',
        (WidgetTester tester) async {
      final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
      final FirestoreService firestore = FirestoreService(firestore: fake);
      await fake.collection('astrologers').doc('hans-ojha').set(
        <String, Object?>{
          'name': 'Hans Ojha',
          'status': 'offline',
          'chatAvailable': true,
          'callAvailable': true,
        },
      );
      await _pumpApp(
        tester,
        ConsultScreen(
          firestore: firestore,
          authService: _TestAuth(),
        ),
      );
      expect(find.text('Hans Ojha'), findsOneWidget);
      await tester.tap(find.text('Hans Ojha'));
      await tester.pumpAndSettle();
      expect(find.text('Phone: Phone number not provided yet'), findsOneWidget);
    });

    testWidgets('waiting Hans Ojha is not listed in Consult',
        (WidgetTester tester) async {
      final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
      final FirestoreService firestore = FirestoreService(firestore: fake);
      await fake.collection('astrologers').doc('hans-ojha').set(
        <String, Object?>{
          'name': 'Hans Ojha',
          'status': 'waiting',
          'chatAvailable': true,
          'callAvailable': true,
        },
      );
      await _pumpApp(
        tester,
        ConsultScreen(
          firestore: firestore,
          authService: _TestAuth(),
        ),
      );
      expect(find.text('Hans Ojha'), findsNothing);
      expect(find.textContaining('No astrologers yet'), findsOneWidget);
    });
  });

  group('Admin screens', () {
    testWidgets('Manage Astrologers shows Hans Ojha once opened',
        (WidgetTester tester) async {
      final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
      final FirestoreService firestore = FirestoreService(firestore: fake);
      await _pump(
        tester,
        AstrologersScreen(firestore: firestore),
      );
      expect(find.text('Hans Ojha'), findsOneWidget);
      final Map<String, dynamic>? doc =
          await firestore.getDoc('astrologers', 'hans-ojha');
      expect(doc?['name'], 'Hans Ojha');
    });

    testWidgets('editing his record in Manage Astrologers persists',
        (WidgetTester tester) async {
      final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
      final FirestoreService firestore = FirestoreService(firestore: fake);
      await AstrologerService(firestore: firestore).ensureHansOjhaRecord();
      await _pump(
        tester,
        AstrologersScreen(firestore: firestore),
      );
      await tester.tap(find.text('View'));
      await tester.pumpAndSettle();
      expect(find.text('Qualifications: Astrology'), findsOneWidget);
      expect(find.text('Phone: 9303849941'), findsOneWidget);
      expect(find.text('Kundli vishleshan'), findsOneWidget);
      expect(find.text('Adhyatmik sadhna evam jeevan margdarshan'), findsOneWidget);
      await tester.tap(find.text('Edit details'));
      await tester.pumpAndSettle();
      // Index 0 is the search field behind the dialog; the
      // edit form fields follow in form order.
      await tester.enterText(find.byType(TextField).at(4), 'Jyotishacharya');
      await tester.enterText(find.byType(TextField).at(6), '9876543210');
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();
      final Map<String, dynamic>? doc =
          await firestore.getDoc('astrologers', 'hans-ojha');
      expect(doc?['qualifications'], 'Jyotishacharya');
      expect(doc?['phone'], '9876543210');
      expect(doc?['name'], 'Hans Ojha');
      // The seeded specialities survive an edit that does
      // not touch them.
      expect(
        doc?['specialities'],
        <String>[
          'Kundli vishleshan',
          'Mahadosh nivaran',
          'Vivah evam rishta margdarshan',
          'Career evam vyavasay margdarshan',
          'Grah shanti evam vastu margdarshan',
          'Swasthya margdarshan',
          'Santan prapti evam parivar sukh',
          'Adhyatmik sadhna evam jeevan margdarshan',
        ],
      );
    });

    testWidgets('admin chat view routes his chats to him by name',
        (WidgetTester tester) async {
      final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
      final FirestoreService firestore = FirestoreService(firestore: fake);
      await fake.collection('chats').doc('chat_hans-ojha_user_1').set(
        <String, Object?>{
          'astrologerId': 'hans-ojha',
          'astrologerName': 'Hans Ojha',
          'participantIds': <String>['user_1', 'hans-ojha'],
          'lastMessage': 'Please read my chart',
        },
      );
      await _pump(
        tester,
        AdminChatsScreen(firestore: firestore, auth: _TestAuth()),
      );
      expect(find.text('Hans Ojha with user_1'), findsOneWidget);
      expect(find.text('Please read my chart'), findsOneWidget);
    });
  });
}

Future<void> _pump(WidgetTester tester, Widget screen) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: screen)),
    ),
  );
  await tester.pumpAndSettle();
}

/// Pump for full screens that already are a Scaffold with
/// their own scrollable body, such as the workspace and
/// Consult screens. Wrapping one in another scroll view
/// gives it an unbounded height and fails layout.
Future<void> _pumpApp(WidgetTester tester, Widget screen) async {
  await tester.pumpWidget(
    MaterialApp(home: screen),
  );
  await tester.pumpAndSettle();
}

class _TestAuth extends AuthService {
  @override
  String? get currentUserId => 'user_1';
}
