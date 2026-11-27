import 'package:dharm_guru_shrinkhala/screens/user_modules.dart';
import 'package:dharm_guru_shrinkhala/services/astro.dart';
import 'package:dharm_guru_shrinkhala/services/auth_service.dart';
import 'package:dharm_guru_shrinkhala/services/birth_profile.dart';
import 'package:dharm_guru_shrinkhala/services/consult_booking.dart';
import 'package:dharm_guru_shrinkhala/services/divisional.dart';
import 'package:dharm_guru_shrinkhala/services/firestore_service.dart';
import 'package:dharm_guru_shrinkhala/services/gochar.dart';
import 'package:dharm_guru_shrinkhala/services/horoscope_periods.dart';
import 'package:dharm_guru_shrinkhala/services/notification_prefs.dart';
import 'package:dharm_guru_shrinkhala/services/numerology.dart';
import 'package:dharm_guru_shrinkhala/services/report_builder.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAuth extends AuthService {
  @override
  String? get currentUserId => 'test-uid';

  @override
  String? get currentUserEmail => 'test@example.com';
}

class _FakeFirestore extends FirestoreService {
  List<Map<String, dynamic>> added = <Map<String, dynamic>>[];

  @override
  Future<Map<String, dynamic>?> getUserProfile(String uid) async =>
      <String, dynamic>{
        'name': 'Test User',
        'dateOfBirth': '1998-03-14',
        'timeOfBirth': '06:25',
        'birthCity': 'Jaipur',
        'birthState': 'Rajasthan',
        'birthCountry': 'India',
      };

  @override
  Stream<List<Map<String, dynamic>>> watchDocs(String collection) =>
      Stream<List<Map<String, dynamic>>>.value(<Map<String, dynamic>>[]);

  @override
  Future<String> addDoc(String collection, Map<String, Object?> data) async {
    added.add(<String, dynamic>{'collection': collection, ...data});
    return 'doc1';
  }

  @override
  Future<void> saveDoc(
    String collection,
    String id,
    Map<String, Object?> data, {
    bool isNew = false,
  }) async {}

  @override
  Future<void> deleteDoc(String collection, String id) async {}
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('Numerology', () {
    test('P8N1 life path for 15 January 2000 is 9', () {
      expect(Numerology.lifePath('2000-01-15'), 9);
    });
    test('P8N2 destiny for A is 1, soul urge for A is 1', () {
      expect(Numerology.destiny('A'), 1);
      expect(Numerology.soulUrge('A'), 1);
      expect(Numerology.personality('A'), 0);
    });
    test('P8N3 letter values cycle after I', () {
      expect(Numerology.letterValue('J'), 1);
      expect(Numerology.letterValue('Z'), 8);
      expect(Numerology.letterValue('1'), 0);
    });
    test('P8N4 master numbers are kept', () {
      expect(Numerology.reduce(11), 11);
      expect(Numerology.reduce(22), 22);
      expect(Numerology.reduce(29), 11);
      expect(Numerology.reduce(38), 11);
    });
    test('P8N5 personal year for 15 January in 2026 is 8', () {
      expect(Numerology.personalYear('2000-01-15', 2026), 8);
    });
    test('P8N6 full calculation has every number', () {
      final NumerologyResult result = Numerology.calculate(
        fullName: 'Test User',
        dateOfBirth: '1998-03-14',
        asOf: DateTime(2026, 11, 28),
      );
      expect(result.lifePath, greaterThan(0));
      expect(result.destiny, greaterThan(0));
      expect(result.birthDay, 5);
      expect(kNumerologyMeanings[result.lifePath], isNotNull);
    });
  });

  group('Divisional Navamsa', () {
    test('P8D1 Mesha at 0 degrees stays Mesha', () {
      expect(Divisional.navamsaRashi(0.0), 'Mesha');
    });
    test('P8D2 fixed Vrishabha at 30 degrees starts at Makara', () {
      expect(Divisional.navamsaRashi(30.0), 'Makara');
    });
    test('P8D3 dual Mithuna at 60 degrees starts at Tula', () {
      expect(Divisional.navamsaRashi(60.0), 'Tula');
    });
    test('P8D4 degree text parses', () {
      expect(Divisional.degreesWithinRashi('01° 24′'), closeTo(1.4, 0.001));
      expect(Divisional.degreesWithinRashi('bad'), 0);
    });
    test('P8D5 navamsa chart keeps nine planets', () {
      final KundliResult kundli = KundliCalculator.calculate(
        birthLocal: DateTime(1998, 3, 14, 6, 25),
        placeText: 'Jaipur',
      );
      final KundliResult d9 = Divisional.navamsaChart(kundli);
      expect(d9.planets.length, 9);
      expect(d9.lagna, isNotEmpty);
    });
  });

