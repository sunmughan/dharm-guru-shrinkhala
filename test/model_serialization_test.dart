import 'package:dharm_guru_shrinkhala/models/kundli.dart';
import 'package:dharm_guru_shrinkhala/models/panchang.dart';
import 'package:dharm_guru_shrinkhala/models/remedies.dart';
import 'package:flutter_test/flutter_test.dart';

/// Phase 18, test IDs SER-01 to SER-06. Every model that is
/// stored in Firestore or sent over the wire round trips
/// through toJson and fromJson without losing a field.
void main() {
  group('Model serialization', () {
    test('SER-01 BirthDetails round trip', () {
      const BirthDetails original = BirthDetails(
        name: 'Test User',
        dateOfBirth: '2000-01-15',
        timeOfBirth: '07:30',
        placeOfBirth: 'Jaipur',
        rashi: 'Kanya',
        nakshatra: 'Hasta',
        tithiAtBirth: 'Shukla Panchami',
      );
      final BirthDetails back =
          BirthDetails.fromJson(original.toJson());
      expect(back.name, 'Test User');
      expect(back.dateOfBirth, '2000-01-15');
      expect(back.timeOfBirth, '07:30');
      expect(back.placeOfBirth, 'Jaipur');
      expect(back.rashi, 'Kanya');
      expect(back.nakshatra, 'Hasta');
      expect(back.tithiAtBirth, 'Shukla Panchami');
    });

    test('SER-02 PlanetDetail round trip', () {
      const PlanetDetail original = PlanetDetail(
        name: 'Sun',
        rashi: 'Simha',
        bhava: 'Bhava 1',
        degree: '01° 24′',
        swami: 'Sun',
        note: 'Sun in Simha.',
      );
      final PlanetDetail back =
          PlanetDetail.fromJson(original.toJson());
      expect(back.name, 'Sun');
      expect(back.rashi, 'Simha');
      expect(back.bhava, 'Bhava 1');
      expect(back.degree, '01° 24′');
      expect(back.swami, 'Sun');
      expect(back.note, 'Sun in Simha.');
    });

    test('SER-03 Panchang round trip', () {
      const Panchang original = Panchang(
        weekday: 'Friday',
        city: 'Jaipur',
        tithi: 'Shukla Panchami',
        vaar: 'Shukravaar',
        nakshatra: 'Hasta',
        yoga: 'Siddhi',
        karana: 'Bava',
        sunrise: '06:48 AM',
        sunset: '05:52 PM',
        shubhMuhurat: 'Abhijit 11:36 AM to 12:00 PM',
        rahuKaal: '10:30 AM to 12:00 PM.',
      );
      final Panchang back = Panchang.fromJson(original.toJson());
      expect(back.weekday, 'Friday');
      expect(back.city, 'Jaipur');
      expect(back.tithi, 'Shukla Panchami');
      expect(back.sunrise, '06:48 AM');
      expect(back.sunset, '05:52 PM');
      expect(back.rahuKaal, contains('10:30 AM'));
    });

    test('SER-04 HoroscopeEntry round trip', () {
      const HoroscopeEntry original = HoroscopeEntry(
        rashi: 'Kanya',
        date: '2026-11-28',
        summary: 'A strong day for money talks.',
      );
      final HoroscopeEntry back =
          HoroscopeEntry.fromJson(original.toJson());
      expect(back.rashi, 'Kanya');
      expect(back.date, '2026-11-28');
      expect(back.summary, 'A strong day for money talks.');
    });

    test('SER-05 UserProfile round trip, premium and free', () {
      const UserProfile premium = UserProfile(
        displayName: 'Test User',
        plan: PlanTier.premium,
      );
      expect(
        UserProfile.fromJson(premium.toJson()).plan,
        PlanTier.premium,
      );
      const UserProfile free = UserProfile(
        displayName: 'Test User',
        plan: PlanTier.free,
      );
      final UserProfile back = UserProfile.fromJson(free.toJson());
      expect(back.plan, PlanTier.free);
      expect(back.displayName, 'Test User');
    });

    test('SER-06 Remedy round trip', () {
      const Remedy original = Remedy(
        title: 'Surya Arghya',
        body: 'Offer water to the Sun at sunrise.',
        action: 'done',
      );
      final Remedy back = Remedy.fromJson(original.toJson());
      expect(back.title, 'Surya Arghya');
      expect(back.body, contains('Sun at sunrise'));
      expect(back.action, 'done');
    });

    test('SER-07 fromJson tolerates missing fields with empty strings', () {
      final BirthDetails back =
          BirthDetails.fromJson(<String, dynamic>{});
      expect(back.name, '');
      final Panchang panchang =
          Panchang.fromJson(<String, dynamic>{'city': 'Jaipur'});
      expect(panchang.city, 'Jaipur');
      expect(panchang.tithi, '');
      final UserProfile profile =
          UserProfile.fromJson(<String, dynamic>{});
      expect(profile.plan, PlanTier.free);
    });
  });
}
