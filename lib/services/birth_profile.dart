import 'astro.dart';

/// One saved birth profile. The main user profile holds one
/// set of birth details; these extra profiles cover family
/// members, so matching, kundli and remedies can run for each
/// person without overwriting the owners own details.
/// Latitude, longitude and timezone are stored when the user
/// enters them. When they are empty the engine falls back to
/// the city lookup in astro.dart and the result is marked
/// approximate, exactly like the main profile.
class BirthProfile {
  const BirthProfile({
    this.id,
    required this.name,
    this.relation,
    this.dateOfBirth,
    this.timeOfBirth,
    this.timeAccuracy = 'exact',
    this.birthCity,
    this.birthState,
    this.birthCountry,
    this.latitude,
    this.longitude,
    this.timezone = 'Asia/Kolkata',
    this.isActive = false,
  });

  final String? id;
  final String name;
  final String? relation;
  final String? dateOfBirth;
  final String? timeOfBirth;

  /// exact, approx or unknown.
  final String timeAccuracy;
  final String? birthCity;
  final String? birthState;
  final String? birthCountry;
  final double? latitude;
  final double? longitude;
  final String? timezone;
  final bool isActive;

  static const List<String> timeAccuracies = <String>[
    'exact',
    'approx',
    'unknown',
  ];

  static String accuracyLabel(String value) {
    return switch (value) {
      'approx' => 'Approximate time',
      'unknown' => 'Time not known',
      _ => 'Exact time',
    };
  }

  bool get timeKnown => timeAccuracy != 'unknown' && (timeOfBirth ?? '').isNotEmpty;

  String get placeLine {
    final List<String> parts = <String>[];
    if ((birthCity ?? '').trim().isNotEmpty) parts.add(birthCity!.trim());
    if ((birthState ?? '').trim().isNotEmpty) parts.add(birthState!.trim());
    if ((birthCountry ?? '').trim().isNotEmpty) parts.add(birthCountry!.trim());
    return parts.join(', ');
  }

  /// Coordinates from the city list when the user did not type
  /// any. Null when the city is not in the list.
  AstroPlace? get suggestedPlace =>
      birthCity == null ? null : placeFor(birthCity!);

  double? get effectiveLatitude => latitude ?? suggestedPlace?.latitude;
  double? get effectiveLongitude => longitude ?? suggestedPlace?.longitude;

  /// First problem found, or null when the profile is valid.
  /// Date must be yyyy-MM-dd, not in the future. Time is
  /// required unless accuracy is unknown. Coordinates, when
  /// given, must be in range.
  static String? validate({
    required String name,
    String? dateOfBirth,
    String? timeOfBirth,
    String timeAccuracy = 'exact',
    double? latitude,
    double? longitude,
  }) {
    if (name.trim().isEmpty) return 'Enter a name.';
    if (dateOfBirth != null && dateOfBirth.isNotEmpty) {
      final DateTime? date = DateTime.tryParse(dateOfBirth);
      if (date == null) return 'Enter the date as yyyy-MM-dd.';
      final DateTime today = DateTime.now();
      if (date.isAfter(DateTime(today.year, today.month, today.day))) {
        return 'Date of birth cannot be in the future.';
      }
    }
    if (timeAccuracy != 'unknown' &&
        timeOfBirth != null &&
        timeOfBirth.isNotEmpty) {
      final List<String> bits = timeOfBirth.split(':');
      final int? hour = bits.isNotEmpty ? int.tryParse(bits[0]) : null;
      final int? minute = bits.length > 1 ? int.tryParse(bits[1]) : null;
      if (bits.length != 2 || hour == null || minute == null || hour < 0 || hour > 23 || minute < 0 || minute > 59) {
        return 'Enter the time as HH:mm, for example 07:30.';
      }
    }
    if (latitude != null && (latitude < -90 || latitude > 90)) {
      return 'Latitude must be between -90 and 90.';
    }
    if (longitude != null && (longitude < -180 || longitude > 180)) {
      return 'Longitude must be between -180 and 180.';
    }
    return null;
  }

  factory BirthProfile.fromMap(Map<String, dynamic> map) {
    String? text(String key) {
      final Object? value = map[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
      return null;
    }

    double? number(String key) {
      final Object? value = map[key];
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return BirthProfile(
      id: text('id'),
      name: text('name') ?? '',
      relation: text('relation'),
      dateOfBirth: text('dateOfBirth'),
      timeOfBirth: text('timeOfBirth'),
      timeAccuracy: text('timeAccuracy') ?? 'exact',
      birthCity: text('birthCity'),
      birthState: text('birthState'),
      birthCountry: text('birthCountry'),
      latitude: number('latitude'),
      longitude: number('longitude'),
      timezone: text('timezone') ?? 'Asia/Kolkata',
      isActive: map['isActive'] == true,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'name': name.trim(),
      'relation': relation,
      'dateOfBirth': dateOfBirth,
      'timeOfBirth': timeAccuracy == 'unknown' ? null : timeOfBirth,
      'timeAccuracy': timeAccuracy,
      'birthCity': birthCity,
      'birthState': birthState,
      'birthCountry': birthCountry,
      'latitude': latitude,
      'longitude': longitude,
      'timezone': timezone ?? 'Asia/Kolkata',
      'isActive': isActive,
    };
  }
}

/// Firestore path for one users birth profiles.
String birthProfilesPath(String uid) => 'users/$uid/birth_profiles';

/// Firestore path for one users saved reports and results.
String savedReportsPath(String uid) => 'users/$uid/reports';

/// Firestore path for one users saved calculation results
/// (matching, numerology, remedies).
String savedResultsPath(String uid) => 'users/$uid/saved_results';