  group('Gochar and Sade Sati', () {
    test('P8G1 Saturn in Moon rashi is Peak', () {
      expect(
        Gochar.sadeSatiPhase(moonRashi: 'Mesha', saturnRashi: 'Mesha'),
        'Peak',
      );
    });
    test('P8G2 Saturn one sign before Moon is Rising', () {
      expect(
        Gochar.sadeSatiPhase(moonRashi: 'Mesha', saturnRashi: 'Meena'),
        'Rising',
      );
    });
    test('P8G3 Saturn one sign after Moon is Setting', () {
      expect(
        Gochar.sadeSatiPhase(moonRashi: 'Mesha', saturnRashi: 'Vrishabha'),
        'Setting',
      );
    });
    test('P8G4 Saturn elsewhere is not Sade Sati', () {
      expect(
        Gochar.sadeSatiPhase(moonRashi: 'Mesha', saturnRashi: 'Mithuna'),
        '',
      );
    });
    test('P8G5 transit bhava counts from lagna', () {
      expect(
        Gochar.transitBhava(transitRashi: 'Mesha', natalLagna: 'Mesha'),
        1,
      );
      expect(
        Gochar.transitBhava(transitRashi: 'Vrishabha', natalLagna: 'Mesha'),
        2,
      );
    });
    test('P8G6 reading for the release 9 sample birth is real', () {
      final KundliResult natal = KundliCalculator.calculate(
        birthLocal: DateTime(1998, 3, 14, 6, 25),
        placeText: 'Jaipur',
      );
      expect(natal.lagna, 'Kumbha');
      final GocharReading reading = Gochar.forDate(
        natal: natal,
        asOf: DateTime(2026, 11, 28),
      );
      expect(reading.saturnRashi, isNotEmpty);
      expect(reading.jupiterRashi, isNotEmpty);
      expect(reading.transit.planets.length, 9);
    });
  });

  group('Birth profile', () {
    test('P8B1 valid profile passes', () {
      expect(
        BirthProfile.validate(name: 'Asha', dateOfBirth: '2000-01-15'),
        isNull,
      );
    });
    test('P8B2 empty name fails', () {
      expect(BirthProfile.validate(name: '  '), 'Enter a name.');
    });
    test('P8B3 future birth date fails', () {
      expect(
        BirthProfile.validate(name: 'Asha', dateOfBirth: '2999-01-01'),
        'Date of birth cannot be in the future.',
      );
    });
    test('P8B4 latitude out of range fails', () {
      expect(
        BirthProfile.validate(name: 'Asha', latitude: 100),
        'Latitude must be between -90 and 90.',
      );
    });
    test('P8B5 accuracy labels are plain words', () {
      expect(BirthProfile.accuracyLabel('approx'), 'Approximate time');
      expect(BirthProfile.accuracyLabel('unknown'), 'Time not known');
    });
    test('P8B6 Jaipur city suggests real coordinates', () {
      const BirthProfile profile = BirthProfile(
        name: 'Asha',
        birthCity: 'Jaipur',
      );
      expect(profile.effectiveLatitude, closeTo(26.9124, 0.001));
      expect(profile.effectiveLongitude, closeTo(75.7873, 0.001));
    });
    test('P8B7 round trip through a map', () {
      const BirthProfile profile = BirthProfile(
        name: 'Asha',
        relation: 'Daughter',
        dateOfBirth: '2000-01-15',
        timeOfBirth: '07:30',
        timeAccuracy: 'exact',
        birthCity: 'Delhi',
        latitude: 28.6,
        longitude: 77.2,
        timezone: 'Asia/Kolkata',
      );
      final BirthProfile back = BirthProfile.fromMap(profile.toMap());
      expect(back.name, 'Asha');
      expect(back.latitude, 28.6);
      expect(back.timeAccuracy, 'exact');
    });
  });

