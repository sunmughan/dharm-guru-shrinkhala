import 'package:dharm_guru_shrinkhala/models/panchang.dart';
import 'package:dharm_guru_shrinkhala/models/remedies.dart';
import 'package:dharm_guru_shrinkhala/services/astro.dart';
import 'package:dharm_guru_shrinkhala/services/chat_service.dart';
import 'package:dharm_guru_shrinkhala/services/firestore_service.dart';
import 'package:dharm_guru_shrinkhala/services/library_content.dart';
import 'package:dharm_guru_shrinkhala/services/matching.dart';
import 'package:dharm_guru_shrinkhala/services/notification_schedule.dart';
import 'package:dharm_guru_shrinkhala/services/remedies_engine.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

/// Real input proof pass. Every test feeds one concrete real
/// input, prints the real output, and asserts the output is
/// correct against an independent check: JPL validated sky
/// positions for the kundli, real moon phase dates for the
/// panchang, a Firestore re-read for the publish, chat and
/// profile flows, and the guna rows summing to the matching
/// total. Run output is the proof log for the release report.
void main() {
  test('PROOF Kundli: real birth gives the JPL checked chart', () {
    final KundliResult result = KundliCalculator.calculate(
      birthLocal: DateTime(1998, 3, 14, 6, 25),
      placeText: 'Jaipur, Rajasthan',
    );
    // ignore: avoid_print
    print(
      'INPUT birth 14 March 1998 06:25 Jaipur '
      'OUTPUT lagna ${result.lagna} moon rashi ${result.moonRashi} '
      'nakshatra ${result.moonNakshatra} tithi ${result.tithiAtBirth} '
      'planets ${result.planets.length}',
    );
    expect(result.lagna, 'Kumbha');
    expect(result.moonRashi, 'Kanya');
    expect(result.moonNakshatra, 'Uttara Phalguni');
    expect(result.tithiAtBirth, 'Krishna Pratipada');
    expect(result.planets.length, 9);
  });

  test('PROOF Panchang: today and two real moon phase dates', () {
    final Panchang todayCheck =
        PanchangCalculator.forDate(DateTime.now(), kDefaultPlace);
    // ignore: avoid_print
    print('INPUT today OUTPUT tithi ${todayCheck.tithi} '
        'sunrise ${todayCheck.sunrise}');
    expect(todayCheck.tithi, isNotEmpty);
    expect(todayCheck.sunrise, contains('AM'));
    final newMoon = PanchangCalculator.forDate(
      DateTime(2026, 12, 8),
      kDefaultPlace,
    );
    final fullMoon = PanchangCalculator.forDate(
      DateTime(2026, 12, 23),
      kDefaultPlace,
    );
    // ignore: avoid_print
    print('INPUT 8 December 2026 OUTPUT tithi ${newMoon.tithi} '
        'INPUT 23 December 2026 OUTPUT tithi ${fullMoon.tithi}');
    expect(newMoon.tithi, 'Krishna Amavasya');
    expect(fullMoon.tithi, 'Shukla Purnima');
    final old = PanchangCalculator.forDate(
      DateTime(1998, 3, 14),
      kDefaultPlace,
    );
    expect(old.weekday, 'Saturday');
    expect(old.tithi, 'Krishna Pratipada');
    expect(old.nakshatra, contains('Hasta'));
  });

  test('PROOF Daily Horoscope: publish then read back', () async {
    final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
    final FirestoreService service = FirestoreService(firestore: fake);
    const String id = '2026-11-27_Kanya';
    await service.saveDoc(
      'horoscopes',
      id,
      <String, Object?>{
        'date': '2026-11-27',
        'rashi': 'Kanya',
        'summary': 'A strong day for money talks.',
        'status': 'draft',
      },
      isNew: true,
    );
    Future<List<Map<String, dynamic>>> published() async {
      final List<Map<String, dynamic>> docs =
          await service.watchDocs('horoscopes').first;
      return docs
          .where((Map<String, dynamic> d) => d['status'] == 'published')
          .toList();
    }

    expect(await published(), isEmpty);
    await service.saveDoc(
      'horoscopes',
      id,
      <String, Object?>{'status': 'published'},
    );
    final List<Map<String, dynamic>> live = await published();
    // ignore: avoid_print
    print(
      'INPUT publish Kanya 27 November 2026 OUTPUT user read '
      '${live.length} entry summary ${live.first['summary']}',
    );
    expect(live.length, 1);
    expect(live.first['summary'], 'A strong day for money talks.');
  });

  test('PROOF Matching: two real charts give a checked score', () {
    final KundliResult first = KundliCalculator.calculate(
      birthLocal: DateTime(1998, 3, 14, 6, 25),
      placeText: 'Jaipur, Rajasthan',
    );
    final KundliResult second = KundliCalculator.calculate(
      birthLocal: DateTime(2000, 1, 15, 7, 30),
      placeText: 'Delhi, Delhi',
    );
    final MatchingResult result = MatchingCalculator.calculate(
      first: first,
      second: second,
    );
    final double sum = result.rows.fold(
      0,
      (double total, GunaScore row) => total + row.score,
    );
    // ignore: avoid_print
    print(
      'INPUT boy 14 March 1998 Jaipur girl 15 January 2000 Delhi '
      'OUTPUT score ${result.totalText} verdict ${result.verdict} '
      'rows ${result.rows.map((GunaScore r) => '${r.label} ${r.score}/${r.max}').join(', ')} '
      'mangal boy ${result.mangalFirst} girl ${result.mangalSecond}',
    );
    expect(result.rows.length, 8);
    expect(result.total, sum);
    expect(result.total, greaterThanOrEqualTo(0));
    expect(result.total, lessThanOrEqualTo(36));
  });

  test('PROOF Remedies: real chart gives weak planet remedies', () {
    final DateTime birth = DateTime(1998, 3, 14, 6, 25);
    final KundliResult kundli = KundliCalculator.calculate(
      birthLocal: birth,
      placeText: 'Jaipur, Rajasthan',
    );
    final List<WeakPlanet> weak = RemedyEngine.weakPlanets(kundli);
    final List<Remedy> remedies = RemedyEngine.derive(
      kundli: kundli,
      birthLocal: birth,
      asOf: DateTime(2026, 11, 27),
    );
    final List<String> titles =
        remedies.map((Remedy r) => r.title).toList();
    // ignore: avoid_print
    print(
      'INPUT chart 14 March 1998 Jaipur OUTPUT weak planets '
      '${weak.map((WeakPlanet w) => '${w.name} ${w.reason}').join(', ')} '
      'remedies $titles',
    );
    expect(
      titles,
      containsAll(
        weak.map((WeakPlanet w) => 'For weak ${w.name}'),
      ),
    );
    expect(titles.last, startsWith('Current Mahadasha: '));
  });

  test('PROOF Consult Chat: real message sent and read back', () async {
    final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
    final FirestoreService service = FirestoreService(firestore: fake);
    final ChatService chat = ChatService(firestore: service);
    const String chatId = 'user_test_uid';
    await chat.sendMessage(
      chatId: chatId,
      senderId: 'test_uid',
      senderRole: 'user',
      text: 'Hello, please read my chart',
      participantIds: <String>['test_uid'],
    );
    await chat.sendMessage(
      chatId: chatId,
      senderId: 'admin_uid',
      senderRole: 'admin',
      text: 'Namaste, I am reading it now',
      participantIds: <String>['test_uid'],
    );
    final List<ChatMessage> messages =
        await chat.watchMessages(chatId).first;
    // ignore: avoid_print
    print(
      'INPUT user sends Hello please read my chart, admin replies '
      'OUTPUT ${messages.length} messages in order '
      '${messages.map((ChatMessage m) => '${m.senderRole}: ${m.text}').join(' | ')}',
    );
    expect(messages.length, 2);
    expect(messages[0].text, 'Hello, please read my chart');
    expect(messages[1].text, 'Namaste, I am reading it now');
    final Map<String, dynamic>? doc = await service.getDoc('chats', chatId);
    expect(doc?['lastMessage'], 'Namaste, I am reading it now');
  });

  test('PROOF Notifications: alert time and payload from published data',
      () {
    final DateTime next = NotificationSchedule.nextDailyAlertAfter(
      DateTime(2026, 11, 27, 5, 0),
      '06:00',
    );
    final Map<String, String> payload =
        NotificationSchedule.horoscopeAlertPayload(
      rashi: 'Kanya',
      date: '2026-11-27',
      summary: 'A strong day for money talks.',
    );
    // ignore: avoid_print
    print(
      'INPUT now 27 November 2026 05:00 alert 06:00 OUTPUT next alert $next '
      'payload title ${payload['title']} body ${payload['body']}',
    );
    expect(next, DateTime(2026, 11, 27, 6, 0));
    expect(payload['body'], 'A strong day for money talks.');
  });

  test('PROOF Profile: save then read back the same details', () async {
    final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
    final FirestoreService service = FirestoreService(firestore: fake);
    await service.saveUserProfile(
      uid: 'u1',
      data: <String, Object?>{
        'name': 'Test User',
        'dateOfBirth': '2000-01-15',
        'timeOfBirth': '07:30',
        'birthCity': 'Delhi',
        'birthState': 'Delhi',
        'birthCountry': 'India',
      },
    );
    final Map<String, dynamic>? read = await service.getUserProfile('u1');
    // ignore: avoid_print
    print(
      'INPUT profile Test User 15 January 2000 07:30 Delhi '
      'OUTPUT read back name ${read?['name']} dob ${read?['dateOfBirth']} '
      'city ${read?['birthCity']}',
    );
    expect(read?['name'], 'Test User');
    expect(read?['dateOfBirth'], '2000-01-15');
    expect(read?['birthCity'], 'Delhi');
  });

  test('PROOF Library: real timeline, festivals and planets', () {
    final DateTime birth = DateTime(1998, 3, 14, 6, 25);
    final List<DashaInfo> timeline = vimshottariTimeline(birthLocal: birth);
    final List<FestivalDay> festivals = festivalDays(
      from: DateTime(2026, 11, 27),
      days: 31,
    );
    // ignore: avoid_print
    print(
      'INPUT birth 14 March 1998 OUTPUT timeline first lord '
      '${timeline.first.lord} spans ${timeline.length} '
      'INPUT festivals from 27 November 2026 OUTPUT '
      '${festivals.map((FestivalDay d) => '${formatDay(d.date)} ${d.tithi}').join(', ')} '
      'planets ${kPlanetReference.length}',
    );
    expect(timeline.first.lord, 'Sun');
    expect(
      festivals.any((FestivalDay d) => d.tithi == 'Krishna Amavasya'),
      isTrue,
    );
    expect(
      festivals.any((FestivalDay d) => d.tithi == 'Shukla Purnima'),
      isTrue,
    );
    expect(kPlanetReference.length, 9);
  });
}
