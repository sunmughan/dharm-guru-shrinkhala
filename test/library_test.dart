import 'package:dharm_guru_shrinkhala/screens/screens.dart';
import 'package:dharm_guru_shrinkhala/services/astro.dart';
import 'package:dharm_guru_shrinkhala/services/auth_service.dart';
import 'package:dharm_guru_shrinkhala/services/firestore_service.dart';
import 'package:dharm_guru_shrinkhala/services/library_content.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('vimshottariTimeline', () {
    test('covers the full 120 year cycle in order', () {
      final DateTime birth = DateTime(1998, 3, 14, 6, 25);
      final List<DashaInfo> spans = vimshottariTimeline(birthLocal: birth);
      expect(spans.first.lord, 'Sun');
      expect(spans.first.start, birth);
      expect(spans.last.end, DateTime(2118, 3, 14));
      for (int i = 1; i < spans.length; i++) {
        expect(spans[i].start, spans[i - 1].end);
        final int prevOrder = kDashaOrder.indexOf(spans[i - 1].lord);
        expect(
          spans[i].lord,
          kDashaOrder[(prevOrder + 1) % kDashaOrder.length],
        );
      }
      final Duration total =
          spans.last.end.difference(spans.first.start);
      expect(total.inDays, greaterThanOrEqualTo(120 * 365));
      expect(total.inDays, lessThanOrEqualTo(120 * 366));
    });

    test('current dasha from the timeline matches vimshottariDasha', () {
      final DateTime birth = DateTime(1998, 3, 14, 6, 25);
      final DateTime asOf = DateTime(2026, 11, 27);
      final List<DashaInfo> spans = vimshottariTimeline(birthLocal: birth);
      final DashaInfo current = spans.firstWhere(
        (DashaInfo s) => !asOf.isBefore(s.start) && !asOf.isAfter(s.end),
      );
      final DashaInfo direct =
          vimshottariDasha(birthLocal: birth, asOf: asOf);
      expect(current.lord, direct.lord);
      expect(current.start, direct.start);
    });
  });

  group('festivalDays', () {
    test('finds a full moon and a new moon in any 31 day window', () {
      final DateTime from = DateTime(2026, 11, 27);
      final List<FestivalDay> days = festivalDays(from: from, days: 31);
      expect(days, isNotEmpty);
      expect(
        days.any((FestivalDay d) => d.tithi.contains('Purnima')),
        isTrue,
      );
      expect(
        days.any((FestivalDay d) => d.tithi.contains('Amavasya')),
        isTrue,
      );
      for (int i = 1; i < days.length; i++) {
        expect(days[i].date.isAfter(days[i - 1].date), isTrue);
      }
      for (final FestivalDay d in days) {
        expect(d.date.isBefore(from.add(const Duration(days: 31))), isTrue);
        expect(d.date.isAfter(from.subtract(const Duration(days: 1))), isTrue);
        expect(d.observance, isNotEmpty);
      }
    });
  });

  group('planet reference', () {
    test('covers all nine planets with complete reference data', () {
      expect(kPlanetReference.length, 9);
      final Set<String> names =
          kPlanetReference.map((PlanetReference r) => r.name).toSet();
      expect(names.length, 9);
      for (final PlanetReference r in kPlanetReference) {
        expect(r.rules, isNotEmpty);
        expect(r.exalted, isNotEmpty);
        expect(r.debilitated, isNotEmpty);
        expect(r.signifies, isNotEmpty);
      }
    });
  });

  test('formatDay spells the month out', () {
    expect(formatDay(DateTime(2026, 11, 27)), '27 November 2026');
  });

  group('LibraryScreen widget', () {
    testWidgets('shows the real timeline, festivals and planets',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LibraryScreen(
            firestore: _FakeLibraryFirestore(withProfile: true),
            authService: _FakeLibraryAuth(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Your dasha timeline'), findsOneWidget);
      expect(find.textContaining('Mahadasha'), findsWidgets);
      expect(find.text('Current'), findsOneWidget);
      await _dragTo(tester, find.text('Festivals in the next 30 days'));
      expect(find.text('Festivals in the next 30 days'), findsOneWidget);
      await _tapRow(tester, find.text('Full moon day'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Tithi '), findsWidgets);
      expect(find.textContaining('Nakshatra '), findsOneWidget);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      await _dragTo(tester, find.text('Planets'));
      expect(find.text('Planets'), findsOneWidget);
      await _tapRow(tester, find.text('Rules Leo. Exalted in Aries.'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Vitality'), findsOneWidget);
      expect(find.textContaining('In your chart:'), findsOneWidget);
    });

    testWidgets('without a profile it asks for birth details, honestly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LibraryScreen(
            firestore: _FakeLibraryFirestore(withProfile: false),
            authService: _FakeLibraryAuth(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Add your birth details to see your dasha timeline.'),
        findsOneWidget,
      );
      await _dragTo(tester, find.text('Festivals in the next 30 days'));
      expect(find.text('Festivals in the next 30 days'), findsOneWidget);
      await _dragTo(tester, find.text('Planets'));
      expect(find.text('Planets'), findsOneWidget);
      await _tapRow(tester, find.text('Rules Leo. Exalted in Aries.'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Add your birth details to see where this planet sits in your chart.',
        ),
        findsOneWidget,
      );
    });
  });
}



/// Drags to a row, then makes sure it is fully visible
/// before tapping it. _dragTo stops the moment the row is
/// built, which can leave it half off the bottom edge, and
/// a blind extra drag can push it off the top edge instead,
/// so the row is disposed and the tap finds no element.
Future<void> _tapRow(WidgetTester tester, Finder target) async {
  await _dragTo(tester, target);
  await tester.ensureVisible(target.first);
  await tester.pumpAndSettle();
  await tester.tap(target.first);
}

/// Drags the Library list down until the target is built.
/// scrollUntilVisible cannot be used here: the list builds
/// lazily, so an offscreen row does not exist yet and the
/// finder throws No element before any scrolling happens.
Future<void> _dragTo(WidgetTester tester, Finder target) async {
  for (int i = 0; i < 20; i++) {
    if (target.evaluate().isNotEmpty) return;
    await tester.drag(find.byType(ListView).first, const Offset(0, -400));
    await tester.pumpAndSettle();
  }
  expect(target, findsWidgets);
}

class _FakeLibraryAuth extends AuthService {
  @override
  String? get currentUserId => 'test-uid';
}

class _FakeLibraryFirestore extends FirestoreService {
  _FakeLibraryFirestore({required this.withProfile});

  final bool withProfile;

  @override
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    if (!withProfile) return null;
    return <String, dynamic>{
      'name': 'Test User',
      'dateOfBirth': '2000-01-15',
      'timeOfBirth': '07:30',
      'birthCity': 'Delhi',
      'birthState': 'Delhi',
      'birthCountry': 'India',
    };
  }
}
