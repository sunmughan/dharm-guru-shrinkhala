/// Notification scheduling, pure logic with no Firebase call.
/// The app cannot prove delivery on a real device from this
/// machine, but the time and the payload are computed here
/// from published data, and tests prove them.
class NotificationSchedule {
  NotificationSchedule._();

  /// Next daily alert after [now] for a profile alert time
  /// "HH:mm". Rolls to tomorrow when today at that time has
  /// already passed.
  static DateTime nextDailyAlertAfter(DateTime now, String hhmm) {
    final List<String> bits = hhmm.split(':');
    final int hour = int.tryParse(bits.isEmpty ? '' : bits[0]) ?? 6;
    final int minute =
        bits.length > 1 ? int.tryParse(bits[1]) ?? 0 : 0;
    DateTime next = DateTime(now.year, now.month, now.day, hour, minute);
    if (!next.isAfter(now)) {
      next = next.add(const Duration(days: 1));
    }
    return next;
  }

  /// Delivery time for the admin "Send at HH:mm AM" choice:
  /// today at that time when it is still ahead, else tomorrow.
  /// "Send now" delivers now. Null when the choice is unknown.
  static DateTime? scheduledSendTime({
    required DateTime now,
    required String sendTime,
  }) {
    if (sendTime == 'Send now') return now;
    final RegExp match = RegExp(r'(\d{1,2}):(\d{2})\s*(AM|PM)');
    final RegExpMatch? found =
        match.firstMatch(sendTime.toUpperCase());
    if (found == null) return null;
    int hour = int.parse(found.group(1)!);
    final int minute = int.parse(found.group(2)!);
    if (found.group(3) == 'PM' && hour != 12) hour += 12;
    if (found.group(3) == 'AM' && hour == 12) hour = 0;
    DateTime next = DateTime(now.year, now.month, now.day, hour, minute);
    if (!next.isAfter(now)) {
      next = next.add(const Duration(days: 1));
    }
    return next;
  }

  /// Payload for the daily horoscope alert, from the published
  /// horoscope document. Title names the rashi and the date;
  /// body is the published summary, never invented text.
  static Map<String, String> horoscopeAlertPayload({
    required String rashi,
    required String date,
    required String summary,
  }) {
    return <String, String>{
      'title': 'Your $rashi horoscope for $date is ready',
      'body': summary,
    };
  }
}
