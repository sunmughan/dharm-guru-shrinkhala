import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dharm_guru_shrinkhala/screens/admin_phase9_screens.dart';
import 'package:dharm_guru_shrinkhala/services/admin_metrics.dart';
import 'package:dharm_guru_shrinkhala/services/auth_service.dart';
import 'package:dharm_guru_shrinkhala/services/firestore_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Phase 9 proof: pure metric and validation logic is tested
/// with plain maps, and every new admin screen is pumped
/// against the real FirestoreService on an in memory Firestore.
/// A screen that writes proves the write by reading the
/// document again afterwards.
void main() {
  group('AdminMetrics', () {
    test('counts new registrations inside the range only', () {
      final DateTime now = DateTime.now();
      final List<Map<String, dynamic>> docs = <Map<String, dynamic>>[
        <String, dynamic>{
          'createdAt': Timestamp.fromDate(now),
        },
        <String, dynamic>{
          'createdAt': Timestamp.fromDate(
            now.subtract(const Duration(days: 10)),
          ),
        },
      ];
      expect(AdminMetrics.countInRange(docs, 'Today', now), 1);
      expect(AdminMetrics.countInRange(docs, '30 days', now), 2);
    });

    test('active users need a lastActiveAt inside the range', () {
      final DateTime now = DateTime.now();
      final List<Map<String, dynamic>> docs = <Map<String, dynamic>>[
        <String, dynamic>{
          'lastActiveAt': Timestamp.fromDate(now),
        },
        <String, dynamic>{'name': 'No activity recorded'},
      ];
      expect(AdminMetrics.activeUsersInRange(docs, 'Today', now), 1);
    });

    test('paid total sums paid only, inside the range', () {
      final DateTime now = DateTime.now();
      final List<Map<String, dynamic>> docs = <Map<String, dynamic>>[
        <String, dynamic>{
          'amount': 499,
          'status': 'paid',
          'createdAt': Timestamp.fromDate(now),
        },
        <String, dynamic>{
          'amount': 299,
          'status': 'failed',
          'createdAt': Timestamp.fromDate(now),
        },
        <String, dynamic>{
          'amount': 100,
          'status': 'paid',
          'createdAt': Timestamp.fromDate(
            now.subtract(const Duration(days: 40)),
          ),
        },
      ];
      expect(AdminMetrics.paidTotalInRange(docs, '30 days', now), 499);
    });

    test('consult minutes sum durationMinutes inside the range', () {
      final DateTime now = DateTime.now();
      final List<Map<String, dynamic>> docs = <Map<String, dynamic>>[
        <String, dynamic>{
          'durationMinutes': 30,
          'createdAt': Timestamp.fromDate(now),
        },
        <String, dynamic>{
          'durationMinutes': 45,
          'createdAt': Timestamp.fromDate(now),
        },
      ];
      expect(AdminMetrics.consultMinutesInRange(docs, 'Today', now), 75);
    });

    test('counts by status groups every document', () {
      final List<Map<String, dynamic>> docs = <Map<String, dynamic>>[
        <String, dynamic>{'status': 'paid'},
        <String, dynamic>{'status': 'paid'},
        <String, dynamic>{'status': 'failed'},
      ];
      expect(
        AdminMetrics.countsByStatus(docs),
        <String, int>{'paid': 2, 'failed': 1},
      );
    });

    test('valid calc config passes validation', () {
      expect(
        AdminMetrics.validateCalcConfig(<String, dynamic>{
          'version': '1',
          'ayanamsha': 'Lahiri',
          'zodiacSystem': 'Sidereal',
          'houseSystem': 'Whole Sign',
          'nodeMode': 'Mean',
          'region': 'Jaipur',
          'effectiveDate': '2026-11-28',
        }),
        isEmpty,
      );
    });

    test('invalid calc config reports every problem', () {
      final List<String> errors = AdminMetrics.validateCalcConfig(
        <String, dynamic>{
          'version': '',
          'ayanamsha': 'Made Up',
          'zodiacSystem': 'Sidereal',
          'houseSystem': 'Whole Sign',
          'nodeMode': 'Mean',
          'region': '',
          'effectiveDate': 'not a date',
        },
      );
      expect(errors.length, 4);
    });

    test('audit entry carries actor action target and detail', () {
      final Map<String, Object?> entry = AdminMetrics.auditEntry(
        actor: 'owner',
        action: 'user_suspended',
        target: 'u1',
        detail: 'User suspended.',
      );
      expect(entry['actor'], 'owner');
      expect(entry['action'], 'user_suspended');
      expect(entry['target'], 'u1');
      expect(entry['status'], 'recorded');
    });
  });

  group('Users', () {
    testWidgets('mark verified writes verified and an audit entry',
        (WidgetTester tester) async {
      final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
      final FirestoreService service = FirestoreService(firestore: fake);
      await fake.collection('users').doc('u1').set(
        <String, Object?>{
          'name': 'Test User',
          'email': 'test@example.com',
          'status': 'active',
          'verified': false,
          'createdAt': Timestamp.fromDate(DateTime.now()),
        },
      );
      await _pump(tester, UsersScreen(firestore: service));
      expect(find.text('Test User'), findsOneWidget);
      await tester.tap(find.text('Test User'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mark verified'));
      await tester.pumpAndSettle();
      final Map<String, dynamic>? doc =
          await service.getDoc('users', 'u1');
      expect(doc?['verified'], true);
      final List<Map<String, dynamic>> audit =
          await service.watchDocs('audit_logs').first;
      expect(audit.length, 1);
      expect(audit.first['action'], 'user_verification');
    });

    testWidgets('suspend writes suspended after confirm',
        (WidgetTester tester) async {
      final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
      final FirestoreService service = FirestoreService(firestore: fake);
      await fake.collection('users').doc('u1').set(
        <String, Object?>{
          'name': 'Test User',
          'email': 'test@example.com',
          'status': 'active',
          'createdAt': Timestamp.fromDate(DateTime.now()),
        },
      );
      await _pump(tester, UsersScreen(firestore: service));
      await tester.tap(find.text('Test User'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Suspend'));
      await tester.pumpAndSettle();
      expect(find.text('Suspend this user?'), findsOneWidget);
      await tester.tap(find.text('Suspend').last);
      await tester.pumpAndSettle();
      final Map<String, dynamic>? doc =
          await service.getDoc('users', 'u1');
      expect(doc?['status'], 'suspended');
    });

    testWidgets('shows empty state with no users',
        (WidgetTester tester) async {
      final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
      final FirestoreService service = FirestoreService(firestore: fake);
      await _pump(tester, UsersScreen(firestore: service));
      expect(find.text('No users yet'), findsOneWidget);
    });
  });

  group('Admin team', () {
    testWidgets('invite writes a pending invitation',
        (WidgetTester tester) async {
      final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
      final FirestoreService service = FirestoreService(firestore: fake);
      await _pump(tester, AdminTeamScreen(firestore: service));
      await tester.tap(find.text('Invite admin'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField).first,
        'helper@example.com',
      );
      await tester.pump();
      await tester.tap(find.text('Save invitation'));
      await tester.pumpAndSettle();
      final List<Map<String, dynamic>> invites =
          await service.watchDocs('admin_invites').first;
      expect(invites.length, 1);
      expect(invites.first['email'], 'helper@example.com');
      expect(invites.first['status'], 'pending');
    });

    testWidgets('revoke writes revoked after confirm',
        (WidgetTester tester) async {
      final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
      final FirestoreService service = FirestoreService(firestore: fake);
      await fake.collection('admins').doc('a1').set(
        <String, Object?>{
          'email': 'helper@example.com',
          'role': 'admin',
          'createdAt': Timestamp.fromDate(DateTime.now()),
        },
      );
      await _pump(tester, AdminTeamScreen(firestore: service));
      expect(find.text('helper@example.com'), findsOneWidget);
      await tester.tap(find.text('Revoke access'));
      await tester.pumpAndSettle();
      expect(find.text('Revoke access?'), findsOneWidget);
      await tester.tap(find.text('Revoke access').last);
      await tester.pumpAndSettle();
      final Map<String, dynamic>? doc =
          await service.getDoc('admins', 'a1');
      expect(doc?['role'], 'revoked');
    });
  });

  group('Library', () {
    testWidgets('new entry saves as draft with its type',
        (WidgetTester tester) async {
      final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
      final FirestoreService service = FirestoreService(firestore: fake);
      await _pump(tester, LibraryScreen(firestore: service));
      expect(find.text('No library entries yet'), findsOneWidget);
      await tester.tap(find.text('New entry'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Shani Sade Sati');
      await tester.pump();
      await tester.tap(find.text('Save entry'));
      await tester.pumpAndSettle();
      final List<Map<String, dynamic>> docs =
          await service.watchDocs('library_items').first;
      expect(docs.length, 1);
      expect(docs.first['title'], 'Shani Sade Sati');
      expect(docs.first['type'], 'Interpretation');
      expect(docs.first['status'], 'draft');
    });

    testWidgets('publish toggles a draft to published',
        (WidgetTester tester) async {
      final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
      final FirestoreService service = FirestoreService(firestore: fake);
      await fake.collection('library_items').doc('l1').set(
        <String, Object?>{
          'title': 'Shani Sade Sati',
          'type': 'Dosha',
          'category': 'Saturn',
          'content': 'Text here.',
          'source': '',
          'reference': '',
          'status': 'draft',
        },
      );
      await _pump(tester, LibraryScreen(firestore: service));
      await tester.tap(find.text('Shani Sade Sati'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Publish'));
      await tester.pumpAndSettle();
      final Map<String, dynamic>? doc =
          await service.getDoc('library_items', 'l1');
      expect(doc?['status'], 'published');
    });
  });

  group('Calculation config', () {
    testWidgets('invalid version cannot activate and saves nothing',
        (WidgetTester tester) async {
      final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
      final FirestoreService service = FirestoreService(firestore: fake);
      await _pump(tester, CalcConfigScreen(firestore: service));
      await tester.tap(find.text('New version'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Activate'));
      await tester.pumpAndSettle();
      expect(find.text('Version is required.'), findsOneWidget);
      final List<Map<String, dynamic>> docs =
          await service.watchDocs('calc_configs').first;
      expect(docs, isEmpty);
    });

    testWidgets('valid version activates and writes active',
        (WidgetTester tester) async {
      final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
      final FirestoreService service = FirestoreService(firestore: fake);
      await _pump(tester, CalcConfigScreen(firestore: service));
      await tester.tap(find.text('New version'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, '1');
      await tester.enterText(find.byType(TextField).at(1), 'Jaipur');
      await tester.pump();
      await tester.tap(find.text('Activate'));
      await tester.pumpAndSettle();
      final List<Map<String, dynamic>> docs =
          await service.watchDocs('calc_configs').first;
      expect(docs.length, 1);
      expect(docs.first['version'], '1');
      expect(docs.first['ayanamsha'], 'Lahiri');
      expect(docs.first['status'], 'active');
    });
  });

  group('Content', () {
    testWidgets('new content publishes with its type',
        (WidgetTester tester) async {
      final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
      final FirestoreService service = FirestoreService(firestore: fake);
      await _pump(tester, ContentManagerScreen(firestore: service));
      expect(find.text('No content yet'), findsOneWidget);
      await tester.tap(find.text('New content'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField).first,
        'Diwali Festival Notes',
      );
      await tester.pump();
      await tester.tap(find.text('Publish'));
      await tester.pumpAndSettle();
      final List<Map<String, dynamic>> docs =
          await service.watchDocs('content_items').first;
      expect(docs.length, 1);
      expect(docs.first['title'], 'Diwali Festival Notes');
      expect(docs.first['status'], 'published');
    });
  });

  group('Consultations', () {
    testWidgets('assign writes astrologer and assigned status',
        (WidgetTester tester) async {
      final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
      final FirestoreService service = FirestoreService(firestore: fake);
      await fake.collection('astrologers').doc('a1').set(
        <String, Object?>{
          'name': 'Guru Dev',
          'status': 'offline',
        },
      );
      await fake.collection('consultations').doc('c1').set(
        <String, Object?>{
          'user': 'Test User',
          'astrologer': '',
          'note': '',
          'status': 'booked',
          'durationMinutes': 0,
          'createdAt': Timestamp.fromDate(DateTime.now()),
        },
      );
      await _pump(tester, ConsultationsScreen(firestore: service));
      await tester.tap(find.textContaining('Test User'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Guru Dev').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      final Map<String, dynamic>? doc =
          await service.getDoc('consultations', 'c1');
      expect(doc?['astrologer'], 'Guru Dev');
      expect(doc?['status'], 'assigned');
      expect((doc?['history'] as List<dynamic>).length, 1);
    });

    testWidgets('cancel writes cancelled after confirm',
        (WidgetTester tester) async {
      final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
      final FirestoreService service = FirestoreService(firestore: fake);
      await fake.collection('consultations').doc('c1').set(
        <String, Object?>{
          'user': 'Test User',
          'astrologer': '',
          'note': '',
          'status': 'booked',
          'durationMinutes': 0,
          'createdAt': Timestamp.fromDate(DateTime.now()),
        },
      );
      await _pump(tester, ConsultationsScreen(firestore: service));
      await tester.tap(find.textContaining('Test User'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel booking'));
      await tester.pumpAndSettle();
      expect(find.text('Cancel this consultation?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      final Map<String, dynamic>? doc =
          await service.getDoc('consultations', 'c1');
      expect(doc?['status'], 'cancelled');
    });
  });

  group('Security audit', () {
    testWidgets('lists the seeded audit entry',
        (WidgetTester tester) async {
      final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
      final FirestoreService service = FirestoreService(firestore: fake);
      await fake.collection('audit_logs').doc('log1').set(
        <String, Object?>{
          'actor': 'owner',
          'action': 'user_suspended',
          'target': 'u1',
          'detail': 'User suspended.',
          'status': 'recorded',
          'createdAt': Timestamp.fromDate(DateTime.now()),
        },
      );
      await _pump(
        tester,
        SecurityAuditScreen(firestore: service, auth: _Phase9Auth()),
      );
      expect(find.textContaining('user_suspended'), findsOneWidget);
      expect(find.textContaining('owner@example.com'), findsOneWidget);
    });

    testWidgets('shows empty state with no entries',
        (WidgetTester tester) async {
      final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
      final FirestoreService service = FirestoreService(firestore: fake);
      await _pump(
        tester,
        SecurityAuditScreen(firestore: service, auth: _Phase9Auth()),
      );
      expect(find.text('No audit entries yet'), findsOneWidget);
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

class _Phase9Auth extends AuthService {
  @override
  String? get currentUserId => 'owner-uid';

  @override
  String? get currentUserEmail => 'owner@example.com';
}
