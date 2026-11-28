import 'notification_schedule.dart';

/// Notification preferences for one user, stored on the user
/// document under notificationPreferences. The daily alert
/// time reuses NotificationSchedule, so the scheduledFor
/// computation from release 10 stays in one place and the
/// preferences only decide whether the alert is wanted.
class NotificationPreferences {
  const NotificationPreferences({
    this.dailyHoroscope = true,
    this.consultReplies = true,
    this.adminAnnouncements = true,
    this.alertTime = '06:00',
  });

  final bool dailyHoroscope;
  final bool consultReplies;
  final bool adminAnnouncements;

  /// Daily alert time as HH:mm, 24 hour clock.
  final String alertTime;

  static final RegExp _timePattern = RegExp(r'^([01]\d|2[0-3]):[0-5]\d$');

  /// Reads preferences from a stored map. Missing keys fall
  /// back to on, missing time falls back to 06:00. A bad time
  /// value throws, so a corrupt stored value is reported
  /// instead of silently alerting at the wrong hour.
  factory NotificationPreferences.fromMap(Map<String, dynamic> map) {
    final Object? time = map['alertTime'];
    final String alertTime;
    if (time == null) {
      alertTime = '06:00';
    } else if (time is String && _timePattern.hasMatch(time)) {
      alertTime = time;
    } else {
      throw FormatException('Bad alertTime value: $time');
    }
    bool flag(String key) {
      final Object? value = map[key];
      if (value == null) return true;
      if (value is bool) return value;
      throw FormatException('Bad $key value: $value');
    }

    return NotificationPreferences(
      dailyHoroscope: flag('dailyHoroscope'),
      consultReplies: flag('consultReplies'),
      adminAnnouncements: flag('adminAnnouncements'),
      alertTime: alertTime,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'dailyHoroscope': dailyHoroscope,
      'consultReplies': consultReplies,
      'adminAnnouncements': adminAnnouncements,
      'alertTime': alertTime,
    };
  }

  /// Next daily alert after now, or null when the user turned
  /// daily horoscope alerts off.
  DateTime? nextDailyAlertAfter(DateTime now) {
    if (!dailyHoroscope) return null;
    return NotificationSchedule.nextDailyAlertAfter(now, alertTime);
  }
}
