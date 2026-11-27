import 'package:dharm_guru_shrinkhala/services/notification_schedule.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('next daily alert is today when the time is still ahead', () {
    final DateTime next = NotificationSchedule.nextDailyAlertAfter(
      DateTime(2026, 11, 27, 5, 0),
      '06:00',
    );
    expect(next, DateTime(2026, 11, 27, 6, 0));
  });

  test('next daily alert rolls to tomorrow when the time has passed', () {
    final DateTime next = NotificationSchedule.nextDailyAlertAfter(
      DateTime(2026, 11, 27, 7, 0),
      '06:00',
    );
    expect(next, DateTime(2026, 11, 28, 6, 0));
  });

  test('scheduled send now delivers now', () {
    final DateTime now = DateTime(2026, 11, 27, 10, 0);
    expect(
      NotificationSchedule.scheduledSendTime(
        now: now,
        sendTime: 'Send now',
      ),
      now,
    );
  });

  test('scheduled send at 06:00 AM is today before 6 and tomorrow after', () {
    expect(
      NotificationSchedule.scheduledSendTime(
        now: DateTime(2026, 11, 27, 5, 0),
        sendTime: 'Send at 06:00 AM',
      ),
      DateTime(2026, 11, 27, 6, 0),
    );
    expect(
      NotificationSchedule.scheduledSendTime(
        now: DateTime(2026, 11, 27, 7, 0),
        sendTime: 'Send at 06:00 AM',
      ),
      DateTime(2026, 11, 28, 6, 0),
    );
  });

  test('scheduled send with an unknown choice is null', () {
    expect(
      NotificationSchedule.scheduledSendTime(
        now: DateTime(2026, 11, 27, 10, 0),
        sendTime: 'Whenever',
      ),
      isNull,
    );
  });

  test('horoscope alert payload comes from published data', () {
    final Map<String, String> payload =
        NotificationSchedule.horoscopeAlertPayload(
      rashi: 'Kanya',
      date: '2026-11-27',
      summary: 'A strong day for money talks.',
    );
    expect(
      payload['title'],
      'Your Kanya horoscope for 2026-11-27 is ready',
    );
    expect(payload['body'], 'A strong day for money talks.');
  });
}