  group('Booking and review', () {
    test('P8C1 past booking date fails', () {
      expect(
        ConsultBooking.validate(
          date: '2020-01-01',
          time: '10:00',
          mode: 'chat',
        ),
        'Booking date cannot be in the past.',
      );
    });
    test('P8C2 bad mode fails', () {
      expect(
        ConsultBooking.validate(
          date: '2999-01-01',
          time: '10:00',
          mode: 'video',
        ),
        'Choose chat or call.',
      );
    });
    test('P8C3 requested booking can be cancelled, cancelled cannot', () {
      expect(ConsultBooking.canCancel('requested'), isTrue);
      expect(ConsultBooking.canCancel('confirmed'), isTrue);
      expect(ConsultBooking.canCancel('cancelled'), isFalse);
    });
    test('P8C4 review rating out of range fails', () {
      expect(
        ConsultBooking.validateReview(rating: 0, text: 'Good'),
        'Choose a rating from 1 to 5.',
      );
      expect(
        ConsultBooking.validateReview(rating: 5, text: '  '),
        'Write a short review.',
      );
    });
    test('P8C5 booking payload carries status requested', () {
      final Map<String, Object?> payload = ConsultBooking.payload(
        userId: 'u1',
        astrologerId: 'a1',
        astrologerName: 'Test Astrologer',
        mode: 'chat',
        date: '2999-01-01',
        time: '10:00',
      );
      expect(payload['status'], 'requested');
      expect(payload['userId'], 'u1');
    });
  });

  group('Reports and periods', () {
    test('P8R1 kundli report names lagna Kumbha for the sample birth', () {
      final KundliResult kundli = KundliCalculator.calculate(
        birthLocal: DateTime(1998, 3, 14, 6, 25),
        placeText: 'Jaipur',
      );
      final String body = ReportBuilder.kundli(
        name: 'Test User',
        birthLine: '14 March 1998, Jaipur',
        kundli: kundli,
        birthLocal: DateTime(1998, 3, 14, 6, 25),
        asOf: DateTime(2026, 11, 28),
      );
      expect(body, contains('Lagna: Kumbha'));
      expect(body, contains('Test User'));
      expect(body, contains('Current Mahadasha:'));
    });
    test('P8R2 numerology report lists every number', () {
      final NumerologyResult result = Numerology.calculate(
        fullName: 'Test User',
        dateOfBirth: '1998-03-14',
        asOf: DateTime(2026, 11, 28),
      );
      final String body = ReportBuilder.numerology(
        fullName: 'Test User',
        dateOfBirth: '1998-03-14',
        result: result,
      );
      expect(body, contains('Life Path:'));
      expect(body, contains('Destiny:'));
    });
    test('P8R3 period text names rashi and dasha lord', () {
      final String text = HoroscopePeriods.periodText(
        period: 'monthly',
        moonRashi: 'Mesha',
        dashaLord: 'Jupiter',
        saturnRashi: 'Meena',
      );
      expect(text, contains('Mesha'));
      expect(text, contains('Jupiter'));
      expect(text, contains('rule based guidance'));
    });
    test('P8R4 unread ids are the ones not read', () {
      expect(
        NotificationPrefs.unreadIds(<String>['a', 'b'], <String>{'a'}),
        <String>['b'],
      );
    });
  });

  group('Phase 8 widgets', () {
    testWidgets('P8W1 numerology calculates from name and date',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: NumerologyScreen()),
      );
      await tester.enterText(
        find.byType(TextField).first,
        'Test User',
      );
      await tester.enterText(
        find.byType(TextField).last,
        '15 January 2000',
      );
      await tester.tap(find.text('Calculate numbers'));
      await tester.pumpAndSettle();
      expect(find.text('Life Path'), findsOneWidget);
      expect(find.text('Destiny'), findsOneWidget);
    });

    testWidgets('P8W2 gochar screen shows dasha from a real profile',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GocharScreen(
            firestore: _FakeFirestore(),
            authService: _FakeAuth(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Current Dasha'), findsOneWidget);
      expect(find.text('Sade Sati'), findsOneWidget);
      expect(find.text('Dasha timeline'), findsOneWidget);
    });

    testWidgets('P8W3 reports screen shows empty state honestly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ReportsScreen(
            firestore: _FakeFirestore(),
            authService: _FakeAuth(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('No reports saved yet.'), findsOneWidget);
      expect(find.text('Generate Kundli report'), findsOneWidget);
    });
  });
}
