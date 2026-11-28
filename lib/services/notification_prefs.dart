import 'package:shared_preferences/shared_preferences.dart';

/// Notification preferences and read state, stored on the
/// phone in SharedPreferences. Read ids are notification
/// document ids the user already opened. Nothing here claims
/// delivery: it only records what the user has seen and what
/// they asked to receive.
class NotificationPrefs {
  NotificationPrefs._();

  static const String dailyKey = 'notif_daily_enabled';
  static const String festivalKey = 'notif_festival_enabled';
  static const String consultKey = 'notif_consult_enabled';
  static const String readIdsKey = 'notif_read_ids';

  static Future<bool> dailyEnabled() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(dailyKey) ?? true;
  }

  static Future<bool> festivalEnabled() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(festivalKey) ?? true;
  }

  static Future<bool> consultEnabled() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(consultKey) ?? true;
  }

  static Future<void> setEnabled(String key, bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  static Future<Set<String>> readIds() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(readIdsKey)?.toSet() ?? <String>{};
  }

  static Future<void> markRead(String id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Set<String> read = prefs.getStringList(readIdsKey)?.toSet() ?? <String>{};
    read.add(id);
    await prefs.setStringList(readIdsKey, read.toList());
  }

  static Future<void> markAllRead(List<String> ids) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Set<String> read = prefs.getStringList(readIdsKey)?.toSet() ?? <String>{};
    read.addAll(ids);
    await prefs.setStringList(readIdsKey, read.toList());
  }

  /// Ids in [allIds] that are not in [readIds]. Pure helper
  /// so tests can check the count without SharedPreferences.
  static List<String> unreadIds(List<String> allIds, Set<String> readIds) {
    return allIds.where((String id) => !readIds.contains(id)).toList();
  }
}
