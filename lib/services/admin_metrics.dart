import 'package:cloud_firestore/cloud_firestore.dart';

/// Pure Phase 9 admin logic. No Firestore call lives here, so
/// every function is unit testable with plain maps. Dates come
/// from a createdAt Timestamp or a date string in a document.
class AdminMetrics {
  AdminMetrics._();

  static const List<String> ayanamshas = <String>[
    'Lahiri',
    'Raman',
    'KP',
    'Tropical',
  ];

  static const List<String> zodiacSystems = <String>[
    'Sidereal',
    'Tropical',
  ];

  static const List<String> houseSystems = <String>[
    'Whole Sign',
    'Placidus',
    'Equal',
  ];

  static const List<String> nodeModes = <String>[
    'Mean',
    'True',
  ];

  /// Start of the range ending today. Today means today only.
  static DateTime rangeStart(String range, DateTime now) {
    final DateTime today = DateTime(now.year, now.month, now.day);
    if (range == 'Today') return today;
    final int days = range == '7 days' ? 7 : 30;
    return today.subtract(Duration(days: days - 1));
  }

  /// Document day from createdAt, updatedAt, or a date string.
  /// Null when the document carries no usable date.
  static DateTime? docDay(Map<String, dynamic> doc) {
    final Object? created = doc['createdAt'];
    if (created is Timestamp) return created.toDate();
    final Object? updated = doc['updatedAt'];
    if (updated is Timestamp) return updated.toDate();
    final Object? date = doc['date'];
    if (date is String && date.length == 10) {
      return DateTime.tryParse(date);
    }
    return null;
  }

  static bool _inRange(DateTime? day, String range, DateTime now) {
    if (day == null) return false;
    final DateTime start = rangeStart(range, now);
    final DateTime end = DateTime(now.year, now.month, now.day + 1);
    return !day.isBefore(start) && day.isBefore(end);
  }

  /// Documents created inside the range.
  static List<Map<String, dynamic>> inRange(
    List<Map<String, dynamic>> docs,
    String range,
    DateTime now,
  ) {
    return docs
        .where((Map<String, dynamic> d) => _inRange(docDay(d), range, now))
        .toList();
  }

  static int countInRange(
    List<Map<String, dynamic>> docs,
    String range,
    DateTime now,
  ) {
    return inRange(docs, range, now).length;
  }

  /// Users with a lastActiveAt inside the range. When no user
  /// carries lastActiveAt, the count is zero and the caller
  /// shows an honest empty state instead of inventing activity.
  static int activeUsersInRange(
    List<Map<String, dynamic>> docs,
    String range,
    DateTime now,
  ) {
    int count = 0;
    for (final Map<String, dynamic> doc in docs) {
      final Object? last = doc['lastActiveAt'];
      if (last is Timestamp &&
          _inRange(last.toDate(), range, now)) {
        count++;
      }
    }
    return count;
  }

  /// Sum of paid payment amounts inside the range.
  static double paidTotalInRange(
    List<Map<String, dynamic>> docs,
    String range,
    DateTime now,
  ) {
    double total = 0;
    for (final Map<String, dynamic> doc in inRange(docs, range, now)) {
      if (doc['status'] != 'paid') continue;
      final Object? amount = doc['amount'];
      if (amount is num) total += amount.toDouble();
    }
    return total;
  }

  /// Consult minutes inside the range, from consultation
  /// documents that carry durationMinutes.
  static int consultMinutesInRange(
    List<Map<String, dynamic>> docs,
    String range,
    DateTime now,
  ) {
    int total = 0;
    for (final Map<String, dynamic> doc in inRange(docs, range, now)) {
      final Object? minutes = doc['durationMinutes'];
      if (minutes is num) total += minutes.toInt();
    }
    return total;
  }

  /// Counts by status for a list of documents.
  static Map<String, int> countsByStatus(
    List<Map<String, dynamic>> docs,
  ) {
    final Map<String, int> counts = <String, int>{};
    for (final Map<String, dynamic> doc in docs) {
      final Object? status = doc['status'];
      final String key =
          status is String && status.isNotEmpty ? status : 'unknown';
      counts[key] = (counts[key] ?? 0) + 1;
    }
    return counts;
  }

  /// Validation for a calculation configuration. An invalid
  /// config must never become active: the caller saves it as
  /// draft only when this list is empty, and refuses to
  /// activate it while any error remains.
  static List<String> validateCalcConfig(Map<String, dynamic> config) {
    final List<String> errors = <String>[];
    String text(Object? value) =>
        value is String ? value.trim() : '';
    final String version = text(config['version']);
    if (version.isEmpty) {
      errors.add('Version is required.');
    }
    final String ayanamsha = text(config['ayanamsha']);
    if (!ayanamshas.contains(ayanamsha)) {
      errors.add('Ayanamsha must be one of the supported values.');
    }
    final String zodiac = text(config['zodiacSystem']);
    if (!zodiacSystems.contains(zodiac)) {
      errors.add('Zodiac system must be one of the supported values.');
    }
    final String houses = text(config['houseSystem']);
    if (!houseSystems.contains(houses)) {
      errors.add('House system must be one of the supported values.');
    }
    final String nodes = text(config['nodeMode']);
    if (!nodeModes.contains(nodes)) {
      errors.add('Node mode must be one of the supported values.');
    }
    final String effective = text(config['effectiveDate']);
    if (effective.isEmpty) {
      errors.add('Effective date is required.');
    } else if (DateTime.tryParse(effective) == null) {
      errors.add('Effective date must be a valid date.');
    }
    final String city = text(config['region']);
    if (city.isEmpty) {
      errors.add('Region is required.');
    }
    return errors;
  }

  /// Audit log entry body. The service adds the timestamp and
  /// the document id when it writes the entry.
  static Map<String, Object?> auditEntry({
    required String actor,
    required String action,
    required String target,
    required String detail,
  }) {
    return <String, Object?>{
      'actor': actor,
      'action': action,
      'target': target,
      'detail': detail,
      'status': 'recorded',
    };
  }
}
