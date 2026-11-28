import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dharm_guru_shrinkhala/screens/admin_screens.dart';
import 'package:dharm_guru_shrinkhala/services/auth_service.dart';
import 'package:dharm_guru_shrinkhala/services/firestore_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Admin proof: every admin screen is pumped against the real
/// FirestoreService on an in memory Firestore, seeded with
/// real input, and the output is read back from that same
/// Firestore. A screen that shows a number proves the number
/// came from the seed; a screen that writes proves the write
/// landed by reading the document again afterwards.
void main() {
  group('Dashboard', () {
    testWidgets('shows real counts from Firestore', (WidgetTester tester) async {
      final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
      final FirestoreService service = FirestoreService(firestore: fake);
      final Timestamp now = Timestamp.fromDate(DateTime.now());
      final String today = dateKey(DateTime.now());
      await fake.collection('users').doc('u1').set(
        <String, Object?>{'name': 'User One', 'createdAt': now},
      );
      await fake.collection('users').doc('u2').set(
        <String, Object?>{'name': 'User Two', 'createdAt': now},
      );
      await fake.collection('astrologers').doc('a1').set(
        <String, Object?>{'name': 'Guru One', 'status': 'waiting'},
      );
      await fake.collection('astrologers').doc('a2').set(
        <String, Object?>{'name': 'Guru Two', 'status': 'approved'},
      );
      await fake.collection('horoscopes').doc('${today}_Kanya').set(
        <String, Object?>{
          'date': today,
          'rashi': 'Kanya',
          'status': 'published',
        },
      );
      await fake.collection('horoscopes').doc('${today}_Mesha').set(
        <String, Object?>{
          'date': today,
          'rashi': 'Mesha',
          'status': 'draft',
        },
      );
      await fake.collection('payments').doc('p1').set(
        <String, Object?>{
          'user': 'Test User',
          'amount': 499,
          'currency': 'INR',
          'status': 'paid',
          'createdAt': now,
        },
      );
      await _pump(
        tester,
        AdminDashboardScreen(
          firestore: service,
          featureFlags: const <String, bool>{
            'live_consult_enabled': false,
          },
          onNavigate: (_) {},
        ),
      );
      expect(find.text('2'), findsNWidgets(3));
      expect(find.text('1'), findsOneWidget);
      expect(find.text('499 INR'), findsNWidgets(2));
      expect(find.text('No data yet'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(
        find.text('Astrologers waiting for approval: 1'),
        findsOneWidget,
      );
      expect(
        find.text('Horoscopes still drafts today: 1'),
        findsOneWidget,
      );
      expect(find.text('Moderation items waiting: 0'), findsOneWidget);
    });

    testWidgets('shows honest empty states with no docs',
        (WidgetTester tester) async {
      final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
      final FirestoreService service = FirestoreService(firestore: fake);
      await _pump(
        tester,
        AdminDashboardScreen(
          firestore: service,
          featureFlags: const <String, bool>{
            'live_consult_enabled': false,
          },
          onNavigate: (_) {},
        ),
      );
      expect(find.text('No data yet'), findsNWidgets(6));
      expect(find.text('No payments yet'), findsNWidgets(2));
      expect(find.text('Moderation items waiting: 0'), findsOneWidget);
    });
  });

  group('Astrologers', () {
    testWidgets('approve writes offline to the astrologer document',
        (WidgetTester tester) async {
      final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
      final FirestoreService service = FirestoreService(firestore: fake);
      await fake.collection('astrologers').doc('a1').set(
        <String, Object?>{
          'name': 'Guru Dev',
          'status': 'waiting',
          'languages': 'Hindi',
          'bio': 'Vedic astrologer',
          'phone': '9876543210',
          'rate': '',
        },
      );
      await _pump(tester, AstrologersScreen(firestore: service));
      expect(find.text('Guru Dev'), findsOneWidget);
      // Phase 10: opening Manage Astrologers also creates
      // the Hans Ojha record, so there are two View buttons.
      // Tap the one on the Guru Dev tile.
      final Finder guruTile = find.ancestor(
        of: find.text('Guru Dev'),
        matching: find.byType(ListTile),
      );
      await tester.tap(
        find.descendant(of: guruTile, matching: find.text('View')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Status: waiting'), findsOneWidget);
      expect(find.text('Phone: 9876543210'), findsOneWidget);
      await tester.tap(find.text('Approve'));
      await tester.pumpAndSettle();
      final Map<String, dynamic>? doc =
          await service.getDoc('astrologers', 'a1');
      expect(doc?['status'], 'offline');
    });
  });

  group('Daily content', () {
    testWidgets('publish through the editor writes published',
        (WidgetTester tester) async {
      final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
      final FirestoreService service = FirestoreService(firestore: fake);
      final String today = dateKey(DateTime.now());
      await fake.collection('horoscopes').doc('${today}_Kanya').set(
        <String, Object?>{
          'date': today,
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
      );
      await _pump(tester, DailyContentScreen(firestore: service));
      expect(find.text('A strong day for money talks.'), findsOneWidget);
      await tester.tap(find.text('Kanya'));
      await tester.pumpAndSettle();
      expect(find.text('Save draft'), findsOneWidget);
      await tester.tap(find.text('Publish'));
      await tester.pumpAndSettle();
      final Map<String, dynamic>? doc =
          await service.getDoc('horoscopes', '${today}_Kanya');
      expect(doc?['status'], 'published');
      expect(doc?['summary'], 'A strong day for money talks.');
    });
  });

  group('Analytics and Revenue', () {
    testWidgets('counts and charts come from the seeded docs',
        (WidgetTester tester) async {
      final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
      final FirestoreService service = FirestoreService(firestore: fake);
      final Timestamp now = Timestamp.fromDate(DateTime.now());
      await fake.collection('users').doc('u1').set(
        <String, Object?>{'name': 'User One', 'createdAt': now},
      );
      await fake.collection('users').doc('u2').set(
        <String, Object?>{'name': 'User Two', 'createdAt': now},
      );
      await fake.collection('payments').doc('p1').set(
        <String, Object?>{
          'user': 'Test User',
          'amount': 499,
          'currency': 'INR',
          'status': 'paid',
          'createdAt': now,
        },
      );
      await _pump(tester, AnalyticsScreen(firestore: service));
      expect(find.text('2'), findsNWidgets(3));
      expect(
        find.text('Kundlis created in this range: 2'),
        findsOneWidget,
      );
      expect(find.text('Earnings in this range: 499'), findsOneWidget);
      expect(find.text('No data yet'), findsWidgets);
    });

    testWidgets('shows empty states with no docs',
        (WidgetTester tester) async {
      final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
      final FirestoreService service = FirestoreService(firestore: fake);
      await _pump(tester, AnalyticsScreen(firestore: service));
      expect(find.text('No data yet'), findsNWidgets(5));
      expect(find.text('No data in this range.'), findsNWidgets(3));
    });
  });

  group('Push Notifications', () {
    testWidgets('compose and send writes a sent notification',
        (WidgetTester tester) async {
      final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
      final FirestoreService service = FirestoreService(firestore: fake);
      await _pump(tester, NotificationsScreenAdmin(firestore: service));
      expect(find.text('No notifications sent yet'), findsOneWidget);
      await tester.tap(find.text('New notification'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Test alert');
      await tester.enterText(
        find.byType(TextField).at(1),
        'Kanya: a strong day.',
      );
      await tester.pump();
      await tester.ensureVisible(
        find.widgetWithText(ElevatedButton, 'Send now'),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Send now'));
      await tester.pumpAndSettle();
      expect(find.text('Send this notification?'), findsOneWidget);
      await tester.tap(find.text('Send'));
      await tester.pumpAndSettle();
      final List<Map<String, dynamic>> docs =
          await service.watchDocs('notifications').first;
      expect(docs.length, 1);
      expect(docs.first['title'], 'Test alert');
      expect(docs.first['message'], 'Kanya: a strong day.');
      expect(docs.first['status'], 'sent');
      expect(find.text('Test alert'), findsOneWidget);
    });
  });

  group('Content Moderation', () {
    testWidgets('approve writes approved with the owner recorded',
        (WidgetTester tester) async {
      final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
      final FirestoreService service = FirestoreService(firestore: fake);
      await fake.collection('moderation').doc('m1').set(
        <String, Object?>{
          'type': 'chat',
          'title': 'Rude message',
          'body': 'This is rude.',
          'status': 'pending',
          'createdAt': Timestamp.fromDate(DateTime.now()),
        },
      );
      await _pump(tester, ModerationScreen(firestore: service));
      expect(find.text('Rude message'), findsOneWidget);
      expect(find.text('1 items waiting'), findsOneWidget);
      await tester.tap(find.text('Approve'));
      await tester.pumpAndSettle();
      expect(find.text('Approve this item?'), findsOneWidget);
      await tester.tap(find.text('Approve').last);
      await tester.pumpAndSettle();
      final Map<String, dynamic>? doc =
          await service.getDoc('moderation', 'm1');
      expect(doc?['status'], 'approved');
      expect(doc?['decidedBy'], 'owner');
    });

    testWidgets('shows All clear with nothing waiting',
        (WidgetTester tester) async {
      final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
      final FirestoreService service = FirestoreService(firestore: fake);
      await _pump(tester, ModerationScreen(firestore: service));
      expect(find.text('All clear'), findsOneWidget);
      expect(find.text('Nothing waiting'), findsOneWidget);
    });
  });

  group('Chats', () {
    testWidgets('lists the seeded chat room with its last message',
        (WidgetTester tester) async {
      final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
      final FirestoreService service = FirestoreService(firestore: fake);
      await fake.collection('chats').doc('user_u1').set(
        <String, Object?>{
          'participantIds': <String>['u1'],
          'lastMessage': 'Hello, please read my chart',
          'createdAt': Timestamp.fromDate(DateTime.now()),
        },
      );
      await _pump(
        tester,
        AdminChatsScreen(firestore: service, auth: _ProofAuth()),
      );
      expect(find.text('u1'), findsOneWidget);
      expect(find.text('Hello, please read my chart'), findsOneWidget);
    });

    testWidgets('shows an empty state with no chats',
        (WidgetTester tester) async {
      final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
      final FirestoreService service = FirestoreService(firestore: fake);
      await _pump(
        tester,
        AdminChatsScreen(firestore: service, auth: _ProofAuth()),
      );
      expect(find.text('No chats yet'), findsOneWidget);
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

class _ProofAuth extends AuthService {
  @override
  String? get currentUserId => 'owner-uid';
}
